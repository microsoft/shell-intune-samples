#!/bin/zsh
#set -x
############################################################################################
##
## Script to set and enforce policies to iManage Work Desktop on macOS (Machine Level)
##
############################################################################################

## Copyright (c) 2025 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: neiljohn@microsoft.com

# Define variables
appname="iManageWorkDesktopPolicyEnforcerMachineLevel"                                       # The name of our script
plist="/Library/Application Support/iManage/Configuration/com.imanage.configuration.plist"   # Location of plist for iManage Work Desktop
plistbuddy="/usr/libexec/PlistBuddy"                                                         # Location of plistbuddy, that we will use
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/$appname"                               # The location of our logs and last updated data
log="$logandmetadir/$appname.log"                                                            # The location of the script log file

# Create log directory if it doesn't exist
if [ ! -d "$logandmetadir" ]; then
    echo "$(/bin/date) | Creating log directory - $logandmetadir"
    mkdir -p "$logandmetadir"
else
    echo "$(/bin/date) | Log directory already exists - $logandmetadir"
fi

# Ensure PlistBuddy exists
if [ ! -x "$plistbuddy" ]; then
    echo "$(/bin/date) | ERROR: PlistBuddy not found at $plistbuddy"
    exit 1
fi

# Ensure parent directory exists
ensure_directory_exists() {
  local dir_path
  dir_path="$(dirname "$plist")"
  if [ ! -d "$dir_path" ]; then
    echo "$(/bin/date) | Creating directory: $dir_path"
    mkdir -p "$dir_path"
  else
    echo "$(/bin/date) | Directory already exists: $dir_path"
  fi
}

# Ensure plist exist
create_plist() {
  ensure_directory_exists
  if [[ ! -f "$plist" ]]; then
    echo "$(/bin/date) | [CREATE] Creating empty plist at $plist"
    $plistbuddy -c "Clear" "$plist" > /dev/null 2>&1
  fi
}

# Ensure parent dictionaries exist
ensure_parents_exist() {
  local path="$1"
  local plist="$2"

  local -a parts
  parts=("${(@s/:/)path}")
  local quoted_parts=()

  for part in "${parts[@]}"; do
    quoted_parts+=("'$part'")
  done

  for ((i = 1; i < ${#quoted_parts[@]}; i++)); do
    local current_path="${(j/:/)quoted_parts[1,i]}"
    if ! $plistbuddy -c "Print $current_path" "$plist" &>/dev/null; then
      echo "$(/bin/date) | [ADD] Creating missing dictionary: ${(j/:/)parts[1,i]}"
      $plistbuddy -c "Add $current_path dict" "$plist"
    fi
  done
}

# Enforce key value
enforce_value() {
  local key_path="$1"
  local type="$2"
  local expected="$3"

  ensure_parents_exist "$key_path" "$plist"

  if $plistbuddy -c "Print '$key_path'" "$plist" &>/dev/null; then
    local current="$($plistbuddy -c "Print '$key_path'" "$plist")"
    if [[ "$current" != "$expected" ]]; then
      echo "$(/bin/date) | [UPDATE] $key_path: $current -> $expected"
      $plistbuddy -c "Set '$key_path' $expected" "$plist"
    else
      echo "$(/bin/date) | [OK] $key_path is already set to $expected"
    fi
  else
    echo "$(/bin/date) | [ADD] $key_path = $expected"
    $plistbuddy -c "Add '$key_path' $type $expected" "$plist"
  fi
}

# Delete key if it exists
delete_key() {
  local key_path="$1"
  if $plistbuddy -c "Print '$key_path'" "$plist" &>/dev/null; then
    echo "$(/bin/date) | [DELETE] Removing key: $key_path"
    $plistbuddy -c "Delete '$key_path'" "$plist"
  else
    echo "$(/bin/date) | [INFO] Key not found, nothing to delete: $key_path"
  fi
}

# Start logging
exec &> >(tee -a "$log")

# Begin Script Body
echo ""
echo "##############################################################"
echo "# $(/bin/date) | Starting running of script $appname"
echo "##############################################################"
echo ""

# Run functions

# Apply iManage Work Desktop policies
echo "$(/bin/date) | Applying iManage Work Desktop policies..."

# [CREATE] Create plist if not existed
create_plist

# [ADD/UPDATE] CheckIn Default - Root
enforce_value "CheckIn Default" integer 2 "$plist"

# [ADD/UPDATE] Disable AutoUpdates - Root
enforce_value "Disable AutoUpdates" boolean false "$plist"

# [ADD/UPDATE] Email Client Configuration - Root
enforce_value "Email Client Configuration" integer 3 "$plist"

# [ADD/UPDATE] MDM Payload - Root
enforce_value "MDM Payload" bool true "$plist"

# [ADD/UPDATE] ServerURL - Root
enforce_value "ServerURL" string "https://dms.example.com" "$plist"

# [DELETE] ServerURL - Root (Example commented)
# delete_key "ServerURL"

# End of script
echo ""
echo "$(/bin/date) | Script $appname completed."
echo "##############################################################"