#!/bin/bash
#set -x

############################################################################################
##
## Script to download latest Intune Company Portal for macOS
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

tempfile="/tmp/cp.pkg"
weburl="https://go.microsoft.com/fwlink/?linkid=853070"
appname="Intune Company Portal"
log="/var/log/installcp.log"

# start logging

exec 1>> $log 2>&1

# Begin Script Body

echo ""
echo "##############################################################"
echo "# $(date) | Starting install of $appname"
echo "############################################################"
echo ""

# Let's download the files we need and attempt to install...

echo "$(date) | Downloading $appname"
curl -L -f -o $tempfile $weburl

echo "$(date) | Installing $appname"
installer -dumplog -pkg $tempfile -target /Applications
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
