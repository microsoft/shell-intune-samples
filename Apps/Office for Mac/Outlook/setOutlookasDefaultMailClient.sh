#!/bin/bash
#set -x

############################################################################################
##
## Script to download and run Paul Bowdens MailtoOutlook tool
## this will change the default e-Mail client on the Mac to Outlook
##
###########################################

## Copyright (c) 2020 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: neiljohn@microsoft.com

# Define variables

tempdir="/tmp"
tempfile="/tmp/MailToOutlook.pkg"
weburl="https://macadmins.software/tools/MailToOutlook_2.0.pkg"
appname="MailToOutlook"
log="/var/log/MailToOutlook.log"

# function to check if softwareupdate is running to prevent us from installing Rosetta at the same time as another script
isSoftwareUpdateRunning () {

    while ps aux | grep "/usr/sbin/softwareupdate" | grep -v grep; do

        echo "$(date) | [/usr/sbin/softwareupdate] running, waiting..."
        sleep 60

    done

    echo "$(date) | [/usr/sbin/softwareupdate] isn't running, lets carry on"

}

# function to check if we need Rosetta 2
checkForRosetta2 () {

    # Wait here if software update is already running
    isSoftwareUpdateRunning

    echo "$(date) | Checking if we need Rosetta 2 or not"

    processor=$(/usr/sbin/sysctl -n machdep.cpu.brand_string)
    if [[ "$processor" == *"Intel"* ]]; then

        echo "$(date) | $processor processor detected, no need to install Rosetta."
        
    else

        echo "$(date) | $processor processor detected, lets see if Rosetta 2 already installed"

        # Check Rosetta LaunchDaemon. If no LaunchDaemon is found,
        # perform a non-interactive install of Rosetta.
        
        if [[ ! -f "/Library/Apple/System/Library/LaunchDaemons/com.apple.oahd.plist" ]]; then
            /usr/sbin/softwareupdate --install-rosetta --agree-to-license
        
            if [[ $? -eq 0 ]]; then
                echo "$(date) | Rosetta has been successfully installed."
            else
                echo "$(date) | Rosetta installation failed!"
                exit 1
            fi
    
        else
            echo "$(date) | Rosetta is already installed. Nothing to do."
        fi
    fi

}

# start logging

exec 1>> $log 2>&1

# Begin Script Body

echo ""
echo "##############################################################"
echo "# $(date) | Starting install of $appname"
echo "############################################################"
echo ""

# See if we need Rosetta
checkForRosetta2

echo "$(date) | Downloading $appname"
curl -L -f -o $tempfile $weburl
if [ "$?" = "0" ]; then
   echo "$(date) | $appname downloaded to $tempfile"
else
   echo "$(date) | Failed to download from $weburl"
   exit 1
fi

echo "$(date) | Running $appname"
installer -pkg $tempfile -target /Applications
if [ "$?" = "0" ]; then
   echo "$(date) | $appname installed"
   exit 0
else
   echo "$(date) | Failed to install $appname"
   exit 2
fi
