#!/bin/bash
#set -x

############################################################################################
##
## Script to wait for apps to be installed and then configure the Mac Dock
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

##
## Notes
##
## The array Dockitems contains a list of applications that the script expects to find on the Mac. These need to be deployed
## by some other means than this script. Either via MDM, VPP, or other scripts. This script will wait indefinitely until all
## of the apps are present and then it will clear the current dock and add the apps.
##
## Lines 94 onwards confiure Dock look and feel, uncomment as necessary
##

# Define variables
log="/tmp/addAppstoDock.log"
appname="Dock Script"
startCompanyPortalifADE="true"

exec &> >(tee -a "$log")

if [[ -f "$HOME/Library/Logs/prepareDock" ]]; then

  echo "Script has already run, nothing to do"
  exit 0

fi

dockitems=( "/Applications/Microsoft Edge.app"
            "/Applications/Microsoft Outlook.app"
            "/Applications/Microsoft Word.app"
            "/Applications/Microsoft Excel.app"
            "/Applications/Microsoft PowerPoint.app"
            "/Applications/Microsoft OneNote.app"
            "/Applications/Microsoft Teams.app"
            "/Applications/Visual Studio Code.app"
            "/Applications/Company Portal.app"
            "/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app"
            "/System/Applications/App Store.app"
            "/System/Applications/Utilities/Terminal.app"
            "/System/Applications/System Preferences.app")


echo ""
echo "##############################################################"
echo "# $(date) | Starting install of $appname"
echo "############################################################"
echo ""

# function to delay until the user has finished setup assistant.
waitForDesktop () {
  until ps aux | grep /System/Library/CoreServices/Dock.app/Contents/MacOS/Dock | grep -v grep; do
    echo "$(date) | Dock not running, waiting..."
    sleep 5
  done
  echo "$(date) | Desktop is here, lets carry on"
}


waitForDesktop
echo "Looking for required applications..."

while [[ $ready -ne 1 ]];do

  missingappcount=0

  for i in "${dockitems[@]}"; do
    if [[ -a "$i" ]]; then
      echo " $(date) | $i is installed"
    else
      let missingappcount=$missingappcount+1
    fi
  done

  echo " $(date) | [$missingappcount] application missing"

  if [[ $missingappcount -eq 0 ]]; then
    ready=1
    echo " $(date) | All apps found, lets prep the dock"
  else
    echo " $(date) | Waiting for 10 seconds"
    sleep 10
  fi

done

echo " $(date) | Removing Dock Persistent Apps"
defaults delete $HOME/Library/Preferences/com.apple.dock persistent-apps
defaults delete $HOME/Library/Preferences/com.apple.dock persistent-others

for i in "${dockitems[@]}"; do
  if [[ -a "$i" ]] ; then
    echo " $(date) | Adding [$i] to Dock"
    defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$i</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
  fi
done

echo "$(date) | Adding Downloads Stack"
consoleuser=$(ls -l /dev/console | awk '{ print $3 }')
downloadfolder="$HOME/Downloads"
defaults write com.apple.dock persistent-others -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$downloadfolder</string><key>_CFURLStringType</key><integer>0</integer></dict><key>file-label</key><string>Downloads</string><key>file-type</key><string>2</string></dict><key>tile-type</key><string>directory-tile</string></dict>"

echo "$(date) | Enabling Magnification"
defaults write com.apple.dock magnification -boolean YES

echo "$(date) | Enable Dim Hidden Apps in Dock"
defaults write com.apple.dock showhidden -bool true

#echo "$(date) | Enable Auto Hide dock"
#defaults write com.apple.dock autohide -bool true

echo "$(date) | Disable show recent items"
defaults write com.apple.dock show-recents -bool FALSE

echo "$(date) | Enable Minimise Icons into Dock Icons"
defaults write com.apple.dock minimize-to-application -bool yes

echo "$(date) | Restarting Dock"
killall Dock

echo "$(date) | Writng completion lock to [~/Library/Logs/prepareDock]"
touch "$HOME/Library/Logs/prepareDock"

# If this is an ADE enrolled device (DEP) we should launch the Company Portal for the end user to complete registration
if [ "$startCompanyPortalifADE" = true ]; then
  echo "Checking MDM Profile Type"
  profiles status -type enrollment | grep "Enrolled via DEP: Yes"
  if [ ! $? == 0 ]; then
    echo "This device is not ABM managed, exiting"
    exit 0;
  else
    echo "Device is ABM Managed. launching Company Portal"
    open "/Applications/Company Portal.app"
  fi
fi
