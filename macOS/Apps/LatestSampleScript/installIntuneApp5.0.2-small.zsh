#!/bin/zsh
weburl="https://web.whatsapp.com/desktop/mac_native/release/?configuration=Release&architecture=arm64"
appname="WhatsApp"
app="WhatsApp.app"
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/install$appname"
appdir="/Applications"
processpath="$appdir/$app/Contents/MacOS/$appname"
terminateprocess="false"
autoUpdate="false"
tempdir=$(mktemp -d)
log="$logandmetadir/$appname.log"
metafile="$logandmetadir/$appname.meta"
logdate() { date '+%Y-%m-%d %H:%M:%S'; }
ARIA2="/usr/local/aria2/bin/aria2c"


function installAria2c () {
    aria2Url="https://github.com/aria2/aria2/releases/download/release-1.35.0/aria2-1.35.0-osx-darwin.dmg"
    [[ -f "$ARIA2" ]] && return
    echo "$(logdate) | Installing aria2"
    output="$tempdir/$(basename "$aria2Url")"
    if ! curl -fsL --connect-timeout 30 --retry 3 -o "$output" "$aria2Url"; then
        echo "$(logdate) | Aria download failed"; return 1
    fi
    mountpoint="$tempdir/aria2"
    if ! hdiutil attach -quiet -nobrowse -mountpoint "$mountpoint" "$output"; then
        rm -rf "$output"; return 1
    fi
    if sudo installer -pkg "$mountpoint/aria2.pkg" -target /; then
        echo "$(logdate) | Aria2 installed"
    else
        echo "$(logdate) | Aria2 install failed"; hdiutil detach -quiet "$mountpoint"; rm -rf "$output"; return 1
    fi
    hdiutil detach -quiet "$mountpoint"; rm -rf "$output"
}

waitForProcess () {
    processName=$1; fixedDelay=$2; terminate=$3
    while pgrep -f "$processName" &>/dev/null; do
        [[ $terminate == "true" ]] && { pkill -9 -f "$processName"; return; }
        delay=${fixedDelay:-$(( $RANDOM % 50 + 10 ))}
        echo "$(logdate) | Waiting for $processName [$delay]s"; sleep $delay
    done
}

fetchLastModifiedDate() {
    [[ ! -d "$logandmetadir" ]] && mkdir -p "$logandmetadir"
    lastmodified=$(curl -sIL "$weburl" | awk -F': ' 'tolower($1)=="last-modified"{gsub(/\r/,"",$2);print $2;exit}')
    [[ $1 == "update" ]] && echo "$lastmodified" > "$metafile"
}

function downloadApp () {
    echo "$(logdate) | Downloading $appname"
    cd "$tempdir" || exit 1
    if ! $ARIA2 -q -x16 -s16 -d "$tempdir" "$weburl" --download-result=hide --summary-interval=0; then
        echo "$(logdate) | Download failed"; rm -rf "$tempdir"; exit 1
    fi
    tempfile=$(ls -1 "$tempdir" | head -1)
    [[ -z "$tempfile" ]] && { echo "$(logdate) | No file found"; rm -rf "$tempdir"; exit 1; }

    case $tempfile in
    *.pkg|*.PKG|*.mpkg|*.MPKG) packageType="PKG" ;;
    *.zip|*.ZIP) packageType="ZIP" ;;
    *.tbz2|*.TBZ2|*.bz2|*.BZ2) packageType="BZ2" ;;
    *.tgz|*.TGZ|*.tar.gz|*.TAR.GZ) packageType="TGZ" ;;
    *.dmg|*.DMG) packageType="DMG" ;;
    *)
        metadata=$(file -bz "$tempdir/$tempfile")
        case "$metadata" in
            *"Zip archive"*) packageType="ZIP"; mv "$tempfile" "$tempdir/install.zip"; tempfile="install.zip" ;;
            *"xar archive"*) packageType="PKG"; mv "$tempfile" "$tempdir/install.pkg"; tempfile="install.pkg" ;;
            *"DOS/MBR"*|*"Apple Driver"*) packageType="DMG"; mv "$tempfile" "$tempdir/install.dmg"; tempfile="install.dmg" ;;
            *"bzip2"*) packageType="BZ2"; mv "$tempfile" "$tempdir/install.tar.bz2"; tempfile="install.tar.bz2" ;;
            *"gzip"*) packageType="TGZ"; mv "$tempfile" "$tempdir/install.tar.gz"; tempfile="install.tar.gz" ;;
        esac ;;
    esac
    if [[ "$packageType" == "DMG" ]]; then
        volume="$tempdir/$appname"
        if hdiutil attach -quiet -nobrowse -mountpoint "$volume" "$tempdir/$tempfile"; then
            has_app=$(find "$volume" -maxdepth 1 -iname "*.app" 2>/dev/null | wc -l | tr -d ' ')
            has_pkg=$(find "$volume" -maxdepth 1 \( -iname "*.pkg" -o -iname "*.mpkg" \) 2>/dev/null | wc -l | tr -d ' ')
            [[ $has_app -gt 0 && $has_pkg -gt 0 ]] && { hdiutil detach -quiet "$volume"; rm -rf "$tempdir"; exit 1; }
            [[ $has_pkg -gt 0 ]] && packageType="DMGPKG"
            hdiutil detach -quiet "$volume"
        else
            rm -rf "$tempdir"; exit 1
        fi
    fi
    [[ -z "$packageType" ]] && { rm -rf "$tempdir"; exit 1; }
    echo "$(logdate) | Package type: $packageType"
}

# Check if we need to update or not
function updateCheck() {
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

## Install DMGPKG Function
function installDMGPKG () {
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

    # Checking if the app was installed successfully
    if [[ -e "$appdir/$app" ]]; then
        echo "$(logdate) | [$appname] Installed"
        echo "$(logdate) | Fixing up permissions"
        sudo chown -R root:wheel "$appdir/$app"
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


## Install DMG Function
function installDMG () {
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