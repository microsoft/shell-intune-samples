#!/bin/bash
#set -x

############################################################################################
##
## Script to download a local copy of the Office Business Pro install files for Mac
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
weburl="https://go.microsoft.com/fwlink/?linkid=854187"

echo "$(date) | Downloading Manifest"
curl -L -o $tempdir/officemanifest.xml $weburl

echo "$(date) | Determining CDN url"
url="$(echo "cat /plist[@version="1.0"]//array[1]/dict[1]/string[2]/text()[1]" | xmllint --nocdata --shell $tempdir/officemanifest.xml | sed '1d;$d')"

echo "$(date) | Downloading Office from CDN"
curl -L -o /Library/WebServer/Documents/OfficeBusinessPro.pkg $url
