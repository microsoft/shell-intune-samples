#!/bin/zsh

# Check if Mac is registered with Platform SSO (PSSO) and AutoFill from Company Portal is enabled

logandmetadir="/Library/Logs/Microsoft/IntuneScripts/checkPSSO"
logfile="$logandmetadir/Check-PSSO.log"
verbose=false

# Create log directory if needed
if [[ ! -d "$logandmetadir" ]]; then
    mkdir -p "$logandmetadir"
    if [[ $? -ne 0 ]]; then
        echo "ERROR: Failed to create log directory $logandmetadir"
        exit 1
    fi
fi

# Rotate log if larger than 1MB
if [[ -f "$logfile" ]] && (( $(stat -f%z "$logfile" 2>/dev/null || echo 0) > 1048576 )); then
    mv "$logfile" "${logfile}.old"
fi

# Start logging
exec > >(tee -a "$logfile") 2>&1

# Helper function to reduce repeated date calls
log() { echo "$(date -u "+%Y-%m-%d %H:%M:%S UTC") | $1"; }

log ""
log "========================================="
log "Starting Platform SSO (PSSO) Check"
log "========================================="

# 0. Check macOS version early - PSSO requires macOS 13+
macos_version=$(sw_vers -productVersion)
macos_major=${macos_version%%.*}
if (( macos_major < 13 )); then
    log "macOS $macos_version detected. Platform SSO requires macOS 13 (Ventura) or later."
    exit 1
fi

if [[ "$verbose" == true ]]; then
    log "macOS version: $macos_version (Build $(sw_vers -buildVersion))"
    log "Hardware: $(sysctl -n hw.model)"
    log "Script running as: $(whoami) (UID $(id -u))"
fi

# 1. Wait for Dock (indicates user session is ready)
DOCK_WAIT=0
DOCK_MAX_WAIT=600
DOCK_LOG_INTERVAL=30
while ! pgrep -x "Dock" &>/dev/null; do
    if (( DOCK_WAIT >= DOCK_MAX_WAIT )); then
        log "Timed out waiting for Dock after ${DOCK_MAX_WAIT}s. No user session available."
        exit 1
    fi
    # Only log every DOCK_LOG_INTERVAL seconds to reduce noise
    if (( DOCK_WAIT % DOCK_LOG_INTERVAL == 0 )); then
        log "Waiting for Dock... (${DOCK_WAIT}s)"
    fi
    sleep 5
    (( DOCK_WAIT += 5 ))
done

# 2. Get the current console user and UID
currentUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ { print $3 }')
if [[ -z "$currentUser" || "$currentUser" == "loginwindow" ]]; then
    log "No user currently logged in."
    exit 1
fi
currentUID=$(id -u "$currentUser" 2>/dev/null)
if [[ -z "$currentUID" ]]; then
    log "Failed to resolve UID for user: $currentUser"
    exit 1
fi
log "Running as user: $currentUser (UID $currentUID)"

# 3. Check if app-sso command exists
if ! command -v app-sso &>/dev/null; then
    log "app-sso command not found. Platform SSO requires macOS 13 (Ventura) or later."
    exit 1
fi

# 4. Check Platform SSO status
log "Checking Platform SSO registration status..."
psso_output=$(launchctl asuser "$currentUID" sudo -u "$currentUser" app-sso platform -s 2>&1)
psso_rc=$?
if [[ "$verbose" == true ]]; then
    log "app-sso exit code: $psso_rc"
    log "app-sso output:"
    echo "$psso_output" | while IFS= read -r line; do
        log "  $line"
    done
fi

if [[ $psso_rc -ne 0 ]]; then
    log "Platform SSO registration: NOT CONFIGURED"
    exit 1
fi

# 5. Parse registration state using zsh pattern matching (avoids spawning grep)
if [[ "$psso_output" == *'"registrationCompleted" : true'* ]]; then
    log "Platform SSO registration: COMPLETE"
else
    log "Platform SSO registration: NOT COMPLETE"
    exit 1
fi

# 6. Check Company Portal installation
cp_app_path="/Applications/Company Portal.app"
autofill_bundle="$cp_app_path/Contents/PlugIns/AutofillExtensionMacOS.appex"

if [[ ! -d "$cp_app_path" ]]; then
    log "ERROR: Company Portal NOT found at $cp_app_path. Cannot enable AutoFill."
    exit 1
fi

if [[ "$verbose" == true ]]; then
    cp_version=$(/usr/bin/defaults read "$cp_app_path/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null)
    log "Company Portal installed: $cp_app_path (version $cp_version)"
fi

# Check if the AutoFill extension bundle exists on disk - fail early if missing
if [[ ! -d "$autofill_bundle" ]]; then
    log "ERROR: AutoFill extension bundle NOT found at $autofill_bundle. Company Portal may need updating."
    exit 1
fi

if [[ "$verbose" == true ]]; then
    log "AutoFill extension bundle found on disk: $autofill_bundle"
    log "All registered credential provider extensions:"
    launchctl asuser "$currentUID" sudo -u "$currentUser" pluginkit -m -v 2>/dev/null | grep -i "autofill\|credential\|company" | while IFS= read -r line; do
        log "  $line"
    done
fi

# 7. Wait for Company Portal AutoFill extension to be registered
log "Checking AutoFill from Company Portal..."
autofill_id="com.microsoft.CompanyPortalMac.Mac-Autofill-Extension"
AUTOFILL_WAIT=0
AUTOFILL_MAX_WAIT=300
AUTOFILL_LOG_INTERVAL=30
autofill_found=false
while [[ "$autofill_found" == false ]]; do
    # Check if extension is registered (filter by identifier directly)
    if launchctl asuser "$currentUID" sudo -u "$currentUser" pluginkit -m -i "$autofill_id" 2>/dev/null | grep -q "$autofill_id"; then
        autofill_found=true
        break
    fi
    if (( AUTOFILL_WAIT >= AUTOFILL_MAX_WAIT )); then
        log "AutoFill from Company Portal: NOT FOUND (timed out after ${AUTOFILL_MAX_WAIT}s)"
        exit 1
    fi
    # Only log every AUTOFILL_LOG_INTERVAL seconds
    if (( AUTOFILL_WAIT % AUTOFILL_LOG_INTERVAL == 0 )); then
        log "Waiting for AutoFill extension to register... (${AUTOFILL_WAIT}s)"
    fi
    sleep 10
    (( AUTOFILL_WAIT += 10 ))
done

# 8. Enable the AutoFill extension via pluginkit with retry
log "Enabling AutoFill from Company Portal..."
enable_attempts=0
enable_max=3
enable_success=false

while (( enable_attempts < enable_max )); do
    (( enable_attempts++ ))
    launchctl asuser "$currentUID" sudo -u "$currentUser" pluginkit -e use -i "$autofill_id" 2>/dev/null
    sleep 2

    # Verify it is actually ENABLED by reading the state flag (col 1):
    #   +  enabled   -  disabled   (blank)  no explicit state
    # head -1 drops the trailing "(1 plug-in)" summary line.
    pk_state=$(launchctl asuser "$currentUID" sudo -u "$currentUser" \
        pluginkit -m -v -i "$autofill_id" 2>/dev/null | head -1 | cut -c1)

    if [[ "$pk_state" == "+" ]]; then
        enable_success=true
        break
    fi
    log "Enable attempt $enable_attempts/$enable_max — state '${pk_state:-unset}', retrying..."
    sleep 3
done

if [[ "$enable_success" == true ]]; then
    log "AutoFill from Company Portal: ENABLED"
    exit 0
else
    log "AutoFill from Company Portal: FAILED TO ENABLE after $enable_max attempts (last state: ${pk_state:-unset})"
    exit 1
fi
