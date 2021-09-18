#!/bin/bash

#set -x

############################################################################################
##
## Script to rename a Mac based on device type and serial number
##
############################################################################################

## Copyright (c) 2021 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: paoloma@microsoft.com

## Define variables
appname="DeviceRename"
logandmetadir="/Library/Logs/Microsoft/Intune/Scripts/$appname"
log="$logandmetadir/$appname.log"

## Check if the log directory has been created
if [ -d $logandmetadir ]; then
    ## Already created
    echo "# $(date) | Log directory already exists - $logandmetadir"
else
    ## Creating Metadirectory
    echo "# $(date) | creating log directory - $logandmetadir"
    mkdir -p $logandmetadir
fi

# start logging
exec &> >(tee -a "$log")

# Begin Script Body
echo ""
echo "##############################################################"
echo "# $(date) | Starting $appname"
echo "############################################################"
echo "Writing log output to [$log]"
echo ""

echo " $(date) | Checking if renaming is necessary"

SerialNum=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}' | cut -d ':' -f2- | xargs)
if [ "$?" = "0" ]; then
  echo " $(date) | Serial detected as $SerialNum"
else
   echo "$(date) | Unable to determine serial number"
   exit 1
fi


CurrentNameCheck=$(scutil --get ComputerName)
if [ "$?" = "0" ]; then
  echo " $(date) | Current computername detected as $CurrentNameCheck"
else
   echo "$(date) | Unable to determine current name"
   exit 1
fi


echo " $(date) | Old Name: $CurrentNameCheck"
ModelName=$(system_profiler SPHardwareDataType | awk /'Model Name: '/ | cut -d ':' -f2- | xargs)
if [ "$?" = "0" ]; then
  echo " $(date) | Retrieved model name: $ModelName"
else
   echo "$(date) | Unable to determine modelname"
   exit 1
fi

## What is our public IP
echo " $(date) | Looking up public IP"
myip=$(dig +short myip.opendns.com @resolver1.opendns.com)
Country=$(curl -s https://ipapi.co/$myip/country)



echo " $(date) | Generating four characters code based on retrieved model name $ModelName"

case $ModelName in
  MacBook\ Air*) ModelCode=MBA;;
  MacBook\ Pro*) ModelCode=MBP;;
  MacBook*) ModelCode=MB;;
  iMac*) ModelCode=IMAC;;
  Mac\ Pro*) ModelCode=PRO;;
  Mac\ mini*) ModelCode=MINI;;
  *) ModelCode=$(echo $ModelName | tr -d ' ' | cut -c1-4);;
esac

echo " $(date) | ModelCode variable set to $ModelCode"
echo " $(date) | Retrieved serial number: $SerialNum"
echo " $(date) | Detected country as: $Country"
echo " $(date) | Building the new name..."
NewName=$ModelCode-$SerialNum-$Country

echo " $(date) | Generated Name: $NewName"


if [[ "$CurrentNameCheck" == "$NewName" ]]
  then
  echo " $(date) | Rename not required already set to [$CurrentNameCheck]"
  exit 0
fi

#Setting ComputerName
scutil --set ComputerName $NewName
if [ "$?" = "0" ]; then
   echo " $(date) | Computername changed from $CurrentNameCheck to $NewName"
else
   echo " $(date) | Failed to rename the device from $CurrentNameCheck to $NewName"
   exit 1
fi

#Setting HostName
scutil --set HostName $NewName
if [ "$?" = "0" ]; then
   echo " $(date) | HostName changed from $CurrentNameCheck to $NewName"
else
   echo " $(date) | Failed to rename the device from $CurrentNameCheck to $NewName"
   exit 1
fi

#Setting LocalHostName
scutil --set LocalHostName $NewName
if [ "$?" = "0" ]; then
   echo " $(date) | LocalHostName changed from $CurrentNameCheck to $NewName"
else
   echo " $(date) | Failed to rename the device from $CurrentNameCheck to $NewName"
   exit 1
fi