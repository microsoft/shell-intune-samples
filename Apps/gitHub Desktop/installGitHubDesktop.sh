#!/bin/bash
#set -x

############################################################################################
##
## Script to download latest gitHub Desktop for macOS
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
tempfile="/tmp/githubdesktop.zip"                                                              # What filename are we going to store the downloaded files in?
weburl="https://neiljohn.blob.core.windows.net/macapps/GitHubDesktop.zip"                      # What is the Azure Blob Storage URL?
appname="GitHub Desktop"                                                                       # The name of our App deployment script
app="GitHub Desktop.app"                                                                       # The actual name of our App once installed
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/installGitHubDesktop"                     # The location of our logs and last updated data
processpath="/Applications/GitHub Desktop.app/Contents/MacOS/GitHub Desktop"                   # The process name of the App we are installing
terminateprocess="false"                                                                       # Do we want to terminate the running process? If false we'll wait until its not running

# Generated variables
log="$logandmetadir/$appname.log"                                         # The location of the script log file
metafile="$logandmetadir/$appname.meta"                                   # The location of our meta file (for updates)
volume="/tmp/$appname"

# function to delay download if another download is running
waitForCurl () {

    #################################################################################################################
    #################################################################################################################
    ##
    ##  Function to pause while other Curl processes are running to avoid swamping the network connection
    ##
    ##  Functions used
    ##
    ##      None
    ##
    ##  Variables used
    ##
    ##      None
    ##
    ###############################################################
    ###############################################################

    echo "$(date) | Waiting for other Curl processes to end"
     while ps aux | grep -i curl | grep -v grep &>/dev/null; do
          echo "$(date) |  + Another instance of Curl is running, waiting 10s"
          sleep 10
     done
     echo "$(date) | No instances of Curl found, safe to proceed"

}

# function to check if app is running and either terminate or wait
isAppRunning () {

    #################################################################################################################
    #################################################################################################################
    ##
    ##  Function to either terminate running application or wait until user closes it before we update
    ##
    ##  Functions used
    ##
    ##      None
    ##
    ##  Variables used
    ##
    ##      $terminateprocess = global variable if "true", kill the process or "false" wait until it's closed by the user
    ##      $processpath = path to application binary
    ##      $appname = Description of the App we are installing
    ##
    ###############################################################
    ###############################################################

    echo "$(date) | Checking if the application is running"
    while ps aux | grep -i "$processpath" | grep -v grep &>/dev/null; do
      if [ $terminateprocess == "false" ]; then
        echo "$(date) |  + [$appname] running, waiting 5m..."
        sleep 300
      else
        echo "$(date) | + [$appname] running, terminating [$processpath]..."
        pkill -f "$processpath"
      fi
    done

    echo "$(date) | [$appname] isn't running, lets carry on"

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
    ##      isSoftwareUpdateRunning (pauses check if softwareupdate already running since it could be in the process of installing Rosetta anyway)
    ##
    ##  Variables
    ##
    ##      None
    ##
    ###############################################################
    ###############################################################

    echo "$(date) | Checking if we need Rosetta 2 or not"

    # if Software update is already running, we need to wait...
    while ps aux | grep -i "/usr/sbin/softwareupdate" | grep -v grep &>/dev/null; do

        echo "$(date) | [/usr/sbin/softwareupdate] running, waiting 10s"
        sleep 10

    done

    processor=$(/usr/sbin/sysctl -n machdep.cpu.brand_string)
    if [[ "$processor" == *"Intel"* ]]; then

        echo "$(date) | [$processor] found, Rosetta not needed"
        
    else

        echo "$(date) | [$processor] founbd, is Rosetta already installed?"

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
    waitForCurl

    #download the file
    updateOctory installing
    echo "$(date) | Downloading $appname"

    curl -f -s --connect-timeout 30 --retry 5 --retry-delay 60 -L -o "$tempfile" "$weburl"
    if [ $? == 0 ]; then
         echo "$(date) | Downloaded [$app]"
    else
    
         echo "$(date) | Failure to download [$weburl] to [$tempfile]"
         exit 1
    fi

}

# Function to check if we need to update or not
function updateCheck() {

    #################################################################################################################
    #################################################################################################################
    ##
    ##  This function takes the following dependencies and variables and exits if no update is required
    ##
    ##  Functions
    ##
    ##      fetchLastModifiedDate
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


    echo "$(date) | Checking if we need to install or update [$appname]"

    ## Is the app already installed?
    if [ -d "/Applications/$app" ]; then

    # App is already installed, we need to determine if it requires updating or not
        echo "$(date) | [$appname] already installed, let's see if we need to update"
        fetchLastModifiedDate

        ## Did we store the last modified date last time we installed/updated?
        if [[ -d "$logandmetadir" ]]; then

            if [ -f "$metafile" ]; then
                previouslastmodifieddate=$(cat "$metafile")
                if [[ "$previouslastmodifieddate" != "$lastmodified" ]]; then
                    echo "$(date) | Update found, previous [$previouslastmodifieddate] and current [$lastmodified]"
                    update="update"
                else
                    echo "$(date) | No update between previous [$previouslastmodifieddate] and current [$lastmodified]"
                    echo "$(date) | Exiting, nothing to do"
                    exit 0
                fi
            else
                echo "$(date) | Meta file [$metafile] not found"
                echo "$(date) | Unable to determine if update required, updating [$appname] anyway"

            fi
            
        fi

    else
        echo "$(date) | [$appname] not installed, need to download and install"
    fi

}

## Install DMG Function
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
    isAppRunning

    echo "$(date) | Installing $appname"
    updateOctory installing

    cd "$tempdir"
    rm -rf "$app"
    unzip -qq -o "$tempfile"
    if [ "$?" = "0" ]; then
      echo "$(date) | $tempfile unzipped"
    else
      echo "$(date) | failed to unzip $tmpfile"
      updateOctory failed
      exit 1
    fi

    if [[ -a "/Applications/$app" ]]; then
    
      echo "$(date) | Renoving old installation at /Applications/$app"
      rm -rf "/Applications/$app"
    
    fi

    \cp -Rf "$app/" "/Applications/$app/"
    if [ "$?" = "0" ]; then
      echo "$(date) | $appname moved into /Applications"
    else
      echo "$(date) | failed to move $appname to /Applications"
      updateOctory failed
      exit 1
    fi

    echo "$(date) | Fix up permissions"
    sudo chown -R root:wheel "/Applications/$app"
    if [ "$?" = "0" ]; then
      echo "$(date) | correctly applied permissions to $appname"
    else
      echo "$(date) | failed to apply permissions to $appname"
      updateOctory failed
      exit 1
    fi

    # Checking if the app was installed successfully
    if [ "$?" = "0" ]; then
        if [[ -a "/Applications/$app" ]]; then

            echo "$(date) | $appname Installed"
            updateOctory installed
            echo "$(date) | Cleaning Up"
            rm -rf "$tempfile"

            echo "$(date) | Writing last modifieddate $lastmodified to $metafile"
            echo "$lastmodified" > "$metafile"

            echo "$(date) | Fixing up permissions"
            sudo chown -R root:wheel "/Applications/$app"
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
            /Library/Application\ Support/Octory/octo-notifier monitor "$appname" --state $1 >/dev/null
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

# Install Rosetta if we need it
checkForRosetta2

# Test if we need to install or update
updateCheck

# Download app
downloadApp

# Install ZIP file
installZIP

