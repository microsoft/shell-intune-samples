#!/bin/zsh

#set -x

############################################################################################
##
## Script to enable Secure Keyboard Entry in Terminal.app
##
## CIS: Ensure Secure Keyboard Entry terminal.app is Enabled (Automated)
## NIST: N/A
##
############################################################################################

## Copyright (c) 2026 Microsoft Corp. Licensed under the MIT license.

ScriptName="EnableSecureKeyboardEntry"
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
currentValue=$(defaults read com.apple.Terminal SecureKeyboardEntry 2>/dev/null)

if [ "$currentValue" = "1" ]; then
    echo "$(date) | Secure Keyboard Entry is already enabled in Terminal. No changes needed."
else
    echo "$(date) | Secure Keyboard Entry is not enabled. Enabling now..."
    defaults write com.apple.Terminal SecureKeyboardEntry -bool true
    if [ $? -eq 0 ]; then
        echo "$(date) | Successfully enabled Secure Keyboard Entry in Terminal."
    else
        echo "$(date) | ERROR: Failed to enable Secure Keyboard Entry in Terminal."
        exit 1
    fi
fi

echo "$(date) | Script $ScriptName completed."
exit 0
