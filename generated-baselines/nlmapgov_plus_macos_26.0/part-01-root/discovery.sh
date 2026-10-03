#!/bin/bash

normalize_output() {
  local value="$1"
  value=${value//$'\r'/ }
  value=${value//$'\n'/ }
  value=${value//$'\t'/ }
  printf '%s' "$value" | /usr/bin/sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//'
}

json_escape() {
  local value="$1"
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  printf '%s' "$value"
}

emit_separator=""

emit_string_field() {
  local name="$1"
  local value="$2"
  printf '%s"%s":"%s"' "$emit_separator" "$name" "$(json_escape "$value")"
  emit_separator=','
}

emit_int_field() {
  local name="$1"
  local value="$2"
  if [[ ! "$value" =~ ^-?[0-9]+$ ]]; then
    >&2 echo "[$name] expected integer output but got: $value"
    value=0
  fi
  printf '%s"%s":%s' "$emit_separator" "$name" "$value"
  emit_separator=','
}

printf '{'

# audit_acls_files_configure
run_check_001() {
  /bin/bash <<'__MSCP_RULE_001__'
/bin/ls -le $(/usr/bin/grep '^dir' /etc/security/audit_control | /usr/bin/awk -F: '{print $2}') | /usr/bin/awk '{print $1}' | /usr/bin/grep -c ":"
__MSCP_RULE_001__
}
raw_output="$(run_check_001 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_acls_files_configure" "$normalized_output"

# audit_acls_folders_configure
run_check_002() {
  /bin/bash <<'__MSCP_RULE_002__'
/bin/ls -lde /var/audit | /usr/bin/awk '{print $1}' | /usr/bin/grep -c ":"
__MSCP_RULE_002__
}
raw_output="$(run_check_002 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_acls_folders_configure" "$normalized_output"

# audit_auditd_enabled
run_check_003() {
  /bin/bash <<'__MSCP_RULE_003__'
LAUNCHD_RUNNING=$(/bin/launchctl print system | /usr/bin/grep -c -E '\tcom.apple.auditd')
AUDITD_RUNNING=$(/usr/sbin/audit -c | /usr/bin/grep -c "AUC_AUDITING")
if [[ $LAUNCHD_RUNNING == 1 ]] && [[ -e /etc/security/audit_control ]] && [[ $AUDITD_RUNNING == 1 ]]; then
  echo "pass"
else
  echo "fail"
fi
__MSCP_RULE_003__
}
raw_output="$(run_check_003 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "audit_auditd_enabled" "$normalized_output"

# audit_control_acls_configure
run_check_004() {
  /bin/bash <<'__MSCP_RULE_004__'
/bin/ls -le /etc/security/audit_control | /usr/bin/awk '{print $1}' | /usr/bin/grep -c ":"
__MSCP_RULE_004__
}
raw_output="$(run_check_004 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_control_acls_configure" "$normalized_output"

# audit_control_group_configure
run_check_005() {
  /bin/bash <<'__MSCP_RULE_005__'
/bin/ls -dn /etc/security/audit_control | /usr/bin/awk '{print $4}'
__MSCP_RULE_005__
}
raw_output="$(run_check_005 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_control_group_configure" "$normalized_output"

# audit_control_mode_configure
run_check_006() {
  /bin/bash <<'__MSCP_RULE_006__'
/bin/ls -l /etc/security/audit_control | /usr/bin/awk '!/-r--[r-]-----|current|total/{print $1}' | /usr/bin/wc -l | /usr/bin/xargs
__MSCP_RULE_006__
}
raw_output="$(run_check_006 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_control_mode_configure" "$normalized_output"

# audit_control_owner_configure
run_check_007() {
  /bin/bash <<'__MSCP_RULE_007__'
/bin/ls -dn /etc/security/audit_control | /usr/bin/awk '{print $3}'
__MSCP_RULE_007__
}
raw_output="$(run_check_007 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_control_owner_configure" "$normalized_output"

# audit_files_group_configure
run_check_008() {
  /bin/bash <<'__MSCP_RULE_008__'
/bin/ls -n $(/usr/bin/grep '^dir' /etc/security/audit_control | /usr/bin/awk -F: '{print $2}') | /usr/bin/awk '{s+=$4} END {print s}'
__MSCP_RULE_008__
}
raw_output="$(run_check_008 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_files_group_configure" "$normalized_output"

# audit_files_mode_configure
run_check_009() {
  /bin/bash <<'__MSCP_RULE_009__'
/bin/ls -l $(/usr/bin/grep '^dir' /etc/security/audit_control | /usr/bin/awk -F: '{print $2}') | /usr/bin/awk '!/-r--r-----|current|total/{print $1}' | /usr/bin/wc -l | /usr/bin/tr -d ' '
__MSCP_RULE_009__
}
raw_output="$(run_check_009 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_files_mode_configure" "$normalized_output"

# audit_files_owner_configure
run_check_010() {
  /bin/bash <<'__MSCP_RULE_010__'
/bin/ls -n $(/usr/bin/grep '^dir' /etc/security/audit_control | /usr/bin/awk -F: '{print $2}') | /usr/bin/awk '{s+=$3} END {print s}'
__MSCP_RULE_010__
}
raw_output="$(run_check_010 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_files_owner_configure" "$normalized_output"

# audit_flags_ad_configure
run_check_011() {
  /bin/bash <<'__MSCP_RULE_011__'
/usr/bin/awk -F':' '/^flags/ { print $NF }' /etc/security/audit_control | /usr/bin/tr ',' '\n' | /usr/bin/grep -Ec 'ad'
__MSCP_RULE_011__
}
raw_output="$(run_check_011 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_flags_ad_configure" "$normalized_output"

# audit_folder_group_configure
run_check_012() {
  /bin/bash <<'__MSCP_RULE_012__'
/bin/ls -dn $(/usr/bin/grep '^dir' /etc/security/audit_control | /usr/bin/awk -F: '{print $2}') | /usr/bin/awk '{print $4}'
__MSCP_RULE_012__
}
raw_output="$(run_check_012 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_folder_group_configure" "$normalized_output"

# audit_folder_owner_configure
run_check_013() {
  /bin/bash <<'__MSCP_RULE_013__'
/bin/ls -dn $(/usr/bin/grep '^dir' /etc/security/audit_control | /usr/bin/awk -F: '{print $2}') | /usr/bin/awk '{print $3}'
__MSCP_RULE_013__
}
raw_output="$(run_check_013 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_folder_owner_configure" "$normalized_output"

# audit_folders_mode_configure
run_check_014() {
  /bin/bash <<'__MSCP_RULE_014__'
/usr/bin/stat -f %A $(/usr/bin/grep '^dir' /etc/security/audit_control | /usr/bin/awk -F: '{print $2}')
__MSCP_RULE_014__
}
raw_output="$(run_check_014 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_folders_mode_configure" "$normalized_output"

# audit_retention_configure
run_check_015() {
  /bin/bash <<'__MSCP_RULE_015__'
/usr/bin/awk -F: '/expire-after/{print $2}' /etc/security/audit_control
__MSCP_RULE_015__
}
raw_output="$(run_check_015 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "audit_retention_configure" "$normalized_output"

# icloud_drive_disable
run_check_016() {
  /bin/bash <<'__MSCP_RULE_016__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowCloudDocumentSync').js
EOS
__MSCP_RULE_016__
}
raw_output="$(run_check_016 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "icloud_drive_disable" "$normalized_output"

# icloud_keychain_disable
run_check_017() {
  /bin/bash <<'__MSCP_RULE_017__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowCloudKeychainSync').js
EOS
__MSCP_RULE_017__
}
raw_output="$(run_check_017 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "icloud_keychain_disable" "$normalized_output"

# icloud_sync_disable
run_check_018() {
  /bin/bash <<'__MSCP_RULE_018__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowCloudDesktopAndDocuments').js
EOS
__MSCP_RULE_018__
}
raw_output="$(run_check_018 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "icloud_sync_disable" "$normalized_output"

# os_anti_virus_installed
run_check_019() {
  /bin/bash <<'__MSCP_RULE_019__'
/usr/bin/xprotect status | /usr/bin/grep -cE "(launch scans: enabled|background scans: enabled)"
__MSCP_RULE_019__
}
raw_output="$(run_check_019 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_anti_virus_installed" "$normalized_output"

# os_authenticated_root_enable
run_check_020() {
  /bin/bash <<'__MSCP_RULE_020__'
/sbin/mount | /usr/bin/grep ' / ' | /usr/bin/grep -o 'sealed'
__MSCP_RULE_020__
}
raw_output="$(run_check_020 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_authenticated_root_enable" "$normalized_output"

# os_external_storage_access_defined
run_check_021() {
  /bin/bash <<'__MSCP_RULE_021__'
/usr/bin/plutil -convert json /var/db/ManagedConfigurationFiles/DiskManagement/DiskManagement_Settings.plist -o - | /usr/bin/jq --raw-output '.Restrictions.ExternalStorage'
__MSCP_RULE_021__
}
raw_output="$(run_check_021 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_external_storage_access_defined" "$normalized_output"

# os_gatekeeper_enable
run_check_022() {
  /bin/bash <<'__MSCP_RULE_022__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.systempolicy.control')\
.objectForKey('EnableAssessment').js
EOS
__MSCP_RULE_022__
}
raw_output="$(run_check_022 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_gatekeeper_enable" "$normalized_output"

# os_home_folders_secure
run_check_023() {
  /bin/bash <<'__MSCP_RULE_023__'
/usr/bin/find /System/Volumes/Data/Users -mindepth 1 -maxdepth 1 -type d ! \( -perm 700 -o -perm 711 \) | /usr/bin/grep -v "Shared" | /usr/bin/grep -v "Guest" | /usr/bin/wc -l | /usr/bin/xargs
__MSCP_RULE_023__
}
raw_output="$(run_check_023 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_home_folders_secure" "$normalized_output"

# os_httpd_disable
run_check_024() {
  /bin/bash <<'__MSCP_RULE_024__'
result="FAIL"
enabled=$(/bin/launchctl print-disabled system | /usr/bin/grep '"org.apache.httpd" => enabled')
running=$(/bin/launchctl print system/org.apache.httpd 2>/dev/null)

if [[ -z "$running" ]] && [[ -z "$enabled" ]]; then
  result="PASS"
elif [[ -n "$running" ]]; then
  result="${result}  RUNNING"
elif [[ -n "$enabled" ]]; then
  result="${result}  ENABLED"
fi
echo $result
__MSCP_RULE_024__
}
raw_output="$(run_check_024 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_httpd_disable" "$normalized_output"

# os_install_log_retention_configure
run_check_025() {
  /bin/bash <<'__MSCP_RULE_025__'
/usr/sbin/aslmanager -dd 2>&1 | /usr/bin/awk '/\/var\/log\/install.log$/ {count++} /Processing module com.apple.install/,/Finished/ { for (i=1;i<=NR;i++) { if ($i == "TTL" && $(i+2) >= 365) { ttl="True" }; if ($i == "MAX") {max="True"}}} END{if (count > 1) { print "Multiple config files for /var/log/install, manually remove the extra files"} else if (max == "True") { print "all_max setting is configured, must be removed" } if (ttl != "True") { print "TTL not configured" } else { print "Yes" }}'
__MSCP_RULE_025__
}
raw_output="$(run_check_025 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_install_log_retention_configure" "$normalized_output"

# os_mdm_require
run_check_026() {
  /bin/bash <<'__MSCP_RULE_026__'
/usr/bin/profiles status -type enrollment | /usr/bin/awk -F: '/MDM enrollment/ {print $2}' | /usr/bin/grep -c "Yes (User Approved)"
__MSCP_RULE_026__
}
raw_output="$(run_check_026 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_mdm_require" "$normalized_output"

# os_nfsd_disable
run_check_027() {
  /bin/bash <<'__MSCP_RULE_027__'
isDisabled=$(/sbin/nfsd status | /usr/bin/awk '/nfsd service/ {print $NF}')
if [[ "$isDisabled" == "disabled" ]] && [[ -z $(/usr/bin/pgrep nfsd) ]]; then
  echo "pass"
else
  echo "fail"
fi
__MSCP_RULE_027__
}
raw_output="$(run_check_027 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_nfsd_disable" "$normalized_output"

# os_on_device_dictation_enforce
run_check_028() {
  /bin/bash <<'__MSCP_RULE_028__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('forceOnDeviceOnlyDictation').js
EOS
__MSCP_RULE_028__
}
raw_output="$(run_check_028 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_on_device_dictation_enforce" "$normalized_output"

# os_password_hint_remove
run_check_029() {
  /bin/bash <<'__MSCP_RULE_029__'
HINT=$(/usr/bin/dscl . -list /Users hint | /usr/bin/awk '{ print $2 }')

if [ -z "$HINT" ]; then
  echo "PASS"
else
  echo "FAIL"
fi
__MSCP_RULE_029__
}
raw_output="$(run_check_029 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_password_hint_remove" "$normalized_output"

# os_password_proximity_disable
run_check_030() {
  /bin/bash <<'__MSCP_RULE_030__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowPasswordProximityRequests').js
EOS
__MSCP_RULE_030__
}
raw_output="$(run_check_030 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_password_proximity_disable" "$normalized_output"

# os_password_sharing_disable
run_check_031() {
  /bin/bash <<'__MSCP_RULE_031__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowPasswordSharing').js
EOS
__MSCP_RULE_031__
}
raw_output="$(run_check_031 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_password_sharing_disable" "$normalized_output"

# os_root_disable
run_check_032() {
  /bin/bash <<'__MSCP_RULE_032__'
/usr/bin/dscl '/Local/Default' read '/Users/root' AuthenticationAuthority 2>/dev/null | /usr/bin/grep -c 'AuthenticationAuthority'
__MSCP_RULE_032__
}
raw_output="$(run_check_032 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_root_disable" "$normalized_output"

# os_safari_advertising_privacy_protection_enable
run_check_033() {
  /bin/bash <<'__MSCP_RULE_033__'
/usr/bin/profiles -P -o stdout | /usr/bin/grep -c '"WebKitPreferences.privateClickMeasurementEnabled" = 1' | /usr/bin/awk '{ if ($1 >= 1) {print "1"} else {print "0"}}'
__MSCP_RULE_033__
}
raw_output="$(run_check_033 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_safari_advertising_privacy_protection_enable" "$normalized_output"

# os_safari_open_safe_downloads_disable
run_check_034() {
  /bin/bash <<'__MSCP_RULE_034__'
/usr/bin/profiles -P -o stdout | /usr/bin/grep -c 'AutoOpenSafeDownloads = 0' | /usr/bin/awk '{ if ($1 >= 1) {print "1"} else {print "0"}}'
__MSCP_RULE_034__
}
raw_output="$(run_check_034 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_safari_open_safe_downloads_disable" "$normalized_output"

# os_safari_prevent_cross-site_tracking_enable
run_check_035() {
  /bin/bash <<'__MSCP_RULE_035__'
/usr/bin/profiles -P -o stdout | /usr/bin/grep -cE '"WebKitPreferences.storageBlockingPolicy" = 1|"WebKitStorageBlockingPolicy" = 1|"BlockStoragePolicy" =2' | /usr/bin/awk '{ if ($1 >= 1) {print "1"} else {print "0"}}'
__MSCP_RULE_035__
}
raw_output="$(run_check_035 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_safari_prevent_cross-site_tracking_enable" "$normalized_output"

# os_safari_show_full_website_address_enable
run_check_036() {
  /bin/bash <<'__MSCP_RULE_036__'
/usr/bin/profiles -P -o stdout | /usr/bin/grep -c 'ShowFullURLInSmartSearchField = 1' | /usr/bin/awk '{ if ($1 >= 1) {print "1"} else {print "0"}}'
__MSCP_RULE_036__
}
raw_output="$(run_check_036 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_safari_show_full_website_address_enable" "$normalized_output"

# os_safari_show_status_bar_enabled
run_check_037() {
  /bin/bash <<'__MSCP_RULE_037__'
/usr/bin/profiles -P -o stdout | /usr/bin/grep -c 'ShowOverlayStatusBar = 1' | /usr/bin/awk '{ if ($1 >= 1) {print "1"} else {print "0"}}'
__MSCP_RULE_037__
}
raw_output="$(run_check_037 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_safari_show_status_bar_enabled" "$normalized_output"

# os_safari_warn_fraudulent_website_enable
run_check_038() {
  /bin/bash <<'__MSCP_RULE_038__'
/usr/bin/profiles -P -o stdout | /usr/bin/grep -c 'WarnAboutFraudulentWebsites = 1' | /usr/bin/awk '{ if ($1 >= 1) {print "1"} else {print "0"}}'
__MSCP_RULE_038__
}
raw_output="$(run_check_038 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_safari_warn_fraudulent_website_enable" "$normalized_output"

# os_secure_boot_verify
run_check_039() {
  /bin/bash <<'__MSCP_RULE_039__'
/usr/libexec/mdmclient QuerySecurityInfo 2>/dev/null | /usr/bin/grep -c "SecureBootLevel = full"
__MSCP_RULE_039__
}
raw_output="$(run_check_039 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_secure_boot_verify" "$normalized_output"

# os_setup_assistant_filevault_enforce
run_check_040() {
  /bin/bash <<'__MSCP_RULE_040__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.MCX.FileVault2')\
.objectForKey('ForceEnableInSetupAssistant')
EOS
__MSCP_RULE_040__
}
raw_output="$(run_check_040 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_setup_assistant_filevault_enforce" "$normalized_output"

# os_sip_enable
run_check_041() {
  /bin/bash <<'__MSCP_RULE_041__'
/usr/bin/csrutil status | /usr/bin/grep -c 'System Integrity Protection status: enabled.'
__MSCP_RULE_041__
}
raw_output="$(run_check_041 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_sip_enable" "$normalized_output"

# os_software_update_app_update_enforce
run_check_042() {
  /bin/bash <<'__MSCP_RULE_042__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.SoftwareUpdate')\
.objectForKey('AutomaticallyInstallAppUpdates').js
EOS
__MSCP_RULE_042__
}
raw_output="$(run_check_042 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_software_update_app_update_enforce" "$normalized_output"

# os_sudo_log_enforce
run_check_043() {
  /bin/bash <<'__MSCP_RULE_043__'
/usr/bin/sudo /usr/bin/sudo -V | /usr/bin/grep -c "Log when a command is allowed by sudoers"
__MSCP_RULE_043__
}
raw_output="$(run_check_043 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_sudo_log_enforce" "$normalized_output"

# os_sudoers_timestamp_type_configure
run_check_044() {
  /bin/bash <<'__MSCP_RULE_044__'
/usr/bin/sudo /usr/bin/sudo -V | /usr/bin/awk -F": " '/Type of authentication timestamp record/{print $2}'
__MSCP_RULE_044__
}
raw_output="$(run_check_044 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_sudoers_timestamp_type_configure" "$normalized_output"

# os_terminal_secure_keyboard_enable
run_check_045() {
  /bin/bash <<'__MSCP_RULE_045__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.Terminal')\
.objectForKey('SecureKeyboardEntry').js
EOS
__MSCP_RULE_045__
}
raw_output="$(run_check_045 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_terminal_secure_keyboard_enable" "$normalized_output"

# os_time_server_enabled
run_check_046() {
  /bin/bash <<'__MSCP_RULE_046__'
/bin/launchctl print system | /usr/bin/grep -c -E '\tcom.apple.timed'
__MSCP_RULE_046__
}
raw_output="$(run_check_046 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_time_server_enabled" "$normalized_output"

# os_unlock_active_user_session_disable
run_check_047() {
  /bin/bash <<'__MSCP_RULE_047__'
RESULT="FAIL"
SS_RULE=$(/usr/bin/security -q authorizationdb read system.login.screensaver  2>&1 | /usr/bin/xmllint --xpath "//dict/key[.='rule']/following-sibling::array[1]/string/text()" -)

if [[ "${SS_RULE}" == "authenticate-session-owner" ]]; then
    RESULT="PASS"
else
    PSSO_CHECK=$(/usr/bin/security -q authorizationdb read "$SS_RULE"  2>&1 | /usr/bin/xmllint --xpath '//key[.="rule"]/following-sibling::array[1]/string/text()' -)
    if /usr/bin/grep -Fxq "authenticate-session-owner" <<<"$PSSO_CHECK"; then
        RESULT="PASS"
    fi
fi

echo $RESULT
__MSCP_RULE_047__
}
raw_output="$(run_check_047 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_unlock_active_user_session_disable" "$normalized_output"

# pwpolicy_minimum_length_enforce
run_check_048() {
  /bin/bash <<'__MSCP_RULE_048__'
/usr/bin/pwpolicy -getaccountpolicies 2>/dev/null | tail +2 | grep -oE "policyAttributePassword matches '.\{[0-9]+," | awk -F'[{,]' -v ODV=6 '{if ($2 > max) max=$2} END {print (max >= ODV) ? "pass" : "fail"}'
__MSCP_RULE_048__
}
raw_output="$(run_check_048 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "pwpolicy_minimum_length_enforce" "$normalized_output"

# system_settings_automatic_login_disable
run_check_049() {
  /bin/bash <<'__MSCP_RULE_049__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.loginwindow')\
.objectForKey('com.apple.login.mcx.DisableAutoLoginClient').js
EOS
__MSCP_RULE_049__
}
raw_output="$(run_check_049 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_automatic_login_disable" "$normalized_output"

# system_settings_background_security_improvement_removal_disable
run_check_050() {
  /bin/bash <<'__MSCP_RULE_050__'
/usr/bin/plutil -convert json /var/db/softwareupdate/SoftwareUpdateDDMStatePersistence.plist -o - | /usr/bin/jq --raw-output .'SUCorePersistedStatePolicyFields.SUCoreDDMDeclarationGlobalSettings.enableRapidSecurityResponseRollback'
__MSCP_RULE_050__
}
raw_output="$(run_check_050 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_background_security_improvement_removal_disable" "$normalized_output"

# system_settings_diagnostics_reports_disable
run_check_051() {
  /bin/bash <<'__MSCP_RULE_051__'
/usr/bin/osascript -l JavaScript << EOS
function run() {
let pref1 = $.NSUserDefaults.alloc.initWithSuiteName('com.apple.SubmitDiagInfo')\
.objectForKey('AutoSubmit').js
let pref2 = $.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowDiagnosticSubmission').js
if ( pref1 == false && pref2 == false ){
    return("true")
} else {
    return("false")
}
}
EOS
__MSCP_RULE_051__
}
raw_output="$(run_check_051 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_diagnostics_reports_disable" "$normalized_output"

# system_settings_download_software_update_enforce
run_check_052() {
  /bin/bash <<'__MSCP_RULE_052__'
/usr/bin/plutil -convert json /var/db/softwareupdate/SoftwareUpdateDDMStatePersistence.plist -o - | /usr/bin/jq --raw-output .'SUCorePersistedStatePolicyFields.SUCoreDDMDeclarationGlobalSettings.automaticallyDownload'
__MSCP_RULE_052__
}
raw_output="$(run_check_052 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_download_software_update_enforce" "$normalized_output"

# system_settings_external_intelligence_sign_in_disable
run_check_053() {
  /bin/bash <<'__MSCP_RULE_053__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowExternalIntelligenceIntegrationsSignIn').js
EOS
__MSCP_RULE_053__
}
raw_output="$(run_check_053 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_external_intelligence_sign_in_disable" "$normalized_output"

# system_settings_filevault_enforce
run_check_054() {
  /bin/bash <<'__MSCP_RULE_054__'
dontAllowDisable=$(/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.MCX')\
.objectForKey('dontAllowFDEDisable').js
EOS
)
fileVault=$(/usr/bin/fdesetup status | /usr/bin/grep -c "FileVault is On.")
if [[ "$dontAllowDisable" == "true" ]] && [[ "$fileVault" == 1 ]]; then
  echo "1"
else
  echo "0"
fi
__MSCP_RULE_054__
}
raw_output="$(run_check_054 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_filevault_enforce" "$normalized_output"

# system_settings_find_my_disable
run_check_055() {
  /bin/bash <<'__MSCP_RULE_055__'
/usr/bin/osascript -l JavaScript << EOS
function run() {
  let pref1 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowFindMyDevice'))
  let pref2 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowFindMyFriends'))
  let pref3 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.icloud.managed')\
.objectForKey('DisableFMMiCloudSetting'))
  if ( pref1 == false && pref2 == false && pref3 == true ) {
    return("true")
  } else {
    return("false")
  }
}
EOS
__MSCP_RULE_055__
}
raw_output="$(run_check_055 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_find_my_disable" "$normalized_output"

# system_settings_firewall_enable
run_check_056() {
  /bin/bash <<'__MSCP_RULE_056__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.security.firewall')\
.objectForKey('EnableFirewall').js
EOS
__MSCP_RULE_056__
}
raw_output="$(run_check_056 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_firewall_enable" "$normalized_output"

# system_settings_firewall_stealth_mode_enable
run_check_057() {
  /bin/bash <<'__MSCP_RULE_057__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.security.firewall')\
.objectForKey('EnableStealthMode').js
EOS
__MSCP_RULE_057__
}
raw_output="$(run_check_057 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_firewall_stealth_mode_enable" "$normalized_output"

# system_settings_gatekeeper_identified_developers_allowed
run_check_058() {
  /bin/bash <<'__MSCP_RULE_058__'
/usr/bin/osascript -l JavaScript << EOS
function run() {
  let pref1 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.systempolicy.control')\
.objectForKey('AllowIdentifiedDevelopers'))
  let pref2 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.systempolicy.control')\
.objectForKey('EnableAssessment'))
  if ( pref1 == true && pref2 == true ) {
    return("true")
  } else {
    return("false")
  }
}
EOS
__MSCP_RULE_058__
}
raw_output="$(run_check_058 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_gatekeeper_identified_developers_allowed" "$normalized_output"

# system_settings_gatekeeper_override_disallow
run_check_059() {
  /bin/bash <<'__MSCP_RULE_059__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.systempolicy.managed')\
.objectForKey('DisableOverride').js
EOS
__MSCP_RULE_059__
}
raw_output="$(run_check_059 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_gatekeeper_override_disallow" "$normalized_output"

# system_settings_guest_account_disable
run_check_060() {
  /bin/bash <<'__MSCP_RULE_060__'
/usr/bin/osascript -l JavaScript << EOS
function run() {
  let pref1 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.MCX')\
.objectForKey('DisableGuestAccount'))
  let pref2 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.MCX')\
.objectForKey('EnableGuestAccount'))
  if ( pref1 == true && pref2 == false ) {
    return("true")
  } else {
    return("false")
  }
}
EOS
__MSCP_RULE_060__
}
raw_output="$(run_check_060 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_guest_account_disable" "$normalized_output"

# system_settings_improve_assistive_voice_disable
run_check_061() {
  /bin/bash <<'__MSCP_RULE_061__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.Accessibility')\
.objectForKey('AXSAudioDonationSiriImprovementEnabled').js
EOS
__MSCP_RULE_061__
}
raw_output="$(run_check_061 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_improve_assistive_voice_disable" "$normalized_output"

# system_settings_improve_search_disable
run_check_062() {
  /bin/bash <<'__MSCP_RULE_062__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.assistant.support')\
.objectForKey('Search Queries Data Sharing Status').js
EOS
__MSCP_RULE_062__
}
raw_output="$(run_check_062 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_improve_search_disable" "$normalized_output"

# system_settings_improve_siri_dictation_disable
run_check_063() {
  /bin/bash <<'__MSCP_RULE_063__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.assistant.support')\
.objectForKey('Siri Data Sharing Opt-In Status').js
EOS
__MSCP_RULE_063__
}
raw_output="$(run_check_063 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_improve_siri_dictation_disable" "$normalized_output"

# system_settings_internet_sharing_disable
run_check_064() {
  /bin/bash <<'__MSCP_RULE_064__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.MCX')\
.objectForKey('forceInternetSharingOff').js
EOS
__MSCP_RULE_064__
}
raw_output="$(run_check_064 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_internet_sharing_disable" "$normalized_output"

# system_settings_macos_updates_install_enforce
run_check_065() {
  /bin/bash <<'__MSCP_RULE_065__'
/usr/bin/plutil -convert json /var/db/softwareupdate/SoftwareUpdateDDMStatePersistence.plist -o - | /usr/bin/jq --raw-output .'SUCorePersistedStatePolicyFields.SUCoreDDMDeclarationGlobalSettings.automaticallyInstallOSUpdates'
__MSCP_RULE_065__
}
raw_output="$(run_check_065 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_macos_updates_install_enforce" "$normalized_output"

# system_settings_media_sharing_disabled
run_check_066() {
  /bin/bash <<'__MSCP_RULE_066__'
/usr/bin/osascript -l JavaScript << EOS
function run() {
  let pref1 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowMediaSharing'))
  let pref2 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowMediaSharingModification'))
  if ( pref1 == false && pref2 == false ) {
    return("true")
  } else {
    return("false")
  }
}
EOS
__MSCP_RULE_066__
}
raw_output="$(run_check_066 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_media_sharing_disabled" "$normalized_output"

# system_settings_password_hints_disable
run_check_067() {
  /bin/bash <<'__MSCP_RULE_067__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.loginwindow')\
.objectForKey('RetriesUntilHint').js
EOS
__MSCP_RULE_067__
}
raw_output="$(run_check_067 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_password_hints_disable" "$normalized_output"

# system_settings_personalized_advertising_disable
run_check_068() {
  /bin/bash <<'__MSCP_RULE_068__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowApplePersonalizedAdvertising').js
EOS
__MSCP_RULE_068__
}
raw_output="$(run_check_068 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_personalized_advertising_disable" "$normalized_output"

# system_settings_printer_sharing_disable
run_check_069() {
  /bin/bash <<'__MSCP_RULE_069__'
/usr/sbin/cupsctl | /usr/bin/grep -c "_share_printers=0"
__MSCP_RULE_069__
}
raw_output="$(run_check_069 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_printer_sharing_disable" "$normalized_output"

# system_settings_rae_disable
run_check_070() {
  /bin/bash <<'__MSCP_RULE_070__'
/bin/launchctl print-disabled system | /usr/bin/grep -c '"com.apple.AEServer" => disabled'
__MSCP_RULE_070__
}
raw_output="$(run_check_070 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_rae_disable" "$normalized_output"

# system_settings_remote_management_disable
run_check_071() {
  /bin/bash <<'__MSCP_RULE_071__'
/usr/libexec/mdmclient QuerySecurityInfo 2>/dev/null | /usr/bin/grep -c "RemoteDesktopEnabled = 0"
__MSCP_RULE_071__
}
raw_output="$(run_check_071 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_remote_management_disable" "$normalized_output"

# system_settings_screensaver_ask_for_password_delay_enforce
run_check_072() {
  /bin/bash <<'__MSCP_RULE_072__'
/usr/bin/osascript -l JavaScript << EOS
function run() {
  let delay = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.screensaver')\
.objectForKey('askForPasswordDelay'))
  if ( delay <= 0 ) {
    return("true")
  } else {
    return("false")
  }
}
EOS
__MSCP_RULE_072__
}
raw_output="$(run_check_072 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_screensaver_ask_for_password_delay_enforce" "$normalized_output"

# system_settings_screensaver_password_enforce
run_check_073() {
  /bin/bash <<'__MSCP_RULE_073__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.screensaver')\
.objectForKey('askForPassword').js
EOS
__MSCP_RULE_073__
}
raw_output="$(run_check_073 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_screensaver_password_enforce" "$normalized_output"

# system_settings_screensaver_timeout_enforce
run_check_074() {
  /bin/bash <<'__MSCP_RULE_074__'
/usr/bin/osascript -l JavaScript << EOS
function run() {
  let timeout = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.screensaver')\
.objectForKey('idleTime'))
  if ( timeout <= 300 ) {
    return("true")
  } else {
    return("false")
  }
}
EOS
__MSCP_RULE_074__
}
raw_output="$(run_check_074 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_screensaver_timeout_enforce" "$normalized_output"

# system_settings_security_update_install
run_check_075() {
  /bin/bash <<'__MSCP_RULE_075__'
/usr/bin/plutil -convert json /var/db/softwareupdate/SoftwareUpdateDDMStatePersistence.plist -o - | /usr/bin/jq --raw-output .'SUCorePersistedStatePolicyFields.SUCoreDDMDeclarationGlobalSettings.automaticallyInstallSystemAndSecurityUpdates'
__MSCP_RULE_075__
}
raw_output="$(run_check_075 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_security_update_install" "$normalized_output"

# system_settings_smbd_disable
run_check_076() {
  /bin/bash <<'__MSCP_RULE_076__'
/bin/launchctl print-disabled system | /usr/bin/grep -c '"com.apple.smbd" => disabled'
__MSCP_RULE_076__
}
raw_output="$(run_check_076 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_smbd_disable" "$normalized_output"

# system_settings_ssh_disable
run_check_077() {
  /bin/bash <<'__MSCP_RULE_077__'
result="FAIL"
enabled=$(/bin/launchctl print-disabled system | /usr/bin/grep '"com.openssh.sshd" => enabled')
running=$(/bin/launchctl print system/com.openssh.sshd 2>/dev/null)

if [[ -z "$running" ]] && [[ -z "$enabled" ]]; then
  result="PASS"
elif [[ -n "$running" ]]; then
  result="${result}  RUNNING"
elif [[ -n "$enabled" ]]; then
  result="${result}  ENABLED"
fi
echo $result
__MSCP_RULE_077__
}
raw_output="$(run_check_077 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_ssh_disable" "$normalized_output"

# system_settings_system_wide_preferences_configure
run_check_078() {
  /bin/bash <<'__MSCP_RULE_078__'
authDBs=("system.preferences" "system.preferences.energysaver" "system.preferences.network" "system.preferences.printing" "system.preferences.sharing" "system.preferences.softwareupdate" "system.preferences.startupdisk" "system.preferences.timemachine")
result="1"
for section in ${authDBs[@]}; do
  if [[ $(/usr/bin/security -q authorizationdb read "$section" | /usr/bin/xmllint -xpath 'name(//*[contains(text(), "shared")]/following-sibling::*[1])' -) != "false" ]]; then
    result="0"
  fi
  if [[ $(/usr/bin/security -q authorizationdb read "$section" | /usr/bin/xmllint -xpath '//*[contains(text(), "group")]/following-sibling::*[1]/text()' - ) != "admin" ]]; then
    result="0"
  fi
  if [[ $(/usr/bin/security -q authorizationdb read "$section" | /usr/bin/xmllint -xpath 'name(//*[contains(text(), "authenticate-user")]/following-sibling::*[1])' -) != "true" ]]; then
    result="0"
  fi
  if [[ $(/usr/bin/security -q authorizationdb read "$section" | /usr/bin/xmllint -xpath 'name(//*[contains(text(), "session-owner")]/following-sibling::*[1])' -) != "false" ]]; then
    result="0"
  fi
done
echo $result
__MSCP_RULE_078__
}
raw_output="$(run_check_078 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_system_wide_preferences_configure" "$normalized_output"

# system_settings_time_machine_encrypted_configure
run_check_079() {
  /bin/bash <<'__MSCP_RULE_079__'
/usr/bin/sudo /usr/bin/defaults read /Library/Preferences/com.apple.TimeMachine.plist | grep -c NotEncrypted
__MSCP_RULE_079__
}
raw_output="$(run_check_079 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_time_machine_encrypted_configure" "$normalized_output"

# system_settings_time_server_configure
run_check_080() {
  /bin/bash <<'__MSCP_RULE_080__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.MCX')\
.objectForKey('timeServer').js
EOS
__MSCP_RULE_080__
}
raw_output="$(run_check_080 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_time_server_configure" "$normalized_output"

# system_settings_time_server_enforce
run_check_081() {
  /bin/bash <<'__MSCP_RULE_081__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.timed')\
.objectForKey('TMAutomaticTimeOnlyEnabled').js
EOS
__MSCP_RULE_081__
}
raw_output="$(run_check_081 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_time_server_enforce" "$normalized_output"

# os_secure_enclave
run_check_082() {
  /bin/bash <<'__MSCP_RULE_082__'
/usr/sbin/ioreg -w 0 -c AppleSEPManager | /usr/bin/grep -q 'AppleSEPManager'; /bin/echo $?
__MSCP_RULE_082__
}
raw_output="$(run_check_082 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_secure_enclave" "$normalized_output"

printf '}'
