#!/bin/bash
#set -x

############################################################################################
##
## This script checks if there is sufficient diskspace on the device. 
##
## The variable "MIN_SPACE_REQUIRED" can be customized to be a value greater than what is required for intune compliance (in an effort to make the script more universal). 
## For now, it will be set to the compliance requirement for intune. 
##
## If using only for intune purposes, there must be more than 10485760 KB (10.4GB) of space available in order to be compliant. 
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

# Set this variable to the minimum diskspace requirement. 
# Intune's requirement: 10485760KB = 10G = 10*1024*1024k
MIN_SPACE_REQUIRED=10485760

################################################################################
## SCRIPT 
##########################################################################

# This variable determines the about of free diskspace remaining on the device. 
FREE=`df -k --output=avail "$PWD" | tail -n1`   # df -k not df -h

# Start of a bash "try-catch loop" that will safely exit the script if a command fails or causes an error. 
(
    # Set the error status
    set -e     
    
    if [[ $FREE < $MIN_SPACE_REQUIRED ]]; then               
        echo "{"Adequate_Disk_Space", "False"}"
    else
        echo "{"Adequate_Disk_Space", "True"}"
    fi

)

# Catch any necessary errors to prevent the program from improperly exiting. 
ERROR_CODE=$?
if [ $ERROR_CODE -ne 0 ]; then
    echo "There was an error. Please restart the script or contact your admin if the error persists."
    exit $ERROR_CODE
fi

# The script has finished checking if there is the desired amount of diskspace available. 