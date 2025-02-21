#!/bin/bash
############################################################################################
##
## Post-install Script for Swift Dialog
## 
## VER 1.0.0
##
############################################################################################

# Define any variables we need here:
logDir="/Library/Application Support/Microsoft/IntuneScripts/Swift Dialog"
DIALOG_BIN="/usr/local/bin/dialog"
PKG_PATH="/var/tmp/dialog.pkg"
PKG_URL="https://github.com/swiftDialog/swiftDialog/releases/download/v2.5.2/dialog-2.5.2-4777.pkg"

# Start Logging
mkdir -p "$logDir"
exec > >(tee -a "$logDir/postinstall.log") 2>&1

# Check if we've run before
#if [[ -f "$logDir/onboardingComplete" ]]; then
#  echo "$(date) | POST | We've already completed onboarding, let's exit quietly"
#  exit 1
#fi

# Check if SwiftDialog is installed
if [[ ! -f "$DIALOG_BIN" ]]; then
  echo "$(date) | POST | Swift Dialog is not installed [$DIALOG_BIN]. Installing now..."

    # Download the SwiftDialog .pkg
    curl -L -o "$PKG_PATH" "$PKG_URL"

    # Install SwiftDialog from the downloaded .pkg file
    sudo installer -pkg "$PKG_PATH" -target /

else
  echo "$(date) | POST | Swift Dialog is already installed."
fi

# Wait for Desktop
until pgrep -x Dock >/dev/null 2>&1; do
    echo "$(date) | + Dock not running, waiting [1] seconds"
    sleep 1
done
echo "$(date) | Dock is here, let's carry on"
ps aux

# Wait for Swift Dialog to launch
MAX_ATTEMPTS=5
attempt=1

while [ $attempt -le $MAX_ATTEMPTS ]; do
    echo "$(date) | INFO | Attempting to launch Swift Dialog (Attempt $attempt of $MAX_ATTEMPTS)"
    
    # Launch Swift Dialog in the background
    killall Dialog
    /usr/local/bin/dialog --jsonfile "/Library/Application Support/SwiftDialogResources/swiftdialog.json" --width 1280 --height 670 --blurscreen --ontop &
    sleep 2
    
    start_time=$(date +%s)
    launched=0
    
    # Wait up to 5 seconds for the process to appear
    while true; do
        if ps aux | grep /usr/local/bin/dialog | grep -v grep > /dev/null; then
            launched=1
            break
        fi
        
    done
    
    if [ $launched -eq 1 ]; then
        echo "$(date) | INFO | Swift Dialog launched successfully on attempt $attempt."
        break
    else
        echo "$(date) | WARNING | Swift Dialog did not launch within 60 seconds on attempt $attempt."
        attempt=$((attempt+1))
    fi
done

if [ $attempt -gt $MAX_ATTEMPTS ]; then
    echo "$(date) | ERROR | Swift Dialog failed to launch after $MAX_ATTEMPTS attempts. Continuing with the script..."
fi

echo "$(date) | POST | Processing scripts..."
for script in /Library/Application\ Support/SwiftdialogResources/scripts/*.*; do
  echo "$(date) | POST | Executing [$script]"
  xattr -d com.apple.quarantine "$script" >/dev/null 2>&1
  chmod +x "$script" >/dev/null 2>&1
  nice -n 20 "$script" &
done

# Once we're done, we should write a flag file out so that we don't run again
sudo touch "$logDir/onboardingComplete"
exit 0