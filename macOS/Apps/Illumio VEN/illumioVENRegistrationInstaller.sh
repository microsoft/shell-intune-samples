#!/bin/bash
#set -x


############################################################################################
##
## Illumio VEN Registration Installer
##
###########################################

## Copyright (c) 2023 Microsoft Corp. All rights reserved.
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
## This script will install Illumio VEN Registration to Mac-devices that already have Illumio VEN installed.
##

# User Defined variables
appname="IllumioVENRegistrationInstaller"                                                           # The name of our App deployment script (also used for Octory monitor)
app="Illumio-ven-ctl"                                                                               # The actual name of our App once installed
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/$appname"                                      # The location of our logs and last updated data
processpath="/opt/Illumio_ven/Illumio-ven-ctl"                                                      # The process name of the App we are installing
apppath="/opt/Illumio_ven/Illumio-ven-ctl"                                                          # The location of the app
abmcheck=true                                                                                       # Apply this registration only if this device is ABM managed.
activationcode=000000000000000000000000000000000000000000000000000000000000000000000000000000000    # Illumio activation code from pairing script
managementserver=eu-scp13.illum.io:443                                                              # Management server url from pairing script
profileid=000000000000000000                                                                        # Profile ID for pairing script

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

# Checks if Illumio VEN is installed. If yes, we can proceed. Otherwise, we will close this script
function checkIllumioVENInstallation() {
if test -f "$apppath"; then
    echo "$(date) | Illumio VEN is installed. Let's continue..."
else
    echo "$(date) | Illumio VEN is not installed. We cannot apply Registration. Closing script..."
    exit 1
fi
}

# Function that apply Illumio VEN Registration.
function IllumioVENRegistration () {
echo  "$(date) | Applying Illumio VEN Registration..."
rm -fr /opt/illumio_ven_data/tmp && umask 026 && mkdir -p /opt/illumio_ven_data/tmp && curl --tlsv1 "https://$managementserver/api/v25/software/ven/image?pair_script=pair.sh&profile_id=$profileid" -o /opt/illumio_ven_data/tmp/pair.sh && chmod +x /opt/illumio_ven_data/tmp/pair.sh && /opt/illumio_ven_data/tmp/pair.sh --management-server $managementserver --activation-code $activationcode
echo "$(date) | Illumio VEN Registration applied. Closing script..."
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

# Is this a ABM DEP device?
if [ "$abmcheck" = true ]; then
  echo "$(date) | Checking MDM Profile Type"
  profiles status -type enrollment | grep "Enrolled via DEP: Yes"
  if [[ ! $? == 0 ]]; then
    echo "$(date) | This device is not ABM managed"
    exit 0;
  else
    echo "$(date) | Device is ABM Managed"
  fi
fi

# Checks if Illumio VEN is installed
checkIllumioVENInstallation

# Apply Illumio VEN Registration
IllumioVENRegistration
