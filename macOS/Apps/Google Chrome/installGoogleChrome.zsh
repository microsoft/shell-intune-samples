#!/bin/bash

############################################################################################
##
## Script to install the latest Google Chrome on macOS
## 
## VER 4.0.3
##
## Change Log
##
## 2025-04-03 - Changed download URL to direct Google source
##            - Simplified script to use curl instead of aria2c
##            - Removed unused functions and improved documentation
##            - Restructured script for better readability
##            - Removed Rosetta 2 check as Chrome is now a universal binary
##            - Improved Swift Dialog integration to only run when Dialog is active
##
############################################################################################

## Copyright (c) 2020 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: neiljohn@microsoft.com

###################################################################################
##
## VARIABLES
##
###################################################################################

# User Defined variables
weburl="https://dl.google.com/chrome/mac/universal/stable/gcem/GoogleChrome.pkg"  # URL to download Chrome PKG
appname="Google Chrome"                                                           # App name for logging and display
app="Google Chrome.app"                                                           # App bundle name as installed
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/GoogleChrome"                # Directory for logs
processpath="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"        # Full path to process
terminateprocess="true"                                                           # Whether to kill running app (true/false)
autoUpdate="true"                                                                 # App self-updates; skip if installed

# Generated variables
tempdir=$(mktemp -d)                                                              # Temporary directory for downloads
log="$logandmetadir/$appname.log"                                                 # Full path to log file
metafile="$logandmetadir/$appname.meta"                                           # Metadata for update tracking

###################################################################################
##
## LOGGING FUNCTIONS
##
###################################################################################

# Initialize logging to file and terminal
function startLog() {
    # Create log directory if it doesn't exist
    if [[ ! -d "$logandmetadir" ]]; then
        echo "$(date) | Creating [$logandmetadir] to store logs"
        mkdir -p "$logandmetadir"
    fi

    # Output to terminal and log file simultaneously
    exec &> >(tee -a "$log")
}

# Update Swift Dialog if present and running (provides visual feedback to user)
function updateSplashScreen() {
    # Parameters:
    # $1 - Status: wait, success, fail, error, pending or progress:xx
    # $2 - Status text to display
    
    # Check if Swift Dialog is installed AND running
    if pgrep -x "Dialog" &>/dev/null && [[ -a "/Library/Application Support/Dialog/Dialog.app/Contents/MacOS/Dialog" ]]; then
        echo "$(date) | Updating Swift Dialog monitor for [$appname] to [$1]"
        echo listitem: title: $appname, status: $1, statustext: $2 >> /var/tmp/dialog.log 
    fi
    # If Dialog isn't running, we don't log anything about it
}

###################################################################################
##
## UTILITY FUNCTIONS
##
###################################################################################

# Function to delay script if specified process is running
function waitForProcess() {
    # Parameters:
    # $1 - Process name to check
    # $2 - Fixed delay in seconds (optional)
    # $3 - Whether to terminate process if found (true/false)
    
    processName=$1
    fixedDelay=$2
    terminate=$3

    echo "$(date) | Checking if [$processName] is running"
    while ps aux | grep "$processName" | grep -v grep &>/dev/null; do

        if [[ $terminate == "true" ]]; then
            echo "$(date) | + [$appname] running, terminating process..."
            pkill -f "$processName"
            return
        fi

        # Use fixed delay if provided, otherwise random delay
        if [[ ! $fixedDelay ]]; then
            delay=$(( $RANDOM % 50 + 10 ))
        else
            delay=$fixedDelay
        fi

        echo "$(date) | + Another instance of $processName is running, waiting [$delay] seconds"
        sleep $delay
    done
    
    echo "$(date) | No instances of [$processName] found, safe to proceed"
}

# Function to wait for Desktop to be ready (ensures install happens after login)
function waitForDesktop() {
    echo "$(date) | Waiting for Desktop environment to be ready..."
    until ps aux | grep /System/Library/CoreServices/Dock.app/Contents/MacOS/Dock | grep -v grep &>/dev/null; do
        delay=$(( $RANDOM % 50 + 10 ))
        echo "$(date) | + Dock not running, waiting [$delay] seconds"
        sleep $delay
    done
    echo "$(date) | Desktop environment is ready, proceeding with installation"
}

###################################################################################
##
## APPLICATION INSTALLATION FUNCTIONS
##
###################################################################################

# Function to check if we need to install or update
function updateCheck() {
    echo "$(date) | Checking if $appname needs to be installed or updated"

    # Check if app is already installed
    if [ -d "/Applications/$app" ]; then
        if [[ $autoUpdate == "true" ]]; then
            echo "$(date) | [$appname] is already installed and handles its own updates"
            updateSplashScreen success "Already Installed"
            echo "$(date) | Exiting as no action needed"
            exit 0
        fi
        
        echo "$(date) | [$appname] is installed but autoUpdate is disabled"
        echo "$(date) | Will proceed with update check/installation"
    else
        echo "$(date) | [$appname] is not currently installed"
    fi
}

# Download the application
function downloadApp() {
    echo "$(date) | Starting download of $appname installer package"
    updateSplashScreen wait "Downloading"

    cd "$tempdir"
    echo "$(date) | Downloading from: $weburl"
    
    # Download with curl (with retry support)
    curl -f -s --connect-timeout 30 --retry 5 --retry-delay 60 -L -o "chrome.pkg" "$weburl"
    
    # Check if download was successful
    if [ $? == 0 ]; then
        tempfile="$tempdir/chrome.pkg"
        echo "$(date) | Successfully downloaded $appname installer to $tempfile"
    else
        echo "$(date) | ERROR: Failed to download from $weburl"
        updateSplashScreen fail "Download Failed"
        exit 1
    fi
}

# Install PKG Function
function installPKG() {
    # Check if app is running and terminate if needed
    waitForProcess "$processpath" "300" "$terminateprocess"

    echo "$(date) | Beginning installation of $appname"
    updateSplashScreen wait "Installing"

    # Remove existing app if present (clean install)
    if [[ -d "/Applications/$app" ]]; then
        echo "$(date) | Removing existing installation of $appname"
        rm -rf "/Applications/$app"
    fi

    # Installation with retry logic
    max_attempts=5
    attempt=1

    while [ $attempt -le $max_attempts ]; do
        echo "$(date) | Installation attempt $attempt of $max_attempts"

        # Run installer
        installer -pkg "$tempfile" -target /

        # Check if installation succeeded
        if [ "$?" = "0" ]; then
            echo "$(date) | SUCCESS: $appname installed successfully"
            echo "$(date) | Cleaning up temporary files"
            rm -rf "$tempdir"
            
            echo "$(date) | Installation of $appname completed successfully"
            updateSplashScreen success "Installed"
            break
        else
            echo "$(date) | WARNING: Installation attempt $attempt failed"
            updateSplashScreen error "Failed, retry $attempt of $max_attempts"
            attempt=$((attempt + 1))
            sleep 5
        fi
    done

    # Check if all attempts failed
    if [ $attempt -gt $max_attempts ]; then
        echo "$(date) | ERROR: Installation failed after $max_attempts attempts"
        updateSplashScreen fail "Installation Failed"
        rm -rf "$tempdir"
        exit 1
    fi
}

###################################################################################
##
## MAIN SCRIPT BODY
##
###################################################################################

# Initialize logging
startLog

echo ""
echo "##############################################################"
echo "#                                                            #"
echo "#           Google Chrome Installation Script                #"
echo "#                                                            #"
echo "##############################################################"
echo "# $(date) | Starting installation of $appname"
echo "# $(date) | Log file: $log"
echo "##############################################################"
echo ""

# Check if we need to install/update
updateCheck

# Wait for desktop to be ready
waitForDesktop

# Download the app
downloadApp

# Install the package
installPKG

echo ""
echo "##############################################################"
echo "# $(date) | $appname installation completed"
echo "##############################################################"
echo ""

exit 0