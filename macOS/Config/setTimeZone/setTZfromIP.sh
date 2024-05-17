#!/bin/bash
#set -x

############################################################################################
##
## Script to guess timezone based on public IP address and then set the timezone of the Mac
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

## Define variables
log="/var/log/setTimezone.log"
appname="Set Timezone"
exec > >(tee -a "$log") 2>&1

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


        echo "$(date) | Updating Swift Dialog monitor for [$appname] to [$1]"
        echo listitem: title: $appname, status: $1, statustext: $2 >> /var/tmp/dialog.log 

        # Supported status: wait, success, fail, error, pending or progress:xx

    fi

}

echo ""
echo "##############################################################"
echo "# $(date) | Beginning $appname"
echo "############################################################"
echo ""

## What is our public IP
echo "$(date) | Looking up public IP"
myip=$(dig +short myip.opendns.com @resolver1.opendns.com)
if [ "$?" = "0" ]; then
  echo "$(date) | Public IP is $myip"
else
   echo "$(date) | Unable to determine public IP address"
   updateSplashScreen fail "Unable to determine public IP address"
   exit 1
fi

## What is our TZ
## Note: See https://ipapi.co/api/ for documentation on this api

max_attempts=20
for ((attempt=1; attempt<=max_attempts; attempt++)); do
    # Run the curl command and store the output in a variable
    echo "$(date) | Looking up TZ from IPAPI"
    tz=$(curl -s 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36 Edg/116.0.1938.69' "https://ipapi.co/$myip/timezone")
    updateSplashScreen wait "Looking up TZ..."

    # Check if the response contains 'error'
    if [[ "$tz" != *"error"* ]]; then
        echo "$(date) | Timezone detected as $tz"
        updateSplashScreen wait "Timezone detected as $tz"

        break
    else
        echo "$(date) | IPAPI returned an error. Attempt $attempt of $max_attempts"
        updateSplashScreen wait "Retrying $attempt of $max_attempts"
        # Add a sleep to wait before the next attempt (optional)
        sleep 5
    fi
done

#
# Ok, we know the timezone, let's set it
#

currentTZ=$(sudo systemsetup -gettimezone | awk '{print $3}' | xargs)

if [ "$tz" = "$currentTZ" ]; then
    echo "$(date) | TimeZone is already set to $tz"
    updateSplashScreen success "TimeZone is already set to $tz"
else
    echo "$(date) | TimeZone is currently set to $currentTZ. Setting to $tz"
    sudo systemsetup -settimezone $tz
    $currentTZ=$(sudo systemsetup -gettimezone | awk '{print $3}' | xargs)
    if [ "$tz" != "$currentTZ" ]; then

      echo "$(date) | Failed to change $currentTZ to $tz"
      updateSplashScreen fail "Failed to change $currentTZ to $tz"

    fi
fi
