#!/bin/bash
#set -x

############################################################################################
##
## Script to automatically re-escrow a macOS bootstrap token
##
############################################################################################

## Copyright (c) 2023 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: neiljohn@microsoft.com

# Define variables
ADMIN_USERNAME="<local admin username>"
ADMIN_PASSWORD="<local admin password>"

logdir="/Library/Application Support/Microsoft/IntuneScripts/checkBootstrapEscrow"
if [[ ! -d "$logdir" ]]; then
    ## Creating Log Directory
    echo "$(date) | Creating [$logdir] to store logs"
    mkdir -p "$logdir"
fi

exec &> >(tee -a "$logdir/checkBootstrapEscrow.log")

# Function to print command output and status
function print_status {
    echo "$(date) | Command Output: $1"
    if [ $2 -eq 0 ]; then
        echo "$(date) |  + Command succeeded."
    else
        echo "$(date) |  + Command failed."
    fi
}




# Check Bootstrap Token status
BOOTSTRAP_TOKEN_STATUS=$(profiles validate -type bootstraptoken -user $ADMIN_USERNAME -password $ADMIN_PASSWORD 2>&1)
print_status "$BOOTSTRAP_TOKEN_STATUS" $?

# Specifically check for "escrowed: YES" in the output
if echo "$BOOTSTRAP_TOKEN_STATUS" | grep -q "Bootstrap Token validated."; then
    echo "$(date) | Bootstrap Token validation succeeded. Not proceeding with re-escrow."
    exit 0
else
    echo "$(date) | Bootstrap Token validation failed. Re-escrowing token..."

    # Attempt to escrow the Bootstrap Token
    ESCROW_RESULT=$(profiles install -type bootstraptoken -user $ADMIN_USERNAME -password $ADMIN_PASSWORD 2>&1)
    print_status "$ESCROW_RESULT" $?

    # Check status again after attempting to escrow
    sleep 10  # Wait for the server to process the request
    BOOTSTRAP_TOKEN_STATUS=$(profiles validate -type bootstraptoken -user $ADMIN_USERNAME -password $ADMIN_PASSWORD 2>&1)
    print_status "$BOOTSTRAP_TOKEN_STATUS" $?

    if echo "$BOOTSTRAP_TOKEN_STATUS" | grep -q "Bootstrap Token validated."; then
        echo "$(date) | Bootstrap Token escrowed successfully."
    else
        echo "$(date) | Failed to escrow Bootstrap Token. Please check the MDM server or configuration."
        exit 1
    fi
fi
