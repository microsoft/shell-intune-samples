#!/bin/zsh
#set -x
############################################################################################
##
## Script to disable SMB 1, NetBIOS and netbiosd name registration
##
############################################################################################

## Copyright (c) 2025 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: neiljohn@microsoft.com

# Define variables
appname="DisableSMB1NetBIOSAndNetbiosd"                                 # The name of our script
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/$appname"          # The location of our logs and last updated data
log="$logandmetadir/$appname.log"                                       # The location of the script log file
file="/etc/nsmb.conf"

# Check if the log directory has been created
if [ -d $logandmetadir ]; then
    # Already created
    echo "$(date) | Log directory already exists - $logandmetadir"
else
    # Creating Metadirectory
    echo "$(date) | creating log directory - $logandmetadir"
    mkdir -p $logandmetadir
fi

# Disable SMB 1 and NetBIOS
DisableSMB1NetBIOSAndNetbiosd() {
echo  "$(date) | Disabling SMB1 and NetBIOS..."
## Check if "/etc/nsmb.conf" existed
if [ -f "$file" ]; then
    echo "$(date) | $file exists. Let's proceed..."
    # Check if protocol_vers_map is set to a different number or missing
    ## Lock negotiation to SMB2/3 only
    ## 7 == 0111  SMB 1/2/3 should be enabled
    ## 6 == 0110  SMB 2/3 should be enabled
    ## 4 == 0100  SMB 3 should be enabled
    if grep -q "^protocol_vers_map=" "$file"; then
        current_value=$(grep -E "^protocol_vers_map=" "$file" | cut -d'=' -f2)
        if [ "$current_value" != "6" ]; then
            echo "$(date) | protocol_vers_map is set to $current_value. Changing it to 6..."
            sed -i '' 's/^protocol_vers_map=.*/protocol_vers_map=6/' "$file"
        else
            echo "$(date) | protocol_vers_map is already set to 6."
        fi
    else
        echo "$(date) | protocol_vers_map is missing. Adding it..."
        echo "protocol_vers_map=6" | tee -a "$file" > /dev/null
    fi
else
    ## Creates /etc/nsmb.conf if not existed
    echo "$(date) | $file does not exist. Creating file..."
    echo "[default]" | tee -a $file > /dev/null
    ## Lock negotiation to SMB2/3 only
    ## 7 == 0111  SMB 1/2/3 should be enabled
    ## 6 == 0110  SMB 2/3 should be enabled
    ## 4 == 0100  SMB 3 should be enabled
    echo "protocol_vers_map=6" | tee -a $file > /dev/null
    ## No SMB1, so we disable NetBIOS
    echo "port445=no_netbios" | tee -a /etc/nsmb.conf > /dev/null
fi

## Disable netbiosd name registration
launchctl disable system/netbiosd 2> /dev/null
launchctl unload -w /System/Library/LaunchDaemons/com.apple.netbiosd.plist 2> /dev/null
echo  "$(date) | SMB1, NetBIOS and netbiosd is disabled or already disabled. Closing script..." 
}

# Start logging
exec &> >(tee -a "$log")

# Begin Script Body
echo ""
echo "##############################################################"
echo "# $(date) | Starting running of script $appname"
echo "############################################################"
echo ""

# Run function
DisableSMB1NetBIOSAndNetbiosd