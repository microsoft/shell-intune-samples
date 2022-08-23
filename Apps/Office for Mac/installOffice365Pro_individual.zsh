#!/bin/zsh
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
logandmetadir="/Library/Logs/IntuneScripts/installOffice2019"
log="$logandmetadir/installOffice2019.log"
SourceXML="https://macadmins.software/latest.xml"
tempdir=$(mktemp -d)
appname="Microsoft Office"
declare -i errors=0

# Edit AppstoInstall array with "id" values from https://macadmins.software/latest.xml for the apps you want to install
AppsToInstall=(     "com.microsoft.outlook.standalone.365"
                    "com.microsoft.word.standalone.365"
                    "com.microsoft.excel.standalone.365"
                    "com.microsoft.powerpoint.standalone.365"
                    "com.microsoft.onenote.standalone.365"
                    "com.microsoft.onedrive.standalone"
                    "com.microsoft.teams.standalone"
               )

TotalAppsToInstall=${#AppsToInstall[*]}

function startLog() {

     if [[ ! -d "$logandmetadir" ]]; then
          ## Creating Metadirectory
          echo "$(date) | Creating [$logandmetadir] to store logs"
          mkdir -p "$logandmetadir"
     fi

     exec > >(tee -a "$log") 2>&1

}

function waitForDesktop () {

     until ps aux | grep /System/Library/CoreServices/Dock.app/Contents/MacOS/Dock | grep -v grep &>/dev/null; do
          delay=$(( $RANDOM % 50 + 10 ))
          echo "$(date) |  + Dock not running, waiting [$delay] seconds"
          sleep $delay
     done

     echo "$(date) | Dock is here, lets carry on"

}

function waitForDesktop () {
  until ps aux | grep /System/Library/CoreServices/Dock.app/Contents/MacOS/Dock | grep -v grep &>/dev/null; do
    delay=$(( $RANDOM % 50 + 10 ))
    echo "$(date) |  + Dock not running, waiting [$delay] seconds"
    sleep $delay
  done
  echo "$(date) | Dock is here, lets carry on"
}

function updateOctory () {

    if [[ -a "/Library/Application Support/Octory" ]]; then

        # Octory is installed, but is it running?
        if [[ $(ps aux | grep -i "Octory" | grep -v grep) ]]; then
            /usr/local/bin/octo-notifier monitor "$appname" --state $1 >/dev/null
        fi
    fi

}

function waitForProcess() {

     processName=$1

     echo "$(date) | Waiting for other [$processName] processes to end"
     while ps aux | grep "$processName" | grep -v grep &>/dev/null; do

          delay=$(( $RANDOM % 50 + 10 ))
          echo "$(date) |  + Another instance of $processName is running, waiting [$delay] seconds"
          sleep $delay

     done

     echo "$(date) | No instances of [$processName] found, safe to proceed"

}

# start logging
startLog

# Check for supported Operating System
os_ver=$(sw_vers -productVersion)
case $os_ver in

10.10.*)
    echo "$(date) |  + macOS 10.10 Yosemite detected, not supported - exiting"
    exit 1
    ;;

10.11.*)
    echo "$(date) |  + macOS 10.11 El Capitan detected, not supported - exiting"
    exit 1
    ;;

10.12.*)
    echo "$(date) |  + macOS 10.12 Sierra detected, not supported - exiting"
    exit 1
    ;;

10.13.*)
    echo "$(date) |  + macOS 10.13 High Sierra detected, not supported - exiting"
    exit 1
    ;;

10.14.*)
    echo "$(date) |  + macOS 10.14 Mojave detected, not supported - exiting"
    exit 1
    ;;

esac

# wait for Desktop
waitForDesktop

echo "$(date) "
echo "$(date) ##############################################################"
echo "$(date) | Starting Individual App Installs [$TotalAppsToInstall] found"
echo "$(date) ############################################################"
echo "$(date) "

echo "$(date) | Downloading latest XML file from [$SourceXML]"
curl -f -s --connect-timeout 30 --retry 300 --retry-delay 60 -L -o "$tempdir/latest.xml" "$SourceXML"
if [[ $? == 0 ]]; then
     echo "$(date) | Successfully downloaded [$SourceXML] to [$tempdir/latest.xml]"
else
     echo "$(date) | Failed to download [$SourceXML] to [$tempdir/latest.xml]"
     exit 1
fi

echo "$(date) | Downloading binaries..."
for app in "${AppsToInstall[@]}"
do
  echo -n "$(date) |  + Downloading [$app]..."
  url=$(xmllint --xpath "//package[contains(id,\"$app\")]/download" $tempdir/latest.xml | sed -e 's/<[^>]*>//g')
  localtmpfile="$tempdir/$app".pkg
  updateOctory installing
  curl -f -s --connect-timeout 30 --retry 5 --retry-delay 60 --compressed -L -J -o $localtmpfile $url
  if [[ $? == 0 ]]; then
       echo "OK"
  else

      errors=$((errors + 1))
      echo "Failed"
  fi

done

echo "$(date) | Installing applications..."
for app in "${AppsToInstall[@]}"
do

  echo -n "$(date) |  + Installing [$app]..."
  localtmpfile="$tempdir/$app".pkg
  installer -pkg "$localtmpfile" -target /Applications >/dev/null 2>&1
  if [[ $? == 0 ]]; then
      echo "OK"
  else
      echo "Failed"
      errors=$((errors + 1))

  fi

   rm -rf "$localtmpfile"

done

rm -rf "/tmp/$appname.app"
rm -rf "$tempfile"

if [[ "$errors" == 0 ]]; then

  echo -n "$(date) | Installation succeeded...[$errors] errors"
  updateOctory installed
  exit 0

else

  echo -n "$(date) | Installation failed [$errors] errors"
  updateOctory failed
  exit 1
fi
