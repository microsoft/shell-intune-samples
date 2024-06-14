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
## Lines 146 onwards confiure Dock look and feel, uncomment as necessary
##

# Dock Configuration Values
autoHideDock=false
magnification=false
dimHiddenApps=true
showRecentItems=true
enableMinimiseIconsToDock=true

# Script Configuration
secondsToWaitForOtherApps=3600
appname="Dock"

# Define log and start logging...
log="/var/tmp/addAppstoDock.log"
exec &> >(tee -a "$log")

# Lets find out who we're running as...
scriptRunningAs=$(whoami)
desktopUser=$(who | awk '/console/{print $1}')

# Determine home directory
desktopUserHomeDirectory=$(dscl . -read "/users/$desktopUser" NFSHomeDirectory | cut -d " " -f 2)
plist="${desktopUserHomeDirectory}/Library/Preferences/com.apple.dock.plist"

echo "The script is running under the user: $scriptRunningAs"
echo "The current desktop user is: $desktopUser"
echo "The current desktop users home directory is: $desktopUserHomeDirectory" 

# Check if an script has already run before
if [[ -f "$desktopUserHomeDirectory/Library/Logs/prepareDock" ]]; then

  echo "$(date) | Script has already run, nothing to do"
  exit 0

fi

# Wait for Dock...
until ps aux | grep /System/Library/CoreServices/Dock.app/Contents/MacOS/Dock | grep -v grep &>/dev/null; do
  delay=$(( $RANDOM % 50 + 10 ))
  echo "$(date) |  + Dock not running, waiting [$delay] seconds"
  sleep $delay
done
echo "$(date) | Dock is here, lets carry on"

# workaround for Ventura (macOS Ver 13.x) System Settings.app name change
if [[ -a "/System/Applications/System Settings.app" ]]; then settingsApp="System Settings.app"; else settingsApp="System Preferences.app"; fi

dockapps=(  "/System/Applications/Launchpad.app"
            "/Applications/Microsoft Edge.app"
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
            "/System/Applications/$settingsApp")

echo ""
echo "##############################################################"
echo "# $(date) | Starting install of $appname"
echo "############################################################"
echo ""

# Function to update Swift dialog
function updateSplashScreen () {

    #################################################################################################################
    #################################################################################################################
    ##
    ##  This function is designed to update the Splash Screen status (if required)
    ##
    ###############################################################
    ###############################################################


    # Is Swift Dialog present
    if [[ -a "/Library/Application Support/Dialog/Dialog.app/Contents/MacOS/Dialog" ]]; then


        echo "$(date) |     Updating Swift Dialog monitor for [$appname] to [$1]"
        echo listitem: title: $appname, status: $1, statustext: $2 >> /var/tmp/dialog.log 

        # Supported status: wait, success, fail, error, pending or progress:xx

    fi

}


START=$(date +%s) # define loop start time so we can timeout gracefully
echo "$(date) | Looking for required applications..."

while [[ $ready -ne 1 ]];do

  # If we've waited for too long, we should just carry on
  if [[ $(($(date +%s) - $START)) -ge $secondsToWaitForOtherApps ]]; then
      echo "$(date) | Waited for [$secondsToWaitForOtherApps] seconds, continuing anyway]"
      break
  fi

  missingappcount=0

  for i in "${dockapps[@]}"; do
    if [[ -a "$i" ]]; then
      echo "$(date) |  $i is installed"
    else
      let missingappcount=$missingappcount+1
    fi
  done

  echo "$(date) |  [$missingappcount] application missing"
  updateSplashScreen wait "Waiting for $missingappcount apps..."


  if [[ $missingappcount -eq 0 ]]; then
    ready=1
    echo "$(date) |  All apps found, lets prep the dock"
  else
    echo "$(date) |  Waiting for 10 seconds"
    sleep 10
  fi

done


# Check if /usr/local/bin/dockutil is present, if not quit
if [[ ! -a "/usr/local/bin/dockutil" ]]; then
  echo "$(date) | dockutil is not present, exiting"
  updateSplashScreen fail "Dockutil is missing"
  exit 1
fi

updateSplashScreen wait "Installing"


# Clear the dock
echo "$(date) |  Clearing Dock Items"
sudo -i -u $desktopUser /usr/local/bin/dockutil --remove all --no-restart > /dev/null 2>&1

# Add the apps to the dock
echo "$(date) |  Adding Apps to Dock"
for i in "${dockapps[@]}"; do
  if [[ -a "$i" ]] ; then
    echo "$(date) |   + Adding [$i] to Dock"
    updateSplashScreen wait "Adding $i to Dock"
    sudo -i -u $desktopUser /usr/local/bin/dockutil --add "$i" --no-restart > /dev/null 2>&1
  fi
done

# Add the Download folder to the dock
echo "$(date) | Adding Downloads Stack"
downloadfolder="$desktopUserHomeDirectory/Downloads"
updateSplashScreen wait "Adding $downloadfolder to Dock"
sudo -i -u $desktopUser /usr/local/bin/dockutil --add "$downloadfolder" --view fan --display stack --sort dateadded --no-restart > /dev/null 2>&1

# Add the Documents folder to the dock
echo "$(date) | Adding Documents Stack"
documentsFolder="$desktopUserHomeDirectory/Documents"
updateSplashScreen wait "Adding $documentsFolder to Dock"
sudo -i -u $desktopUser /usr/local/bin/dockutil --add "$documentsFolder" --view fan --display stack --sort dateadded --no-restart > /dev/null 2>&1

# Configure Settings Magnification 
echo "$(date) | Setting Magnification to ${magnification}"
updateSplashScreen wait "Setting Magnification to ${magnification}"
sudo -i -u $desktopUser defaults write "${desktopUserHomeDirectory}/Library/Preferences/com.apple.dock.plist" magnification -boolean ${magnification}

# Configure Dim Hidden Apps
echo "$(date) | Setting Dim Hidden Apps to ${dimHiddenApps}"
updateSplashScreen wait "Setting Dim Hidden Apps to ${dimHiddenApps}"
sudo -i -u $desktopUser defaults write "${desktopUserHomeDirectory}/Library/Preferences/com.apple.dock.plist" showhidden -bool ${dimHiddenApps}

# Configure Auto Hide Dock
echo "$(date) | Setting Auto Hide Dock to ${autoHideDock}"
updateSplashScreen wait "Setting Auto Hide Dock to ${autoHideDock}"
sudo -i -u $desktopUser defaults write "${desktopUserHomeDirectory}/Library/Preferences/com.apple.dock.plist" autohide -bool ${autoHideDock}

# Configure Show Recent Items
echo "$(date) | Setting Show Recent Items to ${showRecentItems}"
updateSplashScreen wait "Setting Show Recent Items to ${showRecentItems}"
sudo -i -u $desktopUser defaults write "${desktopUserHomeDirectory}/Library/Preferences/com.apple.dock.plist" show-recents -bool ${showRecentItems}

# Configure Enable Minimise Icons into Dock Icons
echo "$(date) | Setting Enable Minimise Icons into Dock Icons to ${enableMinimiseIconsToDock}"
updateSplashScreen wait "Setting Enable Minimise Icons into Dock Icons to ${enableMinimiseIconsToDock}"
sudo -i -u $desktopUser defaults write "${desktopUserHomeDirectory}/Library/Preferences/com.apple.dock.plist" minimize-to-application -bool ${enableMinimiseIconsToDock}

# Restart the Dock
echo "$(date) | Restarting Dock"
updateSplashScreen wait "Restarting Dock..."
killall Dock

# Write a completion lock file
echo "$(date) | Writng completion lock"
touch "${desktopUserHomeDirectory}/Library/Logs/prepareDock"

# Update the swiftdialog Screen
updateSplashScreen success Installed

