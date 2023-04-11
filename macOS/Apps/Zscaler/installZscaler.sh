#!/bin/bash
#set -x

############################################################################################
##
## Script to install Zscaler from Zscaler's CDN
## 
## Based on https://github.com/microsoft/shell-intune-samples/tree/master/Apps/LatestSampleScript
##
## Download is always a zip; other methods removed for clarity
##
## Addidtional variables added to suit the installation $appdir, $installversion, $installerapp and $installargs
##
## Zscaler is unusual in that it installs to /Applications/Zscaler/Zscaler.app, and other oddities
##
## Use for fresh installs only. Script has NOT been tested to update the app as Zscaler autoupdate is preferred
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

# User Defined variables
installversion="3.6.1.19"                                               # Which version do we want?
installerapp="Zscaler-osx-$installversion-installer.app"                # Name of the installer app that unzips
weburl="https://d32a6ru7mhaq0c.cloudfront.net/$installerapp.zip"        # What is the Zscaler CDN URL?
appname="Zscaler"                                                       # The name of our App deployment script (also used for Octory monitor)
app="Zscaler.app"                                                       # The actual name of our App once installed
appdir="Zscaler"                                                        # Folder within /Applications where the App installs to

logandmetadir="/Library/Logs/Microsoft/IntuneScripts/$appname"          # The location of our logs and last updated data
processpath="/Applications/$appdir/$app/Contents/MacOS/$appname"        # The process name of the App we are installing
terminateprocess="false"                                                # Do we want to terminate the running process? If false we'll wait until its not running
autoUpdate="true"                                                       # Application updates itself, if already installed we should exit
installargs="--unattendedmodeui none \
--userDomain YOUR.DOMAIN.NAME \
--cloudName YOUR_ZSCALER_CLOUD_NAME \
--mode unattended"                                                      # Arguments to pass to the installer. See https://community.zscaler.com/t/guide-deploy-zscaler-client-connector-with-intune-windows-macos/9121

# Generated variables
tempdir=$(mktemp -d)
log="$logandmetadir/$appname.log"                                               # The location of the script log file
metafile="$logandmetadir/$appname.meta"                                         # The location of our meta file (for updates)

# function to delay script if the specified process is running
waitForProcess () {

    #################################################################################################################
    #################################################################################################################
    ##
    ##  Function to pause while a specified process is running
    ##
    ##  Functions used
    ##
    ##      None
    ##
    ##  Variables used
    ##
    ##      $1 = name of process to check for
    ##      $2 = length of delay (if missing, function to generate random delay between 10 and 60s)
    ##      $3 = true/false if = "true" terminate process, if "false" wait for it to close
    ##
    ###############################################################
    ###############################################################

    processName=$1
    fixedDelay=$2
    terminate=$3

    echo "$(date) | Waiting for other [$processName] processes to end"
    while ps aux | grep "$processName" | grep -v grep &>/dev/null; do

        if [[ $terminate == "true" ]]; then
            echo "$(date) | + [$appname] running, terminating [$processpath]..."
            pkill -f "$processName"
            return
        fi

        # If we've been passed a delay we should use it, otherwise we'll create a random delay each run
        if [[ ! $fixedDelay ]]; then
            delay=$(( $RANDOM % 50 + 10 ))
        else
            delay=$fixedDelay
        fi

        echo "$(date) |  + Another instance of $processName is running, waiting [$delay] seconds"
        sleep $delay
    done
    
    echo "$(date) | No instances of [$processName] found, safe to proceed"

}

# function to check if we need Rosetta 2
checkForRosetta2 () {

    #################################################################################################################
    #################################################################################################################
    ##
    ##  Simple function to install Rosetta 2 if needed.
    ##
    ##  Functions
    ##
    ##      waitForProcess (used to pause script if another instance of softwareupdate is running)
    ##
    ##  Variables
    ##
    ##      None
    ##
    ###############################################################
    ###############################################################

    

    echo "$(date) | Checking if we need Rosetta 2 or not"

    # if Software update is already running, we need to wait...
    waitForProcess "/usr/sbin/softwareupdate"


    ## Note, Rosetta detection code from https://derflounder.wordpress.com/2020/11/17/installing-rosetta-2-on-apple-silicon-macs/
    OLDIFS=$IFS
    IFS='.' read osvers_major osvers_minor osvers_dot_version <<< "$(/usr/bin/sw_vers -productVersion)"
    IFS=$OLDIFS

    if [[ ${osvers_major} -ge 11 ]]; then

        # Check to see if the Mac needs Rosetta installed by testing the processor

        processor=$(/usr/sbin/sysctl -n machdep.cpu.brand_string | grep -o "Intel")
        
        if [[ -n "$processor" ]]; then
            echo "$(date) | $processor processor installed. No need to install Rosetta."
        else

            # Check for Rosetta "oahd" process. If not found,
            # perform a non-interactive install of Rosetta.
            
            if /usr/bin/pgrep oahd >/dev/null 2>&1; then
                echo "$(date) | Rosetta is already installed and running. Nothing to do."
            else
                /usr/sbin/softwareupdate -install-rosetta -agree-to-license
            
                if [[ $? -eq 0 ]]; then
                    echo "$(date) | Rosetta has been successfully installed."
                else
                    echo "$(date) | Rosetta installation failed!"
                    exitcode=1
                fi
            fi
        fi
        else
            echo "$(date) | Mac is running macOS $osvers_major.$osvers_minor.$osvers_dot_version."
            echo "$(date) | No need to install Rosetta on this version of macOS."
    fi

}

# Function to update the last modified date for this app
fetchLastModifiedDate() {

    #################################################################################################################
    #################################################################################################################
    ##
    ##  This function takes the following global variables and downloads the URL provided to a temporary location
    ##
    ##  Functions
    ##
    ##      none
    ##
    ##  Variables
    ##
    ##      $logandmetadir = Directory to read nand write meta data to
    ##      $metafile = Location of meta file (used to store last update time)
    ##      $weburl = URL of download location
    ##      $tempfile = location of temporary DMG file downloaded
    ##      $lastmodified = Generated by the function as the last-modified http header from the curl request
    ##
    ##  Notes
    ##
    ##      If called with "fetchLastModifiedDate update" the function will overwrite the current lastmodified date into metafile
    ##
    ###############################################################
    ###############################################################

    ## Check if the log directory has been created
    if [[ ! -d "$logandmetadir" ]]; then
        ## Creating Metadirectory
        echo "$(date) | Creating [$logandmetadir] to store metadata"
        mkdir -p "$logandmetadir"
    fi

    # generate the last modified date of the file we need to download
    lastmodified=$(curl -sIL "$weburl" | grep -i "last-modified" | awk '{$1=""; print $0}' | awk '{ sub(/^[ \t]+/, ""); print }' | tr -d '\r')

    if [[ $1 == "update" ]]; then
        echo "$(date) | Writing last modifieddate [$lastmodified] to [$metafile]"
        echo "$lastmodified" > "$metafile"
    fi

}

function downloadApp () {

    #################################################################################################################
    #################################################################################################################
    ##
    ##  This function takes the following global variables and downloads the URL provided to a temporary location
    ##
    ##  Functions
    ##
    ##      waitForCurl (Pauses download until all other instances of Curl have finished)
    ##      downloadSize (Generates human readable size of the download for the logs)
    ##
    ##  Variables
    ##
    ##      $appname = Description of the App we are installing
    ##      $weburl = URL of download location
    ##      $tempfile = location of temporary DMG file downloaded
    ##
    ###############################################################
    ###############################################################

    echo "$(date) | Starting downlading of [$appname]"

    # wait for other downloads to complete
    waitForProcess "curl -f"

    #download the file
    updateOctory installing
    echo "$(date) | Downloading $appname [$weburl]"

    cd "$tempdir"
    curl -f -s --connect-timeout 30 --retry 5 --retry-delay 60 --compressed -L -J -O "$weburl"
    if [ $? == 0 ]; then

            # We have downloaded a file, we need to know what the file is called and what type of file it is
            tempSearchPath="$tempdir/*"
            for f in $tempSearchPath; do
                tempfile=$f
            done
            packageType="ZIP"

    else
    
         echo "$(date) | Failure to download [$weburl] to [$tempfile]"
         updateOctory failed
         exit 1
    fi

}

## Install ZIP Function
function installZIP () {

    #################################################################################################################
    #################################################################################################################
    ##
    ##  This function takes the following global variables and installs the DMG file into /Applications
    ##
    ##  Functions
    ##
    ##      isAppRunning (Pauses installation if the process defined in global variable $processpath is running )
    ##      fetchLastModifiedDate (Called with update flag which causes the function to write the new lastmodified date to the metadata file)
    ##
    ##  Variables
    ##
    ##      $appname = Description of the App we are installing
    ##      $tempfile = location of temporary DMG file downloaded
    ##      $volume = name of volume mount point
    ##      $app = name of Application directory under /Applications
    ##
    ###############################################################
    ###############################################################


    # Check if app is running, if it is we need to wait.
    waitForProcess "$processpath" "300" "$terminateprocess"

    echo "$(date) | Installing $appname"
    updateOctory installing

    # Change into temp dir
    cd "$tempdir"
    if [ "$?" = "0" ]; then
      echo "$(date) | Changed current directory to $tempdir"
    else
      echo "$(date) | failed to change to $tempfile"
      if [ -d "$tempdir" ]; then rm -rf $tempdir; fi
      updateOctory failed
      exit 1
    fi

    # Unzip files in temp dir
    unzip -qq -o "$tempfile"
    if [ "$?" = "0" ]; then
      echo "$(date) | $tempfile unzipped"
    else
      echo "$(date) | failed to unzip $tempfile"
      if [ -d "$tempdir" ]; then rm -rf $tempdir; fi
      updateOctory failed
      exit 1
    fi

    # If app is already installed, remove all old files
    if [[ -a "/Applications/$appdir/$app" ]]; then
    
      echo "$(date) | Removing old installation at /Applications/$app"
      rm -rf "/Applications/$appdir/$app"
    
    fi

    # Install the application
    sudo $installerapp/Contents/MacOS/installbuilder.sh $installargs

    if [ "$?" = "0" ]; then
      echo "$(date) | $appname installed into /Applications/$appdir"
    else
      echo "$(date) | failed to install $appname to /Applications/$appdir"
      if [ -d "$tempdir" ]; then rm -rf $tempdir; fi
      updateOctory failed
      exit 1
    fi

    # Make sure permissions are correct
    echo "$(date) | Fix up permissions"
    sudo chown -R root:wheel "/Applications/$appdir/$app"
    if [ "$?" = "0" ]; then
      echo "$(date) | correctly applied permissions to $appname"
    else
      echo "$(date) | failed to apply permissions to $appname"
      if [ -d "$tempdir" ]; then rm -rf $tempdir; fi
      updateOctory failed
      exit 1
    fi

    # Checking if the app was installed successfully
    if [ "$?" = "0" ]; then
        if [[ -a "/Applications/$appdir/$app" ]]; then

            echo "$(date) | $appname Installed"
            updateOctory installed
            echo "$(date) | Cleaning Up"
            rm -rf "$tempfile"

            # Update metadata
            fetchLastModifiedDate update

            echo "$(date) | Fixing up permissions"
            sudo chown -R root:wheel "/Applications/$appdir/$app"
            echo "$(date) | Application [$appname] succesfully installed"
            exit 0
        else
            echo "$(date) | Failed to install $appname"
            exit 1
        fi
    else

        # Something went wrong here, either the download failed or the install Failed
        # intune will pick up the exit status and the IT Pro can use that to determine what went wrong.
        # Intune can also return the log file if requested by the admin
        
        echo "$(date) | Failed to install $appname"
        if [ -d "$tempdir" ]; then rm -rf $tempdir; fi
        exit 1
    fi
}

function updateOctory () {

    #################################################################################################################
    #################################################################################################################
    ##
    ##  This function is designed to update Octory status (if required)
    ##
    ##
    ##  Parameters (updateOctory parameter)
    ##
    ##      notInstalled
    ##      installing
    ##      installed
    ##
    ###############################################################
    ###############################################################

    # Is Octory present
    if [[ -a "/Library/Application Support/Octory" ]]; then

        # Octory is installed, but is it running?
        if [[ $(ps aux | grep -i "Octory" | grep -v grep) ]]; then
            echo "$(date) | Updating Octory monitor for [$appname] to [$1]"
            /usr/local/bin/octo-notifier monitor "$appname" --state $1 >/dev/null
        fi
    fi

}

function startLog() {

    ###################################################
    ###################################################
    ##
    ##  start logging - Output to log file and STDOUT
    ##
    ####################
    ####################

    if [[ ! -d "$logandmetadir" ]]; then
        ## Creating Metadirectory
        echo "$(date) | Creating [$logandmetadir] to store logs"
        mkdir -p "$logandmetadir"
    fi

    exec &> >(tee -a "$log")
    
}

# function to delay until the user has finished setup assistant.
waitForDesktop () {
  until ps aux | grep /System/Library/CoreServices/Dock.app/Contents/MacOS/Dock | grep -v grep &>/dev/null; do
    delay=$(( $RANDOM % 50 + 10 ))
    echo "$(date) |  + Dock not running, waiting [$delay] seconds"
    sleep $delay
  done
  echo "$(date) | Dock is here, lets carry on"
}

###################################################################################
###################################################################################
##
## Begin Script Body
##
#####################################
#####################################

# Initiate logging
startLog

echo ""
echo "##############################################################"
echo "# $(date) | Logging install of [$appname] to [$log]"
echo "############################################################"
echo ""

# Check whether a version of Zscaler is already installed
if [ -d "/Applications/$appdir/$app" ]
then
    echo "$(date) | Zscaler already installed at /Applications/$appdir/$app"
    exit 0
fi

# Install Rosetta if we need it
checkForRosetta2

# Wait for Desktop
waitForDesktop

# Download app
downloadApp

# Install ZIP file
installZIP
