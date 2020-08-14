#!/bin/bash
#set -x

############################################################################################
##
## Script to install the latest Visual Studio Code
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

tempfile="/tmp/vscode.zip"
weburl="https://go.microsoft.com/fwlink/?LinkID=620882"
appname="Visual Studio Code"
log="/var/log/installvscode.log"

# start logging

exec 1>> $log 2>&1

# Begin Script Body

echo ""
echo "##############################################################"
echo "# $(date) | Starting install of $appname"
echo "############################################################"
echo ""

echo "$(date) | Downloading $appname"
curl -L -f -o $tempfile $weburl

cd /tmp
echo "$(date) | Unzipping $tempfile"
rm -rf "/tmp/$appname.app"
unzip -q $tempfile

echo "$(date) | Copying files to /Applications"
rsync -a "/tmp/$appname.app" "/Applications/"

echo "$(date) | Fixing up permissions"
sudo chown -R root:wheel "/Applications/$appname.app"

echo "$(date) | Cleaning up tmp files"
rm -rf "/tmp/$appname.app"
rm -rf "$tempfile"
