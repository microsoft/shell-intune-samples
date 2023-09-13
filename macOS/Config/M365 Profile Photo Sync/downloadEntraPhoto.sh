#!/bin/bash
Ver="2309.27"
#set -x

############################################################################################
##
## Script to download the profile photo from entraID
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
## Feedback: marc.nahum@microsoft.com

# User Defined variables
clientID=""
secretValue=""
tenantID=""

# Standard Variables
userName=$(ls -l /dev/console | awk '{ print $3 }') 
headers=(-H "Content-Type: application/x-www-form-urlencoded")
logDir="/Library/logs/Microsoft/IntuneScripts/PhotoID"
log=$logDir"/PhotoID.log"
file="PhotoID.jpg"

# Generated Variables
url="https://login.microsoftonline.com/$tenantID/oauth2/v2.0/token"
#data="client_id=$clientID&scope=https%3A%2F%2Fgraph.microsoft.com%2F.default&client_secret=$secretValue&grant_type=client_credentials"
data="client_id=$clientID&scope=https://graph.microsoft.com/.default&client_secret=$secretValue&grant_type=client_credentials"

## Check if the log directory has been created
if [ -d $logDir ]; then
	## Already created
	echo "$(date) | log directory already exists - $logDir"
else
	## Creating Metadirectory
	echo "$(date) | creating log directory - $logDir"
	mkdir -p $logDir
fi

# function to delay until the user has finished setup assistant.
waitForDesktop () {
  until ps aux | grep /System/Library/CoreServices/Dock.app/Contents/MacOS/Dock | grep -v grep &>/dev/null; do
    delay=$(( $RANDOM % 50 + 10 ))
    echo "$(date) |  + Dock not running, waiting [$delay] seconds"
    sleep $delay
  done
  echo "$(date) | Dock is here, lets carry on"
}


# start logging
exec &> >(tee -a "$log")

# Begin Script Body

echo ""
echo "##############################################################"
echo "# $(date) | Starting run PhotoID ([$Ver])"
echo "############################################################"
echo ""

# We don't want to interrupt setup assistant
waitForDesktop


# Attempt to read UPN from OfficeActivationEmailAddress
officePlistPath="/Library/Managed Preferences/com.microsoft.office.plist"

# Set Max Retries
max_retries=10
retries=0



until [ -e "$officePlistPath" ]; do
    # Check if the current time has exceeded the end time
    echo "$(date) | Looking for Office Plist File [$officePlistPath]"
    if [ "$retries" -ge "$max_retries" ]; then
        echo "$(date) | Office plist file not found [$officePlistPath]"
        exit 1
    fi

    # If the file is not found, sleep for the specified interval
    ((retries++)) 
    sleep 30
done

echo "$(date) | Office plist file found [$officePlistPath]"


echo "$(date) | Trying to determine UPN from OfficeActivationEmailAddress"
UPN=$(defaults read /Library/Managed\ Preferences/com.microsoft.office.plist OfficeActivationEmailAddress)
if [ $? == 0 ]; then
    echo "$(date) |  + UPN found as [$UPN]"
else
    echo "$(date) |  + UPN not found, exiting (did you set Office Activation e-Mail is Settings Picker?)"
    exit 1
fi


# Attempt to get a token from Entra
echo "$(date) | Getting the Token"
token=$(curl -s -X POST "${headers[@]}" -d "$data" "$url" | sed -E 's/.*"access_token":"([^"]+)".*/\1/')

#Use the Token to download the photo
photoURL="https://graph.microsoft.com/beta/users/$UPN/photo/\$value"

headers2="Authorization: Bearer $token"
pathPhoto="/Users/$userName/$file"
echo "$(date) | getting the Photo [$file]"

curl -s --location --request GET "$photoURL" --header "${headers2[@]}" --output $pathPhoto


# Check if image was written to disk
if [ ! -f $pathPhoto ]; then

    echo "$(date) | Failed to write image to disk [$pathPhoto]]"
    exit 1

else

    echo "$(date) | Image written to disk [$pathPhoto]"
fi


# Set the user photo
echo "$(date) | Setting the user photo from [$pathPhoto]"
TF=$(mktemp)                                             
ER=0x0A                 # `0x0A` (Hex) = `10` (ASCII) = `LF`
EC=0x5C                 # `0x5C` (Hex) = `92` (ASCII) = `\`
FS=0x3A                 # `0x3A` (Hex) = `58` (ASCII) = `:`
VS=0x2C                 # `0x2C` (Hex) = `44` (ASCII) = `,`


# Write a record description (header line) to the import file
echo "$(date) | Write a record description (header line) to the import file"
echo "$ER $EC $FS $VS dsRecTypeStandard:Users 2 RecordName externalbinary:JPEGPhoto" > $TF


# Write the record to the import file
echo "$(date) | Write the record to the import file"
echo "$userName:$pathPhoto" >> $TF

# Delete the existing `JPEGPhoto` attribute for the user 
echo "$(date) | Delete the existing photo for [$userName]"
dscl . delete /Users/$userName JPEGPhoto

# Quit System Settings (previously System Preferences prior to macOS Ventura 13)
SETTINGS="System Settings"
if [[ $(system_profiler SPSoftwareDataType | awk '/System Version/ {print $4}' | cut -d . -f 1) -lt 13 ]]; then
    SETTINGS="System Preferences"
fi

killall "$SETTINGS" 2> /dev/null                        # Write STDERR to /dev/null to supress message if process isn't running

# Import the record updating the `JPEGPhoto` attribute for the user
echo "$(date) | Import new photo for [$userName]"
dsimport $TF /Local/Default M

# Clean up
rm $TF


