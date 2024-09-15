#!/bin/zsh
#set -x
############################################################################################
##
## Script to disable creation of ".DS_Store" -files on network shares and removable drives
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

# Define variables
appname="DisableCreationOfDS_StoreFilesOnNetworkSharesAndRemovableDrives"                                   # The name of our script
logandmetadir="$HOME/Library/Logs/Microsoft/IntuneScripts/$appname"                                         # The location of our logs and last updated data
log="$logandmetadir/$appname.log"                                                                           # The location of the script log file
statusnetworkshares=$(defaults read com.apple.desktopservices DSDontWriteNetworkStores)                     # Current status of creation of ".DS_Store" -files on network shares
statusremovabledrives=$(defaults read com.apple.desktopservices DSDontWriteUSBStores)                       # Current status of creation of ".DS_Store" -files on removable drives

# Check if the log directory has been created
if [ -d $logandmetadir ]; then
    # Already created
    echo "$(date) | Log directory already exists - $logandmetadir"
else
    # Creating Metadirectory
    echo "$(date) | creating log directory - $logandmetadir"
    mkdir -p $logandmetadir
fi

# Disable creation of ".DS_Store" -files on network shares
DisableDS_StoreFilesOnNetworkShares() {
echo "$(date) | Checking if creation of '.DS_Store' -files have been disabled on network shares for user $USER..."
if [[ "$statusnetworkshares" == "0" ]]; then
    echo  "$(date) | Creation of '.DS_Store' -files have been enabled on network shares for user $USER. Disabling it..."
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE
    echo  "$(date) | Creation of '.DS_Store' -files have been disabled on network shares for user $USER. Let's continue..."
else
    echo "$(date) | Creation of '.DS_Store' -files have been already disabled on network shares for user $USER. Let's continue..."
fi
}

# Disable creation of ".DS_Store" -files on removable drives
DisableDS_StoreFilesOnRemovableDrives() {
echo "$(date) | Checking if creation of '.DS_Store' -files have been disabled on removable drives for user $USER..."
if [[ "$statusremovabledrives" == "0" ]]; then
    echo  "$(date) | Creation of '.DS_Store' -files have been enabled on removable drives for user $USER. Disabling it..."
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool TRUE
    echo  "$(date) | Creation of '.DS_Store' -files have been disabled on removable drives for user $USER. All done! Any changes made will take effect the next time you log in to your Mac-device. Closing script..."
    exit 0
else
    echo "$(date) | Creation of '.DS_Store' -files have been already disabled on removable drives for user $USER. All done! Any changes made will take effect the next time you log in to your Mac-device. Closing script..."
    exit 0
fi
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
DisableDS_StoreFilesOnNetworkShares
DisableDS_StoreFilesOnRemovableDrives