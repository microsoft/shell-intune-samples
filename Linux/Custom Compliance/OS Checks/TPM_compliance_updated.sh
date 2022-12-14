#!/bin/bash
#set -x

############################################################################################
##
## This script checks whether or not Trusted Platform Module (TPM) is enabled on the given device. 
## TPM:
## Not configured (default): intune does not check, by default, the device for a TPM chip version. Requirement: intune checks the TPM device for compliance by determinig if the TPM chip version is greater than zero. If not,the device is considered non compliant.
## TPM must be enabled in order to be properly compatible with BitLocker and other Intune services.
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
# Set this variable to the TPM path on the device if it differs from standard TPM location. 
CUSTOM_TPM_PATH=/example/tmp/path

#############################################################################################################################
################### SCRIPT 
#############################################################################################################################


# Start of a bash "try-catch loop" that will safely exit the script if a command fails or causes an error. 
(
    # Set the error status
    set -e     

    # Change directory so that the script begins searching at root or top-most directory level 
    cd / 

    # Check for an active TPM file, which indicates that TPM is enabled on a given device. If the path is invalid, TPM is disabled and the device is noncompliant.
    # Note: posix test for -c is checking for character special file -d is checking for directory
    cd / 
    if [ -c /dev/tpmrm0 ] || [ -c /dev/tpm0 ] || [ -c "$CUSTOM_TPM_PATH" ] || [ -d $(ls -d /sys/kernel/security/tpm* 2>/dev/null | head -1) ]; then 
        echo "{"TPM_Enabled", "True"}" 
    else 
        echo "{"TPM_Enabled", "False"}" 
    fi  
)

# Catch any necessary errors to prevent the program from improperly exiting. 
ERROR_CODE=$?
if [ $ERROR_CODE -ne 0 ]; then
    echo "There was an error. Please restart the script or contact your admin if the error persists."
    exit $ERROR_CODE
fi

# The script has finished checking TPM status as enabled or disabled. 