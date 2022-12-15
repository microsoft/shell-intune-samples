#!/bin/bash
#set -x

############################################################################################
##
## This script checks the OS and/or distribution version running on a device.
## OS/distro:
## In order to be compliant for intune linux standards, device must be running "LINUX" as the OS and "UBUNTU" as the distribution.
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

# This variable represents the OS platform runnning on the device. It can be set via this script or manually (if known).
UNAME=$(uname | tr "[:upper:]" "[:lower:]")

# After OS has been defined, the following script identifies the OS distrubtion. It also can be set manually, if OS distribution is known. 
    # If OS is linux, set distrubution to the following:
    if [ "$UNAME" == "linux" ]; then
        # If LSB distribution is available, use it to identify distribution.
        if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
            export DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
        # Otherwise, use release info file to identify distrubution.
        else
            export DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1)
        fi
    # Else, use a generic identifier for the distribution. 
    else
        [ "$DISTRO" == "" ] && export DISTRO=$UNAME
    fi


#############################################################################################################################
################### CHECK FOR PROPER VARIABLE STATUS 
#############################################################################################################################

# UNAME
if [[ -z $UNAME ]]; then
    echo "The OS name has not been updated. Please correct or restart the script."
    exit 1
fi

# DISTRO
if [[ -z $DISTRO ]]; then
    echo "The distribution name has not been updated. Please correct or restart the script."
    exit 1
fi

#############################################################################################################################
################### SCRIPT 
#############################################################################################################################

# Start of a bash "try-catch loop" that will safely exit the script if a command fails or causes an error. 
(
    # Set the error status
    set -e     
    
    if [ "$UNAME" = "linux" ]; then
        if [ "$DISTRO" = "Ubuntu" ]; then
            # Report (true, true) for linux ubuntu devices.
            echo "{{"linux_os_name", "True"}, {"ubuntu_distro_name", "True"}}"
        else
            # Report (true, false) for linux devices running a distribution other than Ubuntu.
            echo "{{"linux_os_name", "True"}, {"ubuntu_distro_name", "False"}}"
        fi
    else
        # Report (false, false) for non-linux devices
        echo "{{"linux_os_name", "False"}, {"ubuntu_distro_name", "False"}}"
    fi
)

# Catch any necessary errors to prevent the program from improperly exiting. 
ERROR_CODE=$?
if [ $ERROR_CODE -ne 0 ]; then
    echo "There was an error. Please restart the script or contact your admin if the error persists."
    exit $ERROR_CODE
fi

# The script has finished checking OS and distribution. 