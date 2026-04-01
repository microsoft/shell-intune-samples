#!/bin/bash
#set -x

############################################################################################
## IMM - Install Microsoft Remote Help (PKG)
##
## Version: 1.1.0
## Maintainer: manahum@microsoft.com
##
## Summary
## - Downloads and installs Microsoft Remote Help on macOS using a signed PKG.
## - If Microsoft Remote Help is already installed and autoUpdate=true, exits without changes.
## - Otherwise performs an update check via HTTP Last-Modified and a local meta file, then installs/updates Microsoft Remote Help.
## - Optionally terminates a running Microsoft Remote Help process before install when configured.
## - Implements automatic retry logic for download failures with detailed error diagnostics.
## - Detailed logging written to /Library/Logs/Microsoft/IntuneScripts/installRemoteHelp/Microsoft Remote Help.log
##
## Inputs (variables)
## - weburl: Download URL for the Microsoft Remote Help PKG
## - appname, app, processpath, terminateprocess, autoUpdate
##
## Artifacts (outputs)
## - Log: /Library/Logs/Microsoft/IntuneScripts/installRemoteHelp/Microsoft Remote Help.log
## - Meta: /Library/Logs/Microsoft/IntuneScripts/installRemoteHelp/Microsoft Remote Help.meta (Last-Modified)
##
## Requirements
## - macOS 11 or later
## - Root privileges
## - Built-ins: curl, installer, softwareupdate, rsync
##
## Exit codes
## - 0: Success (installed or no action required)
## - 1: Failure (unsupported package type)
## - 6-56+: curl-specific error codes (DNS, network, SSL, timeout, etc.)
##
## Usage
## - Run as root via Intune device script or your management workflow.
############################################################################################

## Copyright (c) 2020 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: manahum@microsoft.com

# User Defined variables

weburl="https://aka.ms/downloadremotehelpmacos"                        # The URL to download the PKG from (should be a direct link to a PKG for best results)
appname="Microsoft Remote Help"                                                        # The name of our App deployment script
app="Microsoft Remote Help.app"                                                        # The actual name of our App once installed
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/installRemoteHelp"      # The location of our logs and last updated data
processpath="/Applications//Microsoft Remote Help.app/Contents/MacOS/Microsoft Remote Help"    # The process name of the App we are installing
terminateprocess="true"                                                         # Do we want to terminate the running process? If false we'll wait until its not running
autoUpdate="true"                                                               # Application updates itself, if already installed we should exit

# Generated variables
tempdir=$(mktemp -d)
log="$logandmetadir/$appname.log"                                               # The location of the script log file
metafile="$logandmetadir/$appname.meta"                                         # The location of our meta file (for updates)

# Helpers

cleanup() {
    if [[ -d "$tempdir" ]]; then
        rm -rf "$tempdir"
    fi
}
trap cleanup EXIT

# function to delay download if another download is running
waitForCurl () {

     while ps aux | grep curl | grep -v grep; do
          echo "$(date) | Another instance of Curl is running, waiting 60s for it to complete"
          sleep 10
     done
     echo "$(date) | No instances of Curl found, safe to proceed"

}


# function to delay script if the specified process is running
waitForProcess () {
    #################################################################################################################
    #################################################################################################################
    ##  Function to pause while a specified process is running
    ##  $1 = name of process to check for; $2 = delay; $3 = terminate true/false
    processName=$1
    fixedDelay=$2
    terminate=$3

    echo "$(date) | Waiting for other [$processName] processes to end"
    while ps aux | grep "$processName" | grep -v grep &>/dev/null; do
        if [[ $terminate == "true" ]]; then
            pid=$(pgrep -f "$processName" | head -n1)
            if [[ -n "$pid" ]]; then
                echo "$(date) | + [$appname] running, terminating [$processName] at pid [$pid]..."
                kill -9 $pid 2>/dev/null || true
            fi
            return
        fi
        if [[ ! $fixedDelay ]]; then
            delay=$(( $RANDOM % 50 + 10 ))
        else
            delay=$fixedDelay
        fi
        echo "$(date) |  + Another instance of $processName is running, waiting [$delay] seconds"
        sleep $delay
    done
    echo "$(date) | No instances of [$processName] found, safe to proceed"
}


# Update the last modified date for this app
fetchLastModifiedDate() {
    if [[ ! -d "$logandmetadir" ]]; then
        echo "$(date) | Creating [$logandmetadir] to store metadata"
        mkdir -p "$logandmetadir"
    fi
    lastmodified=$(curl -sIL "$weburl" | grep -i "last-modified" | awk '{$1=""; print $0}' | awk '{ sub(/^[ \t]+/, ""); print }' | tr -d '\r')
    if [[ $1 == "update" ]]; then
        echo "$(date) | Writing last modified date [$lastmodified] to [$metafile]"
        echo "$lastmodified" > "$metafile"
    fi
}

# Download PKG
downloadApp () {
    echo "$(date) | Starting downlading of [$appname]"
    echo "$(date) | Downloading $appname [$weburl]"

    cd "$tempdir"
    curl -o "Microsoft_Remote_Help_installer.pkg" --connect-timeout 30 --retry 5 --retry-delay 60 -L -J "$weburl"
    curlExitCode=$?
    
    # Retry once if curl failed
    if [[ $curlExitCode != 0 ]]; then
        echo "$(date) | First download attempt failed with exit code [$curlExitCode], retrying once more..."
        sleep 5
        curl -o "Microsoft_Remote_Help_installer.pkg" --connect-timeout 30 --retry 5 --retry-delay 60 -L -J "$weburl"
        curlExitCode=$?
    fi
    
    if [[ $curlExitCode == 0 ]]; then
        tempfile="Microsoft_Remote_Help_installer.pkg"
        echo "$(date) | Found downloaded tempfile [$tempfile]"
        case $tempfile in
            *.pkg|*.PKG|*.mpkg|*.MPKG)
                packageType="PKG"
                ;;
            *)
                echo "$(date) | Expected a PKG, but downloaded an unsupported type [$tempfile]"
                exit 1
                ;;
        esac
        echo "$(date) | Downloaded [$app] to [$tempfile]"
        echo "$(date) | Detected install type as [$packageType]"
    else
        echo "$(date) | Failed to download [$appname] from [$weburl]"
        echo "$(date) | curl exit code: [$curlExitCode]"
        case $curlExitCode in
            6)  echo "$(date) | Error: Could not resolve host. Check DNS settings." ;;
            7)  echo "$(date) | Error: Failed to connect to host. Check network connectivity." ;;
            22) echo "$(date) | Error: HTTP error (404/403). Check if download URL is valid." ;;
            28) echo "$(date) | Error: Operation timeout. Check network speed/stability." ;;
            35) echo "$(date) | Error: SSL connect error. Check system date/time and certificates." ;;
            56) echo "$(date) | Error: Failure receiving network data. Network connection was interrupted." ;;
            *)  echo "$(date) | Error: curl failed with exit code $curlExitCode. Check network/proxy settings." ;;
        esac
        echo "$(date) | Troubleshooting: Verify network connectivity, proxy settings, and firewall rules."
        echo "$(date) | You can test manually with: curl -v \"$weburl\""
        updateOctory failed
        exit $curlExitCode
    fi
}

# Check if we need to update or not
updateCheck() {
    echo "$(date) | Checking if we need to install or update [$appname]"
    if [ -d "/Applications/$app" ]; then
        if [[ $autoUpdate == "true" ]]; then
            echo "$(date) | [$appname] is already installed and handles updates itself, exiting"
            exit 0
        fi
        echo "$(date) | [$appname] already installed, let's see if we need to update"
        fetchLastModifiedDate
        if [[ -d "$logandmetadir" ]]; then
            if [ -f "$metafile" ]; then
                previouslastmodifieddate=$(cat "$metafile")
                if [[ "$previouslastmodifieddate" != "$lastmodified" ]]; then
                    echo "$(date) | Update found, previous [$previouslastmodifieddate] and current [$lastmodified]"
                    update="update"
                else
                    echo "$(date) | No update between previous [$previouslastmodifieddate] and current [$lastmodified]"
                    echo "$(date) | Exiting, nothing to do"
                    exit 0
                fi
            else
                echo "$(date) | Meta file [$metafile] not found"
                echo "$(date) | Unable to determine if update required, updating [$appname] anyway"
            fi
        fi
    else
        echo "$(date) | [$appname] not installed, need to download and install"
    fi
}

## Install PKG Function (PKG-only path)
installPKG () {
    waitForProcess "$processpath" "300" "$terminateprocess"
    echo "$(date) | Installing $appname"

    if [[ -d "/Applications/$app" ]]; then
        rm -rf "/Applications/$app"
    fi

    installer -pkg "$tempfile" -target /Applications
    if [ "$?" = "0" ]; then
        echo "$(date) | $appname Installed"
        echo "$(date) | Cleaning Up"
        rm -rf "$tempdir"
        echo "$(date) | Application [$appname] succesfully installed"
        fetchLastModifiedDate update
        exit 0
    else
        echo "$(date) | Failed to install $appname"
        rm -rf "$tempdir"
        exit 1
    fi
}

startLog() {
    if [[ ! -d "$logandmetadir" ]]; then
        echo "$(date) | Creating [$logandmetadir] to store logs"
        mkdir -p "$logandmetadir"
    fi
    exec > >(tee -a "$log") 2>&1
}

# delay until the user has finished setup assistant.
waitForDesktop () {
  until ps aux | grep /System/Library/CoreServices/Dock.app/Contents/MacOS/Dock | grep -v grep &>/dev/null; do
    delay=$(( $RANDOM % 50 + 10 ))
    echo "$(date) |  + Dock not running, waiting [$delay] seconds"
    sleep $delay
  done
  echo "$(date) | Dock is here, lets carry on"
}

###################################################################################
###################################################################################
## Begin Script Body
###################################################################################
###################################################################################

startLog

echo ""
echo "##############################################################"
echo "# $(date) | Logging install of [$appname] to [$log]"
echo "############################################################"
echo ""


waitForDesktop
waitForCurl
downloadApp


# PKG only
if [[ $packageType == "PKG" ]]; then
    installPKG
else
    echo "$(date) | Unsupported package type [$packageType]"
    exit 1
fi
