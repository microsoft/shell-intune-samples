#!/bin/bash
#set -x

############################################################################################
##
## Script to download and run Octory splash screen
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

# User Defined variables
weburl="https://neiljohn.blob.core.windows.net/macapps/Octory.zip?sp=r&st=2021-06-22T11:00:42Z&se=2099-06-22T19:00:42Z&spr=https&sv=2020-02-10&sr=b&sig=%2FxK9Xhy07R9yZnD%2F4L1saDzV2a5VvXBlqr9GJbrBzSw%3D"

# Standard Variables
targetdir="/Library/Application Support/Octory"                 # Installation directory
appname="Octory"                                                # Name of application to display in the logs
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/Octory"    # Log file directory

# Generated variables
tempdir=$(mktemp -d)                                            # Temp directory
tempfile="/$tempdir/octory.zip"                                 # Temp file
log="$logandmetadir/$appname.log"                               # Log file name
consoleuser=$(ls -l /dev/console | awk '{ print $3 }')          # Current user

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
exec &> >(tee -a "$log")

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

#########################
##
##   Download, unzip and move application and resources into correct locations
##
##############

# Download Octory
echo "$(date) | Downloading [$appname] from [$weburl]"
curl -f -s --connect-timeout 30 --retry 5 --retry-delay 60 -L -o "$tempfile" "$weburl"
cd "$tempdir"

curl -f -s --connect-timeout 30 --retry 5 --retry-delay 60 -L -o "$tempfile" https://neiljohn.blob.core.windows.net/macapps/octo-notifier-0.1.1.pkg?sp=r&st=2021-06-24T14:29:11Z&se=2099-06-24T22:29:11Z&spr=https&sv=2020-08-04&sr=b&sig=4%2BcMPc4CSew%2BcGuooXIx7jkDv5dR7uG00eYePUTxuT4%3D

# Unzip files
echo "$(date) | Unzipping binary and resource files"
unzip -q octory.zip

# Remove previous Octory files if they exist
if [ -d "$targetdir" ]; then
    ## Octory directory already exists, we need to remove it
    echo "$(date) | Removing previous Octory files from [$targetdir]"
    rm -rf "$targetdir"
fi

# Move files into correct location
echo "$(date) | Copying to /Application Support/Octory"
mv Octory/ /Library/Application\ Support/
cd /Library/Application\ Support/Octory

# Ensure correct permissions are set
echo "$(date) | Setting Permissions"
sudo chown -R root:wheel /Library/Application\ Support/Octory
sudo chmod -R 755 /Library/Application\ Support/Octory
sudo chmod 644 /Library/Application\ Support/Octory/onboarding.plist
cd $HOME
rm -rf "$tempdir"

# Launch Octory splash screen to show the end user how app installation progress is doing
echo "$(date) | Launching Octory for user [$consoleuser]"
sudo -u "$consoleuser" Octory.app/Contents/MacOS/Octory -c onboarding.plist
if [[ $? -eq 0 ]]; then
    echo "$(date) | Octory succesfully launched"
    exit 0
else
    echo "$(date) | Octory failed to launch, let's try one more time"
    sleep 10
    sudo -u "$consoleuser" Octory.app/Contents/MacOS/Octory -c onboarding.plist
    if [[ $? -eq 0 ]]; then
        echo "$(date) | Octory succesfully launched"
        exit 0
    else
        echo "$(date) | Octory failed on 2nd launch"
        exit 1
    fi
fi


