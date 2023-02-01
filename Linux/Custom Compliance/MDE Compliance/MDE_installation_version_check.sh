#!/bin/bash
#set -x

############################################################################################
##
## This script checks if MDE is installed, if MDE is licensed properly on a given device, and what version of MDE the device is running
## Given the variable intenstive nature of the script, there are no custom input variables. 
## The installation status, license status, and version are instead set via the script itself. 
##
####################################################################################

## Copyright (c) 2020 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: neiljohn@microsoft.com

# Variables

# The first variable of interest is whether or not MDE is installed on the device. 
# If MDE is installed on the device (regardless of if it is licensed or not), the command "mdatp" will bring up the Microsoft Defender options menu
# If not, the script will not find the phrase "Microsoft Defender."

    if ( mdatp | grep "Microsoft Defender" ); then 
        INSTALLED=True
    else
        INSTALLED=False
    fi

# If MDE is installed, the script then checks to see what its version is and if MDE is properly onboarded.
if [ "$INSTALLED" == "True" ]; then
    # This sets the licensed variable equal to MDE license status. 
    # If the device is properly onboarded, LICENSED!=false
    LICENSED=$(mdatp health --field licensed | grep "false")
    if ( "$LICENSED" != "false" ); then
        LICENSED=true
        VERSION=$(mdatp version | cut -c 18- )
    else
        VERSION=$(mdatp version | sed '1d' | cut -c 18- )
    fi
fi

#############################################################################################################################
################### CHECK FOR PROPER VARIABLE STATUS 
#############################################################################################################################

# INSTALLED
if [[ -z $INSTALLED ]]; then
    eecho "MDE installation status has not been set correctly. Please restart the script or contact admin."
    exit 1
fi

# LICENSED
if [[ -z $LICENSED ]]; then
    echo "MDE license status has not been set correctly. Please restart the script or contact admin."
    exit 1
fi

# VERSION
if ! [[ $VERSION =~ ^[0-9]+$ || $VERSION =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    echo "MDE version has not been set correctly. Please restart the script or contact admin."
    exit 1
fi


#############################################################################################################################
################### SCRIPT 
#############################################################################################################################

# Start of a bash "try-catch loop" that will safely exit the script if a command fails or causes an error. 
(
    # Set the error status
    set -e     
    
    # Determine the status of each variable and report each as a key-value pair. 
    
    # If MDE is installed on the device, check license status and version. 
    if [ "$INSTALLED" == "True" ]; then
        # If MDE is installed on the device, check license status and version. 
        if [ "$LICENSED" == "true" ]; then
            # If MDE is installed and licensed, check version installed. 
            # Check with someone to figure out which version is considered minimal to be compliant.

            # If MDE version is at least ____, then all variables are true.
            if [[ $VERSION -gt 00.00 ]]; then
                echo "[{"MDE_installed": "True"}, {"MDE_licensed": "True"}, {"MDE_version": "True"}]"
            else
                # If not, MDE version is false but license and installation are true. 
                echo "[{"MDE_installed": "True"}, {"MDE_licensed": "True"}, {"MDE_version": "False"}]"
            fi
        # If MDE is not licenesd, check version installed. 
        else
            # If MDE version is at least ____, then installation and version are true and license is false. 
            if [[ $VERSION -gt 00.00 ]]; then
                echo "[{"MDE_installed": "True"}, {"MDE_licensed": "False"}, {"MDE_version": "True"}]"
            else
                # If not, version and license are false and installation is true. 
                echo "[{"MDE_installed": "True"}, {"MDE_licensed": "False"}, {"MDE_version": "False"}]"
            fi
        fi
    # If MDE is not installed on the device, all variables are false. 
    else
        echo "[{"MDE_installed": "False"}, {"MDE_licensed": "False"}, {"MDE_version": "False"}]"
    fi

)

# Catch any necessary errors to prevent the program from improperly exiting. 
ERROR_CODE=$?
if [ $ERROR_CODE -ne 0 ]; then
    echo "There was an error. Please restart the script or contact your admin if the error persists."
    exit $ERROR_CODE
fi

# The script has finished checking if MDE is installed, if MDE is licensed properly on a given device, and what version of MDE the device is running
