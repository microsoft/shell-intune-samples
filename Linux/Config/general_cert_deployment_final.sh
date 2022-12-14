#!/bin/bash

#############################################################################################################################
################### CUSTOM INPUT VARIABLES
#############################################################################################################################

# Set this variable to the certificate files to be deployed.
    CERTIFICATE_FILES=(
        "example.crt"
        "example2.crt"
        )

#############################################################################################################################
################### SCRIPT 
#############################################################################################################################

# Recommended that this script be run using root privileges: 
echo "It is recommended that this script is run with root privileges. Please type the following or contact your administration: sudo -s"

# Start of a bash "try-catch loop" that will safely exit the script if a command fails or causes an error. 
(
    # Set the error status
    set -e  

        for i in "${CERTIFICATE_FILES[@]}"; do
            # Copy the certificate into the device's ca-certificae directory as per the man pages.
            cp $i /usr/local/share/ca-certificates/

            # Ensure certificate file permissions are not locked.
            chmod 644 $i

            # Update certificates and add new certificate to the list.
            dpkg-reconfigure ca-certificates
            update-ca-certificates
            echo "The certificate " $i " has been added."
        done
)

ERROR_CODE=$?
if [ $ERROR_CODE -ne 0 ]; then
    echo "There was an error. Please restart the script or contact your admin if the error persists."
    exit $ERROR_CODE
fi

# Final output message - to be configured TBD.
echo "The script is finished running. The result will be sent in the necessary format."