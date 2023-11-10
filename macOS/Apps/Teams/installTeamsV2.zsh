#!/bin/zsh
#set -x

############################################################################################
##
## Script to install the latest [Teams V2]
## 
## VER 4.0.5
##
## Change Log
##
## 2023-11-10   - changed function order to check for Rosetta first
## 2023-08-07   - Add missing logandmetadir prefix 'install'
## 2023-08-07   - Make /Applications target configurable
## 2023-08-07   - Added detection support for tgz and tar.gz
## 2023-07-17   - Fixed bug in installAria2c function that was causing problems for DMGs
## 2023-06-23   - Changed from Curl to Aria2 for main package download
## 2023-02-03   - Changed ZIP and DMG process to include dot_clean after file copy
##              - Added Apple Silicon architecture detection logic
## 2022-06-24   - First re-write in ZSH
## 2022-06-20   - Fixed terminate process function bugs
## 2022-02-28   - Updated file type detection logic where we can't tell what the file is by filename in downloadApp function
## 2022-02-23   - Added detection support for bz2 and tbz2
## 2022-02-11   - Added detection support for mpkg
## 2022-01-05   - Updated Rosetta detection code
## 2021-11-19   - Added logic to handle both APP and PKG inside DMG file. New function DMGPKG
## 2021-12-06   - Added --compressed to curl cli
##              - Fixed DMGPKG detection
##
############################################################################################

## Copyright (c) 2023 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: neiljohn@microsoft.com

# User Defined variables

#
# Note, where you have a universal binary, either put the same URL for both, or set weburl explicitly
#
# Pick correct URL for the CPU architecture
if [[ $(uname -m) == 'arm64' ]]; then
    # This is Apple Silicon URL
    weburl="https://go.microsoft.com/fwlink/?linkid=2249065" 
    else
    # This is x64 URL
    weburl="https://go.microsoft.com/fwlink/?linkid=2249065"   
fi

appname="Microsoft Teams"                                               # The name of our App deployment script (also used for Octory monitor)
app="Microsoft Teams (work or school).app"                              # The actual name of our App once installed
appdir="/Applications/"                                                 # The location directory for the application (usually /Applications)
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/$appname"          # The location of our logs and last updated data
processpath="/Applications/$app/Contents/MacOS/Teams"                   # The process name of the App we are installing
terminateprocess="false"                                                # Do we want to terminate the running process? If false we'll wait until its not running
autoUpdate="true"                                                       # Application updates itself, if already installed we should exit
installTeamsAudioDriver="true"                                          # Controls if we should install the Teams Audio Driver or not

# Generated variables
tempdir=$(mktemp -d)
log="$logandmetadir/$appname.log"                                       # The location of the script log file
metafile="$logandmetadir/$appname.meta"                                 # The location of our meta file (for updates)


function installAria2c () {

    #####################################
    ## Aria2c installation
    #####################
    ARIA2="/usr/local/aria2/bin/aria2c"
    aria2Url="https://github.com/aria2/aria2/releases/download/release-1.35.0/aria2-1.35.0-osx-darwin.dmg"
    if [[ -f $ARIA2 ]]; then
        echo "$(date) | Aria2 already installed, nothing to do"
    else
        echo "$(date) | Aria2 missing, lets download and install"
        filename=$(basename "$aria2Url")
        output="$tempdir/$filename"
        curl -f -s --connect-timeout 30 --retry 5 --retry-delay 60 -L -o "$output" "$aria2Url"
        if [ $? -ne 0 ]; then
            echo "$(date) | Aria download failed"
            echo "$(date) | Output: [$output]"
            echo "$(date) | URL [$aria2Url]"
        else
            echo "$(date) | Downloaded aria2"
        fi

        # Mount aria2 DMG
        mountpoint="$tempdir/aria2"
        echo "$(date) | Mounting Aria DMG..."
        hdiutil attach -quiet -nobrowse -mountpoint "$mountpoint" "$output"
        if [ $? -ne 0 ]; then
            echo "$(date) | Aria mount failed"
            echo "$(date) | Mount: [$mountpoint]"
            echo "$(date) | Temp File [$output]"
        else
            echo "$(date) | Mounted DMG"
        fi
        
        # Install aria2 PKG from inside the DMG
        sudo installer -pkg "$mountpoint/aria2.pkg" -target /
        if [ $? -ne 0 ]; then
            echo "$(date) | Install failed"
            echo "$(date) | PKG: [$mountpoint/aria2.pkg]"
        else
            echo "$(date) | Aria2 installed"
            hdiutil detach -quiet "$mountpoint"
        fi
        rm -rf "$output"
    fi

}

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
            pid=$(ps -fe | grep "$processName" | grep -v grep | awk '{print $2}')
            echo "$(date) | + [$appname] running, terminating [$processName] at pid [$pid]..."
            kill -9 $pid
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
    lastmodified=$(curl -sIL "$weburl" | grep -i "last-modified:" | awk '{$1=""; print $0}' | awk '{ sub(/^[ \t]+/, ""); print }' | tr -d '\r')

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
    waitForProcess "$ARIA2"

    #download the file
    echo "$(date) | Downloading $appname [$weburl]"

    cd "$tempdir"
    #curl -f -s --connect-timeout 30 --retry 5 --retry-delay 60 --compressed -L -J -O "$weburl"
    $ARIA2 -q -x16 -s16 -d "$tempdir" -o "$tempfile" "$weburl" --download-result=hide --summary-interval=0
    if [[ $? == 0 ]]; then

            # We have downloaded a file, we need to know what the file is called and what type of file it is
            cd "$tempdir"
            for f in *; do
                tempfile=$f
                echo "$(date) | Found downloaded tempfile [$tempfile]"
            done

            case $tempfile in

            *.pkg|*.PKG|*.mpkg|*.MPKG)
                packageType="PKG"
                ;;

            *.zip|*.ZIP)
                packageType="ZIP"
                ;;

            *.tbz2|*.TBZ2|*.bz2|*.BZ2)
                packageType="BZ2"
                ;;

            *.tgz|*.TGZ|*.tar.gz|*.TAR.GZ)
                packageType="TGZ"
                ;;

            *.dmg|*.DMG)
                
                packageType="DMG"
                ;;

            *)
                # We can't tell what this is by the file name, lets look at the metadata
                echo "$(date) | Unknown file type [$f], analysing metadata"
                metadata=$(file -z "$tempfile")

                echo "$(date) | [DEBUG ] File metadata [$metadata]"

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

                if [[ "$metadata" == *"DOS/MBR boot sector, extended partition table"* ]] || [[ "$metadata" == *"Apple Driver Map"* ]] ; then
                packageType="DMG"
                mv "$tempfile" "$tempdir/install.dmg"
                tempfile="$tempdir/install.dmg"
                fi

                if [[ "$metadata" == *"POSIX tar archive (bzip2 compressed data"* ]]; then
                packageType="BZ2"
                mv "$tempfile" "$tempdir/install.tar.bz2"
                tempfile="$tempdir/install.tar.bz2"
                fi

                if [[ "$metadata" == *"POSIX tar archive (gzip compressed data"* ]]; then
                packageType="BZ2"
                mv "$tempfile" "$tempdir/install.tar.gz"
                tempfile="$tempdir/install.tar.gz"
                fi
                ;;
            esac

                
            if [[ "$packageType" == "DMG" ]]; then
                # We have what we think is a DMG, but we don't know what is inside it yet, could be an APP or PKG or ZIP
                # Let's mount it and try to guess what we're dealing with...
                echo "$(date) | Found DMG, looking inside..."

                # Mount the dmg file...
                volume="$tempdir/$appname"
                echo "$(date) | Mounting Image [$volume] [$tempfile]"
                hdiutil attach -quiet -nobrowse -mountpoint "$volume" "$tempfile"
                if [[ "$?" = "0" ]]; then
                    echo "$(date) | Mounted succesfully to [$volume]"
                else
                    echo "$(date) | Failed to mount [$tempfile]"
                    
                fi

                if  [[ $(ls "$volume" | grep -i .app) ]] && [[ $(ls "$volume" | grep -i .pkg) ]]; then

                    echo "$(date) | Detected both APP and PKG in same DMG, exiting gracefully"

                else

                    if  [[ $(ls "$volume" | grep -i .app) ]]; then 
                        echo "$(date) | Detected APP, setting PackageType to DMG"
                        packageType="DMG"
                    fi 

                    if  [[ $(ls "$volume" | grep -i .pkg) ]]; then 
                        echo "$(date) | Detected PKG, setting PackageType to DMGPKG"
                        packageType="DMGPKG"
                    fi 

                    if  [[ $(ls "$volume" | grep -i .mpkg) ]]; then 
                        echo "$(date) | Detected PKG, setting PackageType to DMGPKG"
                        packageType="DMGPKG"
                    fi 

                fi

                # Unmount the dmg
                echo "$(date) | Un-mounting [$volume]"
                hdiutil detach -quiet "$volume"
            fi


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
    ##      $appdir = directory path for the Application directory
    ##      $app = name of Application directory under $appdir
    ##
    ###############################################################
    ###############################################################


    echo "$(date) | Checking if we need to install or update [$appname][$appdir/$app]"

    ## Is the app already installed?
    if [[ -d "$appdir/$app" ]]; then

    # App is installed, if it's updates are handled by MAU we should quietly exit
    if [[ $autoUpdate == "true" ]]; then
        echo "$(date) | [$appname] is already installed and handles updates itself, exiting"
        exit 0;
    fi

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

## Install PKG Function
function installPKG () {

    #################################################################################################################
    #################################################################################################################
    ##
    ##  This function takes the following global variables and installs the PKG file
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
    ##      $appdir = directory path for the Application directory
    ##      $app = name of Application directory under $appdir
    ##
    ###############################################################
    ###############################################################


    # Check if app is running, if it is we need to wait.
    waitForProcess "$processpath" "300" "$terminateprocess"

    echo "$(date) | Installing $appname"

    # Remove existing files if present
    if [[ -d "$appdir/$app" ]]; then
        rm -rf "$appdir/$app"
    fi

# Need to write out new Choices XML that includes Audio Driver as required
cat << CHOICESXML > $tempdir/TeamsChoiceChanges.xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
	<dict>
		<key>attributeSetting</key>
		<true/>
		<key>choiceAttribute</key>
		<string>visible</string>
		<key>choiceIdentifier</key>
		<string>Teams</string>
	</dict>
	<dict>
		<key>attributeSetting</key>
		<false/>
		<key>choiceAttribute</key>
		<string>enabled</string>
		<key>choiceIdentifier</key>
		<string>Teams</string>
	</dict>
	<dict>
		<key>attributeSetting</key>
		<integer>1</integer>
		<key>choiceAttribute</key>
		<string>selected</string>
		<key>choiceIdentifier</key>
		<string>Teams</string>
	</dict>
	<dict>
		<key>attributeSetting</key>
		<false/>
		<key>choiceAttribute</key>
		<string>visible</string>
		<key>choiceIdentifier</key>
		<string>TeamsApp</string>
	</dict>
	<dict>
		<key>attributeSetting</key>
		<false/>
		<key>choiceAttribute</key>
		<string>enabled</string>
		<key>choiceIdentifier</key>
		<string>TeamsApp</string>
	</dict>
	<dict>
		<key>attributeSetting</key>
		<integer>1</integer>
		<key>choiceAttribute</key>
		<string>selected</string>
		<key>choiceIdentifier</key>
		<string>TeamsApp</string>
	</dict>
	<dict>
		<key>attributeSetting</key>
		<true/>
		<key>choiceAttribute</key>
		<string>visible</string>
		<key>choiceIdentifier</key>
		<string>AudioDevice</string>
	</dict>
	<dict>
		<key>attributeSetting</key>
		<true/>
		<key>choiceAttribute</key>
		<string>enabled</string>
		<key>choiceIdentifier</key>
		<string>AudioDevice</string>
	</dict>
	<dict>
		<key>attributeSetting</key>
		<integer>1</integer>
		<key>choiceAttribute</key>
		<string>selected</string>
		<key>choiceIdentifier</key>
		<string>AudioDevice</string>
	</dict>
</array>
</plist>
CHOICESXML

    # If we are installing the Teams Audio Driver, we need to use the Choices XML
    if [[ "$installTeamsAudioDriver" == "true" ]]; then
        echo "$(date) | Install $appname with Teams Audio Driver"
        installer -pkg "$tempfile" -target / -applyChoiceChangesXML "$tempdir/TeamsChoiceChanges.xml"
    else
        echo "$(date) | Install $appname without Teams Audio Driver"
        installer -pkg "$tempfile" -target /
    fi

    # Checking if the app was installed successfully
    if [ "$?" = "0" ]; then

        echo "$(date) | $appname Installed"
        echo "$(date) | Cleaning Up"
        rm -rf "$tempdir"

        echo "$(date) | Application [$appname] succesfully installed"
        fetchLastModifiedDate update
        exit 0

    else

        echo "$(date) | Failed to install $appname"
        rm -rf "$tempdir"
        exit 1
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

    exec > >(tee -a "$log") 2>&1
    
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

# Install Aria2c if we don't already have it
installAria2c

# Test if we need to install or update
updateCheck

# Wait for Desktop
waitForDesktop

# Download app
downloadApp

# Install PKG file
installPKG


