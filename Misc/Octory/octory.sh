#!/bin/bash
#set -x

############################################################################################
##
## Script to download and run Octory
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

tempfile="/tmp/octory/octory.zip"
targetdir="/Library/Application Support/Octory"
weburl="https://neiljohn.blob.core.windows.net/macapps/Octory.zip"
appname="Octory"
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/installOctory"
log="$logandmetadir/startOctory.log"

## Check if the log directory has been created
if [ -d $logandmetadir ]; then
    ## Already created
    echo "$(date) | Log directory already exists - $logandmetadir"
else
    ## Creating Metadirectory
    echo "$(date) | creating log directory - $logandmetadir"
    mkdir -p $logandmetadir
fi

# function to check if softwareupdate is running to prevent us from installing Rosetta at the same time as another script
isSoftwareUpdateRunning () {

    while ps aux | grep "/usr/sbin/softwareupdate" | grep -v grep; do

        echo "$(date) | [/usr/sbin/softwareupdate] running, waiting..."
        sleep 10

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

# Check if we need Rosetta 2
checkForRosetta2

# function to delay until the user has finished setup assistant.
waitForDesktop () {
    until ps aux | grep /System/Library/CoreServices/Dock.app/Contents/MacOS/Dock | grep -v grep; do
        echo "$(date) |  + Dock not running, waiting..."
        sleep 5
    done
    echo "$(date) | Desktop is here, lets carry on"
}

echo "$(date) | Removing any old temp files"
rm -rf /tmp/octory
rm -rf /Library/Application\ Support/Octory
mkdir -p /tmp/octory

echo "$(date) | Downloading [$appname] from [$weburl]"
curl -f -s --connect-timeout 30 --retry 5 --retry-delay 60 -L -o $tempfile $weburl
cd /tmp/octory
echo "$(date) | Unzipping binary and resource files"
unzip -q octory.zip
echo "$(date) | Copying to /Application Support/Octory"
mv Octory/ /Library/Application\ Support/
cd /Library/Application\ Support/Octory
echo "$(date) | Setting Permissions"
chown -R root:wheel Octory.app
sleep 10

waitForDesktop
echo "$(date) | Launching Octory for user"
Octory.app/Contents/MacOS/Octory -c Presets/Numberwang/Octory.plist
if [[ $? -eq 0 ]]; then
    echo "$(date) | Octory succesfully launched"
    exit 0
else
    echo "$(date) | Octory failed, let's try one more time"
    sleep 10
    Octory.app/Contents/MacOS/Octory -c Presets/Numberwang/Octory.plist
    if [[ $? -eq 0 ]]; then
        echo "$(date) | Octory succesfully launched"
        exit 0
    else
        echo "$(date) | Octory failed on 2nd launch, let's try one more time"
        exit 1
    fi
fi


