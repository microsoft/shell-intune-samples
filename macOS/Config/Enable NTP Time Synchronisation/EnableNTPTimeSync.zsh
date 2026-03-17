#!/bin/zsh

#set -x

############################################################################################
##
## Script to ensure time synchronisation (NTP) is enabled
##
## CIS: Ensure Set Time and Date Automatically Is Enabled (Automated)
## NIST: N/A
##
############################################################################################

## Copyright (c) 2026 Microsoft Corp. Licensed under the MIT license.

ScriptName="EnableNTPTimeSync"
LogDir="/Library/Logs/Microsoft/IntuneScripts/$ScriptName"

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

## Create log directory
if [ -d "$LogDir" ]; then
    echo "$(date) | Log directory already exists - $LogDir"
else
    mkdir -p "$LogDir"
    echo "$(date) | Created log directory - $LogDir"
fi

## Start logging
exec &> >(tee -a "$LogDir/$ScriptName.log")

echo ""
echo "##############################################################"
echo "# $(date) | Starting running of script $ScriptName"
echo "############################################################"
echo ""

## Check if network time is enabled
ntpEnabled=$(systemsetup -getusingnetworktime 2>/dev/null | grep -c "On")

if [ "$ntpEnabled" -ge 1 ]; then
    echo "$(date) | Network time synchronisation is already enabled. No changes needed."
else
    echo "$(date) | Network time synchronisation is not enabled. Enabling now..."
    systemsetup -setusingnetworktime on
    if [ $? -eq 0 ]; then
        echo "$(date) | Successfully enabled network time synchronisation."
    else
        echo "$(date) | ERROR: Failed to enable network time synchronisation."
        exit 1
    fi
fi

## Verify time server is set
timeServer=$(systemsetup -getnetworktimeserver 2>/dev/null)
echo "$(date) | Current time server: $timeServer"

echo "$(date) | Script $ScriptName completed."
exit 0
