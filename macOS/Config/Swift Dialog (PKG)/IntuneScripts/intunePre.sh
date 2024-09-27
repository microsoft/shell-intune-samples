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
DIALOG_BIN="/path/to/SwiftDialog"  # Set this to the path where SwiftDialog is expected to be installed
PKG_PATH="/var/tmp/dialog.pkg"
PKG_URL="https://github.com/swiftDialog/swiftDialog/releases/download/v2.5.2/dialog-2.5.2-4777.pkg"

# Start Logging
mkdir -p "$logDir"
exec > >(tee -a "$logDir/preinstall.log") 2>&1

if [ -e "/Library/Application Support/Dialog" ]; then
    echo "$(date) | PRE | Removing previous installation"
    rm -rf "/Library/Application Support/Dialog"
    rm -rf "/Library/Application Support/SwiftDialogResources"
    rm -rf "/usr/local/bin/dialog"
fi

# Download the SwiftDialog .pkg
curl -L -o "$PKG_PATH" "$PKG_URL"

# Install SwiftDialog from the downloaded .pkg file
sudo installer -pkg "$PKG_PATH" -target /
  
if [[ $? -eq 0 ]]; then
    echo "$(date) | POST | Swift Dialog has been installed successfully."
else
    echo "$(date) | ERROR | Swift Dialog installation failed."
    exit 1
fi


echo "$(date) | PRE | Completed Pre-install script"
exit 0
