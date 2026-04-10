#!/bin/zsh

############################################################################################
## Install Company Portal and Microsoft AutoUpdate (macOS PKG)
## Maintainer: neiljohn@microsoft.com
## Summary: Download and install Company Portal PKG + MAU, with update check and logging.
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
mauurl="https://go.microsoft.com/fwlink/?linkid=830196"
weburl="https://go.microsoft.com/fwlink/?linkid=853070"
appname="Company Portal"
app="Company Portal.app"
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/installCompanyPortal"
processpath="/Applications/Company Portal.app/Contents/MacOS/Company Portal"
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
    lastmodified=$(curl -sIL "$weburl" | awk 'tolower($0) ~ /^last-modified:/ { $1=""; sub(/^ +/, ""); gsub(/\r$/, ""); print }' | tail -n1)
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
    waitForProcess "curl -f"

    curl -f -s --connect-timeout 30 --retry 5 --retry-delay 60 -L -o "$tempdir/CompanyPortal.pkg" "$weburl" \
        || { echo "$(date) | ERROR: Download failed"; exit 1; }

    file -b "$tempdir/CompanyPortal.pkg" | grep -qi xar \
        || { echo "$(date) | ERROR: Downloaded file is not a valid PKG"; exit 1; }

    echo "$(date) | Download complete"
}

installMAU() {
    echo "$(date) | Downloading MAU"
    curl -f -s --connect-timeout 30 --retry 5 --retry-delay 60 -L -o "$tempdir/mau.pkg" "$mauurl" \
        || { echo "$(date) | WARNING: MAU download failed, continuing"; return; }

    echo "$(date) | Installing MAU"
    if installer -pkg "$tempdir/mau.pkg" -target /; then
        echo "$(date) | MAU installed"
    else
        echo "$(date) | WARNING: MAU install failed, continuing"
    fi
}

installPKG() {
    waitForProcess "$processpath" "$terminateprocess"
    echo "$(date) | Installing $appname"

    if installer -pkg "$tempdir/CompanyPortal.pkg" -target /; then
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
installMAU
installPKG
