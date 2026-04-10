#!/bin/zsh

############################################################################################
## Install Microsoft 365 Copilot (macOS Universal PKG)
## Maintainer: neiljohn@microsoft.com
## Summary: Resolve fwlink -> download PKG -> validate -> install -> record Last-Modified.
## Exit codes: 0 success / not-needed, 1 failure.
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

## Config
weburl="https://go.microsoft.com/fwlink/?linkid=2325438"  # fwlink to latest Copilot PKG
appname="Microsoft 365 Copilot"
app="Microsoft 365 Copilot.app"
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/installM365Copilot"
processpath="/Applications/Microsoft 365 Copilot.app/Contents/MacOS/Microsoft 365 Copilot"
terminateprocess="true"
autoUpdate="true"

# Generated variables
tempdir=$(mktemp -d)
log="$logandmetadir/$appname.log"
metafile="$logandmetadir/$appname.meta"

## Helpers
cleanup() { [[ -d "$tempdir" ]] && rm -rf "$tempdir"; }
trap cleanup EXIT

startLog() { mkdir -p "$logandmetadir"; exec > >(tee -a "$log") 2>&1; }

waitForDesktop () {
    until pgrep -f "/CoreServices/Dock.app/Contents/MacOS/Dock" >/dev/null 2>&1; do
        local d=$(( RANDOM % 50 + 10 ))
        echo "$(date) | Dock not ready, waiting ($d)s"
        sleep $d
    done
    echo "$(date) | Desktop ready"
}

waitForProcess () {
    local name="$1" terminate="$2" pid
    echo "$(date) | Waiting for [$name] to close"
    while pgrep -f "$name" >/dev/null 2>&1; do
        if [[ $terminate == "true" ]]; then
            pid=$(pgrep -f "$name" | head -n1)
            [[ -n $pid ]] && { echo "$(date) | Terminating pid [$pid] ($name)"; kill -9 "$pid" 2>/dev/null || true; }
            return
        fi
        sleep $(( RANDOM % 50 + 10 ))
    done
    echo "$(date) | No running [$name]"
}

fetchLastModifiedDate() {
    local target="${resolvedurl:-$weburl}"
    lastmodified=$(curl -sIL "$target" | awk 'tolower($0) ~ /^last-modified:/ { $1=""; sub(/^ +/, ""); gsub(/\r$/, ""); print }' | tail -n1)
    [[ $1 == update ]] && echo "$lastmodified" > "$metafile"
}

updateCheck() {
    echo "$(date) | Checking if $appname is already installed"
    if [[ -d "/Applications/$app" ]]; then
        if [[ $autoUpdate == "true" ]]; then
            echo "$(date) | $appname already installed and self-updates, exiting"
            exit 0
        fi
        fetchLastModifiedDate
        if [[ -f $metafile ]]; then
            local prev=$(cat "$metafile")
            if [[ -n $prev && $prev == $lastmodified ]]; then
                echo "$(date) | No update available"
                exit 0
            fi
            echo "$(date) | Update available"
        fi
    else
        echo "$(date) | $appname not installed"
    fi
}

downloadPKG() {
    echo "$(date) | Downloading $appname"
    cd "$tempdir" || exit 1

    resolvedurl=$(curl -sIL -o /dev/null -w '%{url_effective}' "$weburl")
    echo "$(date) | Resolved URL: $resolvedurl"
    if [[ -z $resolvedurl || ( $resolvedurl != *.pkg && $resolvedurl != *.pkg\?* ) ]]; then
        echo "$(date) | ERROR: Resolved URL is not a PKG"; exit 1
    fi

    curl -f -S --connect-timeout 30 --retry 5 --retry-delay 60 -L -o "copilot.pkg" "$weburl" \
        || { echo "$(date) | ERROR: Download failed"; exit 1; }

    file -b "copilot.pkg" | grep -qi xar \
        || { echo "$(date) | ERROR: Downloaded file is not a valid PKG"; exit 1; }

    echo "$(date) | Download complete"
}

installPKG() {
    waitForProcess "$processpath" "$terminateprocess"
    echo "$(date) | Installing $appname"

    if installer -pkg "$tempdir/copilot.pkg" -target /; then
        fetchLastModifiedDate update
        echo "$(date) | Install complete"
    else
        echo "$(date) | ERROR: Install failed"; exit 1
    fi
}

###################################################################################
## Begin Script Body
###################################################################################

startLog
echo ""
echo "##############################################################"
echo "# $(date) | Starting install of [$appname]"
echo "##############################################################"
echo ""

updateCheck
waitForDesktop
downloadPKG
installPKG