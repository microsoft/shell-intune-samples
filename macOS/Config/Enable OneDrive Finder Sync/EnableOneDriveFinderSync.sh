#!/bin/bash
#set -x
############################################################################################
##
## Script to enable the Finder Extension for OneDrive
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
## Feedback: neiljohn@microsoft.com

appname="EnableOneDriveFinderSync"
logandmetadir="$HOME/Library/Logs/Microsoft/IntuneScripts/$appname"
log="$logandmetadir/$appname.log"
application="/Applications/OneDrive.app"


# Check if the log directory has been created
if [ -d $logandmetadir ]; then
    # Already created
    echo "$(date) | Log directory already exists - $logandmetadir"
else
    # Creating Metadirectory
    echo "$(date) | creating log directory - $logandmetadir"
    mkdir -p $logandmetadir
fi


# Start logging
exec &> >(tee -a "$log")

# Begin Script Body
echo ""
echo "##############################################################"
echo "# $(date) | Starting running of script $appname"
echo "############################################################"
echo ""

echo "$(date) | OneDrive config: Looking for required applications... "

# Wait for OneDrive to be installed
while [[ $ready -ne 1 ]];do

    if [[ -a "$application" ]]; then
        ready=1
        echo "$(date) | $application found!"
    else
        echo "$(date) | OneDrive config: $i not installed yet"  
        echo "$(date) | OneDrive config: Waiting for 60 seconds" 
        sleep 60
    fi

done

# Get Extension Name (differs between standalone and VPP version)
echo "$(date) | Finding installed OneDrive type (VPP or standalone)" 
if pluginkit -m | grep "com.microsoft.OneDrive-mac.FinderSync"; then
    echo "$(date) | OneDrive installed via VPP. Extension name is com.microsoft.OneDrive-mac.FinderSync" 
    extensionname="com.microsoft.OneDrive-mac.FinderSync"
fi

if pluginkit -m | grep "com.microsoft.OneDrive.FinderSync"; then
    echo "$(date) | OneDrive installed standalone. Extension name is com.microsoft.OneDrive.FinderSync" 
    extensionname="com.microsoft.OneDrive.FinderSync"
fi

# Check if the extension is already enabled and enable it
echo "$(date) | Checking extension status" 
if pluginkit -m | grep "+    $extensionname"; then
    echo "$(date) | OneDrive FinderSync already enabled" 
else
    echo "$(date) | OneDrive config: Enabling FinderSync" 
    echo "$(date) | running pluginkit -e use -i $extensionname"

    pluginkit -e use -i $extensionname

    echo "$(date) | Script finished"
fi
