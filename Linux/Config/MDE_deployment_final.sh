#!/bin/bash

#############################################################################################################################
################### CUSTOM INPUT VARIABLES
#############################################################################################################################

# Set this variable to the distribution type for MDE deployment.
DISTRIBUTION=ubuntu

# Set this variable to the version for MDE deployment. 
VERSION=20.04

# Set this variable to the channel for MDE deployment. 
CHANNEL=prod

#############################################################################################################################
################### CHECK FOR PROPER VARIABLE STATUS 
#############################################################################################################################

# DISTRIBUTION
if [[ -z $DISTRIBUTION || ($DISTRIBUTION != "ubuntu" && $DISTRIBUTION != "debian") ]]; then
    echo "The WIFI name has not been updated. Please correct."
    exit 1
fi

# VERSION
if [[ $VERSION != "4.10" && $VERSION != "5.04" && $VERSION != "5.10" && $VERSION != "6.06" && $VERSION != "6.10" && $VERSION != "7.04" && $VERSION != "7.10" && $VERSION != "8.04" && $VERSION != "8.10" && $VERSION != "9.04" && $VERSION != "9.10" && $VERSION != "10.04" && $VERSION != "10.10" && $VERSION != "11.04" && $VERSION != "11.10" && $VERSION != "12.04" && $VERSION != "12.10" && $VERSION != "13.04" && $VERSION != "13.10" && $VERSION != "14.04" && $VERSION != "14.10" && $VERSION != "15.04" && $VERSION != "15.10" && $VERSION != "16.04" && $VERSION != "16.10" && $VERSION != "17.04" && $VERSION != "17.10" && $VERSION != "18.04" && $VERSION != "18.10" && $VERSION != "19.04" && $VERSION != "19.10" && $VERSION != "20.04" && $VERSION != "20.10" && $VERSION != "21.04" && $VERSION != "21.10" && $VERSION != "22.04" ]]; then
    echo "The system version does not match. Please correct."
    exit 1
fi

# CHANNEL
if [[ $CHANNEL != "prod" && $CHANNEL != "insiders-fast" && $CHANNEL != "insiders-slow" ]]; then
    echo "The channel name has not been updated or has been set to something other than the allowed values (prod, insiders-fast, insiders-slow). Please correct."
    exit 1
fi  

#############################################################################################################################
################### SCRIPT 
#############################################################################################################################

# Recommended that this script be run using root privileges: 
echo "It is recommended that this script is run with root privileges. Please type the following or contact your administration: sudo -s"


# Start of a bash "try-catch loop" that will safely exit the script if a command fails or causes an error. 
(
    # Set the error status
    set -e     

    # First step for Ubuntu systems is to make sure curl and libplist-utils are both installed
    apt-get install curl 
    apt-get update
    apt-get install libplist-utils

    # Need to identify the distribution and version for the MDE trying to be deployed. 
        # replace versoin and distro with the information for the user/system in question. 
        # channels are either prod, insiders-fast and insiders-slow

        curl -o microsoft.list https://packages.microsoft.com/config/$DISTRIBUTION/$VERSION/$CHANNEL.list

    # Install the repo config
    mv ./microsoft.list /etc/apt/sources.list.d/microsoft-$CHANNEL.list

    # Install either gpg or gnupg if gpg is unavailable
    apt-get install gpg
        # apt-get install gnupg

    # Install the MSFT GPG public key
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -

        # Install HTTPS driver if needed
        apt-get install apt-transport-https

    # Update repo metadata
    apt-get update

    # Install the actual application
    apt-get install mdatp

    # Download the onboarding package script and save it was WindowsDefenderATPOnboarindPackage.zip -- This has to be done otherwise the product will be unlicensed.
        # NOTE: for scripting purposes, how can this be streamlined?
        # File at MSFT 465 Defender portal --> Settings--> Endpoints--> Device Management--> Onboarding
        # Linux Server as operating system, Local script as deployment method. 
        unzip WindowsDefenderATPOnboardingPackage.zip

    # Client Config
    mdatp health --field org_id
        
        # Run MicrosoftDefenderATPOnboardingLinuxServer.py
            # For Ubuntu 20.04 or higher, use python3. For other versions, use python. 

        if [[ $VERSION -lt 20.04 ]]; then
            python MicrosoftDefenderATPOnboardingLinuxServer.py
        else
            python3 MicrosoftDefenderATPOnboardingLinuxServer.py
        fi

        # Verifying association
        mdatp health --field org_id

        # Other health and status verifications (might not be needed)
            mdatp health --field healthy
            mdatp config real-time-protection_enabled | mdatp config real-time-protection --value enabled

            # This file should be quarantined by defender.
            curl -o /tmp/eicar.com.txt https://www.eicar.org/download/eicar.com.txt
            mdatp threat list

    # Alternatively, you can use this script which combines installation and onboarding. 
        curl https://raw.githubusercontent.com/microsoft/mdatp-xplat/master/linux/installation/mde_installer.sh -o mde_installer.sh

            # It is possible it will lock permissions - this sets permissions to read, write, and execute.
            chmod +777 ./mde_installer.sh
        ./mde_installer.sh -i -o -c $CHANNEL
)

ERROR_CODE=$?
if [ $ERROR_CODE -ne 0 ]; then
    echo "There was an error. Please restart the script or contact your admin if the error persists."
    exit $ERROR_CODE
fi

# Final output message - to be configured TBD
echo "The script is finished running. The result will be sent in the necessary format."