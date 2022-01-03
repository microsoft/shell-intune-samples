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
weburl="" # Enter blob URL for Octory archive

# Standard Variables
targetdir="/Library/Application Support/Octory"                 # Installation directory
appname="Octory"                                                # Name of application to display in the logs
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/Octory"    # Log file directory

# Generated variables
tempdir=$(mktemp -d)                                            # Temp directory
tempfile="/$tempdir/octory.zip"                                 # Temp file
log="$logandmetadir/$appname.log"                               # Log file name

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

# function to delay until the user has finished setup assistant.
waitForDesktop () {
    until ps aux | grep /System/Library/CoreServices/Dock.app/Contents/MacOS/Dock | grep -v grep; do
        echo "$(date) |  + Dock not running, waiting..."
        sleep 5
    done
    echo "$(date) | Desktop is here, lets carry on"
}

# function to remove Octory after user finishes onboarding
cleanup() {

    cd "$HOME"

    if [ -d "$tempdir" ]; then
        echo "$(date) | Cleanup - Removing temp directory [$tempdir]"
        rm -rf "$tempdir"
    fi

    if [ -d "$targetdir" ]; then
        ## Octory directory already exists, we need to remove it
        echo "$(date) | Cleanup - Removing target directory [$targetdir]"
        rm -rf "$targetdir"
    fi

    ## Remove octo-notifier
    rm -rf /usr/bin/local/octo-notifier
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
        
        if /usr/bin/pgrep oahd >/dev/null 2>&1; then 
            echo "Rosetta 2 is installed"
        else 
            /usr/sbin/softwareupdate --install-rosetta --agree-to-license
        
                if [[ $? -eq 0 ]]; then
                echo "$(date) | Rosetta has been successfully installed."
                else
                echo "$(date) | Rosetta installation failed!"
                exit 1                
                fi  
        
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


# Exit if machine has already been deployed and Company Portal plist detected
#if [[ -f "/Users/$consoleuser/Library/Preferences/com.microsoft.CompanyPortalMac.plist" ]]; then
#
#    echo "$(date) | Skipping Octory launch for user [$consoleuser], Company Portal already Launched."
#   exit 0
#
#fi

# Check if we need Rosetta 2
checkForRosetta2

#########################
##
##   Download, unzip and move application and resources into correct locations
##
##############

# Download Octory
echo "$(date) | Downloading [$appname] from [$weburl]"
curl -f -s --connect-timeout 30 --retry 5 --retry-delay 60 -L -o "$tempfile" "$weburl"
cd "$tempdir"

# Unzip files
echo "$(date) | Unzipping binary and resource files"
unzip -q octory.zip

# Remove previous Octory files if they exist
if [ -d "$targetdir" ]; then
    ## Octory directory already exists, we need to remove it
    echo "$(date) | Removing previous Octory files from [$targetdir]"
    rm -rf "$targetdir"
fi

# Install octo-notifier
sudo installer -pkg "$tempdir/Octory/Octory notifier.pkg" -target /
if [[ $? -eq 0 ]]; then
    echo "$(date) | octo-notifier succesfully installed"
    else
    echo "$(date) | octo-notifier installation failed"
fi

# Move files into correct location
echo "$(date) | Copying to /Application Support/Octory"
mv Octory/ /Library/Application\ Support/
cd /Library/Application\ Support/Octory

# Ensure correct permissions are set
echo "$(date) | Setting Permissions on [$targetdir]"
sudo chown -R root:wheel "$targetdir"
sudo chmod -R 755 "$targetdir"
sudo chmod 644 "$targetdir/onboarding.plist"

# We don't want to interrupt setup assistant
waitForDesktop
consoluser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' ) 

# Launch Octory splash screen to show the end user how app installation progress is doing
echo "$(date) | Launching Octory for user [$consoluser]"
sudo -u "$consoluser" Octory.app/Contents/MacOS/Octory -c onboarding.plist
if [[ $? -eq 0 ]]; then
    echo "$(date) | Octory succesfully launched"
    #cleanup
    exit 0
else
    echo "$(date) | Octory failed to launch, let's try one more time"
    sleep 10
    sudo -u "$consoluser" open Octory.app --args -c onboarding.plist
    if [[ $? -eq 0 ]]; then
        echo "$(date) | Octory succesfully launched"
        #cleanup
        exit 0
    else
        echo "$(date) | Octory failed on 2nd launch"
        #cleanup
        exit 1
    fi
fi
