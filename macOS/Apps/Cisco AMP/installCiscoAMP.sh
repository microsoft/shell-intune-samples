#!/bin/bash
#set -x

############################################################################################
##
## Script to install Cisco AMP
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

##
## Note: This application requires that the following system extensions are allowed
##
##
## 2 extension(s)
## --- com.apple.system_extension.network_extension
## enabled	active	teamID	bundleID (version)	name	[state]
## *	*	DE8Y96K9QP	com.cisco.endpoint.svc.networkextension (1.15.5/837)	AMP Network Extension	[activated enabled]
## --- com.apple.system_extension.endpoint_security
## enabled	active	teamID	bundleID (version)	name	[state]
## *	*	DE8Y96K9QP	com.cisco.endpoint.svc.securityextension (1.15.5/837)	AMP Security Extension	[activated enabled]



# User Defined variables
weburl="Enter Your Azure Blob Storage URL Here"                                 # What is the Azure Blob Storage URL?
appname="Cisco AMP"                                                             # The name of our App deployment script (also used for Octory monitor)
app="Cisco AMP for Endpoints.app"                                               # The actual name of our App once installed
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/CiscoAMP"                  # The location of our logs and last updated data
processpath="/Applications/Cisco AMP for Endpoints/AMP for Endpoints Connector.app/Contents/MacOS/AMP for Endpoints Connector"    # The process name of the App we are installing
terminateprocess="true"                                                         # Do we want to terminate the running process? If false we'll wait until its not running
autoUpdate="true"                                                               # Application updates itself, if already installed we should exit

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
                /usr/sbin/softwareupdate --install-rosetta --agree-to-license
            
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
    echo "$(date) | Downloading $appname"

    cd "$tempdir"
    curl -f -s --connect-timeout 30 --retry 5 --retry-delay 60 -L -J -O "$weburl"
    if [ $? == 0 ]; then

            # We have downloaded a file, we need to know what the file is called and what type of file it is
            tempSearchPath="$tempdir/*"
            for f in $tempSearchPath; do
                tempfile=$f
            done

            case $tempfile in

            *.pkg|*.PKG)
                packageType="PKG"
                ;;

            *.zip|*.ZIP)
                packageType="ZIP"
                ;;

            *.dmg|*.DMG)
                packageType="DMG"
                ;;

            *)
                # We can't tell what this is by the file name, lets look at the metadata
                echo "$(date) | Unknown file type [$f], analysing metadata"
                metadata=$(file "$tempfile")
                if [[ "$metadata" == *"Zip archive data"* ]]; then
                    packageType="ZIP"
                    mv "$tempfile" "$tempdir/install.zip"
                    tempfile="$tempdir/install.zip"
                fi

                if [[ "$metadata" == *"xar archive"* ]]; then
                    packageType="PKG"
                    mv "$tempfile" "$tempdir/install.pkg"
                    tempfile="$tempdir/install.pkg"
                fi

                if [[ "$metadata" == *"bzip2 compressed data"* ]] || [[ "$metadata" == *"zlib compressed data"* ]] ; then
                    packageType="DMG"
                    mv "$tempfile" "$tempdir/install.dmg"
                    tempfile="$tempdir/install.dmg"
                fi
                ;;
            esac

            if [[ ! $packageType ]]; then
                echo "Failed to determine temp file type [$metadata]"
                rm -rf "$tempdir"
            else
                echo "$(date) | Downloaded [$app] to [$tempfile]"
                echo "$(date) | Detected install type as [$packageType]"
            fi
         
    else
    
         echo "$(date) | Failure to download [$weburl] to [$tempfile]"
         exit 1
    fi

}


## Install DMG Function
function installDMG () {

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
    #waitForProcess "$processpath" "300" "$terminateprocess"

    #echo "$(date) | Installing [$appname]"
    #updateOctory installing

    # Mount the dmg file...
    volume="$tempdir/$appname"
    echo "$(date) | Mounting Image"
    hdiutil attach -quiet -nobrowse -mountpoint "$volume" "$tempfile"

    # This is a PKG, so we need to call the installer
    installer -pkg "$volume"/ciscoampmac_connector.pkg -target /Applications


    # Unmount the dmg
    echo "$(date) | Un-mounting [$volume]"
    hdiutil detach -quiet "$volume"

    # Checking if the app was installed successfully

    #if [[ -a "/Applications/$app" ]]; then

     #   echo "$(date) | [$appname] Installed"
      #  echo "$(date) | Cleaning Up"
       # rm -rf "$tempfile"

        #echo "$(date) | Fixing up permissions"
        #sudo chown -R root:wheel "/Applications/$app"
        #echo "$(date) | Application [$appname] succesfully installed"
        #fetchLastModifiedDate update
        #updateOctory installed
        #exit 0
    #else
     #   echo "$(date) | Failed to install [$appname]"
      #  rm -rf "$tempdir"
       # updateOctory failed
       # exit 1
    #fi

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

# Install Rosetta if we need it
checkForRosetta2

# Wait for Desktop
waitForDesktop

# Download app
downloadApp

# Install DMG file
if [[ $packageType == "DMG" ]]; then
    installDMG
fi
