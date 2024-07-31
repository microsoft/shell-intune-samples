#!/bin/bash
#set -x

############################################################################################
##
## Script to interactively re-escrow a macOS bootstrap token
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

# Check if the boostrap token was ever escrowed. If not, stop early as success.
if echo "profiles validate -type bootstraptoken" | grep -q "Bootstrap Token escrowed to server: NO"; then
    exit 0
fi

# Check if we escrowed successfully in the past. If so, stop early as success.
if cat "$logdir/checkBootstrapEscrow.log" | grep -q "Bootstrap Token validated."; then
    exit 0
fi

DIALOG_ICON="/Library/Intune/Microsoft Intune Agent.app/Contents/Resources/AppIcon.icns"

# Prompt the user for an admin username
ADMIN_USERNAME=$(osascript -e "set T to text returned of (display dialog \"Your organization requires an update. Please provide the username for your local admin account.\" default answer \"\" with icon POSIX file \"$DIALOG_ICON\")")

# If no username was provided, fail the operation.
if [ -z "$ADMIN_USERNAME" ]; then
    echo "$(date) | Username not provided. Not proceeding."
    exit 1
fi

# Check if the admin account has secure token enabled. If not, display an error message to the user and fail the operation.
SECURE_TOKEN_STATUS=$(sysadminctl -secureTokenStatus $ADMIN_USERNAME 2>&1)
print_status "$SECURE_TOKEN_STATUS" $?

# Fail early if the account provided does not have secure token enabled
if echo "$SECURE_TOKEN_STATUS" | grep -q "Secure token is DISABLED"; then
    echo "$(date) | Secure token is disabled for $ADMIN_USERNAME. Not proceeding."
    osascript -e "display dialog Error: user $ADMIN_USERNAME is not authorized to perform this operation. Please reach out to your IT administrator for assistance.\" buttons {\"OK\"} default button \"OK\" with icon POSIX file \"$DIALOG_ICON\""
    exit 1
fi

# Fail early if the account provided is not a valid username
if echo "$SECURE_TOKEN_STATUS" | grep -q "Unknown user"; then
    echo "$(date) | Unknown user $ADMIN_USERNAME. Not proceeding."
    osascript -e "display dialog \"Error: user $ADMIN_USERNAME is not authorized to perform this operation. Please reach out to your IT administrator for assistance.\" buttons {\"OK\"} default button \"OK\" with icon POSIX file \"$DIALOG_ICON\""
    exit 1
fi

# Prompt the user for an admin password
ADMIN_PASSWORD=$(osascript -e "set T to text returned of (display dialog \"Enter the password for $ADMIN_USERNAME.\" with hidden answer default answer \"\" with icon POSIX file \"$DIALOG_ICON\")")

# If no password was provided, fail the operation.
if [ -z "${ADMIN_PASSWORD}" ]; then
    echo "$(date) | Password not provided. Not proceeding."
    exit 1
fi

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
        osascript -e "display dialog \"An error occurred while attempting to perform this operation. Please reach out to your IT administrator for assistance.\" buttons {\"OK\"} default button \"OK\" with icon POSIX file \"$DIALOG_ICON\""
        exit 1
    fi
fi