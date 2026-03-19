#!/bin/bash
############################################################################################
##
## Script to install the latest version of 1Password for Linux
## 
## VER 1.1.0
##
############################################################################################

## Copyright (c) 2020 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: neiljohn@microsoft.com

# Check if running with root privileges
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with root privileges. Please use sudo or run as root."
    exit 1
fi
# Variables
# Logging
log_file="/var/log/em_1Password_install.log"
error_log_file="/var/log/em_1Password_install_error.log"
# Functions
# Function to log messages
function log_message() {
    echo -e "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$log_file"
}
# Function to log errors
function log_error() {
    echo -e "$(date +"%Y-%m-%d %H:%M:%S") - ERROR: $1" >> "$error_log_file"
}
# Function to handle errors
function handle_error() {
    log_error "$1"
    log_message "An error occurred. Exiting."
    exit 1
}

# Main
# Create log files if they don't exist
touch "$log_file"
touch "$error_log_file"
log_message "Starting the script."
# Check if 1Password is already installed
log_message "Checking 1Password install status..."
install_status=$(dpkg --status "1password" | grep -Po "^Status:\s+\K(\S+)")
if [ $install_status == "install" ]; then
    log_message "1Password is already installed. Skipping installation."
    exit 0
else
    log_message "1Password is not installed. Installing..."
	# Update the system
    log_message "Updating the system"
	sudo apt-get update >> "$log_file" || log_error "Failed to update the system. \n\n $? \n"
    # Check if curl is installed
    if ! command -v curl &> /dev/null; then
        log_message "curl is not installed. Installing..."
        sudo apt-get install curl --download -y >> "$log_file" || handle_error "Failed to install curl. \n\n $? \n"
        log_message "curl installation complete."
    else
        log_message "curl is already installed."
    fi
	# Check if gnupg is installed
    gnupg_status=$(dpkg --status gnupg | grep -Po "^Status:\s+\K(\S+)")
    if [ $gnupg_status == "install" ]; then
        log_message "gnupg is already installed. Skipping installation."
    else
        log_message "gnupg is not installed. Installing..."
        sudo apt-get install gnupg --download -y || handle_error "Failed to install gnupg. \n\n $? \n"
        log_message "gnupg installation complete."
    fi
	# Validate if the package signing key is already in place
    if [ -f "/etc/apt/trusted.gpg.d/1password-archive-keyring.gpg" ]; then
        log_message "1Password GPG key is already installed. Skipping installation."
    else
        log_message "1Password GPG key is not installed. Installing..."
        # Import the 1Password repository key
        log_message "Importing the 1Password gpg key"
		curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /etc/apt/trusted.gpg.d/1password-archive-keyring.gpg &>> "$log_file" || handle_error "Failed to import the 1Password repository key. \n\n $? \n"
        log_message "1Password GPG key installed successfully."
    fi
    # Append 1Password repository
    log_message "Appending the 1Password repository"
	echo 'deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list >> "$log_file" || handle_error "Unable to add the update repository. \n\n $? \n"
	# Install the debsig-verify policy
	sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
	curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
	sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
	curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
	# Update package lists
    log_message "Updating package lists..."
    sudo apt-get update &>> "$log_file" || log_error "Failed to update package lists. \n\n $? \n"
    # Install 1Password
    log_message "Installing 1Password"

	sudo apt-get install "1password" --download -y &>> "$log_file" || handle_error "Unable to install 1Password. \n\n $? \n"
	# Verify installation
    install_status=$(dpkg --status "1password" | grep -Po "^Status:\s+\K(\S+)")
    if [ $install_status == "install" ]; then
        log_message "1Password installation completed successfully."
        exit 0
    else
        handle_error "1Password installation failed. \n\n $? \n"
    fi
fi
