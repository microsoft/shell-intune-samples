#!/bin/bash
#set -x

############################################################################################
##
## Script to download and install OutlookResetPreferences app
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

# Set script variables
appname="OutlookResetPreferences"
tempdir="/tmp"
targetapp="/Applications/Utilities/OutlookResetPreferences.app"


# Let's check to see if SetDefaultMailApp is already installed...
if [[ -a $targetapp ]]; then
  echo "$appname already installed, nothing to do here"
  exit 0
else
  echo "Downloading $appname"
  curl -L -o "$tempdir/$appname.zip" 'https://download.microsoft.com/download/6/C/3/6C3CF698-61C1-4A6D-9F15-104BE03BC303/OutlookResetPreferences.zip'
  cd "$tempdir"
  unzip -o "$appname.zip"

  echo "Moving $appname to Applications folder"
  mv -f "$tempdir/$appname.app" $targetapp

  echo "Fix up permissions"
  sudo chown -R root:wheel "$targetapp"

  echo "Cleaning up tmp files"
  rm -rf "$tempdir/$appname.zip"

fi
