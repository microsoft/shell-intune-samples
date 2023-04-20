#!/usr/bin/env bash
#set -x

############################################################################################
##
## Script to create Local Admin Account for IT Use
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
## This script creates a new Admin account for temporary IT Admin purposes
## The Admin password is a super simple cipher + base64 of the device serial number.
## i.e. ABCDEF000009 becomes S0xNTk9QNDQ0NDQzCg==
##
## WARNING: It is strongly recommended to change the cipher on line 54 before deploying into production, this is shown for example purposes only

# Define variables
adminaccountname="localadmin"       # This is the accountname of the new admin
adminaccountfullname="Local Admin"  # This is the full name of the new admin user
scriptname="Create Local Admin Account"
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/createLocalAdminAccount"
log="$logandmetadir/createLocalAdminAccount.log"
p="9zUQARy374$"

# function to delay until the user has finished setup assistant.
waitforSetupAssistant () {
  until [[ -f /var/db/.AppleSetupDone ]]; do
    delay=$(( $RANDOM % 50 + 10 ))
    echo "$(date) |  + Setup Assistant not done, waiting [$delay] seconds"
    sleep $delay
  done
  echo "$(date) | Setup Assistant is done, lets carry on"
}

## Check if the log directory has been created and start logging
if [ -d $logandmetadir ]; then
    ## Already created
    echo "# $(date) | Log directory already exists - $logandmetadir"
else
    ## Creating Metadirectory
    echo "# $(date) | creating log directory - $logandmetadir"
    mkdir -p $logandmetadir
fi


# start logging
exec 1>> $log 2>&1

# Begin Script Body
echo ""
echo "##############################################################"
echo "# $(date) | Starting $scriptname"
echo "############################################################"
echo ""

echo "Checking if user has already been created"
$userCreated="`dscl . -list /Users |grep $adminaccountname`"
if ["$userCreated" != "" ]; then
  echo "$(date) | User has already beed created, nothing to do"
  exit 0
fi

echo "Creating new local admin account [$adminaccountfullname]"
waitforSetupAssistant

## Configure account
echo "Create a new user with the username $adminaccountname"
dscl . -create /Users/$adminaccountname
echo "Set the shell interpreter to Bash for $adminaccountname"
dscl . -create /Users/$adminaccountname UserShell /bin/bash
echo "Add the display name of the User as $adminaccountfullname"
dscl . -create /Users/$adminaccountname RealName "$adminaccountfullname"
echo "Set the Unique ID for $adminaccountfullname."
dscl . -create /Users/$adminaccountname UniqueID "510"
echo "Set the group ID for the user"
dscl . -create /Users/$adminaccountname PrimaryGroupID "510"
echo "Create a Home folder for the user"
dscl . -create /Users/$adminaccountname NFSHomeDirectory "/Users/$adminaccountname"
sleep 10
echo "Applying preset password."
dscl . -passwd /Users/$adminaccountname $p
echo "Adding a password hint"
sudo dscl . -create /Users/$adminaccountname hint "Cloud\ LAPS"
echo "Append the User with admin privilege."
sudo dscl . -append /Groups/admin GroupMembership $adminaccountname
echo "Create the home directory"
createhomedir -c > /dev/null
