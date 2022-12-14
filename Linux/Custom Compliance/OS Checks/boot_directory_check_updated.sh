#!/bin/bash
#set -x

############################################################################################
##
## This script checks if there is a boot directory present on the device. 
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

# Set this variable to the boot directory on the device if it is named something different than "/boot"
CUSTOM_BOOT_DIR_NAME=/example_boot

################################################################################
## SCRIPT 
##########################################################################

# Start of a bash "try-catch loop" that will safely exit the script if a command fails or causes an error. 
(
    # Set the error status
    set -e     
    
    if [[ -d "/boot" || -d $CUSTOM_BOOT_DIR_NAME ]]; then 
        echo "{"Boot_Directory_Exists", "True"}"
    else
        echo "{"Boot_Directory_Exists", "False"}"
    fi

)

# Catch any necessary errors to prevent the program from improperly exiting. 
ERROR_CODE=$?
if [ $ERROR_CODE -ne 0 ]; then
    echo "There was an error. Please restart the script or contact your admin if the error persists."
    exit $ERROR_CODE
fi

# The script has finished checking for a boot directory