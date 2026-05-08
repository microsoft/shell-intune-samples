#!/bin/bash
#set -x
############################################################################################
##
## Script to enable the Finder Sync extension for OneDrive
##
## Recommended Intune settings:
##   - Run script as signed-in user : No   (script handles user-context invocation itself)
##   - Hide script notifications on devices : Yes
##   - Script frequency : Not configured
##   - Number of times to retry if script fails : 3
##
## Notes:
##   When this script is run from an MDM / launchd context (e.g. by the Intune agent),
##   pluginkit invoked directly will return:
##       "match: connection invalid"
##   ...because the process is not attached to the user's Aqua GUI launchd bootstrap.
##   The fix is to re-enter the user's session with `launchctl asuser <uid>` so that
##   pluginkit can talk to the per-user pluginkit / extensionkit endpoints.
##   See: https://github.com/microsoft/shell-intune-samples/issues/137
##        https://github.com/microsoft/shell-intune-samples/issues/148
##
############################################################################################

## Copyright (c) 2024 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: neiljohn@microsoft.com

appname="EnableOneDriveFinderSync"
application="/Applications/OneDrive.app"

# Identify the active console user (works regardless of whether this script is
# invoked as root by the Intune agent or as the signed-in user).
currentUser=$(/usr/bin/stat -f%Su /dev/console)
if [[ -z "$currentUser" || "$currentUser" == "root" || "$currentUser" == "_mbsetupuser" || "$currentUser" == "loginwindow" ]]; then
    echo "$(date) | No real console user logged in (got '$currentUser'); nothing to do."
    exit 0
fi
uid=$(/usr/bin/id -u "$currentUser")

# Log to the user's home so existing collection paths still work.
userHome=$(/usr/bin/dscl . -read "/Users/$currentUser" NFSHomeDirectory 2>/dev/null | awk -F': ' '/NFSHomeDirectory/ {print $2}')
[[ -z "$userHome" ]] && userHome="/Users/$currentUser"
logandmetadir="$userHome/Library/Logs/Microsoft/IntuneScripts/$appname"
log="$logandmetadir/$appname.log"

# Make sure the log directory exists and is owned by the user.
if [[ ! -d "$logandmetadir" ]]; then
    mkdir -p "$logandmetadir"
    chown -R "$currentUser":staff "$logandmetadir" 2>/dev/null
fi

# Start logging
exec &> >(tee -a "$log")

echo ""
echo "##############################################################"
echo "# $(date) | Starting $appname"
echo "##############################################################"
echo "$(date) | Console user : $currentUser ($uid)"
echo "$(date) | Running as   : $(/usr/bin/id -un) ($(/usr/bin/id -u))"

# Helper: run a command inside the console user's GUI launchd session so that
# pluginkit attaches to the per-user pluginkit endpoints.
runAsUser() {
    /bin/launchctl asuser "$uid" /usr/bin/sudo -u "$currentUser" "$@"
}

# Wait for OneDrive to be installed (cap the wait so the agent doesn't hang forever)
attempts=0
while [[ ! -d "$application" && $attempts -lt 30 ]]; do
    echo "$(date) | $application not installed yet, waiting 60s (attempt $((attempts+1))/30)"
    sleep 60
    attempts=$((attempts+1))
done

if [[ ! -d "$application" ]]; then
    echo "$(date) | OneDrive still not installed after waiting; exiting."
    exit 1
fi
echo "$(date) | $application found"

# Discover the installed extension ID (differs between standalone and VPP/Mac App Store).
echo "$(date) | Looking for an installed OneDrive Finder Sync extension"
matchOutput=$(runAsUser /usr/bin/pluginkit -m -i com.microsoft.OneDrive.FinderSync 2>/dev/null)
if [[ -n "$matchOutput" ]]; then
    extensionname="com.microsoft.OneDrive.FinderSync"
    echo "$(date) | Found standalone extension: $extensionname"
else
    matchOutput=$(runAsUser /usr/bin/pluginkit -m -i com.microsoft.OneDrive-mac.FinderSync 2>/dev/null)
    if [[ -n "$matchOutput" ]]; then
        extensionname="com.microsoft.OneDrive-mac.FinderSync"
        echo "$(date) | Found VPP / Mac App Store extension: $extensionname"
    fi
fi

if [[ -z "${extensionname:-}" ]]; then
    echo "$(date) | No OneDrive Finder Sync extension registered yet; exiting so the script can retry on the next run."
    exit 1
fi

# Already enabled?
status=$(runAsUser /usr/bin/pluginkit -m -i "$extensionname" 2>/dev/null)
echo "$(date) | Current status: ${status:-<empty>}"
if [[ "$status" == +* ]]; then
    echo "$(date) | $extensionname is already enabled; nothing to do."
    exit 0
fi

# Enable the extension inside the user's GUI session so we don't get
# "match: connection invalid".
echo "$(date) | Enabling $extensionname for $currentUser"
runAsUser /usr/bin/pluginkit -e use -i "$extensionname"
rc=$?

# Verify
status=$(runAsUser /usr/bin/pluginkit -m -i "$extensionname" 2>/dev/null)
echo "$(date) | Post-enable status: ${status:-<empty>}"

if [[ $rc -eq 0 && "$status" == +* ]]; then
    echo "$(date) | $appname completed successfully"
    exit 0
else
    echo "$(date) | $appname failed to enable extension (rc=$rc)"
    exit 1
fi
