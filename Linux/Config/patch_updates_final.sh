#!/bin/bash

#############################################################################################################################
################### CUSTOM INPUT VARIABLES
#############################################################################################################################

REPO_URL=(
    "temp.com"
    )

PATCH_FILES=(
    "example.patch"
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

    # Standard bash update
        # Check for any available updates
        if (apt update | grep 'can be updated'); then
            # If updates are present, perform upgrade of necessary packages
            apt upgrade -y

            # Upgrade package distributions (full system upgrade)
            apt dist-upgrade -y

            # Remove any unused packages
            apt autoremove -y

            # Clean up unncessary packages and install files
            apt autoclean

            echo "Updates, upgrades, and available clean up processes have been performed."
        fi

    # Automatic Update Settings (typically altered via GUI)
        apt-get install unattended-upgrades apt-listchanges
        # Update permissions to allow user to edit the necessary file
        chmod +777 /etc/apt/apt.conf.d/50unattended-upgrades

        # Uncomment the line from the config file to enable automatic upgrades
        FILE=/etc/apt/apt.conf.d/50unattended-upgrades
        sed -i -e '/{distro_codename}-updates/ s,^//,,' $FILE

        # Configure auto-upgrades to enable in the 20auto-upgrades file
        chmod +777 /etc/apt/apt.conf.d/20auto-upgrades
        # Clear the contents of the file
        > /etc/apt/apt.conf.d/20auto-upgrades
        echo -e "APT::Periodic::Update-Package-Lists \“1\”;\nAPT::Periodic::Download-Upgradeable-Packages \“1\”;\nAPT::Periodic::AutocleanInterval \“30\”;\nAPT::Periodic::Unattended-Upgrade \“1\”;" >> /etc/apt/apt.conf.d/20auto-upgrades
        
        echo "Automatic update settings have been updated and daily automatic updates have been enabled."

    # Add/download a new software repository
    for i in "${REPO_URL[@]}"; do
            # Download the repository and add it to the repository list
            wget -q -O - $i | apt-key add -
            apt update
            echo "The repository downloaded from " $i " has been added."
        done

    # Alternate or additional way to enable automatic updates
    dpkg-reconfigure unattended-upgrades
    unattended-upgrades -d
    echo "Automatic update settings have been reconfigured and automatic updates have been enabled."

    # Patching a directory
        # Note: there is a "dry-run" versioning of patching that can ensure there are no errors before files are actually modiifed. 
        # patch --dry-run -ruN -d working < temp.patch

        # Actually applying the patches to the files
        for i in "${PATCH_FILES[@]}"; do
            ./patch -ruN -d working < $i
            echo "The patches from file " $i " have been added."
        done
)

ERROR_CODE=$?
if [ $ERROR_CODE -ne 0 ]; then
    echo "There was an error. Please restart the script or contact your admin if the error persists."
    exit $ERROR_CODE
fi

# System restart
echo "A system restart is required in order for firewall changes to take place. Please either restart at your earliest convenience or type 'Restart Now' to automatically restart your device."
read RESTART_RESPONSE

# Final output message - to be configured TBD
echo "The script is finished running. The result will be sent in the necessary format."

if [[ $RESTART_RESPONSE == "Restart Now" || $RESTART_RESPONSE == "Restart now" || $RESTART_RESPONSE == "restart now" || $RESTART_RESPONSE == "restart Now" ]]; then
    shutdown -r now
fi