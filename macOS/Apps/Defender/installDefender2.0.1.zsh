#!/bin/zsh
# installDefender v2.0.1 - curl only (no aria2c dependency)

weburl="https://go.microsoft.com/fwlink/?linkid=2097502"
appname="Microsoft Defender"
app="Microsoft Defender.app"
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/install$appname"
appdir="/Applications"
processpath="$appdir/$app/Contents/MacOS/$appname"
terminateprocess="true"
autoUpdate="true"

waitForTheseApps=(  "/Applications/Microsoft Edge.app"
                    "/Applications/Microsoft Outlook.app"
                    "/Applications/Microsoft Word.app"
                    "/Applications/Microsoft Excel.app"
                    "/Applications/Microsoft PowerPoint.app"
                    "/Applications/Microsoft OneNote.app"
                    "/Applications/Company Portal.app")

tempdir=$(mktemp -d)
log="$logandmetadir/$appname.log"
metafile="$logandmetadir/$appname.meta"
logdate() { date '+%Y-%m-%d %H:%M:%S'; }

waitForOtherApps() {
    echo "$(logdate) | Looking for required applications before we install"
    local ready=0
    while [[ $ready -ne 1 ]]; do
        missingappcount=0
        for i in "${waitForTheseApps[@]}"; do
            if [[ ! -e "$i" ]]; then
                echo "$(logdate) | Waiting for installation of [$i]"
                (( missingappcount++ ))
            fi
        done
        if [[ $missingappcount -eq 0 ]]; then
            ready=1
            echo "$(logdate) | All apps installed, safe to continue"
        else
            echo "$(logdate) | [$missingappcount] application(s) missing"
            echo "$(logdate) | Waiting for 60 seconds"
            sleep 60
        fi
    done
}

waitForProcess () {
    local processName=$1 fixedDelay=$2 terminate=$3
    echo "$(logdate) | Waiting for [$processName] to end"
    while pgrep -f "$processName" &>/dev/null; do
        if [[ $terminate == "true" ]]; then
            echo "$(logdate) | Terminating [$processName]"; pkill -9 -f "$processName"; return
        fi
        local delay=${fixedDelay:-$(( RANDOM % 50 + 10 ))}
        echo "$(logdate) | $processName running, waiting [$delay]s"; sleep $delay
    done
    echo "$(logdate) | No instances of [$processName] found"
}

fetchLastModifiedDate() {
    [[ ! -d "$logandmetadir" ]] && mkdir -p "$logandmetadir"
    lastmodified=$(curl -sIL "$weburl" | awk -F': ' 'tolower($1) == "last-modified" {gsub(/\r/, "", $2); print $2; exit}')
    if [[ $1 == "update" ]]; then
        echo "$(logdate) | Writing lastmodified [$lastmodified] to [$metafile]"
        echo "$lastmodified" > "$metafile"
    fi
}

function downloadApp () {
    echo "$(logdate) | Downloading [$appname] from [$weburl]"
    cd "$tempdir" || { echo "$(logdate) | Failed to access tempdir"; exit 1; }
    if ! curl -f -s --connect-timeout 30 --retry 5 --retry-delay 60 --compressed -L -o "$tempdir/download" "$weburl"; then
        echo "$(logdate) | Download failed"; rm -rf "$tempdir"; exit 1
    fi
    # Rename using content-disposition or fallback
    local realname=$(curl -sIL "$weburl" | awk -F'filename=' 'tolower($0) ~ /content-disposition/ && $2 {gsub(/["\r]/, "", $2); print $2; exit}')
    if [[ -n "$realname" ]]; then
        mv "$tempdir/download" "$tempdir/$realname"
    fi
    tempfile=$(ls -1 "$tempdir" | head -1)
    [[ -z "$tempfile" ]] && { echo "$(logdate) | No file found"; rm -rf "$tempdir"; exit 1; }
    echo "$(logdate) | Downloaded [$tempfile]"
    case $tempfile in
        *.pkg|*.PKG|*.mpkg|*.MPKG) packageType="PKG";;
        *.zip|*.ZIP) packageType="ZIP";;
        *.tbz2|*.TBZ2|*.bz2|*.BZ2) packageType="BZ2";;
        *.tgz|*.TGZ|*.tar.gz|*.TAR.GZ) packageType="TGZ";;
        *.dmg|*.DMG) packageType="DMG";;
        *)
            echo "$(logdate) | Unknown file type, checking metadata"
            local metadata=$(file -bz "$tempdir/$tempfile")
            case "$metadata" in
                *"Zip archive"*) packageType="ZIP"; mv "$tempfile" "$tempdir/install.zip"; tempfile="install.zip";;
                *"xar archive"*) packageType="PKG"; mv "$tempfile" "$tempdir/install.pkg"; tempfile="install.pkg";;
                *"DOS/MBR boot sector"*|*"Apple Driver Map"*) packageType="DMG"; mv "$tempfile" "$tempdir/install.dmg"; tempfile="install.dmg";;
                *"bzip2 compressed"*) packageType="BZ2"; mv "$tempfile" "$tempdir/install.tar.bz2"; tempfile="install.tar.bz2";;
                *"gzip compressed"*) packageType="TGZ"; mv "$tempfile" "$tempdir/install.tar.gz"; tempfile="install.tar.gz";;
                *) echo "$(logdate) | Unidentifiable file type";;
            esac;;
    esac
    if [[ "$packageType" == "DMG" ]]; then
        volume="$tempdir/$appname"
        if hdiutil attach -quiet -nobrowse -mountpoint "$volume" "$tempdir/$tempfile"; then
            local has_app=$(find "$volume" -maxdepth 1 -iname "*.app" 2>/dev/null | wc -l | tr -d ' ')
            local has_pkg=$(find "$volume" -maxdepth 1 \( -iname "*.pkg" -o -iname "*.mpkg" \) 2>/dev/null | wc -l | tr -d ' ')
            if [[ $has_app -gt 0 && $has_pkg -gt 0 ]]; then
                echo "$(logdate) | Both APP and PKG in DMG, exiting"; hdiutil detach -quiet "$volume"; rm -rf "$tempdir"; exit 1
            elif [[ $has_pkg -gt 0 ]]; then
                packageType="DMGPKG"
            fi
            hdiutil detach -quiet "$volume"
        else
            echo "$(logdate) | Failed to mount DMG"; rm -rf "$tempdir"; exit 1
        fi
    fi
    [[ -z "$packageType" ]] && { echo "$(logdate) | Unknown package type"; rm -rf "$tempdir"; exit 1; }
    echo "$(logdate) | Install type: [$packageType]"
}

function updateCheck() {
    echo "$(logdate) | Checking [$appname]"
    if [[ -d "$appdir/$app" ]]; then
        [[ $autoUpdate == "true" ]] && { echo "$(logdate) | [$appname] auto-updates, exiting"; exit 0; }
        echo "$(logdate) | [$appname] installed, checking for update"
        fetchLastModifiedDate
        if [[ -f "$metafile" ]]; then
            local prev=$(cat "$metafile")
            if [[ "$prev" == "$lastmodified" ]]; then
                echo "$(logdate) | No update needed"; exit 0
            fi
            echo "$(logdate) | Update found: [$prev] -> [$lastmodified]"
        else
            echo "$(logdate) | No meta file, updating anyway"
        fi
    else
        echo "$(logdate) | [$appname] not installed"
    fi
}

function installPKG () {
    waitForProcess "$processpath" "300" "$terminateprocess"
    echo "$(logdate) | Installing $appname"
    [[ -d "$appdir/$app" ]] && rm -rf "$appdir/$app"
    if installer -pkg "$tempdir/$tempfile" -target /; then
        echo "$(logdate) | $appname installed successfully"
        fetchLastModifiedDate update; rm -rf "$tempdir"; exit 0
    else
        echo "$(logdate) | Failed to install $appname"; rm -rf "$tempdir"; exit 1
    fi
}

function installDMGPKG () {
    waitForProcess "$processpath" "300" "$terminateprocess"
    echo "$(logdate) | Installing [$appname]"
    volume="$tempdir/$appname"
    if ! hdiutil attach -quiet -nobrowse -mountpoint "$volume" "$tempdir/$tempfile"; then
        echo "$(logdate) | Failed to mount DMG"; rm -rf "$tempdir"; exit 1
    fi
    [[ -d "$appdir/$app" ]] && rm -rf "$appdir/$app"
    for file in "$volume"/*.{pkg,mpkg}(N); do
        [[ -f "$file" ]] || continue
        echo "$(logdate) | Installing [$file]"
        installer -pkg "$file" -target / || echo "$(logdate) | Warning: Failed [$file]"
    done
    hdiutil detach -quiet "$volume"
    if [[ -e "$appdir/$app" ]]; then
        sudo chown -R root:wheel "$appdir/$app"
        echo "$(logdate) | $appname installed successfully"
        fetchLastModifiedDate update; rm -rf "$tempdir"; exit 0
    else
        echo "$(logdate) | Failed to install $appname"; rm -rf "$tempdir"; exit 1
    fi
}

function installDMG () {
    waitForProcess "$processpath" "300" "$terminateprocess"
    echo "$(logdate) | Installing [$appname]"
    volume="$tempdir/$appname"
    if ! hdiutil attach -quiet -nobrowse -mountpoint "$volume" "$tempdir/$tempfile"; then
        echo "$(logdate) | Failed to mount DMG"; rm -rf "$tempdir"; exit 1
    fi
    [[ -d "$appdir/$app" ]] && rm -rf "$appdir/$app"
    if ! rsync -a "$volume"/*.app/ "$appdir/$app"; then
        echo "$(logdate) | Failed to copy app"; hdiutil detach -quiet "$volume"; rm -rf "$tempdir"; exit 1
    fi
    dot_clean "$appdir/$app"; sudo chown -R root:wheel "$appdir/$app"
    hdiutil detach -quiet "$volume"
    if [[ -e "$appdir/$app" ]]; then
        echo "$(logdate) | $appname installed successfully"
        fetchLastModifiedDate update; rm -rf "$tempdir"; exit 0
    else
        echo "$(logdate) | Failed to install $appname"; rm -rf "$tempdir"; exit 1
    fi
}

function installZIP () {
    waitForProcess "$processpath" "300" "$terminateprocess"
    echo "$(logdate) | Installing $appname"
    if ! unzip -qq -o "$tempdir/$tempfile" -d "$tempdir"; then
        echo "$(logdate) | Failed to unzip"; rm -rf "$tempdir"; exit 1
    fi
    [[ -e "$appdir/$app" ]] && rm -rf "$appdir/$app"
    if ! rsync -a "$tempdir/$app/" "$appdir/$app"; then
        echo "$(logdate) | Failed to copy app"; rm -rf "$tempdir"; exit 1
    fi
    dot_clean "$appdir/$app"; sudo chown -R root:wheel "$appdir/$app"
    if [[ -e "$appdir/$app" ]]; then
        echo "$(logdate) | $appname installed successfully"
        fetchLastModifiedDate update; rm -rf "$tempdir"; exit 0
    else
        echo "$(logdate) | Failed to install $appname"; rm -rf "$tempdir"; exit 1
    fi
}

function installBZ2 () {
    waitForProcess "$processpath" "300" "$terminateprocess"
    echo "$(logdate) | Installing $appname"
    if ! tar -jxf "$tempdir/$tempfile" -C "$tempdir"; then
        echo "$(logdate) | Failed to extract"; rm -rf "$tempdir"; exit 1
    fi
    [[ -e "$appdir/$app" ]] && rm -rf "$appdir/$app"
    if ! rsync -a "$tempdir/$app/" "$appdir/$app"; then
        echo "$(logdate) | Failed to copy app"; rm -rf "$tempdir"; exit 1
    fi
    dot_clean "$appdir/$app"; sudo chown -R root:wheel "$appdir/$app"
    if [[ -e "$appdir/$app" ]]; then
        echo "$(logdate) | $appname installed successfully"
        fetchLastModifiedDate update; rm -rf "$tempdir"; exit 0
    else
        echo "$(logdate) | Failed to install $appname"; rm -rf "$tempdir"; exit 1
    fi
}

function installTGZ () {
    waitForProcess "$processpath" "300" "$terminateprocess"
    echo "$(logdate) | Installing $appname"
    if ! tar -zxf "$tempdir/$tempfile" -C "$tempdir"; then
        echo "$(logdate) | Failed to extract"; rm -rf "$tempdir"; exit 1
    fi
    [[ -e "$appdir/$app" ]] && rm -rf "$appdir/$app"
    if ! rsync -a "$tempdir/$app/" "$appdir/$app"; then
        echo "$(logdate) | Failed to copy app"; rm -rf "$tempdir"; exit 1
    fi
    dot_clean "$appdir/$app"; sudo chown -R root:wheel "$appdir/$app"
    if [[ -e "$appdir/$app" ]]; then
        echo "$(logdate) | $appname installed successfully"
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
        sleep $(( RANDOM % 50 + 10 ))
    done
    echo "$(logdate) | Desktop ready"
}

# Main
startLog
echo ""
echo "##############################################################"
echo "# $(logdate) | Installing [$appname] log: [$log]"
echo "##############################################################"
echo ""
updateCheck
waitForDesktop
waitForOtherApps
downloadApp
case $packageType in
    PKG) installPKG;; ZIP) installZIP;; BZ2) installBZ2;;
    TGZ) installTGZ;; DMG) installDMG;; DMGPKG) installDMGPKG;;
    *) echo "$(logdate) | Unknown package type: [$packageType]"; rm -rf "$tempdir"; exit 1;;
esac
