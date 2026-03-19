#!/bin/zsh

#set -x

############################################################################################
##
## Script to enable Warn When Visiting A Fraudulent Website in Safari
##
## CIS: Ensure Warn When Visiting A Fraudulent Website in Safari is Enabled (Automated)
## NIST: N/A
##
############################################################################################

## Copyright (c) 2026 Microsoft Corp. Licensed under the MIT license.

ScriptName="EnableSafariFraudWarning"
LogDir="$HOME/Library/Logs/Microsoft/IntuneScripts/$ScriptName"

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

## Check current setting
currentValue=$(defaults read com.apple.Safari WarnAboutFraudulentWebsites 2>/dev/null)

if [ "$currentValue" = "1" ]; then
    echo "$(date) | Safari fraudulent website warning is already enabled. No changes needed."
else
    echo "$(date) | Safari fraudulent website warning is not enabled. Enabling now..."
    defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true
    if [ $? -eq 0 ]; then
        echo "$(date) | Successfully enabled Safari fraudulent website warning."
    else
        echo "$(date) | ERROR: Failed to enable Safari fraudulent website warning."
        exit 1
    fi
fi

echo "$(date) | Script $ScriptName completed."
exit 0
