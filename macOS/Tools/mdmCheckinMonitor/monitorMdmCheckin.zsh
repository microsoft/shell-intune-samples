#!/bin/bash
# This is a proof of concept script to detect macOS MDM check-in from the log stream
# neiljohn@microsoft.com

echo "Monitoring for MDM client check-in events..."
echo "Press Ctrl+C to exit"
echo ""

# Stream logs using a predicate that filters on mdmclient,
# checks for the check-in message, and ensures "<Device>" is present.
/usr/bin/log stream --info --predicate 'process=="mdmclient" AND composedMessage CONTAINS "Processing server request: DeclarativeManagement for" AND composedMessage CONTAINS "<Device>"' | while IFS= read -r line; do
    # Skip the header line printed by log
    if [[ "$line" == Filtering\ the\ log\ data* ]]; then
        continue
    fi
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] MDM Check-in detected:"
    echo "$line"
    echo "-------------------------"
done
