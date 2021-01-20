#!/bin/bash

#set -x

############################################################################################
##
## Script to rename a Mac device based on device type and serial number
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
logandmetadir="/Library/Intune/Scripts/installMinecraftEducationEdition"
log="$logandmetadir/rename-mac.log"

appname="Rename a Mac device based on model type and serial number"

# start logging
exec 1>> $log 2>&1

# Begin Script Body
echo ""
echo "##############################################################"
echo "# $(date) | Starting $appname"
echo "############################################################"
echo ""

echo " $(date) | Checking if renaming is necessary"

SerialCheck=$(system_profiler SPHardwareDataType | awk /'Serial Number \(system\):'/ | cut -c34-40)
CurrentNameCheck=$(scutil --get ComputerName)

if [[ "$CurrentNameCheck" == *"$SerialCheck"* ]]
  then
  echo "# $(date) | rename not necessary as the Mac name already includes the serial number. Exiting..."
  exit 0
fi

echo " $(date) | Old Name: $CurrentNameCheck"
ModelName=$(system_profiler SPHardwareDataType | awk /'Model Name: '/ | cut -c19- )

echo " $(date) | Retrieved model name: $ModelName"
echo " $(date) | Generating four characters code based on retrieved model name $ModelName"

case $ModelName in
  MacBook\ Air*) ModelCode=MABA;;
  MacBook\ Pro*) ModelCode=MABP;;
  MacBook*) ModelCode=MACB;;
  iMac*) ModelCode=IMAC;;
  Mac\ Pro*) ModelCode=MACP;;
  Mac\ mini*) ModelCode=MINI;;
  *) ModelCode=$(echo $ModelName | cut -c1-4);;
esac
echo " $(date) | ModelCode variable set to $ModelCode"

SerialNum=$(system_profiler SPHardwareDataType | awk /'Serial Number \(system\):'/ | cut -c31-40)
echo " $(date) | Retrieved serial number: $SerialNum"

#Adjust the serial number length to shorten it to adjust for the designation length
DesignationLength="$((${#Designation} + 1))"
SerialNum=$(echo $SerialNum | cut -c$DesignationLength-)
echo " $(date) | Adjusted serial number: $SerialNum"

echo " $(date) | Building the new name..."
NewName=$ModelCode
NewName+=$SerialNum
echo " $(date) | Generated Name: $NewName"

#Name Computer
scutil --set ComputerName $NewName
scutil --set HostName $NewName
scutil --set LocalHostName $NewName

if [ "$?" = "0" ]; then
   echo "Device renamed from $CurrentNameCheck to $NewName"
   exit 0
else
   echo "$(date) | Failed to rename the device from $CurrentNameCheck to $NewName"
   exit 1
fi
