#!/usr/bin/env bash
#
#  gatherIntuneLogs.sh
#
#  Robust collection of Microsoft Intune logs & diagnostics on macOS.
#  Designed for reliability in support/troubleshooting scenarios.
#
set -euo pipefail
IFS=$'\n\t'

# ───────── Configurable switches ─────────
GATHER_MDMCLIENT=true
GATHER_APP_INSTALL=true
GATHER_INSTALL_LOGS=true
GATHER_SYSTEM_LOGS=true
GATHER_COMPANY_PORTAL=true
GATHER_INTUNE_AGENT=true
GATHER_SYSDIAGNOSE=true
ZIP_OUTPUT=true

# Allow env var overrides
for var in GATHER_MDMCLIENT GATHER_APP_INSTALL GATHER_INSTALL_LOGS GATHER_SYSTEM_LOGS GATHER_COMPANY_PORTAL GATHER_INTUNE_AGENT GATHER_SYSDIAGNOSE ZIP_OUTPUT; do
  : "${!var:=${!var}}"
done

# Logging helper
timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
log() { echo "$(timestamp) | $*"; }

# Ensure running as root
if [[ $EUID -ne 0 ]]; then
  echo "$(timestamp) | ERROR: must run as root" >&2
  exit 1
fi

# Setup output dir
ts=$(date +"%Y%m%d_%H%M%S")
OUTPUT="/var/tmp/IntuneDiagnostics_${ts}"
mkdir -p "${OUTPUT}" || { echo "$(timestamp) | ERROR: cannot create $OUTPUT" >&2; exit 1; }

# Redirect all output
exec > >(tee -a "${OUTPUT}/gatherIntuneLogs.log") 2>&1
log "Starting Intune diagnostics → ${OUTPUT}"

# Detect console user as owner of /dev/console
consoleUser=$(stat -f "%Su" /dev/console 2>/dev/null || true)
if [[ -z "${consoleUser}" || "${consoleUser}" =~ ^(root|loginwindow)$ ]]; then
  log "No valid console user detected; skipping chown & desktop ZIP"
  consoleUser=""
else
  log "Detected console user: ${consoleUser}"
fi

# Safe copy
copy_if_exists() {
  local src=$1 dest=$2
  if [[ -e "$src" || -L "$src" ]]; then
    cp -Rp "$src" "$dest/" || log "WARNING: failed to copy $src"
  fi
}

# Collector: mdmclient
gather_mdmclient() {
  local d="${OUTPUT}/mdmclient"; mkdir -p "$d"
  log "Gathering mdmclient → ${d}"
  /usr/libexec/mdmclient QueryDeviceInformation >"${d}/DeviceInformation.txt" 2>&1 || log "mdmclient QueryDeviceInformation failed"
  /usr/libexec/mdmclient QueryInstalledProfiles >"${d}/InstalledProfiles.txt" 2>&1 || true
  /usr/libexec/mdmclient QueryCertificates >"${d}/InstalledCerts.txt" 2>&1 || true
  /usr/libexec/mdmclient QueryInstalledApps >"${d}/InstalledApps.txt" 2>&1 || true
  /usr/libexec/mdmclient QuerySecurityInfo >"${d}/SecurityInfo.txt" 2>&1 || true
  log "Collecting mdmclient logs"
  log show --last 30d --predicate 'process == "mdmclient" OR subsystem == "com.apple.ManagedClient"' >"${d}/mdmclientLogs.txt" 2>&1 || true
}

# Collector: App Store install logs
gather_app_install_logs() {
  local d="${OUTPUT}/appInstall"; mkdir -p "$d"
  log "Gathering App Store install logs → ${d}"
  log show --last 30d --predicate 'processImagePath contains "storedownloadd" OR processImagePath contains "appstored"' >"${d}/appInstallLogs.txt" 2>&1 || true
}

# Collector: install.log*
gather_install_logs() {
  local d="${OUTPUT}/installLogs"; mkdir -p "$d"
  log "Copying install.log* → ${d}"
  for f in /var/log/install.log*; do copy_if_exists "$f" "$d"; done
}

# Collector: system.log*
gather_system_logs() {
  local d="${OUTPUT}/systemLogs"; mkdir -p "$d"
  log "Copying system.log* → ${d}"
  for f in /var/log/system.log*; do copy_if_exists "$f" "$d"; done
}

# Collector: Company Portal logs
gather_company_portal_logs() {
  if [[ -z \$consoleUser ]]; then
    log "Skipping Company Portal logs"
    return
  fi
  local d="${OUTPUT}/companyPortal"; mkdir -p "$d"
  log "Copying Company Portal logs → ${d}"
  find "/Users/${consoleUser}/Library/Logs/Company Portal" -type f -name '*.log' -maxdepth 1 -exec cp -Rp {} "$d/" \; 2>/dev/null || log "No Company Portal logs"
}

# Collector: Intune Agent logs
gather_intune_agent_logs() {
  local d="${OUTPUT}/intuneAgent"; mkdir -p "$d"
  log "Copying Intune Agent logs → ${d}"
  for base in "/Library/Logs/Microsoft/Intune" "/Library/Application Support/Intune"; do
    if [[ -d "$base" ]]; then
      mkdir -p "${d}/$(basename "$base")"
      log " - from ${base}"
      find "$base" -type f \( -iname '*.log' -o -iname '*.log.*' \) \! \( -iname 'install.log*' -o -iname 'system.log*' \) -mtime -30 -print0 \
        | xargs -0 -I{} cp -Rp {} "${d}/$(basename "$base")/" || log "Warning copying from ${base}"
    fi
  done
}

# Collector: sysdiagnose
gather_sysdiagnose() {
  local d="${OUTPUT}/sysdiagnose"; mkdir -p "$d"
  log "Running sysdiagnose → ${d}"
  sysdiagnose -u -f "$d" -A sysdiagnose &
  local pid=$!
  # Wait up to 5 minutes
  for i in {1..300}; do
    if ls "$d"/*.tar.gz >/dev/null 2>&1; then
      log "sysdiagnose archive complete"
      break
    fi
    sleep 1
  done
  if [[ $i -ge 300 ]]; then
    log "WARNING: sysdiagnose timed out after 5m"
  fi
}

# Execute collectors
$GATHER_MDMCLIENT      && gather_mdmclient
$GATHER_APP_INSTALL    && gather_app_install_logs
$GATHER_INSTALL_LOGS   && gather_install_logs
$GATHER_SYSTEM_LOGS    && gather_system_logs
$GATHER_COMPANY_PORTAL && gather_company_portal_logs
$GATHER_INTUNE_AGENT   && gather_intune_agent_logs
$GATHER_SYSDIAGNOSE    && gather_sysdiagnose

# Fix ownership & permissions
if [[ -n "$consoleUser" ]]; then
  log "Fixing ownership & perms"
  chown -R "$consoleUser":staff "$OUTPUT" || log "chown failed"
  chmod -R u+rwX,go+rX "$OUTPUT" || log "chmod failed"
fi

# Summary
echo
log "Diagnostics collected into ${OUTPUT}"
find "$OUTPUT" -type f | sed 's/^/    /'

# Optional: ZIP to Desktop
if [[ "$ZIP_OUTPUT" == "true" && -n "$consoleUser" ]]; then
  zipPath="/Users/${consoleUser}/Desktop/IntuneDiagnostics_${ts}.zip"
  log "Creating ZIP → ${zipPath}"
  if ditto -c -k --sequesterRsrc --keepParent "$OUTPUT" "$zipPath"; then
    chown "$consoleUser":staff "$zipPath" || true
    log "ZIP creation succeeded"
  else
    log "ERROR: ZIP creation failed"
  fi
fi

log "Collection complete"
