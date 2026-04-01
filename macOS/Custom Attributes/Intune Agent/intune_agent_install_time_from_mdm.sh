#!/bin/zsh
# shellcheck shell=zsh
#
# Script Name: intune_agent_install_time_from_mdm.sh
# Description : Returns the elapsed time in seconds between Microsoft MDM
#              profile installation and Microsoft Intune Agent installation.
# Usage       : ./intune_agent_install_time_from_mdm.sh [--last <window>] [--verbose]
# Default     : Searches the last 30d of unified logs.
# Dependencies: /usr/bin/log, /bin/date, /usr/bin/awk
# Output      : Prints elapsed seconds as a decimal value, or "unknown" when
#              the required markers are unavailable.

setopt errexit nounset pipefail

LOOKBACK="30d"
VERBOSE=0
LOCAL_TZ_OFFSET="$(date +%z)"
MDM_PREDICATE='process == "mdmclient" AND eventMessage CONTAINS[c] "Installed configuration profile: Management Profile (Microsoft.Profiles.MDM"'
INTUNE_PREDICATE='process == "appstored" AND eventMessage CONTAINS "com.microsoft.intuneMDMAgent"'

MDM_TS=""
MDM_MS=""
MDM_LINE=""
INSTALL_TS=""
INSTALL_MS=""
INSTALL_LINE=""
INSTALL_LABEL=""

usage() {
	cat <<'EOF'
Usage: intune_agent_install_time_from_mdm.sh [--last <window>] [--verbose]

Returns the time in seconds from the Microsoft MDM management profile install to
Intune agent installation.

If the required historical markers are no longer available, the script prints
"unknown" instead of failing.
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
		print "Result        : unknown"
		print "Reason        : $reason"
		if [[ -n "$MDM_TS" ]]; then
			print "MDM marker    : $MDM_TS"
			print "$MDM_LINE"
		fi
		if [[ -n "$INSTALL_TS" ]]; then
			print
			print "Install marker: $INSTALL_TS"
			print "$INSTALL_LINE"
			print "Marker used   : $INSTALL_LABEL"
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

find_install_marker() {
	emulate -L zsh
	local line ts ms

	while IFS= read -r line; do
		ts="$(extract_unified_ts "$line")" || continue
		ms="$(to_epoch_ms "$ts")" || continue
		(( ms >= MDM_MS )) || continue

		if [[ "$line" == *"Application was installed at:"* ]]; then
			INSTALL_TS="$ts"
			INSTALL_MS="$ms"
			INSTALL_LINE="$line"
			INSTALL_LABEL="Intune agent app landed on disk"
			return 0
		fi

		if [[ -z "$INSTALL_TS" && "$line" == *"installClientDidFinish"* ]]; then
			INSTALL_TS="$ts"
			INSTALL_MS="$ms"
			INSTALL_LINE="$line"
			INSTALL_LABEL="PKInstallClient finished the Intune install"
		fi
	done < <(/usr/bin/log show --style compact --info --last "$LOOKBACK" --predicate "$INTUNE_PREDICATE" 2>/dev/null)

	[[ -n "$INSTALL_TS" ]]
}

main() {
	parse_args "$@"
	find_mdm_marker || { emit_unknown "Unable to find the MDM management profile install event in the requested log window."; return 0; }
	find_install_marker || { emit_unknown "Unable to find an Intune agent install event after the MDM profile install in the requested log window."; return 0; }

	local delta_ms=$(( INSTALL_MS - MDM_MS ))
	(( delta_ms >= 0 )) || { emit_unknown "Install marker occurred before the MDM profile install, so the elapsed time cannot be trusted."; return 0; }

	if (( VERBOSE )); then
		print "MDM marker    : $MDM_TS"
		print "$MDM_LINE"
		print
		print "Install marker: $INSTALL_TS"
		print "$INSTALL_LINE"
		print "Marker used   : $INSTALL_LABEL"
		print
		print "Seconds       : $(format_seconds_ms "$delta_ms")"
		return 0
	fi

	format_seconds_ms "$delta_ms"
}

main "$@"
