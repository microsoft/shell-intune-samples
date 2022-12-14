#!/bin/bash

#############################################################################################################################
################### CUSTOM INPUT VARIABLES
#############################################################################################################################

# Set this variable to the channel for MDE deployment. 
CHANNEL=prod

#############################################################################################################################
################### CHECK FOR PROPER VARIABLE STATUS 
#############################################################################################################################

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

    # This script combines installation and onboarding. 
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