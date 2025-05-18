#!/bin/zsh
#set -x
############################################################################################
##
## Combined script to set FeatureLockDown and NGL policies for Adobe Acrobat on macOS
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
appname="AdobeAcrobatCombinedPolicyEnforcer"                                               # The name of our script
acrobat_plist="/Library/Preferences/com.adobe.Acrobat.Pro.plist"                           # Location of plist of Adobe Acrobat FeatureLockDown policies
ngl_plist="/Library/Preferences/com.adobe.NGL.AuthInfo.plist"                              # Location of plist of Adobe NGL policy for login_domain
plistbuddy="/usr/libexec/PlistBuddy"                                                       # Location of plistbuddy, that we will use
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/$appname"                             # The location of our logs and last updated data
log="$logandmetadir/$appname.log"                                                          # The location of the script log file

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

# Ensure Adobe Acrobat FeatureLockDown plist exist
acrobat_create_plist() {
  if [[ ! -f "$acrobat_plist" ]]; then
    echo "$(/bin/date) | [CREATE] Creating empty plist at $acrobat_plist"
    $plistbuddy -c "Clear" "$acrobat_plist" > /dev/null 2>&1
  fi
}

# Ensure Adobe NGL plist for login_domain exist
ngl_create_plist() {
  if [[ ! -f "$ngl_plist" ]]; then
    echo "$(/bin/date) | [CREATE] Creating empty plist at $ngl_plist"
    $plistbuddy -c "Clear" "$ngl_plist" > /dev/null 2>&1
  fi
}

# Acrobat: Ensure parent dictionaries exist
acrobat_ensure_parents_exist() {
  local path="$1"
  local plist="$2"

  local -a parts
  parts=("${(@s/:/)path}")
  for ((i = 1; i < ${#parts[@]}; i++)); do
    local current_path="${(j/:/)parts[1,i]}"
    if ! $plistbuddy -c "Print $current_path" "$acrobat_plist" &>/dev/null; then
      echo "$(/bin/date) | [ADD] Creating missing dictionary: $current_path"
      $plistbuddy -c "Add $current_path dict" "$acrobat_plist"
    fi
  done
}

# NGL: Ensure parent dictionaries exist
ngl_ensure_parents_exist() {
  local path="$1"
  local plist="$2"

  local -a parts
  parts=("${(@s/:/)path}")
  for ((i = 1; i < ${#parts[@]}; i++)); do
    local current_path="${(j/:/)parts[1,i]}"
    if ! $plistbuddy -c "Print $current_path" "$ngl_plist" &>/dev/null; then
      echo "$(/bin/date) | [ADD] Creating missing dictionary: $current_path"
      $plistbuddy -c "Add $current_path dict" "$ngl_plist"
    fi
  done
}

# Acrobat: Enforce key value
acrobat_enforce_value() {
  local key_path="$1"
  local type="$2"
  local expected="$3"

  acrobat_ensure_parents_exist "$key_path" "$acrobat_plist"

  if $plistbuddy -c "Print $key_path" "$acrobat_plist" &>/dev/null; then
    local current="$($plistbuddy -c "Print $key_path" "$acrobat_plist")"
    if [[ "$current" != "$expected" ]]; then
      echo "$(/bin/date) | [UPDATE] $key_path: $current -> $expected"
      $plistbuddy -c "Set $key_path $expected" "$acrobat_plist"
    else
      echo "$(/bin/date) | [OK] $key_path is already set to $expected"
    fi
  else
    echo "$(/bin/date) | [ADD] $key_path = $expected"
    $plistbuddy -c "Add $key_path $type $expected" "$acrobat_plist"
  fi
}

# NGL: Enforce key value
ngl_enforce_value() {
  local key_path="$1"
  local type="$2"
  local expected="$3"

  ngl_ensure_parents_exist "$key_path" "$ngl_plist"

  if $plistbuddy -c "Print $key_path" "$ngl_plist" &>/dev/null; then
    local current="$($plistbuddy -c "Print $key_path" "$ngl_plist")"
    if [[ "$current" != "$expected" ]]; then
      echo "$(/bin/date) | [UPDATE] $key_path: $current -> $expected"
      $plistbuddy -c "Set $key_path $expected" "$ngl_plist"
    else
      echo "$(/bin/date) | [OK] $key_path is already set to $expected"
    fi
  else
    echo "$(/bin/date) | [ADD] $key_path = $expected"
    $plistbuddy -c "Add $key_path $type $expected" "$ngl_plist"
  fi
}


# Acrobat: Delete key if it exists
acrobat_delete_key() {
  local key_path="$1"
  if $plistbuddy -c "Print $key_path" "$acrobat_plist" &>/dev/null; then
    echo "$(/bin/date) | [DELETE] Removing key: $key_path"
    $plistbuddy -c "Delete $key_path" "$acrobat_plist"
  else
    echo "$(/bin/date) | [INFO] Key not found, nothing to delete: $key_path"
  fi
}

# NGL: Delete key if it exists
ngl_delete_key() {
  local key_path="$1"
  if $plistbuddy -c "Print $key_path" "$ngl_plist" &>/dev/null; then
    echo "$(/bin/date) | [DELETE] Removing key: $key_path"
    $plistbuddy -c "Delete $key_path" "$ngl_plist"
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

# Apply Adobe Acrobat FeatureLockDown policies
echo "$(/bin/date) | Applying Adobe Acrobat FeatureLockDown policies..."

# [CREATE] Create plist if not existed
acrobat_create_plist

# [ADD/UPDATE] FeatureLockdown - Root
acrobat_enforce_value "DC:FeatureLockdown:bProtectedMode" bool true "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:bToggleShareFeedback" bool false "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:bToggleFTE" bool true "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:bWhatsNewExp" bool false "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:bSuppressSignOut" bool true "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:bEnableCertificateBasedTrust" bool true "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:bEnhancedSecurityInBrowser" bool true "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:bEnhancedSecurityStandalone" bool true "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:bMIPLabelling" bool true "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:bMIPCheckPolicyOnDocSave" bool true "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:bEnableAV2Enterprise" bool false "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:bUpdater" bool true "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:bAcroSuppressUpsell" bool true "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:cSharePoint:bDisableSharePointFeatures" bool false "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:cWebmailProfiles:bDisableWebmail" bool false "$acrobat_plist"

# [ADD/UPDATE] FeatureLockdown - cIPM
acrobat_enforce_value "DC:FeatureLockdown:cIPM:bShowMsgAtLaunch" bool false "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:cIPM:bDontShowMsgWhenViewingDoc" bool false "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:cIPM:bAllowUserToChangeMsgPrefs" bool false "$acrobat_plist"

# [ADD/UPDATE] FeatureLockdown - cServices
acrobat_enforce_value "DC:FeatureLockdown:cServices:bToggleWebConnectors" bool true "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:cServices:bOneDriveConnectorEnabled" bool false "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:cServices:bBoxConnectorEnabled" bool false "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:cServices:bDropboxConnectorEnabled" bool false "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:cServices:bGoogleDriveConnectorEnabled" bool false "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:cServices:bToggleAdobeDocumentServices" bool true "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:cServices:bToggleNotifications" bool true "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:cServices:bToggleSendACopy" bool true "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:cServices:bToggleAdobeSign" bool true "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:cServices:bToggleManageSign" bool true "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:cServices:bUpdater" bool true "$acrobat_plist"
acrobat_enforce_value "DC:FeatureLockdown:cServices:bTogglePrefsSync" bool true "$acrobat_plist"

# [ADD/UPDATE] NGL - AuthInfo
acrobat_enforce_value "NGL:AuthInfo:enabled_social_providers" string "" "$acrobat_plist"

# [ADD/UPDATE] NGL - AuthInfo
acrobat_enforce_value "NGL:Config:EnableExternalBrowserAuth" bool true "$acrobat_plist"

# [DELETE] FeatureLockdown - Root (Example commented)
# acrobat_delete_key "DC:FeatureLockdown:bWhatsNewExp"

# Apply Adobe NGL policy for login_domain
echo ""
echo "$(/bin/date) | Applying NGL AuthInfo policy for login_domain..."

# [CREATE] Create plist if not existed
ngl_create_plist

# [ADD/UPDATE] AuthInfo - login_domain
ngl_enforce_value "AuthInfo:login_domain" string "example.com" "$ngl_plist"

# [DELETE] AuthInfo - login_domain (Example commented)
# ngl_delete_key "AuthInfo:login_domain"

# End of script
echo ""
echo "$(/bin/date) | Script $appname completed."
echo "############################################################"