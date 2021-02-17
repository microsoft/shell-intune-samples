#!/bin/bash
#set -x

############################################################################################
##
## Script to install latest Microsoft Office Business Pro for Mac from CDN Servers
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
localcopy="http://192.168.68.150/OfficeforMac/OfficeBusinessPro.pkg"   # This is your local copy of the OfficeBusinessPro.pkg file. You need to handle this independently
appname="Office Business Pro for Mac"
logandmetadir="/Library/Intune/Scripts/installOfficeBusinessPro"
log="$logandmetadir/installmee.log"

## Check if the log directory has been created
if [ -d $logandmetadir ]; then
    ## Already created
    echo "# $(date) | Log directory already exists - $logandmetadir"
else
    ## Creating Metadirectory
    echo "# $(date) | creating log directory - $logandmetadir"
    mkdir -p $logandmetadir
fi

# start logging

exec 1>> $log 2>&1

echo ""
echo "##############################################################"
echo "# $(date) | Starting install of $appname"
echo "############################################################"
echo ""

consoleuser=$(ls -l /dev/console | awk '{ print $3 }')

echo "$(date) | logged in user is" $consoleuser

#
# Check to see if we can access our local copy of Office
#
curl -s --connect-timeout 30 --retry 300 --retry-delay 60 -L -o $tempfile $localcopy
if [ $? == 0 ]; then

     echo "$(date) | Local copy of $appname downloaded at $tempfile"

else

    echo "$(date) | Couldn't find local copy of $appname, need to fetch from CDN"
    echo "$(date) | Downloading $appname from CDN"

    curl -s --connect-timeout 30 --retry 300 --retry-delay 60 -L -o $tempfile $weburl
    if [ $? == 0 ]; then

         echo "$(date) | Success"
    
    else
    
         echo "$(date) | Failure"
         exit 5
    
    fi

fi

echo "$(date) | Installing $appname"
installer -pkg $tempfile -target /Applications

if [ $? == 0 ]; then
     echo "$(date) | Success"
else
     echo "$(date) | Failure"
     exit 6
fi

echo "$(date) | Removing tmp files"
rm -rf $tempfile
