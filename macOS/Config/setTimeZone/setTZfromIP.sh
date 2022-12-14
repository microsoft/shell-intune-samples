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
appname="Guess Timezone based on IP"
exec 1>> $log 2>&1

echo ""
echo "##############################################################"
echo "# $(date) | Beginning $appname"
echo "############################################################"
echo ""

## What is our public IP
echo "# $(date) | Looking up public IP"
myip=$(dig +short myip.opendns.com @resolver1.opendns.com)
if [ "$?" = "0" ]; then
  echo "# $(date) | Public IP is $myip"
else
   echo "$(date) | Unable to determine public IP address"
   exit 1
fi

## What is our TZ
## Note: See https://ipapi.co/api/ for documentation on this api

tz=$(curl https://ipapi.co/$myip/timezone)
if [ "$?" = "0" ]; then
  echo "# $(date) | Timezone returned as $tz"
else
   echo "$(date) | Unable to determine timezone"
   exit 2
fi

## Let's try and set the TZ
sudo systemsetup -settimezone $tz
if [ "$?" = "0" ]; then
  echo "# $(date) | Timezone set as $tz"
else
   echo "$(date) | Failed to set timezone to $tz"
   exit 3
fi
