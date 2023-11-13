#!/bin/zsh
#set -x


############################################################################################
##
## Qualys Subscription Installer
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
## This script will install Qualys Subscription to Mac-device that already have Qualys installed.
##

# User Defined variables
appname="QualysSubscriptionInstaller"                                                              			# The name of our App deployment script (also used for Octory monitor)
app="QualysCloudAgent.app"                                                                                  # The actual name of our App once installed
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/$appname"                                              # The location of our logs and last updated data
processpath="/Applications/QualysCloudAgent.app/Contents/MacOS/$appname"                                    # The process name of the App we are installing
apppath="/Applications/QualysCloudAgent.app"                                                                # The location of the app
activationid="1234567a-b89c-0d1e-234f-ghi56789012j"                                                         # Activation ID for Qualys
customerid="1234567a-b89c-0d1e-234f-ghi56789012j"															# Customer ID for Qualys
subscriptiondetectionfile="/Library/Application Support/QualysCloudAgent/Subscription.txt"        	        # Subscription detection file to mark device that subscription is already applied
# Generated variables
tempdir=$(mktemp -d)
log="$logandmetadir/$appname.log"                                                                           # The location of the script log file
metafile="$logandmetadir/$appname.meta"                                                                     # The location of our meta file (for updates)

function startLog() {

    ###################################################
    ###################################################
    ##
    ##  start logging - Output to log file and STDOUT
    ##
    ####################
    ####################

    if [[ ! -d "$logandmetadir" ]]; then
        ## Creating Metadirectory
        echo "$(date) | Creating [$logandmetadir] to store logs"
        mkdir -p "$logandmetadir"
    fi

    exec > >(tee -a "$log") 2>&1

}

# Checks if Qualys is installed. If yes, we can proceed. Otherwise, we will close this script
function checkQualysInstallation() {
if test -d "$apppath"; then
    echo "$(date) | Qualys is installed. Let's continue..."
else
    echo "$(date) | Qualys is not installed. We cannot apply subscription. Closing script..."
    exit 1
fi
}

# Checks if Qualys Subscription is already applied. If no, we can proceed. Otherwise, we will close this script
function checkSubscription() {
if test -f "$subscriptiondetectionfile"; then
    echo "$(date) | Qualys subscription is already installed. Closing script..."
    exit 0
else
    echo "$(date) | Qualys subscription is not applied. Let's apply subscription..."
fi    
}

# Function that apply Qualys subscription.
function qualysSubscription () {
cd
echo  "$(date) | Applying Qualys subscription..."
/Applications/QualysCloudAgent.app/Contents/MacOS/qualys-cloud-agent.sh ActivationId=$activationid CustomerId=$customerid
echo  "$(date) | Qualys subscription applied. Creating subscription detection file..."
echo "Qualys Subscription is already applied to this device." > $subscriptiondetectionfile
echo "$(date) | Done. Closing script..."
exit 0
}

###################################################################################
###################################################################################
##
## Begin Script Body
##
#####################################
#####################################

# Initiate logging
startLog

echo ""
echo "##############################################################"
echo "# $(date) | Logging install of [$appname] to [$log]"
echo "############################################################"
echo ""

# Checks if Qualys is installed
checkQualysInstallation

# Checks if Qualys Subscription is already applied
checkSubscription

# Apply Qualys Subscription
qualysSubscription