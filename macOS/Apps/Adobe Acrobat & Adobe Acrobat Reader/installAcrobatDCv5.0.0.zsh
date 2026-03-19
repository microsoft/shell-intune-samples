#!/bin/zsh
#set -x

############################################################################################
##
## Script to install the latest Adobe Acrobat Reader DC for Apple Silicon (arm64) Macs
## 
## VER 5.0.0
##
## Change Log
##
## 2025-12-22   - Performance improvements and code optimization
##              - Optimized logdate function for efficient timestamp generation
##              - Enhanced installAria2c with improved error handling and cleanup
##              - Improved downloadApp DMG detection using efficient find commands
##              - Optimized installDMGPKG to handle multiple PKG files in one loop
##              - Enhanced error handling across all install functions (ZIP, BZ2, TGZ)
##              - Improved file operations using modern zsh syntax
##              - Fixed typo: downlading -> downloading
##              - Fixed PKG installer target (/ instead of $appdir) 
##              - Fixed TGZ metadata detection (was incorrectly set to BZ2)
##              - Added global ARIA2 variable initialization
##              - Removed -o flag from aria2c download (auto-detects filename)
##              - Added validation for downloaded files
##              - Replaced multiple if statements with case statement for package type dispatch
##              - Improved error handling for mount operations across all install functions
##              - Added cleanup on both APP and PKG detection in same DMG
##              - Consolidated metadata detection into nested case statement
##              - Trimmed whitespace from wc output for reliable comparisons
##              - Fixed all instances of 'succesfully' -> 'successfully'
##              - Removed Rosetta 2 check and installation functionality
##              - Added dot_clean to BZ2 and TGZ install functions for consistency
##              - Removed Intel/x64 architecture support (Apple Silicon/arm64 only)
##              - CRITICAL FIX: Added missing appdir variable definition
##              - Added retry logic for post-installation verification (5 attempts with 1s delay)
##              - Enhanced logging for installation verification with detailed diagnostics
##              - CRITICAL FIX: Corrected app name from "Adobe Acrobat Reader DC.app" to "Adobe Acrobat Reader.app"
##                (Adobe installer creates app without "DC" suffix)
##
############################################################################################

## Copyright (c) 2025 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: neiljohn@microsoft.com or ckunze@microsoft.com

# User Defined variables

# Application URL (Apple Silicon/arm64 only)
currentVersion=$(curl -LSs "https://armmf.adobe.com/arm-manifests/mac/AcrobatDC/acrobat/current_version.txt" | sed 's/\.//g')
weburl="https://ardownload2.adobe.com/pub/adobe/reader/mac/AcrobatDC/${currentVersion}/AcroRdrDC_${currentVersion}_MUI.dmg"
appname="Adobe Acrobat Reader DC"                                                       # The name of our App deployment script (also used for Octory monitor)
app="Adobe Acrobat Reader.app"                                                          # The actual name of our App once installed (NOTE: no "DC" in app name)
appdir="/Applications"                                                                  # The directory where the app will be installed
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/Adobe Acrobat Reader DC"           # The location of our logs and last updated data
processpath="/Applications/Adobe Acrobat Reader.app/Contents/MacOS/AdobeReader"         # The process name of the App we are installing
terminateprocess="false"                                                                # Do we want to terminate the running process? If false we'll wait until its not running
autoUpdate="true" 

# Generated variables
tempdir=$(mktemp -d)
log="$logandmetadir/$appname.log"                                               # The location of the script log file
metafile="$logandmetadir/$appname.meta"                                         # The location of our meta file (for updates)
logdate() { date '+%Y-%m-%d %H:%M:%S'; }                                         # Function to generate timestamps efficiently
ARIA2="/usr/local/aria2/bin/aria2c"                                             # Path to aria2c binary


function installAria2c () {

    #####################################
    ## Aria2c installation
    #####################
    aria2Url="https://github.com/aria2/aria2/releases/download/release-1.35.0/aria2-1.35.0-osx-darwin.dmg"
    
    if [[ -f "$ARIA2" ]]; then
        echo "$(logdate) | Aria2 already installed, nothing to do"
        return
    fi
    
    echo "$(logdate) | Aria2 missing, lets download and install"
    filename=$(basename "$aria2Url")
    output="$tempdir/$filename"
    
    if ! curl -f -s --connect-timeout 30 --retry 5 --retry-delay 60 -L -o "$output" "$aria2Url"; then
        echo "$(logdate) | Aria download failed"
        echo "$(logdate) | Output: [$output]"
        echo "$(logdate) | URL [$aria2Url]"
        return 1
    fi
    echo "$(logdate) | Downloaded aria2"

    # Mount aria2 DMG
    mountpoint="$tempdir/aria2"
    echo "$(logdate) | Mounting Aria DMG..."
    if ! hdiutil attach -quiet -nobrowse -mountpoint "$mountpoint" "$output"; then
        echo "$(logdate) | Aria mount failed"
        rm -rf "$output"
        return 1
    fi
    echo "$(logdate) | Mounted DMG"
    
    # Install aria2 PKG from inside the DMG
    if sudo installer -pkg "$mountpoint/aria2.pkg" -target /; then
        echo "$(logdate) | Aria2 installed"
        hdiutil detach -quiet "$mountpoint"
        rm -rf "$output"
    else
        echo "$(logdate) | Install failed"
        echo "$(logdate) | PKG: [$mountpoint/aria2.pkg]"
        hdiutil detach -quiet "$mountpoint"
        rm -rf "$output"
        return 1
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

    echo "$(logdate) | Waiting for other [$processName] processes to end"
    while pgrep -f "$processName" &>/dev/null; do

        if [[ $terminate == "true" ]]; then
            echo "$(logdate) | + [$appname] running, terminating [$processName]..."
            pkill -9 -f "$processName"
            return
        fi

        # If we've been passed a delay we should use it, otherwise we'll create a random delay each run
        if [[ ! $fixedDelay ]]; then
            delay=$(( $RANDOM % 50 + 10 ))
        else
            delay=$fixedDelay
        fi

        echo "$(logdate) |  + Another instance of $processName is running, waiting [$delay] seconds"
        sleep $delay
    done
    
    echo "$(logdate) | No instances of [$processName] found, safe to proceed"

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
    ##      $logandmetadir = Directory to read and write meta data to
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
        echo "$(logdate) | Creating [$logandmetadir] to store metadata"
        mkdir -p "$logandmetadir"
    fi

    # generate the last modified date of the file we need to download
    lastmodified=$(curl -sIL "$weburl" | awk -F': ' 'tolower($1) == "last-modified" {gsub(/\r/, "", $2); print $2; exit}')

    if [[ $1 == "update" ]]; then
        echo "$(logdate) | Writing last modifieddate [$lastmodified] to [$metafile]"
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
    ##      None
    ##
    ##  Variables
    ##
    ##      $appname = Description of the App we are installing
    ##      $weburl = URL of download location
    ##      $tempfile = location of temporary file downloaded
    ##      $packageType = Type of package detected (PKG, ZIP, DMG, etc.)
    ##
    ###############################################################
    ###############################################################

    echo "$(logdate) | Starting downloading of [$appname]"

    #download the file
    echo "$(logdate) | Downloading $appname [$weburl]"

    cd "$tempdir" || { echo "$(logdate) | Failed to access tempdir"; exit 1; }
    #curl -f -s --connect-timeout 30 --retry 5 --retry-delay 60 --compressed -L -J -O "$weburl"
    if ! $ARIA2 -q -x16 -s16 -d "$tempdir" "$weburl" --download-result=hide --summary-interval=0; then
        echo "$(logdate) | Failure to download [$weburl]"
        rm -rf "$tempdir"
        exit 1
    fi

    # We have downloaded a file, we need to know what the file is called and what type of file it is
    tempfile=$(ls -1 "$tempdir" | head -1)
    if [[ -z "$tempfile" ]]; then
        echo "$(logdate) | No file found after download"
        rm -rf "$tempdir"
        exit 1
    fi
    echo "$(logdate) | Found downloaded tempfile [$tempfile]"

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
        echo "$(logdate) | Unknown file type [$tempfile], analysing metadata"
        metadata=$(file -bz "$tempdir/$tempfile")

        echo "$(logdate) | [DEBUG] File metadata [$metadata]"

        case "$metadata" in
            *"Zip archive data"*)
                packageType="ZIP"
                mv "$tempfile" "$tempdir/install.zip"
                tempfile="install.zip"
                ;;
            *"xar archive"*)
                packageType="PKG"
                mv "$tempfile" "$tempdir/install.pkg"
                tempfile="install.pkg"
                ;;
            *"DOS/MBR boot sector"*|*"Apple Driver Map"*)
                packageType="DMG"
                mv "$tempfile" "$tempdir/install.dmg"
                tempfile="install.dmg"
                ;;
            *"POSIX tar archive (bzip2 compressed data"*)
                packageType="BZ2"
                mv "$tempfile" "$tempdir/install.tar.bz2"
                tempfile="install.tar.bz2"
                ;;
            *"POSIX tar archive (gzip compressed data"*)
                packageType="TGZ"
                mv "$tempfile" "$tempdir/install.tar.gz"
                tempfile="install.tar.gz"
                ;;
            *)
                echo "$(logdate) | Unable to identify file type from metadata"
                ;;
        esac
        ;;
    esac

    if [[ "$packageType" == "DMG" ]]; then
        # We have what we think is a DMG, but we don't know what is inside it yet, could be an APP or PKG or ZIP
        # Let's mount it and try to guess what we're dealing with...
        echo "$(logdate) | Found DMG, looking inside..."

        # Mount the dmg file...
        volume="$tempdir/$appname"
        echo "$(logdate) | Mounting Image [$volume] [$tempdir/$tempfile]"
        if hdiutil attach -quiet -nobrowse -mountpoint "$volume" "$tempdir/$tempfile"; then
            echo "$(logdate) | Mounted successfully to [$volume]"
            
            # Check contents more efficiently
            has_app=$(find "$volume" -maxdepth 1 -iname "*.app" 2>/dev/null | wc -l | tr -d ' ')
            has_pkg=$(find "$volume" -maxdepth 1 \( -iname "*.pkg" -o -iname "*.mpkg" \) 2>/dev/null | wc -l | tr -d ' ')
            
            if [[ $has_app -gt 0 && $has_pkg -gt 0 ]]; then
                echo "$(logdate) | Detected both APP and PKG in same DMG, exiting gracefully"
                hdiutil detach -quiet "$volume"
                rm -rf "$tempdir"
                exit 1
            elif [[ $has_app -gt 0 ]]; then
                echo "$(logdate) | Detected APP, setting PackageType to DMG"
                packageType="DMG"
            elif [[ $has_pkg -gt 0 ]]; then
                echo "$(logdate) | Detected PKG, setting PackageType to DMGPKG"
                packageType="DMGPKG"
            fi
            
            # Unmount the dmg
            echo "$(logdate) | Un-mounting [$volume]"
            hdiutil detach -quiet "$volume"
        else
            echo "$(logdate) | Failed to mount [$tempdir/$tempfile]"
            rm -rf "$tempdir"
            exit 1
        fi
    fi

    if [[ -z "$packageType" ]]; then
        echo "$(logdate) | Failed to determine temp file type [$metadata]"
        rm -rf "$tempdir"
        exit 1
    fi

    echo "$(logdate) | Downloaded [$app] to [$tempfile]"
    echo "$(logdate) | Detected install type as [$packageType]"

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
    ##      $appdir = directory path for the Application directory
    ##      $app = name of Application directory under $appdir
    ##      $autoUpdate = whether app handles its own updates
    ##      $lastmodified = last modified date from server
    ##      $metafile = location of stored last modified date
    ##
    ###############################################################
    ###############################################################


    echo "$(logdate) | Checking if we need to install or update [$appname]"

    ## Is the app already installed?
    if [[ -d "$appdir/$app" ]]; then

    # App is installed, if it's updates are handled by MAU we should quietly exit
    if [[ $autoUpdate == "true" ]]; then
        echo "$(logdate) | [$appname] is already installed and handles updates itself, exiting"
        exit 0
    fi

    # App is already installed, we need to determine if it requires updating or not
        echo "$(logdate) | [$appname] already installed, let's see if we need to update"
        fetchLastModifiedDate

        ## Did we store the last modified date last time we installed/updated?
        if [[ -d "$logandmetadir" ]]; then

            if [[ -f "$metafile" ]]; then
                previouslastmodifieddate=$(cat "$metafile")
                if [[ "$previouslastmodifieddate" != "$lastmodified" ]]; then
                    echo "$(logdate) | Update found, previous [$previouslastmodifieddate] and current [$lastmodified]"
                else
                    echo "$(logdate) | No update between previous [$previouslastmodifieddate] and current [$lastmodified]"
                    echo "$(logdate) | Exiting, nothing to do"
                    exit 0
                fi
            else
                echo "$(logdate) | Meta file [$metafile] not found"
                echo "$(logdate) | Unable to determine if update required, updating [$appname] anyway"

            fi
            
        fi

    else
        echo "$(logdate) | [$appname] not installed, need to download and install"
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
    ##      $tempfile = location of temporary PKG file downloaded
    ##      $appdir = directory path for the Application directory
    ##      $app = name of Application directory under $appdir
    ##      $processpath = path to the running process to check
    ##      $terminateprocess = whether to terminate or wait for process
    ##
    ###############################################################
    ###############################################################


    # Check if app is running, if it is we need to wait.
    waitForProcess "$processpath" "300" "$terminateprocess"

    echo "$(logdate) | Installing $appname"

    # Remove existing files if present
    [[ -d "$appdir/$app" ]] && rm -rf "$appdir/$app"

    if installer -pkg "$tempdir/$tempfile" -target /; then
        echo "$(logdate) | $appname Installed"
        echo "$(logdate) | Application [$appname] successfully installed"
        fetchLastModifiedDate update
        rm -rf "$tempdir"
        exit 0
    else
        echo "$(logdate) | Failed to install $appname"
        rm -rf "$tempdir"
        exit 1
    fi

}

## Install DMG Function
function installDMGPKG () {

    #################################################################################################################
    #################################################################################################################
    ##
    ##  This function takes the following global variables and installs the DMG file into $appdir
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

    echo "$(logdate) | Installing [$appname]"

    # Mount the dmg file...
    volume="$tempdir/$appname"
    echo "$(logdate) | Mounting Image"
    if ! hdiutil attach -quiet -nobrowse -mountpoint "$volume" "$tempdir/$tempfile"; then
        echo "$(logdate) | Failed to mount DMG"
        rm -rf "$tempdir"
        exit 1
    fi

    # Remove existing files if present
    if [[ -d "$appdir/$app" ]]; then
        echo "$(logdate) | Removing existing files"
        rm -rf "$appdir/$app"
    fi

    # Install all PKG and MPKG files in one loop
    for file in "$volume"/*.{pkg,mpkg}(N); do
        [[ -f "$file" ]] || continue
        echo "$(logdate) | Starting installer for [$file]"
        if ! installer -pkg "$file" -target /; then
            echo "$(logdate) | Warning: Failed to install [$file]"
        fi
    done

    # Unmount the dmg
    echo "$(logdate) | Un-mounting [$volume]"
    hdiutil detach -quiet "$volume"

    # Wait for filesystem to sync and check if the app was installed successfully
    echo "$(logdate) | Waiting for installation to complete..."
    sleep 2
    
    # Check for app installation with detailed logging
    echo "$(logdate) | Checking for app at [$appdir/$app]"
    
    # Give it a few attempts in case of filesystem delays
    for attempt in {1..5}; do
        if [[ -e "$appdir/$app" ]]; then
            echo "$(logdate) | [$appname] Installed (found on attempt $attempt)"
            echo "$(logdate) | Fixing up permissions"
            sudo chown -R root:wheel "$appdir/$app"
            echo "$(logdate) | Application [$appname] successfully installed"
            fetchLastModifiedDate update
            rm -rf "$tempdir"
            exit 0
        fi
        [[ $attempt -lt 5 ]] && sleep 1
    done
    
    # If we get here, app was not found
    echo "$(logdate) | Failed to install [$appname]"
    echo "$(logdate) | Expected location: [$appdir/$app]"
    echo "$(logdate) | Checking /Applications directory:"
    ls -la "$appdir" | grep -i "acrobat" || echo "$(logdate) | No Adobe Acrobat apps found in $appdir"
    rm -rf "$tempdir"
    exit 1

}


## Install DMG Function
function installDMG () {

    #################################################################################################################
    #################################################################################################################
    ##
    ##  This function takes the following global variables and installs the DMG file into $appdir
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

    echo "$(logdate) | Installing [$appname]"

    # Mount the dmg file...
    volume="$tempdir/$appname"
    echo "$(logdate) | Mounting Image [$volume] [$tempdir/$tempfile]"
    if ! hdiutil attach -quiet -nobrowse -mountpoint "$volume" "$tempdir/$tempfile"; then
        echo "$(logdate) | Failed to mount DMG"
        rm -rf "$tempdir"
        exit 1
    fi

    # Remove existing files if present
    if [[ -d "$appdir/$app" ]]; then
        echo "$(logdate) | Removing existing files"
        rm -rf "$appdir/$app"
    fi

    # Sync the application and unmount once complete
    echo "$(logdate) | Copying app files to $appdir/$app"
    if ! rsync -a "$volume"/*.app/ "$appdir/$app"; then
        echo "$(logdate) | Failed to copy app files"
        hdiutil detach -quiet "$volume"
        rm -rf "$tempdir"
        exit 1
    fi

    # Make sure permissions are correct
    echo "$(logdate) | Fix up permissions"
    dot_clean "$appdir/$app"
    sudo chown -R root:wheel "$appdir/$app"

    # Unmount the dmg
    echo "$(logdate) | Un-mounting [$volume]"
    hdiutil detach -quiet "$volume"

    # Checking if the app was installed successfully
    if [[ -e "$appdir/$app" ]]; then
        echo "$(logdate) | [$appname] Installed"
        echo "$(logdate) | Application [$appname] successfully installed"
        fetchLastModifiedDate update
        rm -rf "$tempdir"
        exit 0
    else
        echo "$(logdate) | Failed to install [$appname]"
        rm -rf "$tempdir"
        exit 1
    fi

}

## Install ZIP Function
function installZIP () {

    #################################################################################################################
    #################################################################################################################
    ##
    ##  This function takes the following global variables and installs the ZIP file into $appdir
    ##
    ##  Functions
    ##
    ##      isAppRunning (Pauses installation if the process defined in global variable $processpath is running )
    ##      fetchLastModifiedDate (Called with update flag which causes the function to write the new lastmodified date to the metadata file)
    ##
    ##  Variables
    ##
    ##      $appname = Description of the App we are installing
    ##      $tempfile = location of temporary ZIP file downloaded
    ##      $appdir = directory path for the Application directory
    ##      $app = name of Application directory under $appdir
    ##
    ###############################################################
    ###############################################################


    # Check if app is running, if it is we need to wait.
    waitForProcess "$processpath" "300" "$terminateprocess"

    echo "$(logdate) | Installing $appname"

    # Unzip files in temp dir
    if ! unzip -qq -o "$tempdir/$tempfile" -d "$tempdir"; then
        echo "$(logdate) | failed to unzip $tempfile"
        rm -rf "$tempdir"
        exit 1
    fi
    echo "$(logdate) | $tempfile unzipped"

    # Remove old installation if present
    [[ -e "$appdir/$app" ]] && rm -rf "$appdir/$app"

    # Copy over new files
    if ! rsync -a "$tempdir/$app/" "$appdir/$app"; then
        echo "$(logdate) | failed to move $appname to $appdir"
        rm -rf "$tempdir"
        exit 1
    fi
    echo "$(logdate) | $appname moved into $appdir"

    # Make sure permissions are correct
    echo "$(logdate) | Fix up permissions"
    dot_clean "$appdir/$app"
    sudo chown -R root:wheel "$appdir/$app"

    # Verify installation
    if [[ -e "$appdir/$app" ]]; then
        echo "$(logdate) | $appname Installed"
        echo "$(logdate) | Application [$appname] successfully installed"
        fetchLastModifiedDate update
        rm -rf "$tempdir"
        exit 0
    else
        echo "$(logdate) | Failed to install $appname"
        rm -rf "$tempdir"
        exit 1
    fi
}

## Install BZ2 Function
function installBZ2 () {

    #################################################################################################################
    #################################################################################################################
    ##
    ##  This function takes the following global variables and installs the BZ2 file into $appdir
    ##
    ##  Functions
    ##
    ##      isAppRunning (Pauses installation if the process defined in global variable $processpath is running )
    ##      fetchLastModifiedDate (Called with update flag which causes the function to write the new lastmodified date to the metadata file)
    ##
    ##  Variables
    ##
    ##      $appname = Description of the App we are installing
    ##      $tempfile = location of temporary BZ2 file downloaded
    ##      $appdir = directory path for the Application directory
    ##      $app = name of Application directory under $appdir
    ##
    ###############################################################
    ###############################################################


    # Check if app is running, if it is we need to wait.
    waitForProcess "$processpath" "300" "$terminateprocess"

    echo "$(logdate) | Installing $appname"

    # Extract BZ2 archive
    if ! tar -jxf "$tempdir/$tempfile" -C "$tempdir"; then
        echo "$(logdate) | failed to uncompress $tempfile"
        rm -rf "$tempdir"
        exit 1
    fi
    echo "$(logdate) | $tempfile uncompressed"

    # Remove old installation if present
    [[ -e "$appdir/$app" ]] && rm -rf "$appdir/$app"

    # Copy over new files
    if ! rsync -a "$tempdir/$app/" "$appdir/$app"; then
        echo "$(logdate) | failed to move $appname to $appdir"
        rm -rf "$tempdir"
        exit 1
    fi
    echo "$(logdate) | $appname moved into $appdir"

    # Fix permissions
    echo "$(logdate) | Fix up permissions"
    dot_clean "$appdir/$app"
    sudo chown -R root:wheel "$appdir/$app"

    # Verify installation
    if [[ -e "$appdir/$app" ]]; then
        echo "$(logdate) | $appname Installed"
        echo "$(logdate) | Application [$appname] successfully installed"
        fetchLastModifiedDate update
        rm -rf "$tempdir"
        exit 0
    else
        echo "$(logdate) | Failed to install $appname"
        rm -rf "$tempdir"
        exit 1
    fi
}

## Install TGZ Function
function installTGZ () {

    #################################################################################################################
    #################################################################################################################
    ##
    ##  This function takes the following global variables and installs the TGZ file into $appdir
    ##
    ##  Functions
    ##
    ##      isAppRunning (Pauses installation if the process defined in global variable $processpath is running )
    ##      fetchLastModifiedDate (Called with update flag which causes the function to write the new lastmodified date to the metadata file)
    ##
    ##  Variables
    ##
    ##      $appname = Description of the App we are installing
    ##      $tempfile = location of temporary TGZ file downloaded
    ##      $appdir = directory path for the Application directory
    ##      $app = name of Application directory under $appdir
    ##
    ###############################################################
    ###############################################################


    # Check if app is running, if it is we need to wait.
    waitForProcess "$processpath" "300" "$terminateprocess"

    echo "$(logdate) | Installing $appname"

    # Extract TGZ archive
    if ! tar -zxf "$tempdir/$tempfile" -C "$tempdir"; then
        echo "$(logdate) | failed to uncompress $tempfile"
        rm -rf "$tempdir"
        exit 1
    fi
    echo "$(logdate) | $tempfile uncompressed"

    # Remove old installation if present
    [[ -e "$appdir/$app" ]] && rm -rf "$appdir/$app"

    # Copy over new files
    if ! rsync -a "$tempdir/$app/" "$appdir/$app"; then
        echo "$(logdate) | failed to move $appname to $appdir"
        rm -rf "$tempdir"
        exit 1
    fi
    echo "$(logdate) | $appname moved into $appdir"

    # Fix permissions
    echo "$(logdate) | Fix up permissions"
    dot_clean "$appdir/$app"
    sudo chown -R root:wheel "$appdir/$app"

    # Verify installation
    if [[ -e "$appdir/$app" ]]; then
        echo "$(logdate) | $appname Installed"
        echo "$(logdate) | Application [$appname] successfully installed"
        fetchLastModifiedDate update
        rm -rf "$tempdir"
        exit 0
    else
        echo "$(logdate) | Failed to install $appname"
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
        echo "$(logdate) | Creating [$logandmetadir] to store logs"
        mkdir -p "$logandmetadir"
    fi

    exec > >(tee -a "$log") 2>&1
    
}

# function to delay until the user has finished setup assistant.
waitForDesktop () {
  until pgrep -x Dock &>/dev/null; do
    delay=$(( $RANDOM % 50 + 10 ))
    echo "$(logdate) |  + Dock not running, waiting [$delay] seconds"
    sleep $delay
  done
  echo "$(logdate) | Dock is here, lets carry on"
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
echo "# $(logdate) | Logging install of [$appname] to [$log]"
echo "############################################################"
echo ""

# Install Aria2c if we don't already have it
installAria2c

# Test if we need to install or update
updateCheck

# Wait for Desktop
waitForDesktop

# Download app
downloadApp

# Install based on package type
case $packageType in
    PKG)
        installPKG
        ;;
    ZIP)
        installZIP
        ;;
    BZ2)
        installBZ2
        ;;
    TGZ)
        installTGZ
        ;;
    DMG)
        installDMG
        ;;
    DMGPKG)
        installDMGPKG
        ;;
    *)
        echo "$(logdate) | Unknown package type: [$packageType]"
        rm -rf "$tempdir"
        exit 1
        ;;
esac
