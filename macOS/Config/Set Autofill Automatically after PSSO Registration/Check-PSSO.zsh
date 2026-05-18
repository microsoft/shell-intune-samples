#!/bin/zsh

# Check if Mac is registered with Platform SSO (PSSO) and AutoFill from Company Portal is enabled

logandmetadir="/Library/Logs/Microsoft/IntuneScripts/checkPSSO"
logfile="$logandmetadir/Check-PSSO.log"
verbose=false

# Create log directory if needed
if [[ ! -d "$logandmetadir" ]]; then
    mkdir -p "$logandmetadir"
fi

# Start logging
exec > >(tee -a "$logfile") 2>&1

echo ""
echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | ========================================="
echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | Starting Platform SSO (PSSO) Check"
echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | ========================================="

# 0. Log system info
if [[ "$verbose" == true ]]; then
    echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | macOS version: $(sw_vers -productVersion) (Build $(sw_vers -buildVersion))"
    echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | Hardware: $(sysctl -n hw.model)"
    echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | Script running as: $(whoami) (UID $(id -u))"
fi

# 1. Wait for Dock (indicates user session is ready)
DOCK_WAIT=0
DOCK_MAX_WAIT=600
while ! pgrep -x "Dock" &>/dev/null; do
    if (( DOCK_WAIT >= DOCK_MAX_WAIT )); then
        echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | Timed out waiting for Dock after ${DOCK_MAX_WAIT}s. No user session available."
        exit 1
    fi
    echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | Waiting for Dock... (${DOCK_WAIT}s)"
    sleep 5
    (( DOCK_WAIT += 5 ))
done

# 2. Get the current console user and UID
currentUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ { print $3 }')
if [[ -z "$currentUser" || "$currentUser" == "loginwindow" ]]; then
    echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | No user currently logged in."
    exit 1
fi
currentUID=$(id -u "$currentUser")
echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | Running as user: $currentUser (UID $currentUID)"

# 3. Check if app-sso command exists
if ! command -v app-sso &>/dev/null; then
    echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | app-sso command not found. Platform SSO requires macOS 13 (Ventura) or later."
    exit 1
fi

# 4. Check Platform SSO status
echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | Checking Platform SSO registration status..."
psso_output=$(launchctl asuser "$currentUID" sudo -u "$currentUser" app-sso platform -s 2>&1)
psso_rc=$?
if [[ "$verbose" == true ]]; then
    echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | app-sso exit code: $psso_rc"
    echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | app-sso output:"
    echo "$psso_output" | while IFS= read -r line; do
        echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") |   $line"
    done
fi

if [[ $psso_rc -ne 0 ]]; then
    echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | Platform SSO registration: NOT CONFIGURED"
    exit 1
fi

# 5. Parse registration state
registered=false
if echo "$psso_output" | grep -q '"registrationCompleted" : true'; then
    registered=true
fi

if [[ "$registered" == true ]]; then
    echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | Platform SSO registration: COMPLETE"
else
    echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | Platform SSO registration: NOT COMPLETE"
    exit 1
fi

# 6. Check Company Portal installation
cp_app_path="/Applications/Company Portal.app"
if [[ -d "$cp_app_path" ]]; then
    cp_version=$(/usr/bin/defaults read "$cp_app_path/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null)
    if [[ "$verbose" == true ]]; then
        echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | Company Portal installed: $cp_app_path (version $cp_version)"
    fi
else
    echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | WARNING: Company Portal NOT found at $cp_app_path"
fi

# Check if the AutoFill extension bundle exists on disk
autofill_bundle="$cp_app_path/Contents/PlugIns/AutofillExtensionMacOS.appex"
if [[ -d "$autofill_bundle" ]]; then
    if [[ "$verbose" == true ]]; then
        echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | AutoFill extension bundle found on disk: $autofill_bundle"
    fi
else
    echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | WARNING: AutoFill extension bundle NOT found at $autofill_bundle"
fi

# Log all registered pluginkit extensions for diagnostics
if [[ "$verbose" == true ]]; then
    echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | All registered credential provider extensions:"
    launchctl asuser "$currentUID" sudo -u "$currentUser" pluginkit -m -v 2>/dev/null | grep -i "autofill\|credential\|company" | while IFS= read -r line; do
        echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") |   $line"
    done
fi

# 7. Wait for Company Portal AutoFill extension to be registered
echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | Checking AutoFill from Company Portal..."
autofill_id="com.microsoft.CompanyPortalMac.Mac-Autofill-Extension"
AUTOFILL_WAIT=0
AUTOFILL_MAX_WAIT=300
autofill_found=false
while [[ "$autofill_found" == false ]]; do
    # Check if extension is registered at all
    if launchctl asuser "$currentUID" sudo -u "$currentUser" pluginkit -m -v 2>/dev/null | grep -q "$autofill_id"; then
        autofill_found=true
        break
    fi
    if (( AUTOFILL_WAIT >= AUTOFILL_MAX_WAIT )); then
        echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | AutoFill from Company Portal: NOT FOUND (timed out after ${AUTOFILL_MAX_WAIT}s)"
        exit 1
    fi
    echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | Waiting for AutoFill extension to register... (${AUTOFILL_WAIT}s)"
    sleep 10
    (( AUTOFILL_WAIT += 10 ))
done

# Enable the AutoFill extension via pluginkit
echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | Enabling AutoFill from Company Portal..."
launchctl asuser "$currentUID" sudo -u "$currentUser" pluginkit -e use -i "$autofill_id"
sleep 2

# Verify it is enabled
if launchctl asuser "$currentUID" sudo -u "$currentUser" pluginkit -m -v 2>/dev/null | grep -q "$autofill_id"; then
    echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | AutoFill from Company Portal: ENABLED"
    exit 0
else
    echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | AutoFill from Company Portal: FAILED TO ENABLE"
    exit 1
fi