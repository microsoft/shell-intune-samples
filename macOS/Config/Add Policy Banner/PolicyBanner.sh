#!/bin/bash
#set -x

############################################################################################
##
## Script to set the Policy Banner
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
## Feedback: ckunze@microsoft.com

# Define variables
appname="PolicyBanner"
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/$appname"
log="$logandmetadir/$appname.log"
PolicyBannerFile="/Library/Security/PolicyBanner.txt"

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

# remove the file if it exists
rm -f $PolicyBannerFile  

# create the file with the banner text
echo "$(date) | Creating the Policy Banner file stating:"
echo "This is the Policy Banner for the Mac. By logging in you agree to the terms and conditions of the UEMCATLABS. If you do not agree, please log out now." | tee $PolicyBannerFile 
sleep 5s

# Check if file was created successfully
if [ -f $PolicyBannerFile ]; then
    # creation succeeded
    echo "$(date) | Policy Banner file created successfully"

    # set the permissions on the file
    chmod o+r /Library/Security/PolicyBanner.txt
    echo "$(date) | Permissions set on Policy Banner file"
  
else
    # creation failed
    echo "$(date) | Policy Banner file creation failed"
fi


