#!/bin/bash

#set -x

############################################################################################
##
## Script to rename a Mac based on Country Code and Serial Number
##
############################################################################################

## Copyright (c) 2024 Microsoft Corp. All rights reserved.
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
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/$appname"
log="$logandmetadir/$appname.log"
CountryCode="FI"
UAMDMStatus=$(profiles status -type enrollment | grep "Enrolled via DEP: No")

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

## Check if device is not enrolled to Apple Business Manager (ABM). If so, we will terminate this script immediately. Otherwise, we will continue.

echo " $(date) | Checking if this macOS-device is enrolled by ABM or not..."
if [ "$UAMDMStatus" == "Enrolled via DEP: No" ]; then
   echo " $(date) | This device is not enrolled by ABM, device name will not be changed."
   exit 0
else
   echo " $(date) | This device is enrolled by ABM"
fi

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

echo " $(date) | Retrieved serial number: $SerialNum"
echo " $(date) | Detected country as: $CountryCode"
echo " $(date) | Building the new name..."
NewName=$CountryCode-$SerialNum

echo " $(date) | Generated Name: $NewName"

if [[ "$CurrentNameCheck" == "$NewName" ]]
  then
  echo " $(date) | Rename not required already set to [$CurrentNameCheck]"
  exit 0
fi

# Setting ComputerName
scutil --set ComputerName $NewName
if [ "$?" = "0" ]; then
   echo " $(date) | Computername changed from $CurrentNameCheck to $NewName"
else
   echo " $(date) | Failed to rename the device from $CurrentNameCheck to $NewName"
   exit 1
fi

# Setting HostName
scutil --set HostName $NewName
if [ "$?" = "0" ]; then
   echo " $(date) | HostName changed from $CurrentNameCheck to $NewName"
else
   echo " $(date) | Failed to rename the device from $CurrentNameCheck to $NewName"
   exit 1
fi

# Setting LocalHostName
scutil --set LocalHostName $NewName
if [ "$?" = "0" ]; then
   echo " $(date) | LocalHostName changed from $CurrentNameCheck to $NewName"
else
   echo " $(date) | Failed to rename the device from $CurrentNameCheck to $NewName"
   exit 1
fi