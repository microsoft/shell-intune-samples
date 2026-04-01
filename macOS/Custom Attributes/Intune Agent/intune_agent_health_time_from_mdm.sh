#!/bin/zsh
# shellcheck shell=zsh
#
# Script Name: intune_agent_health_time_from_mdm.sh
# Description : Returns the elapsed time in seconds between Microsoft MDM
#              profile installation and the first healthy Microsoft Intune
#              agent marker.
# Usage       : ./intune_agent_health_time_from_mdm.sh [--last <window>] [--verbose]
# Default     : Searches the last 30d of unified and Intune agent logs.
# Dependencies: /usr/bin/log, /bin/date, /usr/bin/awk, /usr/bin/find,
#              /usr/bin/sort, /Library/Logs/Microsoft/Intune
# Output      : Prints elapsed seconds as a decimal value, or "unknown" when
#              the required markers are unavailable.

setopt errexit nounset pipefail

LOOKBACK="30d"
VERBOSE=0
LOG_DIR="/Library/Logs/Microsoft/Intune"
LOCAL_TZ_OFFSET="$(date +%z)"
MDM_PREDICATE='process == "mdmclient" AND eventMessage CONTAINS[c] "Installed configuration profile: Management Profile (Microsoft.Profiles.MDM"'

MDM_TS=""
MDM_MS=""
MDM_LINE=""
HEALTH_TS=""
HEALTH_MS=""
HEALTH_LINE=""
HEALTH_FILE=""
HEALTH_LABEL=""

typeset -A FALLBACK_TS FALLBACK_MS FALLBACK_LINE FALLBACK_FILE

usage() {
	cat <<'EOF'
Usage: intune_agent_health_time_from_mdm.sh [--last <window>] [--verbose]

Returns the time in seconds from the Microsoft MDM management profile install to
Intune agent health.

If the required historical markers are no longer available, the script prints
"unknown" instead of failing.

Primary healthy marker:
  HealthCheckWorkflow | Completed health check Domain: regular

Fallbacks:
  - VerifyEnrollmentStatus | Successfully verified enrollment status.
  - VerifyEnrollmentStatus | Successfully verified device status.
  - VerifyEnrollmentStatus | Retrieved enrollment info.
EOF
}

parse_args() {
	while (( $# > 0 )); do
		case "$1" in
			--last)
				(( $# >= 2 )) || { print -u2 -- "Missing value for --last"; exit 2; }
				LOOKBACK="$2"
				shift 2
				;;
			-v|--verbose)
				VERBOSE=1
				shift
				;;
			-h|--help)
				usage
				exit 0
				;;
			*)
				print -u2 -- "Unknown option: $1"
				exit 2
				;;
		esac
	done
}

extract_unified_ts() {
	emulate -L zsh
	local line="$1"
	local -a fields
	fields=(${=line})
	(( ${#fields} >= 2 )) || return 1
	print -r -- "${fields[1]} ${fields[2]}"
}

extract_pipe_ts() {
	emulate -L zsh
	local line="$1"
	local ts="${line%% |*}"
	[[ "$ts" == "$line" ]] && return 1
	print -r -- "$ts"
}

to_epoch_ms() {
	emulate -L zsh
	local ts="$1"
	local re='^([0-9]{4}-[0-9]{2}-[0-9]{2}) ([0-9]{2}:[0-9]{2}:[0-9]{2})([.:]([0-9]{1,6}))?([+-][0-9]{4})?$'
	local date_part time_part frac tz epoch

	if [[ ! "$ts" =~ $re ]]; then
		return 1
	fi

	date_part="$match[1]"
	time_part="$match[2]"
	frac="${match[4]:-0}"
	tz="${match[5]:-$LOCAL_TZ_OFFSET}"
	frac="${frac}000"
	frac="${frac[1,3]}"

	if ! epoch="$(date -j -f "%Y-%m-%d %H:%M:%S %z" "$date_part $time_part $tz" +%s 2>/dev/null)"; then
		return 1
	fi

	print -r -- $(( epoch * 1000 + 10#$frac ))
}

format_seconds_ms() {
	emulate -L zsh
	local value="$1"
	/usr/bin/awk -v ms="$value" 'BEGIN { printf "%.3f\n", ms / 1000 }'
}

emit_unknown() {
	emulate -L zsh
	local reason="$1"

	if (( VERBOSE )); then
		print "Result       : unknown"
		print "Reason       : $reason"
		if [[ -n "$MDM_TS" ]]; then
			print "MDM marker   : $MDM_TS"
			print "$MDM_LINE"
		fi
		if [[ -n "$HEALTH_TS" ]]; then
			print
			print "Health marker: $HEALTH_TS"
			print "$HEALTH_LINE"
			print "Log file     : $HEALTH_FILE"
			print "Marker used  : $HEALTH_LABEL"
		fi
	else
		print "unknown"
	fi
}

find_mdm_marker() {
	emulate -L zsh
	local line ts

	line="$(/usr/bin/log show --style compact --info --last "$LOOKBACK" --predicate "$MDM_PREDICATE" 2>/dev/null | /usr/bin/grep 'Installed configuration profile: Management Profile (Microsoft.Profiles.MDM' | tail -1)"
	[[ -n "$line" ]] || return 1
	ts="$(extract_unified_ts "$line")" || return 1
	MDM_TS="$ts"
	MDM_MS="$(to_epoch_ms "$ts")" || return 1
	MDM_LINE="$line"
}

record_fallback_once() {
	emulate -L zsh
	local key="$1"
	local ts="$2"
	local ms="$3"
	local file="$4"
	local line="$5"
	[[ -n ${FALLBACK_TS[$key]-} ]] && return 0
	FALLBACK_TS[$key]="$ts"
	FALLBACK_MS[$key]="$ms"
	FALLBACK_FILE[$key]="$file"
	FALLBACK_LINE[$key]="$line"
}

find_health_marker() {
	emulate -L zsh
	local file line ts ms

	while IFS= read -r file; do
		while IFS= read -r line; do
			ts="$(extract_pipe_ts "$line")" || continue
			ms="$(to_epoch_ms "$ts")" || continue
			(( ms >= MDM_MS )) || continue

			if [[ "$line" == *"HealthCheckWorkflow | Completed health check Domain: regular"* ]]; then
				HEALTH_TS="$ts"
				HEALTH_MS="$ms"
				HEALTH_FILE="$file"
				HEALTH_LINE="$line"
				HEALTH_LABEL="Completed regular health check"
				return 0
			fi

			if [[ "$line" == *"VerifyEnrollmentStatus | Successfully verified enrollment status."* ]]; then
				record_fallback_once verify_enrollment "$ts" "$ms" "$file" "$line"
			elif [[ "$line" == *"VerifyEnrollmentStatus | Successfully verified device status."* ]]; then
				record_fallback_once verify_device "$ts" "$ms" "$file" "$line"
			elif [[ "$line" == *"VerifyEnrollmentStatus | Retrieved enrollment info."* ]]; then
				record_fallback_once enrollment_info "$ts" "$ms" "$file" "$line"
			fi
		done < "$file"
	done < <(/usr/bin/find "$LOG_DIR" -maxdepth 1 -type f -name 'IntuneMDMDaemon *.log' -print | /usr/bin/sort)

	if [[ -n ${FALLBACK_TS[verify_enrollment]-} ]]; then
		HEALTH_TS="${FALLBACK_TS[verify_enrollment]}"
		HEALTH_MS="${FALLBACK_MS[verify_enrollment]}"
		HEALTH_FILE="${FALLBACK_FILE[verify_enrollment]}"
		HEALTH_LINE="${FALLBACK_LINE[verify_enrollment]}"
		HEALTH_LABEL="Successfully verified enrollment status"
		return 0
	fi

	if [[ -n ${FALLBACK_TS[verify_device]-} ]]; then
		HEALTH_TS="${FALLBACK_TS[verify_device]}"
		HEALTH_MS="${FALLBACK_MS[verify_device]}"
		HEALTH_FILE="${FALLBACK_FILE[verify_device]}"
		HEALTH_LINE="${FALLBACK_LINE[verify_device]}"
		HEALTH_LABEL="Successfully verified device status"
		return 0
	fi

	if [[ -n ${FALLBACK_TS[enrollment_info]-} ]]; then
		HEALTH_TS="${FALLBACK_TS[enrollment_info]}"
		HEALTH_MS="${FALLBACK_MS[enrollment_info]}"
		HEALTH_FILE="${FALLBACK_FILE[enrollment_info]}"
		HEALTH_LINE="${FALLBACK_LINE[enrollment_info]}"
		HEALTH_LABEL="Retrieved enrollment info"
		return 0
	fi

	return 1
}

main() {
	parse_args "$@"
	find_mdm_marker || { emit_unknown "Unable to find the MDM management profile install event in the requested log window."; return 0; }
	find_health_marker || { emit_unknown "Unable to find a health marker after the MDM profile install in the available Intune logs."; return 0; }

	local delta_ms=$(( HEALTH_MS - MDM_MS ))
	(( delta_ms >= 0 )) || { emit_unknown "Healthy marker occurred before the MDM profile install, so the elapsed time cannot be trusted."; return 0; }

	if (( VERBOSE )); then
		print "MDM marker   : $MDM_TS"
		print "$MDM_LINE"
		print
		print "Health marker: $HEALTH_TS"
		print "$HEALTH_LINE"
		print "Log file     : $HEALTH_FILE"
		print "Marker used  : $HEALTH_LABEL"
		print
		print "Seconds      : $(format_seconds_ms "$delta_ms")"
		return 0
	fi

	format_seconds_ms "$delta_ms"
}

main "$@"
