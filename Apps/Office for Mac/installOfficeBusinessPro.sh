#!/bin/bash
#set -x

############################################################################################
##
## Script to install latest Microsoft Office 365 Apps for macOS from CDN Servers
## includes - Outlook, Word, Excel, PowerPoint, OneDrive, OneNote and Teams
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
## Feedback: neiljohn@microsoft.com

# Define variables
##############################

tempdir="/tmp"
tempfile="/tmp/office.pkg"
weburl="https://go.microsoft.com/fwlink/?linkid=2009112"
#localcopy="http://192.168.68.139/Office365forMac/Office365AppsFormacOS.pkg"   # This is your local copy of the OfficeBusinessPro.pkg file. You need to handle this independently, comment out if not required
appname="Office 365 Apps for macOS"
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/installOffice365AppsformacOS"
log="$logandmetadir/Office365AppsformacOS.log"

## Check if the log directory has been created
if [ -d $logandmetadir ]; then
    ## Already created
    echo "# $(date) | Log directory already exists - $logandmetadir"
else
    ## Creating Metadirectory
    echo "# $(date) | creating log directory - $logandmetadir"
    mkdir -p $logandmetadir
fi

# function to delay download if another download is running
waitForCurl () {

     while ps aux | grep curl | grep -v grep; do
          echo "$(date) | Another instance of Curl is running, waiting 60s for it to complete"
          sleep 60
     done
     echo "$(date) | No instances of Curl found, safe to proceed"

}

# function to delay install if another installation process is running
waitForInstaller () {

     while ps aux | grep /System/Library/CoreServices/Installer.app/Contents/MacOS/Installer | grep -v grep; do
          echo "$(date) | Another installer is running, waiting 60s for it to complete"
          sleep 60
     done
     echo "$(date) | Installer not running, safe to start installing"

}

# function to delay install during setup assistant
waitForDesktop () {

     until ps aux | grep /System/Library/CoreServices/Dock.app/Contents/MacOS/Dock | grep -v grep; do
          echo "$(date) | Dock not running, waiting..."
          sleep 5
     done
     echo "$(date) | Desktop is here, lets carry on"

}

# start logging
exec 1>> $log 2>&1

echo ""
echo "##############################################################"
echo "# $(date) | Starting install of $appname"
echo "############################################################"
echo ""

consoleuser=$(ls -l /dev/console | awk '{ print $3 }')

echo "$(date) | logged in user is" $consoleuser

# If local copy is defined, let's try and download it...
if [ $localcopy ]; then

     # Check to see if we can access our local copy of Office
     echo "$(date) | Downloading [$localcopy] to [$tempfile]"
     rm -rf $tempfile > /dev/null 2>&1
     curl -f -s -L -o $tempfile $localcopy
     if [ $? == 0 ]; then
          echo "$(date) | Local copy of $appname downloaded at $tempfile"
          downloadcomplete="true"
     fi
fi

# If we failed to download the local copy, or it wasn't defined then try to download from CDN
if [[ "$downloadcomplete" != "true" ]]; then

    waitForCurl
    rm -rf $tempfile > /dev/null 2>&1
    echo "$(date) | Downloading [$weburl] to [$tempfile]"
    curl -f -s --connect-timeout 60 --retry 10 --retry-delay 30 -L -o $tempfile $weburl
    if [ $? == 0 ]; then
         echo "$(date) | Downloaded $weburl to $tempfile"
    else
    
         echo "$(date) | Failure to download $weburl to $tempfile"
         exit 1
    
    fi

fi

waitForInstaller    # To avoid too much stress on the device, we'll try and only run setup when no other apps are installing

echo "$(date) | Installing $appname from $tempfile"

installer -pkg $tempfile -target /Applications
if [ $? == 0 ]; then
     echo "$(date) | Install of $appname succeeded"
     echo "$(date) | Removing tmp files"
     rm -rf $tempfile
     exit 0
else
     echo "$(date) | Install of $appname failed"
     echo "$(date) | Removing tmp files"
     rm -rf $tempfile
     exit 1
fi
