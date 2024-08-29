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

useDockUtil=false
waitForApps=true

# Hold script until Dock is running, otherwise we might run under _mbsetupuser which would be bad
until pgrep -x "Dock" &>/dev/null; do
  sleep 10
done

currentUser=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ { print $3 }' )

# Get uid logged in user
uid=$(id -u "${currentUser}")

# Current User home folder - do it this way in case the folder isn't in /Users
userHome=$(dscl . -read /users/${currentUser} NFSHomeDirectory | cut -d " " -f 2)

# Logging folder and files
logFolder="${userHome}/Desktop"
log=${logFolder}/addAppstoDock.log
mkdir -p "$logFolder"
exec &> >(tee -a "$log")

# Path to plist
plist="${userHome}/Library/Preferences/com.apple.dock.plist"

# Determine the correct settings app
if [[ -e "/System/Applications/System Settings.app" ]]; then
    settingsApp="System Settings.app"
else
    settingsApp="System Preferences.app"
fi

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

install_dockutil_if_missing() {
  # Check if dockutil is installed
  if [[ ! -e "/usr/local/bin/dockutil" ]]; then
    echo "$(date) | dockutil is not present, installing"

    # Download dockutil package
    if curl -L "https://github.com/kcrawford/dockutil/releases/download/3.1.3/dockutil-3.1.3.pkg" -o /var/tmp/dockutil.pkg; then
      echo "$(date) | Successfully downloaded dockutil.pkg"
    else
      echo "$(date) | Failed to download dockutil.pkg"
      return 1
    fi

    # Install dockutil package
    if sudo installer -pkg /var/tmp/dockutil.pkg -target /; then
      echo "$(date) | Successfully installed dockutil"
    else
      echo "$(date) | Failed to install dockutil"
      return 1
    fi

  else
    echo "$(date) | dockutil is already present"
  fi
}

# Convienience function to handle swiftDialog status updates
# usage: updateSplashScreen "status" "message"
function update_swift_dialog () {
    if [[ -e "/Library/Application Support/Dialog/Dialog.app/Contents/MacOS/Dialog" ]]; then
        # Supported status: wait, success, fail, error, pending or progress:xx
        echo "$(date) |     Updating Swift Dialog monitor for Dock to [$1]"
        echo listitem: title: Dock, status: $1, statustext: $2 >> /var/tmp/dialog.log 
    fi

}

# Convenience function to run a command as the current user
# usage: run_as_user command arguments...
run_as_user() {  
	if [[ "${currentUser}" != "loginwindow" ]]; then
		launchctl asuser "$uid" sudo -u "${currentUser}" "$@"
	else
		echo "no user logged in"
		exit 1
	fi
}

configure_dock_with_dockutil () {

    # Update Swift Dialog
    update_swift_dialog wait "Configuring dock..."

    dockutil="/usr/local/bin/dockutil"

    # Clear Dock
    run_as_user "${dockutil}" --remove all --no-restart ${plist}

    # Add Apps to Dock in order
    for app in "${dockapps[@]}"; do
      if [[ -e "$app" ]]; then
        echo "$(date) | Adding ${app} to Dock..."
        run_as_user "${dockutil}" --add "${app}" --section apps --no-restart ${plist} > /dev/null 2>&1
      else
        echo "$(date) | ${app} not installed, skipping..."
      fi
    done

    # Add Downloads Folder
    run_as_user "${dockutil}" --add "${userHome}/Downloads" --section others --no-restart ${plist} > /dev/null 2>&1

    killall -KILL Dock
    
    touch "/Users/$currentUser/Library/Preferences/.dockconfigured"
    update_swift_dialog success "Configured dock..."
}

configure_dock_via_plist () {

  # Update Swift Dialog
  update_swift_dialog wait "Configuring dock..."

  # Clearing Dock
  echo "$(date) |  Removing Dock Persistent Apps"
  #run_as_user defaults delete com.apple.dock
  run_as_user defaults delete com.apple.dock persistent-apps
  run_as_user defaults delete com.apple.dock persistent-others

  echo "$(date) |  Adding Apps to Dock"
  for i in "${dockapps[@]}"; do
    if [[ -a "$i" ]] ; then
      echo "$(date) |  Adding [$i] to Dock"
      run_as_user defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$i</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
      update_swift_dialog wait "Adding $i to Dock"
    fi
  done

  echo "$(date) | Adding Downloads Stack"
  downloadfolder="${userHome}/Downloads"
  run_as_user defaults write com.apple.dock persistent-others -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$downloadfolder</string><key>_CFURLStringType</key><integer>0</integer></dict><key>file-label</key><string>Downloads</string><key>file-type</key><string>2</string></dict><key>tile-type</key><string>directory-tile</string></dict>"

  #echo "$(date) | Enabling Magnification"
  #defaults write com.apple.dock magnification -boolean YES

  #echo "$(date) | Enable Dim Hidden Apps in Dock"
  #defaults write com.apple.dock showhidden -bool true

  #echo "$(date) | Enable Auto Hide dock"
  #defaults write com.apple.dock autohide -bool true

  #echo "$(date) | Disable show recent items"
  #defaults write com.apple.dock show-recents -bool FALSE

  #echo "$(date) | Enable Minimise Icons into Dock Icons"
  #defaults write com.apple.dock minimize-to-application -bool yes

  echo "$(date) | Restarting Dock"
  killall -KILL Dock

  touch "/Users/$currentUser/Library/Preferences/.dockconfigured"
  update_swift_dialog success "Configured dock..."

}

wait_for_apps_installation() {
    local timeout=$1
    local start_time=$(date +%s)
    update_swift_dialog wait "Waiting for apps..."
    while true; do
        all_installed=true

        for app in "${dockapps[@]}"; do
            if [[ ! -e "$app" ]]; then
                all_installed=false
                break
            fi
        done

        if [[ "$all_installed" = true ]]; then
            echo "$(date) | All apps are installed"
            return 0
        fi

        current_time=$(date +%s)
        elapsed_time=$(( current_time - start_time ))

        if [[ $elapsed_time -ge $timeout ]]; then
            echo "$(date) | Timeout reached. Not all apps are installed."
            return 1
        fi

        sleep 5 # Sleep for a few seconds before checking again
    done
}

## Script Begins Here

# Check if apps are installed
if [[ "$waitForApps" == true ]]; then
    echo "$(date) | Waiting for apps to be installed..."
    wait_for_apps_installation 900      # Wait 900 seconds for apps to be installed
fi

# if useDockUtil is true, use dockutil to configure the dock
if [[ "$useDockUtil" == true ]]; then
    echo "$(date) | Configuring dock with dockutil"
    install_dockutil_if_missing
    configure_dock_with_dockutil
else
    echo "$(date) | Configuring dock with plist"
    configure_dock_via_plist
fi