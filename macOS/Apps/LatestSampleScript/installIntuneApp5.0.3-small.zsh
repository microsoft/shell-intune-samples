#!/bin/zsh
# Latest Sample Script for installing Apps for Mac. v5.0.3
# modify the variables below to fit your needs and environment

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
    if ! curl -f -s --connect-timeout 30 --retry 5 --retry-delay 60 --compressed -L -o "$tempdir/download" "$weburl"; then
        echo "$(logdate) | Download failed"; rm -rf "$tempdir"; exit 1
    fi
    local realname=$(curl -sIL "$weburl" | awk -F'filename=' 'tolower($0) ~ /content-disposition/ && $2 {gsub(/["\r]/, "", $2); print $2; exit}')
    if [[ -n "$realname" ]]; then
        mv "$tempdir/download" "$tempdir/$realname"
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

function updateCheck() {
    echo "$(logdate) | Checking if we need to install or update [$appname]"
    if [[ -d "$appdir/$app" ]]; then
        if [[ $autoUpdate == "true" ]]; then
            echo "$(logdate) | [$appname] is already installed and handles updates itself, exiting"
            exit 0
        fi
        echo "$(logdate) | [$appname] already installed, let's see if we need to update"
        fetchLastModifiedDate
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

function installPKG () {
    waitForProcess "$processpath" "300" "$terminateprocess"
    echo "$(logdate) | Installing $appname"
    [[ -d "$appdir/$app" ]] && rm -rf "$appdir/$app"
    if installer -pkg "$tempdir/$tempfile" -target /; then
        echo "$(logdate) | $appname Installed"
        echo "$(logdate) | Application [$appname] successfully installed"
        fetchLastModifiedDate update
        rm -rf "$tempdir"; exit 0
    else
        echo "$(logdate) | Failed to install $appname"
        rm -rf "$tempdir"; exit 1
    fi
}

function installDMGPKG () {
    waitForProcess "$processpath" "300" "$terminateprocess"
    echo "$(logdate) | Installing [$appname]"
    volume="$tempdir/$appname"
    echo "$(logdate) | Mounting Image"
    if ! hdiutil attach -quiet -nobrowse -mountpoint "$volume" "$tempdir/$tempfile"; then
        echo "$(logdate) | Failed to mount DMG"; rm -rf "$tempdir"; exit 1
    fi
    [[ -d "$appdir/$app" ]] && rm -rf "$appdir/$app"
    for file in "$volume"/*.{pkg,mpkg}(N); do
        [[ -f "$file" ]] || continue
        echo "$(logdate) | Starting installer for [$file]"
        installer -pkg "$file" -target / || echo "$(logdate) | Warning: Failed to install [$file]"
    done
    echo "$(logdate) | Un-mounting [$volume]"
    hdiutil detach -quiet "$volume"
    if [[ -e "$appdir/$app" ]]; then
        echo "$(logdate) | Fixing up permissions"
        sudo chown -R root:wheel "$appdir/$app"
        echo "$(logdate) | Application [$appname] successfully installed"
        fetchLastModifiedDate update; rm -rf "$tempdir"; exit 0
    else
        echo "$(logdate) | Failed to install [$appname]"; rm -rf "$tempdir"; exit 1
    fi
}

function installDMG () {
    waitForProcess "$processpath" "300" "$terminateprocess"
    echo "$(logdate) | Installing [$appname]"
    volume="$tempdir/$appname"
    echo "$(logdate) | Mounting Image [$volume] [$tempdir/$tempfile]"
    if ! hdiutil attach -quiet -nobrowse -mountpoint "$volume" "$tempdir/$tempfile"; then
        echo "$(logdate) | Failed to mount DMG"; rm -rf "$tempdir"; exit 1
    fi
    [[ -d "$appdir/$app" ]] && rm -rf "$appdir/$app"
    echo "$(logdate) | Copying app files to $appdir/$app"
    if ! rsync -a "$volume"/*.app/ "$appdir/$app"; then
        echo "$(logdate) | Failed to copy app files"
        hdiutil detach -quiet "$volume"; rm -rf "$tempdir"; exit 1
    fi
    echo "$(logdate) | Fix up permissions"
    dot_clean "$appdir/$app"
    sudo chown -R root:wheel "$appdir/$app"
    echo "$(logdate) | Un-mounting [$volume]"
    hdiutil detach -quiet "$volume"
    if [[ -e "$appdir/$app" ]]; then
        echo "$(logdate) | Application [$appname] successfully installed"
        fetchLastModifiedDate update; rm -rf "$tempdir"; exit 0
    else
        echo "$(logdate) | Failed to install [$appname]"; rm -rf "$tempdir"; exit 1
    fi
}

function installZIP () {
    waitForProcess "$processpath" "300" "$terminateprocess"
    echo "$(logdate) | Installing $appname"
    if ! unzip -qq -o "$tempdir/$tempfile" -d "$tempdir"; then
        echo "$(logdate) | failed to unzip $tempfile"; rm -rf "$tempdir"; exit 1
    fi
    echo "$(logdate) | $tempfile unzipped"
    [[ -e "$appdir/$app" ]] && rm -rf "$appdir/$app"
    if ! rsync -a "$tempdir/$app/" "$appdir/$app"; then
        echo "$(logdate) | failed to move $appname to $appdir"; rm -rf "$tempdir"; exit 1
    fi
    echo "$(logdate) | Fix up permissions"
    dot_clean "$appdir/$app"
    sudo chown -R root:wheel "$appdir/$app"
    if [[ -e "$appdir/$app" ]]; then
        echo "$(logdate) | Application [$appname] successfully installed"
        fetchLastModifiedDate update; rm -rf "$tempdir"; exit 0
    else
        echo "$(logdate) | Failed to install $appname"; rm -rf "$tempdir"; exit 1
    fi
}

function installBZ2 () {
    waitForProcess "$processpath" "300" "$terminateprocess"
    echo "$(logdate) | Installing $appname"
    if ! tar -jxf "$tempdir/$tempfile" -C "$tempdir"; then
        echo "$(logdate) | failed to uncompress $tempfile"; rm -rf "$tempdir"; exit 1
    fi
    echo "$(logdate) | $tempfile uncompressed"
    [[ -e "$appdir/$app" ]] && rm -rf "$appdir/$app"
    if ! rsync -a "$tempdir/$app/" "$appdir/$app"; then
        echo "$(logdate) | failed to move $appname to $appdir"; rm -rf "$tempdir"; exit 1
    fi
    echo "$(logdate) | Fix up permissions"
    dot_clean "$appdir/$app"
    sudo chown -R root:wheel "$appdir/$app"
    if [[ -e "$appdir/$app" ]]; then
        echo "$(logdate) | Application [$appname] successfully installed"
        fetchLastModifiedDate update; rm -rf "$tempdir"; exit 0
    else
        echo "$(logdate) | Failed to install $appname"; rm -rf "$tempdir"; exit 1
    fi
}

function installTGZ () {
    waitForProcess "$processpath" "300" "$terminateprocess"
    echo "$(logdate) | Installing $appname"
    if ! tar -zxf "$tempdir/$tempfile" -C "$tempdir"; then
        echo "$(logdate) | failed to uncompress $tempfile"; rm -rf "$tempdir"; exit 1
    fi
    echo "$(logdate) | $tempfile uncompressed"
    [[ -e "$appdir/$app" ]] && rm -rf "$appdir/$app"
    if ! rsync -a "$tempdir/$app/" "$appdir/$app"; then
        echo "$(logdate) | failed to move $appname to $appdir"; rm -rf "$tempdir"; exit 1
    fi
    echo "$(logdate) | Fix up permissions"
    dot_clean "$appdir/$app"
    sudo chown -R root:wheel "$appdir/$app"
    if [[ -e "$appdir/$app" ]]; then
        echo "$(logdate) | Application [$appname] successfully installed"
        fetchLastModifiedDate update; rm -rf "$tempdir"; exit 0
    else
        echo "$(logdate) | Failed to install $appname"; rm -rf "$tempdir"; exit 1
    fi
}

function startLog() {
    [[ ! -d "$logandmetadir" ]] && mkdir -p "$logandmetadir"
    exec > >(tee -a "$log") 2>&1
}

waitForDesktop () {
    until pgrep -x Dock &>/dev/null; do
        delay=$(( $RANDOM % 50 + 10 ))
        echo "$(logdate) | Dock not running, waiting [$delay] seconds"
        sleep $delay
    done
    echo "$(logdate) | Dock is here, lets carry on"
}

# Main
startLog
echo ""
echo "##############################################################"
echo "# $(logdate) | Logging install of [$appname] to [$log]"
echo "##############################################################"
echo ""
updateCheck
waitForDesktop
downloadApp
case $packageType in
    PKG) installPKG;; ZIP) installZIP;; BZ2) installBZ2;;
    TGZ) installTGZ;; DMG) installDMG;; DMGPKG) installDMGPKG;;
    *) echo "$(logdate) | Unknown package type: [$packageType]"; rm -rf "$tempdir"; exit 1;;
esac
