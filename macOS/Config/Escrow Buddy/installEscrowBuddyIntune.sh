#!/bin/bash
#set -x

# Script Name: installEB.sh
# Description: This script downloads and installs the latest release of Escrow Buddy, a security agent plugin for macOS. 
#              The script checks if the log directory has been created and creates it if necessary. 
#              It also defines several functions for downloading and updating Escrow Buddy, as well as checking if the Escrow Buddy authorizationdb entry is configured. 
#              The logger function is used to log messages to stdout and a log file.
# Version: 1.0.0
# Author: Tobias Almén
# Date: 2023-06-16

# Manual version override
version="" # Only configure this if you want to control the version of Escrow Buddy that is installed, otherwise leave it blank. Example: version="1.0.0"

# Set the path to the installed Escrow Buddy bundle
install_path="/Library/Security/SecurityAgentPlugins/Escrow Buddy.bundle"
# Set the path to the log directory
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/EscrowBuddy"
# File to store last updatedtime
lastupdated="$logandmetadir/lastupdated"
# Get the current date and time
date=$(date +"%Y-%m-%d %H:%M:%S")
# Set the API URL for the latest release of Escrow Buddy
eb_url="https://api.github.com/repos/macadmins/escrow-buddy/releases/latest"
# Set the path to the installed Escrow Buddy bundle
install_path="/Library/Security/SecurityAgentPlugins/Escrow Buddy.bundle"
# Curl the API URL for the latest release and download url of Escrow Buddy
response=$(curl --silent "$eb_url")
# Get the latest release of Escrow Buddy
latest_release=$(echo "$response" | grep -o '"tag_name": "[^"]*' | grep -o '[^"]*$')
# Get the numerical version of the latest release of Escrow Buddy
latest_version=$(echo "$latest_release" | cut -c 2-)
# Get FDE status
FDE_STATUS=$(fdesetup status)
# Get FDE profile status
FDE_PROFILE=$(profiles list | grep -e filevault.escrow -e FDERecoveryKeyEscrow)
# Path to FileVaultPRK
PRK="/var/db/FileVaultPRK.dat"

## Check if the log directory has been created
if [ -d $logandmetadir ]; then
	## Already created
	echo "[$date] [INFO] Log directory already exists - $logandmetadir"
else
	## Creating Metadirectory
	echo "[$date] [INFO] creating log directory - $logandmetadir"
	sudo mkdir -p $logandmetadir
fi

# Function to log messages to stdout
function logger() {
    # Function to log messages to stdout and a log file
    #
    # Arguments:
    #   $1: The log level (e.g. INFO, WARNING, ERROR)
    #   $2: The message to log

    level=$1
    message=$2

    # Log the message with the current date and time and the specified log level
    echo "[$date] [$level] $message"
    echo "[$date] [$level] $message" >> "$logandmetadir/installeb.log"
}

function remediate() {
    # Function to remediate missing FV key
    #
    # Arguments:
    #   None
    # Returns:
    #   None
    # Variables:
    #   $FDE_STATUS: The status of FileVault
    #   $FDE_PROFILE: FDE profile status
    #   $PRK: The path to the FileVaultPRK

    # If FileVault is not enabled, exit
    if [ "FileVault is On." != "$FDE_STATUS" ]; then
        exit 0
    fi

    # If the escrow plist exists, check if the escrow location is set to Intune
    if [ "$FDE_PROFILE" ]; then
        # If the key has been escrowed, exit
        if [ -a "$PRK" ]; then
            logger "INFO" "Key has been escrowed"
        # If the key has not been escrowed, set GenerateNewKey to true
        else
            logger "INFO" "Key has not been escrowed"
            defaults write /Library/Preferences/com.netflix.Escrow-Buddy.plist GenerateNewKey -bool true
        fi
    # If the escrow plist does not exist, do nothing
    else
        logger "INFO" "No File Vault profile has been applied"
    fi
}

function getVersion() {
    # Convert a version string in the format x.y.z.w to an integer
    # Nabbed from Matt's WS1 example and slightly modified
    #
    # Arguments:
    #   $1: The version string to convert
    # Returns:
    #   The integer representation of the version string
    # Variables:
    #   None

    echo "$1" | awk -F. '{ printf("%d%d%d%d\n", $1,$2,$3,$4); }'
}

# Function to download the latest release of Escrow Buddy
function downloadEscrowBuddy() {
    # Download the latest release of Escrow Buddy
    #
    # Arguments:
    #   None
    # Returns:
    #   None
    # Variables:
    #   $response: The response from the API URL for the latest release of Escrow Buddy
    #   $download_url: The download URL for the latest release of Escrow Buddy

    # Get the download URL for the latest release
    download_url=$(echo "$response" | grep -o '"browser_download_url": "[^"]*' | grep -o '[^"]*$' | grep -i '\.pkg$')

    # Download the latest release of Escrow Buddy
    logger "INFO" "Downloading Escrow Buddy $latest_release"
    curl -L -s "$download_url" -o "/tmp/Escrow.Buddy.pkg"

    # Check if the download was successful
    if [ $? -eq 0 ]; then
        logger "INFO" "Escrow Buddy $latest_release downloaded successfully"
    else
        logger "ERROR" "Escrow Buddy $latest_release download failed"
        exit 1
    fi
}

# Function to check if the Escrow Buddy authorizationdb entry is configured
function authorizationdbCheck() {
    # Check if the Escrow Buddy authorizationdb entry is configured
    #
    # Arguments:
    #   None
    # Returns:
    #   None
    # Variables:
    #   $DBENTRY: The authorizationdb entry to check for

    # Set the authorizationdb entry to check for
    DBENTRY="<string>Escrow Buddy:Invoke,privileged</string>"

    # Check if the authorizationdb entry is configured
    if /usr/bin/security authorizationdb read system.login.console 2>/dev/null | grep -q "$DBENTRY"; then
        logger "INFO" "authorizationdb entry is configured"
    else
        logger "INFO" "authorizationdb entry is not configured, re-installing Escrow Buddy"
        installEscrowBuddy
    fi
}

# Function to update Escrow Buddy if a new version is available
function updateEscrowBuddy() {
    # Update Escrow Buddy if a new version is available
    #
    # Arguments:
    #   input_version: The highest version of Escrow Buddy to install
    # Returns:
    #   None
    # Variables:
    #   $response: The response from the API URL for the latest release of Escrow Buddy
    #   $download_url: The download URL for the latest release of Escrow Buddy
    #   $lastmodified: The last modified date of the latest release of Escrow Buddy
    #   $previouslastmodifieddate: The last modified date of the previously installed release of Escrow Buddy
    #   $lastupdated: The path to the file containing the last modified date of the previously installed release of Escrow Buddy

    # Manual version override
    input_version=$1

    # If the input version is set, check if an update is available
    if [ "$input_version" ]; then 
        # Check if Escrow Buddy is installed
        if [ -d "$install_path" ]; then
            # If the input version is not the same as the latest version, log a warning
            if [ $(getVersion $input_version) != $(getVersion $latest_version) ]; then
                logger "WARNING" "Input version [$input_version] does not match latest version [$latest_version]"
            # If the input version and the latest version are the same, check if an update is available
            else
                # Get the version of the currently installed release of Escrow Buddy
                installed_version=$(defaults read "$install_path"/Contents/Info.plist CFBundleShortVersionString)
                if [ $(getVersion $input_version) -gt $(getVersion $installed_version) ]; then
                    logger "INFO" "Update found, input version [$input_version] and current [$installed_version]"
                    # Install the latest release of Escrow Buddy
                    installEscrowBuddy
                else
                    logger "INFO" "No update found, input version [$input_version] and current [$installed_version]"
                fi
            fi
        else
            logger "INFO" "Unable to check for updates, Escrow Buddy is not installed, installing"
            # Install the latest release of Escrow Buddy
            installEscrowBuddy
        fi

    else
        # Get the download URL for the latest release
        download_url=$(echo "$response" | grep -o '"browser_download_url": "[^"]*' | grep -o '[^"]*$' | grep -i '\.pkg$')
        # Get the last modified date for the latest release
        lastmodified=$(curl -sIL "$download_url" | grep -i "last-modified" | awk '{$1=""; print $0}' | awk '{ sub(/^[ \t]+/, ""); print }' | tr -d '\r')

        # Check if the last modified date of the latest release is different to the last modified date of the previously installed release
        if [ -f "$lastupdated" ]; then
            previouslastmodifieddate=$(cat "$lastupdated")
            if [[ "$previouslastmodifieddate" != "$lastmodified" ]]; then
                logger "INFO" "Update found, previous [$previouslastmodifieddate] and current [$lastmodified]"

                # Install the latest release of Escrow Buddy
                installEscrowBuddy
            # If the last modified date of the latest release is the same as the last modified date of the previously installed release, do nothing
            else
                logger "INFO" "No update between previous [$previouslastmodifieddate] and current [$lastmodified]"
            fi

        # If the last modified date of the previously installed release is not found, install the latest release of Escrow Buddy
        else
            logger "INFO" "Meta file [$lastupdated] not found"
            logger "INFO" "Unable to determine if update required so updating anyway"

            # Install the latest release of Escrow Buddy
            installEscrowBuddy

        fi

    fi

}

# Function to install Escrow Buddy
function installEscrowBuddy() {
    # Install the latest release of Escrow Buddy
    #
    # Arguments:
    #   None
    # Returns:
    #   None
    # Variables:
    #   None

    # Install Escrow Buddy
    downloadEscrowBuddy
    logger "INFO" "Installing Escrow Buddy"
    sudo installer -pkg "/tmp/Escrow.Buddy.pkg" -target "/" > /dev/null 2>&1

    # Clean up
    rm -f "/tmp/Escrow.Buddy.pkg"

    # Check if the installation was successful
    if [ $? -eq 0 ]; then
        logger "INFO" "Escrow Buddy installed successfully"
        lastmodified=$(curl -sIL "$download_url" | grep -i "last-modified" | awk '{$1=""; print $0}' | awk '{ sub(/^[ \t]+/, ""); print }' | tr -d '\r')
        logger "INFO" "Writing last update information to [$lastupdated]"
        echo $lastmodified >"$lastupdated"
    else
        logger "ERROR" "Escrow Buddy installation failed"
        exit 1
    fi
}

# Check if Escrow Buddy is already installed
if [ -d "$install_path" ]; then
    # If Escrow Buddy is already installed, check if an update is required
    logger "INFO" "Escrow Buddy already installed, checking for update" 
    updateEscrowBuddy $version
else
    # If Escrow Buddy is not installed, install it
    logger "INFO" "Escrow Buddy not installed, installing" 
    installEscrowBuddy
fi

# Check if Escrow Buddy authorizationdb entry is configured
authorizationdbCheck

# Run remediation
remediate