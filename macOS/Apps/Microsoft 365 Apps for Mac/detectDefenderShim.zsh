#!/bin/zsh
#set -x

############################################################################################
##
## Script to detect or remove the Defender Shim installed with the Office Business Pro Suite
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
##
## Feedback: neiljohn@microsoft.com


#
# Set removeShim="true" to remove the Defender Shim (This is destructive and may remove the Defender Client, 
# test thoroughly in report mode before deploying!)
#
removeShim="false"                           # If we detect the Defender Shim Launcher, remove the Shim
removeDefenderIfNotLicensed="false"          # If we detect Defender is installed but not licensed, remove it
defender_path="/Applications/Microsoft Defender.app"
logDir="/Library/Application Support/Microsoft/IntuneScripts/Defender Shim Check"
log=$logDir/defenderShimDetect.log

# Create directory to log to
if [[ ! -d "$logDir" ]]; then
    mkdir -p "$logDir"
fi

log() {
    local log_type=$1
    local message=$2

    # Append log message with timestamp and log type to the log file
    echo "[$(date)][$log_type] $message" >> "$log"

}

# Are we root?
if [[ ! $EUID -eq 0 ]]; then
    log "FATAL" "Script not running as root"
    echo "Script not running as root"
    exit 1;
fi

# Check for Defender Shim
if [[ -e "${defender_path}/Contents/MacOS/launcher" ]]; then

    plist_path="$defender_path/Contents/info.plist"
    shimVer=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$plist_path")

    log "INFO" "Defender Shim Detected [ver: ${shimVer}]"
    echo "Defender Shim Detected [ver: ${shimVer}]"

    if [[ "${removeShim}" == "true" ]]; then

        # Find the process ID for "Microsoft Defender"
        defender_pid=$(pgrep "Microsoft Defender")

        if [ -z "$defender_pid" ]; then
        log "INFO" "Microsoft Defender Shim not running"

        else
            # Kill the process using kill -9
            log "ACTION" "Killing Microsoft Defender shim process with PID: $defender_pid"
            kill -9 "$defender_pid"
        fi

        log "ACTION" "Removing Defender Shim"
        rm -rf "${defender_path}"
        pkgutil --forget com.microsoft.wdav

    fi

# Check for Defender Client
elif [[ -e "${defender_path}/Contents/MacOS/wdavdaemon" ]]; then

    # Attempt to determine Defender Version

    if [ -e /usr/local/bin/mdatp ]; then
        
        mdatpVer=$(/usr/local/bin/mdatp version | grep -i "product version" | awk -F: '{print $2}' | awk '{$1=$1};1')
        health_output=$(/usr/local/bin/mdatp health)
        
    else
        log "ERROR" "wdavdaemon detected but /usr/local/bin/mdatp does not exist"
        echo "wdavdaemon detected but mdatp does not exist"
        exit 1
    fi

    # Extract values using awk
    healthy=$(echo "$health_output" | awk '/^healthy/{print $NF}')
    health_issues=$(echo "$health_output" | awk -F ': ' '/^health_issues/{print $2}' | tr -d '[]"')
    licensed=$(echo "$health_output" | awk -F ': ' '/^licensed/{print $2}' | tr -d '[]"')
    

    # Check if healthy is true or false
    if [ "$healthy" = "true" ]; then
        mdatpStatus="Healthy"
    else
        mdatpStatus="$health_issues"
    fi

    log "INFO" "Defender Client Detected [licensed: $licensed][ver: ${mdatpVer}][State: ${mdatpStatus}]"
    echo "Defender Client Detected [licensed: $licensed][ver: $mdatpVer]"

    if [[ "$licensed" = "false" && "$removeDefenderIfNotLicensed" = "true" ]]; then
        log "ACTION" "Defender Client not licensed, removing"
        '/Applications/Microsoft Defender.app/Contents/Resources/Tools/uninstall/uninstall' 1>&2 >$logDir/uinstallDefender.log

    fi

# Check for Defender Directory
elif [[ ! -d "${defender_path}" ]]; then

    log "INFO" "Defender Not Detected"
    echo "Defender Not Detected"

fi
