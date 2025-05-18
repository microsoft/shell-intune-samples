#!/bin/zsh
#set -x
############################################################################################
##
## Script to set policies for Adobe Acrobat
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
appname="AdobeAcrobatPolicies"                                                 # The name of our script
plist="$HOME/Library/Preferences/com.adobe.Acrobat.Pro.plist"                  # Location of plist-file, that we will create or modify
plistbuddy="/usr/libexec/PlistBuddy"                                           # Location of plistbuddy, that we will use
logandmetadir="$HOME/Library/Logs/Microsoft/IntuneScripts/$appname"            # The location of our logs and last updated data
log="$logandmetadir/$appname.log"                                              # The location of the script log file

# Check if the log directory has been created
if [ -d "$logandmetadir" ]; then
    echo "$(/bin/date) | Log directory already exists - $logandmetadir"
else
    echo "$(/bin/date) | Creating log directory - $logandmetadir"
    mkdir -p "$logandmetadir"
fi

# Ensure PlistBuddy exists
if [ ! -x "$plistbuddy" ]; then
    echo "$(/bin/date) | ERROR: PlistBuddy not found at $plistbuddy"
    exit 1
fi

# Ensure Adobe Acrobat plist exist
create_plist() {
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
  for ((i = 1; i < ${#parts[@]}; i++)); do
    local current_path="${(j/:/)parts[1,i]}"
    if ! $plistbuddy -c "Print $current_path" "$plist" &>/dev/null; then
      echo "$(/bin/date) | [ADD] Creating missing dictionary: $current_path"
      $plistbuddy -c "Add $current_path dict" "$plist"
    fi
  done
}

# Enforce key value
acrobat_create_value() {
  local key_path="$1"
  local type="$2"
  local expected="$3"

  ensure_parents_exist "$key_path" "$plist"

  if $plistbuddy -c "Print $key_path" "$plist" &>/dev/null; then
    local current="$($plistbuddy -c "Print $key_path" "$plist")"
    if [[ "$current" != "$expected" ]]; then
      echo "$(/bin/date) | [UPDATE] $key_path: $current -> $expected"
      $plistbuddy -c "Set $key_path $expected" "$plist"
    else
      echo "$(/bin/date) | [OK] $key_path is already set to $expected"
    fi
  else
    echo "$(/bin/date) | [ADD] $key_path = $expected"
    $plistbuddy -c "Add $key_path $type $expected" "$plist"
  fi
}

# Delete key if it exists
acrobat_delete_key() {
  local key_path="$1"
  if $plistbuddy -c "Print $key_path" "$plist" &>/dev/null; then
    echo "$(/bin/date) | [DELETE] Removing key: $key_path"
    $plistbuddy -c "Delete $key_path" "$plist"
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

# Apply Adobe Acrobat policies
echo "$(/bin/date) | Applying Adobe Acrobat policies..."

# [CREATE] Create plist if not existed
create_plist

# [ADD/UPDATE] Access - Root
acrobat_create_value "DC:Access:bShowKeyboardSelectionCursor" bool true

# [ADD/UPDATE] UnifiedShare - Root
acrobat_create_value "DC:UnifiedShare:bLastAttachLinkMode" bool true

# [ADD/UPDATE] FormsPrefs - cRuntimeBGIdleColor
acrobat_create_value "DC:FormsPrefs:cRuntimeBGIdleColor:bRuntimeHighlight" bool true

# [ADD/UPDATE] Originals - Root
acrobat_create_value "DC:Originals:bDisplayAboutDialog" bool true
acrobat_create_value "DC:Originals:bAllowOpenFile" bool true

# [ADD/UPDATE] JSPrefs - Root
acrobat_create_value "DC:JSPrefs:bEnableJS" bool true

# [ADD/UPDATE] Security - cDigSig - cCustomDownload
acrobat_create_value "DC:Security:cDigSig:cCustomDownload:bAskBeforeInstalling" bool true

# [ADD/UPDATE] Security - cDigSig - cAdobeDownload
acrobat_create_value "DC:Security:cDigSig:cAdobeDownload:bLoadSettingsFromURL" bool true

# [ADD/UPDATE] TrustManager - Root
acrobat_create_value "DC:TrustManager:bTrustCertifiedDocuments" bool true
acrobat_create_value "DC:TrustManager:bTrustOSTrustedSites" bool true

# [DELETE] Access - Root (Example commented)
# acrobat_delete_key "DC:Access:bShowKeyboardSelectionCursor"

# End of script
echo ""
echo "$(/bin/date) | Script $appname completed."
echo "############################################################"
