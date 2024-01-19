#!/bin/zsh
#set -x
############################################################################################
##
## Script to require Administrator password to access System-Wide Preferences
##
############################################################################################

## Copyright (c) 2023 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: neiljohn@microsoft.com

# Define variables
appname="AdministratorPasswordToSystemWidePreferences"
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/$appname"
log="$logandmetadir/$appname.log"

# Check if the log directory has been created
if [ -d $logandmetadir ]; then
    # Already created
    echo "$(date) | Log directory already exists - $logandmetadir"
else
    # Creating Metadirectory
    echo "$(date) | creating log directory - $logandmetadir"
    mkdir -p $logandmetadir
fi

# Set to require an administrator password to access system-wide settings
AdministratorPasswordToSystemWidePreferences() {
authDBs=("system.preferences" "system.preferences.energysaver" "system.preferences.network" "system.preferences.printing" "system.preferences.sharing" "system.preferences.softwareupdate" "system.preferences.startupdisk" "system.preferences.timemachine")
for section in ${authDBs[@]}; do 
/usr/bin/security -q authorizationdb read "$section" > "/tmp/$section.plist" key_value=$(/usr/libexec/PlistBuddy -c "Print :shared" "/tmp/$section.plist" 2>&1)
	if [[ "$key_value" == *"Does Not Exist"* ]]; then
			/usr/libexec/PlistBuddy -c "Add :shared bool false" "/tmp/$section.plist"
	else 	/usr/libexec/PlistBuddy -c "Set :shared false" "/tmp/$section.plist" 
	fi 
/usr/bin/security -q authorizationdb write "$section" < "/tmp/$section.plist"
done
echo "$(date) | Ensure an Administrator password is required to access system-wide Preferences is now set or already set. Closing script..."
}

# Start logging
exec &> >(tee -a "$log")

# Begin Script Body
echo ""
echo "##############################################################"
echo "# $(date) | Starting running of script $appname"
echo "############################################################"
echo ""

# Run function
AdministratorPasswordToSystemWidePreferences