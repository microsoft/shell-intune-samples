#!/bin/bash

############################################################################################
##
## Pre-install Script for Swift Dialog
## 
## VER 1.0.0
##
############################################################################################

# Define any variables we need here:
logDir="/Library/Application Support/Microsoft/IntuneScripts/Swift Dialog"

# Start Logging
mkdir -p "$logDir"
exec > >(tee -a "$logDir/preinstall.log") 2>&1

if [ -e "/Library/Application Support/Dialog" ]; then
    echo "$(date) | PRE | Removing previous installation"
    rm -rf "/Library/Application Support/Dialog"
    rm -rf "/Library/Application Support/SwiftDialogResourcs"
    rm -rf "/usr/local/bin/dialog"
fi

echo "$(date) | PRE | Completed Pre-install script"
exit 0