#!/bin/bash
#set -x

############################################################################################
##
## Script to install inidividual Office Mac Apps
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

# Define variables
logandmetadir="/Library/Intune/Scripts/installOfficeSuiteIndividual"
log="$logandmetadir/installOfficeSuiteIndividual.log"
SourceXML="https://macadmins.software/latest.xml"

# Edit AppstoInstall array with "id" values from https://macadmins.software/latest.xml for the apps you want to install
# Note: This script only handles installation of pkg files, DMG and ZIP files will NOT work.
AppsToInstall=(   "com.microsoft.word.standalone.365"
                  "com.microsoft.excel.standalone.365"
                  "com.microsoft.powerpoint.standalone.365"
                  "com.microsoft.outlook.standalone.365"
                  "com.microsoft.onenote.standalone.365"
                  "com.microsoft.onedrive.standalone"
                  "com.microsoft.skypeforbusiness.standalone"
                  "com.microsoft.teams.standalone"
                  )

TotalAppsToInstall=${#AppsToInstall[*]}

## Check if the log directory has been created
if [ -d $logandmetadir ]; then
    ## Already created
    echo "$(date) | Log directory already exists - $logandmetadir"
else
    ## Creating Metadirectory
    echo "$(date) | creating log directory - $logandmetadir"
    mkdir -p $logandmetadir
fi

# start logging
exec 1>> $log 2>&1

#########################################
#
# Begin Script Body
#
##################

echo "$(date) "
echo "$(date) ##############################################################"
echo "$(date) | Starting Individual Office App Installs [$TotalAppsToInstall] found"
echo "$(date) ############################################################"
echo "$(date) "

echo "$(date) | Downloading latest XML file from [$SourceXML]"
#curl -s --connect-timeout 30 --retry 300 --retry-delay 60 -L -o /tmp/latest.xml $SourceXML
if [ $? == 0 ]; then
     echo "$(date) | Successfully downloaded [$SourceXML] to [/tmp/latest.xml]"
else
     echo "$(date) | Failed to download [$SourceXML] to [/tmp/latest.xml]"
     exit 1
fi

for app in "${AppsToInstall[@]}"
do
   :
   echo "$(date) | Looking for download URL for $app"
   url=$(xmllint --xpath "//package[contains(id,\"$app\")]/download" /tmp/latest.xml | sed -e 's/<[^>]*>//g')
   if [ $? == 0 ]; then
        echo "$(date) | Successfully parsed xml file [/tmp/latest.xml] for [$app] -> [$url]"
   else
        echo "$(date) | Failed to parse xml file [/tmp/latest.xml] for [$app]"
        exit 1
   fi

   title=$(xmllint --xpath "//package[contains(id,\"$app\")]/title" /tmp/latest.xml | sed -e 's/<[^>]*>//g')
   minosver=$(xmllint --xpath "//package[contains(id,\"$app\")]/min_os" /tmp/latest.xml | sed -e 's/<[^>]*>//g')
   localtmpfile="/tmp/$app".pkg

   install=$((install+1))
   echo "$(date) "
   echo "$(date) ##############################################################"
   echo "$(date) | [$install / $TotalAppsToInstall] Starting install of $title"
   echo "$(date) ############################################################"
   echo "$(date) "

   echo "$(date) | AppName = $title"
   echo "$(date) | AppUrl = $url"
   echo "$(date) | MinOSVer = $minosver"
   echo "$(date) | Local Temp file = $localtmpfile"

   echo "$(date) | Attempting to download [$url] to $localtmpfile"
   #curl  -s --connect-timeout 30 --retry 300 --retry-delay 60 -L -o $localtmpfile $url
   if [ $? == 0 ]; then
        echo "$(date) | Successfully downloaded from [$url] to [$localtmpfile]"
   else
        echo "$(date) | Failed to download package from [$url] to [$localtmpfile]"
        exit 1
   fi

   echo "$(date) | Attempting to install [$title] from $localtmpfile"
   #installer -pkg $localtmpfile -target /Applications
   if [ $? == 0 ]; then
        echo "$(date) | Successfully installed [$title] from [$localtmpfile]"
   else
        echo "$(date) | Failed to install [$title] from [$localtmpfile]"
        exit 1
   fi

   echo "$(date) | Cleaning up tmp file [$localtmpfile]"
   rm -rf "$localtmpfile"

   echo "$(date) "
   echo "$(date) ##############################################################"
   echo "$(date) | End of $title install"
   echo "$(date) ############################################################"
   echo "$(date) "

done

echo "$(date) | Cleaning up tmp file [/tmp/latest.xml]"
rm -rf "/tmp/$appname.app"
rm -rf "$tempfile"

exit
