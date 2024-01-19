#!/bin/zsh
#set -x

############################################################################################
##
## Script to make sure Gatekeeper will be kept as enabled
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
gatekeeper=$(spctl --status)
appname="GatekeeperEnabler"
notcompliance="assessments disabled"
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/$appname"
log="$logandmetadir/$appname.log"

## Check if the log directory has been created
if [ -d $logandmetadir ]; then
    ## Already created
    echo "$(date) | Log directory already exists - $logandmetadir"
else
    ## Creating Metadirectory
    echo "$(date) | creating log directory - $logandmetadir"
    mkdir -p $logandmetadir
fi

# Function that checks if Gatekeeper is enabled or disabled. If it is disabled, it will be re-enabled back.

enableGatekeeper () {
echo  "$(date) | Checking status of Gatekeeper..."
if [[ "$gatekeeper" == "$notcompliance" ]]; then
    echo  "$(date) | Gatekeeper is not enabled. Re-enabling it..."
    spctl --master-enable
    echo  "$(date) | Gatekeeper is re-enabled. Closing script..."
else
    echo "$(date) | Gatekeeper is already enabled. Closing script..."
fi
}

# start logging
exec &> >(tee -a "$log")

# Begin Script Body
echo ""
echo "##############################################################"
echo "# $(date) | Starting running of script $appname"
echo "############################################################"
echo ""

# Run function
enableGatekeeper