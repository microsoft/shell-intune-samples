#!/bin/bash
#set -x

############################################################################################
##
## Script to download latest Microsoft Copilot M365 for macOS
##
###########################################

## Copyright (c) 2020 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: manahum@microsoft.com
##Update 2604
version="v1.3"

# Define variables

tempfile="/tmp/c365.pkg"
weburl="https://go.microsoft.com/fwlink/?linkid=2325438"
appname="Microsoft Copilot M365"
log="/var/log/installc365.log"
waitApp="Company Portal.app"
initialDelay=120

# function to delay download if another download is running
waitForCurl () {

     while ps aux | grep curl | grep -v grep; do
          echo "$(date) | Another instance of Curl is running, waiting 10s for it to complete"
          sleep 10
     done
     echo "$(date) | No instances of Curl found, safe to proceed"

}


# function to wait for an app to be installed in /Applications
waitForAppInstall () {
    local waitApp="$1"
    while [ ! -d "/Applications/$waitApp" ]; do
        echo "$(date) | Waiting for $waitApp to be installed in /Applications, checking again in 30s..."
        sleep 30
    done
    echo "$(date) | $waitApp detected in /Applications, safe to proceed"
}


# start logging

exec 1>> $log 2>&1

echo "$(date) | Waiting $initialDelay seconds before starting download"
sleep $initialDelay

# Begin Script Body

echo ""
echo "##############################################################"
echo "# $(date) | Starting install of $appname" $version
echo "############################################################"
echo ""

# Ensure that the specified app ($waitApp) is installed before proceeding
waitForAppInstall "$waitApp"

# Let's download the files we need and attempt to install...

# wait for other downloads to complete
waitForCurl

echo "$(date) | Downloading $appname"
echo "$(date) | from $weburl"
curl -s --connect-timeout 30 --retry 300 --retry-delay 10 -L -o $tempfile $weburl

echo "$(date) | Installing $appname"
installer -pkg $tempfile -target /
if [ "$?" = "0" ]; then
   echo "$(date) | $appname Installed"
   echo "$(date) | Cleaning Up"
   rm -rf $tempfile
   exit 0
else
  # Something went wrong here, either the download failed or the install Failed
  # intune will pick up the exit status and the IT Pro can use that to determine what went wrong.
  # Intune can also return the log file if requested by the admin
   echo "$(date) | Failed to install $appname"
   exit 1
fi
