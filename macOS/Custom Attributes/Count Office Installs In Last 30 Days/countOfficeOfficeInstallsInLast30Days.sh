#!/bin/bash
# shellcheck shell=bash
#
# Script Name: countOfficeOfficeInstallsInLast30Days.sh
# Description : Counts Microsoft 365/Office installer entries in macOS install.log
#              within a configurable rolling time window (default 30 days).
# Usage       : ./countOfficeOfficeInstallsInLast30Days.sh [path_to_install.log]
# Default     : When no path is passed, /var/log/install.log is used.
# Env Vars    : LOOKBACK_DAYS overrides the default window length in days.
# Output      : Prints numeric count suitable for Intune custom attribute ingestion.

set -euo pipefail
LOG_PATH="${1:-/var/log/install.log}"
LOOKBACK_DAYS="${LOOKBACK_DAYS:-30}"

if [[ ! -r "$LOG_PATH" ]]; then
    echo "0"
    exit 0
fi

if ! [[ "$LOOKBACK_DAYS" =~ ^[0-9]+$ ]]; then
    echo "0"
    exit 0
fi

CUTOFF_EPOCH="$(/bin/date -u -v-"${LOOKBACK_DAYS}"d +%s 2>/dev/null || echo 0)"
COUNT=0

while IFS= read -r line; do
    [[ $line == *Microsoft_365_and_Office* ]] || continue
    [[ $line =~ Microsoft_365_and_Office_.*Installer\.pkg#Microsoft_Outlook_Internal\.pkg ]] || continue

    ts_part=${line:0:22}
    if [[ ! $ts_part =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]][0-9]{2}:[0-9]{2}:[0-9]{2}[+-][0-9]{2}$ ]]; then
        continue
    fi

    ts_with_min="${ts_part}00"
    epoch=$(/bin/date -j -f "%Y-%m-%d %H:%M:%S%z" "$ts_with_min" +%s 2>/dev/null || echo "")
    [[ -n $epoch ]] || continue

    if (( epoch >= CUTOFF_EPOCH )); then
        COUNT=$((COUNT + 1))
    fi
done < "$LOG_PATH"

echo "$COUNT"
