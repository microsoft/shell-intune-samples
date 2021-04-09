#!/usr/bin/env bash
#set -x

############################################################################################
##
## Script to downgrade all users to Standard Users
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
## This script can set all existing Admin accounts to be standard user accounts. The account specified in adminaccountname will not be downgraded if it is found
##
## WARNING: This script could leave your Mac will no Admin accounts configured at all

# Define variables

scriptname="Downgrade Admin Users to Standard"
log="/var/log/downgradeadminusers.log"
abmcheck=true   # Only downgrade users if this device is ABM managed
downgrade=true  # If set to false, script will not do anything
logandmetadir="/Library/Intune/Scripts/downgradeAdminUsers"
log="$logandmetadir/downgradeAdminUsers.log"

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

# Is this a ABM DEP device?
if [ "$abmcheck" = true ]; then
  downgrade=false
  echo "Checking MDM Profile Type"
  profiles status -type enrollment | grep "Enrolled via DEP: Yes"
  if [ ! $? == 0 ]; then
    echo "This device is not ABM managed"
    exit 0;
  else
    echo "Device is ABM Managed"
    downgrade=true
  fi
fi

if [ $downgrade = true ]; then
  while read useraccount; do
    if [ "$useraccount" == "localadmin" ]; then
        echo "Leaving localadmin account as Admin"
    else
        echo "Making $useraccount a normal user"
        #/usr/sbin/dseditgroup -o edit -d $useraccount -t user admin
    fi
  done < <(dscl . list /Users UniqueID | awk '$2 >= 501 {print $1}')
fi
