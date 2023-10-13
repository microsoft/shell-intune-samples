#!/bin/bash

############################################################################################
##
## Script to install the latest version of Google Chrome on Linux
## 
## VER 1.2.0
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
log_file="/var/log/em_google_chrome_install.log"
error_log_file="/var/log/em_google_chrome_install_error.log"
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
# Check if Google Chrome is already installed
log_message "Checking Google Chrome install status..."
install_status=$(dpkg --status google-chrome-stable | grep -Po "^Status:\s+\K(\S+)")
if [ $install_status == "install" ]; then
    log_message "Google Chrome is already installed. Skipping installation."
    exit 0
else
    log_message "Google Chrome is not installed. Installing..."
    # Update the system
    log_message "Updating the system"
    sudo apt-get update >> "$log_file" || log_error "Failed to update the system. \n\n $? \n"
    # Check if curl is installed
    if ! command -v curl &> /dev/null; then
        log_message "curl is not installed. Installing..."
        sudo apt-get install curl -y >> "$log_file" || handle_error "Failed to install curl. \n\n $? \n"
        log_message "curl installation complete."
    else
        log_message "curl is already installed."
    fi
    # Check if gnupg is installed
    gnupg_status=$(dpkg --status gnupg | grep -Po "^Status:\s+\K(\S+)")
    if [ $gnupg_status == "install" ]; then
        log_message "gnupg is not installed. Installing..."
        sudo apt-get install gnupg -y >> "$log_file" || handle_error "Failed to install gnupg. \n\n $? \n"
        log_message "gnupg installation complete."
    else
        log_message "gnupg is already installed."
    fi
    # Download Google Chrome repository key
    log_message "Adding Google Chrome repository key"
    curl -sS https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor --yes -o /usr/share/keyrings/google-chrome-archive-keyring.gpg || handle_error "Unable to add the Google Chrome repository key. \n\n $? \n"
    log_message "Google Chrome repository key imported."
    # Append the Google Chrome repository
    log_message "Adding Google Chrome repository"
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-archive-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list &>> "$log_file" || handle_error "Unable to add update repository. \n\n $? \n"
    log_message "Google Chrome repository added."
    # Update package lists
    log_message "Updating package lists..."
    sudo apt-get update &>> "$log_file" || log_error "Failed to update package lists. \n\n $? \n"
    # Install Google Chrome
    log_message "Installing Google Chrome"
    sudo apt-get install google-chrome-stable -y &>> "$log_file" || handle_error "Unable to install Google Chrome. \n\n $? \n"
    # Exit script
    log_message "Google Chrome installation completed."
    exit 0
fi