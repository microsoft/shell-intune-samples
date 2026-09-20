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

# audit_configure_capacity_notify
run_check_004() {
  /bin/bash <<'__MSCP_RULE_004__'
/usr/bin/awk -F: '/^minfree/{print $2}' /etc/security/audit_control
__MSCP_RULE_004__
}
raw_output="$(run_check_004 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_configure_capacity_notify" "$normalized_output"

# audit_control_acls_configure
run_check_005() {
  /bin/bash <<'__MSCP_RULE_005__'
/bin/ls -le /etc/security/audit_control | /usr/bin/awk '{print $1}' | /usr/bin/grep -c ":"
__MSCP_RULE_005__
}
raw_output="$(run_check_005 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_control_acls_configure" "$normalized_output"

# audit_control_group_configure
run_check_006() {
  /bin/bash <<'__MSCP_RULE_006__'
/bin/ls -dn /etc/security/audit_control | /usr/bin/awk '{print $4}'
__MSCP_RULE_006__
}
raw_output="$(run_check_006 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_control_group_configure" "$normalized_output"

# audit_control_mode_configure
run_check_007() {
  /bin/bash <<'__MSCP_RULE_007__'
/bin/ls -l /etc/security/audit_control | /usr/bin/awk '!/-r--[r-]-----|current|total/{print $1}' | /usr/bin/wc -l | /usr/bin/xargs
__MSCP_RULE_007__
}
raw_output="$(run_check_007 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_control_mode_configure" "$normalized_output"

# audit_control_owner_configure
run_check_008() {
  /bin/bash <<'__MSCP_RULE_008__'
/bin/ls -dn /etc/security/audit_control | /usr/bin/awk '{print $3}'
__MSCP_RULE_008__
}
raw_output="$(run_check_008 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_control_owner_configure" "$normalized_output"

# audit_failure_halt
run_check_009() {
  /bin/bash <<'__MSCP_RULE_009__'
/usr/bin/awk -F':' '/^policy/ {print $NF}' /etc/security/audit_control | /usr/bin/tr ',' '\n' | /usr/bin/grep -Ec 'ahlt'
__MSCP_RULE_009__
}
raw_output="$(run_check_009 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_failure_halt" "$normalized_output"

# audit_files_group_configure
run_check_010() {
  /bin/bash <<'__MSCP_RULE_010__'
/bin/ls -n $(/usr/bin/grep '^dir' /etc/security/audit_control | /usr/bin/awk -F: '{print $2}') | /usr/bin/awk '{s+=$4} END {print s}'
__MSCP_RULE_010__
}
raw_output="$(run_check_010 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_files_group_configure" "$normalized_output"

# audit_files_mode_configure
run_check_011() {
  /bin/bash <<'__MSCP_RULE_011__'
/bin/ls -l $(/usr/bin/grep '^dir' /etc/security/audit_control | /usr/bin/awk -F: '{print $2}') | /usr/bin/awk '!/-r--r-----|current|total/{print $1}' | /usr/bin/wc -l | /usr/bin/tr -d ' '
__MSCP_RULE_011__
}
raw_output="$(run_check_011 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_files_mode_configure" "$normalized_output"

# audit_files_owner_configure
run_check_012() {
  /bin/bash <<'__MSCP_RULE_012__'
/bin/ls -n $(/usr/bin/grep '^dir' /etc/security/audit_control | /usr/bin/awk -F: '{print $2}') | /usr/bin/awk '{s+=$3} END {print s}'
__MSCP_RULE_012__
}
raw_output="$(run_check_012 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_files_owner_configure" "$normalized_output"

# audit_flags_aa_configure
run_check_013() {
  /bin/bash <<'__MSCP_RULE_013__'
/usr/bin/awk -F':' '/^flags/ { print $NF }' /etc/security/audit_control | /usr/bin/tr ',' '\n' | /usr/bin/grep -Ec 'aa'
__MSCP_RULE_013__
}
raw_output="$(run_check_013 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_flags_aa_configure" "$normalized_output"

# audit_flags_ad_configure
run_check_014() {
  /bin/bash <<'__MSCP_RULE_014__'
/usr/bin/awk -F':' '/^flags/ { print $NF }' /etc/security/audit_control | /usr/bin/tr ',' '\n' | /usr/bin/grep -Ec 'ad'
__MSCP_RULE_014__
}
raw_output="$(run_check_014 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_flags_ad_configure" "$normalized_output"

# audit_flags_ex_configure
run_check_015() {
  /bin/bash <<'__MSCP_RULE_015__'
/usr/bin/awk -F':' '/^flags/ { print $NF }' /etc/security/audit_control | /usr/bin/tr ',' '\n' | /usr/bin/grep -Ec '\-ex'
__MSCP_RULE_015__
}
raw_output="$(run_check_015 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_flags_ex_configure" "$normalized_output"

# audit_flags_fd_configure
run_check_016() {
  /bin/bash <<'__MSCP_RULE_016__'
/usr/bin/awk -F':' '/^flags/ { print $NF }' /etc/security/audit_control | /usr/bin/tr ',' '\n' | /usr/bin/grep -Ec '\-fd'
__MSCP_RULE_016__
}
raw_output="$(run_check_016 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_flags_fd_configure" "$normalized_output"

# audit_flags_fr_configure
run_check_017() {
  /bin/bash <<'__MSCP_RULE_017__'
/usr/bin/awk -F':' '/^flags/ { print $NF }' /etc/security/audit_control | /usr/bin/tr ',' '\n' | /usr/bin/grep -Ec '\-fr'
__MSCP_RULE_017__
}
raw_output="$(run_check_017 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_flags_fr_configure" "$normalized_output"

# audit_flags_fw_configure
run_check_018() {
  /bin/bash <<'__MSCP_RULE_018__'
/usr/bin/awk -F':' '/^flags/ { print $NF }' /etc/security/audit_control | /usr/bin/tr ',' '\n' | /usr/bin/grep -Ec '\-fw'
__MSCP_RULE_018__
}
raw_output="$(run_check_018 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_flags_fw_configure" "$normalized_output"

# audit_flags_lo_configure
run_check_019() {
  /bin/bash <<'__MSCP_RULE_019__'
/usr/bin/awk -F':' '/^flags/ { print $NF }' /etc/security/audit_control | /usr/bin/tr ',' '\n' | /usr/bin/grep -Ec '^lo'
__MSCP_RULE_019__
}
raw_output="$(run_check_019 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_flags_lo_configure" "$normalized_output"

# audit_folder_group_configure
run_check_020() {
  /bin/bash <<'__MSCP_RULE_020__'
/bin/ls -dn $(/usr/bin/grep '^dir' /etc/security/audit_control | /usr/bin/awk -F: '{print $2}') | /usr/bin/awk '{print $4}'
__MSCP_RULE_020__
}
raw_output="$(run_check_020 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_folder_group_configure" "$normalized_output"

# audit_folder_owner_configure
run_check_021() {
  /bin/bash <<'__MSCP_RULE_021__'
/bin/ls -dn $(/usr/bin/grep '^dir' /etc/security/audit_control | /usr/bin/awk -F: '{print $2}') | /usr/bin/awk '{print $3}'
__MSCP_RULE_021__
}
raw_output="$(run_check_021 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_folder_owner_configure" "$normalized_output"

# audit_folders_mode_configure
run_check_022() {
  /bin/bash <<'__MSCP_RULE_022__'
/usr/bin/stat -f %A $(/usr/bin/grep '^dir' /etc/security/audit_control | /usr/bin/awk -F: '{print $2}')
__MSCP_RULE_022__
}
raw_output="$(run_check_022 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_folders_mode_configure" "$normalized_output"

# audit_retention_configure
run_check_023() {
  /bin/bash <<'__MSCP_RULE_023__'
/usr/bin/awk -F: '/expire-after/{print $2}' /etc/security/audit_control
__MSCP_RULE_023__
}
raw_output="$(run_check_023 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "audit_retention_configure" "$normalized_output"

# audit_settings_failure_notify
run_check_024() {
  /bin/bash <<'__MSCP_RULE_024__'
/usr/bin/grep -c "logger -s -p" /etc/security/audit_warn
__MSCP_RULE_024__
}
raw_output="$(run_check_024 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "audit_settings_failure_notify" "$normalized_output"

# auth_pam_login_smartcard_enforce
run_check_025() {
  /bin/bash <<'__MSCP_RULE_025__'
/usr/bin/grep -Ec '^(auth\s+sufficient\s+pam_smartcard.so|auth\s+required\s+pam_deny.so)' /etc/pam.d/login
__MSCP_RULE_025__
}
raw_output="$(run_check_025 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "auth_pam_login_smartcard_enforce" "$normalized_output"

# auth_pam_su_smartcard_enforce
run_check_026() {
  /bin/bash <<'__MSCP_RULE_026__'
/usr/bin/grep -Ec '^(auth\s+sufficient\s+pam_smartcard.so|auth\s+required\s+pam_rootok.so)' /etc/pam.d/su
__MSCP_RULE_026__
}
raw_output="$(run_check_026 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "auth_pam_su_smartcard_enforce" "$normalized_output"

# auth_pam_sudo_smartcard_enforce
run_check_027() {
  /bin/bash <<'__MSCP_RULE_027__'
/usr/bin/grep -Ec '^(auth\s+sufficient\s+pam_smartcard.so|auth\s+required\s+pam_deny.so)' /etc/pam.d/sudo
__MSCP_RULE_027__
}
raw_output="$(run_check_027 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "auth_pam_sudo_smartcard_enforce" "$normalized_output"

# auth_smartcard_allow
run_check_028() {
  /bin/bash <<'__MSCP_RULE_028__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.security.smartcard')\
.objectForKey('allowSmartCard').js
EOS
__MSCP_RULE_028__
}
raw_output="$(run_check_028 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "auth_smartcard_allow" "$normalized_output"

# auth_smartcard_certificate_trust_enforce_high
run_check_029() {
  /bin/bash <<'__MSCP_RULE_029__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.security.smartcard')\
.objectForKey('checkCertificateTrust').js
EOS
__MSCP_RULE_029__
}
raw_output="$(run_check_029 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "auth_smartcard_certificate_trust_enforce_high" "$normalized_output"

# auth_smartcard_certificate_trust_enforce_moderate
run_check_030() {
  /bin/bash <<'__MSCP_RULE_030__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.security.smartcard')\
.objectForKey('checkCertificateTrust').js
EOS
__MSCP_RULE_030__
}
raw_output="$(run_check_030 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "auth_smartcard_certificate_trust_enforce_moderate" "$normalized_output"

# auth_smartcard_enforce
run_check_031() {
  /bin/bash <<'__MSCP_RULE_031__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.security.smartcard')\
.objectForKey('enforceSmartCard').js
EOS
__MSCP_RULE_031__
}
raw_output="$(run_check_031 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "auth_smartcard_enforce" "$normalized_output"

# auth_ssh_password_authentication_disable
run_check_032() {
  /bin/bash <<'__MSCP_RULE_032__'
/usr/sbin/sshd -G | /usr/bin/grep -Ec '^(passwordauthentication\s+no|kbdinteractiveauthentication\s+no)'
__MSCP_RULE_032__
}
raw_output="$(run_check_032 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "auth_ssh_password_authentication_disable" "$normalized_output"

# icloud_addressbook_disable
run_check_033() {
  /bin/bash <<'__MSCP_RULE_033__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowCloudAddressBook').js
EOS
__MSCP_RULE_033__
}
raw_output="$(run_check_033 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "icloud_addressbook_disable" "$normalized_output"

# icloud_appleid_system_settings_disable
run_check_034() {
  /bin/bash <<'__MSCP_RULE_034__'
/usr/bin/profiles show -output stdout-xml | /usr/bin/xmllint --xpath '//key[text()="DisabledSystemSettings"]/following-sibling::*[1]' - | /usr/bin/grep -c "com.apple.systempreferences.AppleIDSettings"
__MSCP_RULE_034__
}
raw_output="$(run_check_034 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "icloud_appleid_system_settings_disable" "$normalized_output"

# icloud_bookmarks_disable
run_check_035() {
  /bin/bash <<'__MSCP_RULE_035__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowCloudBookmarks').js
EOS
__MSCP_RULE_035__
}
raw_output="$(run_check_035 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "icloud_bookmarks_disable" "$normalized_output"

# icloud_calendar_disable
run_check_036() {
  /bin/bash <<'__MSCP_RULE_036__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowCloudCalendar').js
EOS
__MSCP_RULE_036__
}
raw_output="$(run_check_036 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "icloud_calendar_disable" "$normalized_output"

# icloud_drive_disable
run_check_037() {
  /bin/bash <<'__MSCP_RULE_037__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowCloudDocumentSync').js
EOS
__MSCP_RULE_037__
}
raw_output="$(run_check_037 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "icloud_drive_disable" "$normalized_output"

# icloud_freeform_disable
run_check_038() {
  /bin/bash <<'__MSCP_RULE_038__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowCloudFreeform').js
EOS
__MSCP_RULE_038__
}
raw_output="$(run_check_038 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "icloud_freeform_disable" "$normalized_output"

# icloud_game_center_disable
run_check_039() {
  /bin/bash <<'__MSCP_RULE_039__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowGameCenter').js
EOS
__MSCP_RULE_039__
}
raw_output="$(run_check_039 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "icloud_game_center_disable" "$normalized_output"

# icloud_keychain_disable
run_check_040() {
  /bin/bash <<'__MSCP_RULE_040__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowCloudKeychainSync').js
EOS
__MSCP_RULE_040__
}
raw_output="$(run_check_040 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "icloud_keychain_disable" "$normalized_output"

# icloud_mail_disable
run_check_041() {
  /bin/bash <<'__MSCP_RULE_041__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowCloudMail').js
EOS
__MSCP_RULE_041__
}
raw_output="$(run_check_041 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "icloud_mail_disable" "$normalized_output"

# icloud_notes_disable
run_check_042() {
  /bin/bash <<'__MSCP_RULE_042__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowCloudNotes').js
EOS
__MSCP_RULE_042__
}
raw_output="$(run_check_042 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "icloud_notes_disable" "$normalized_output"

# icloud_photos_disable
run_check_043() {
  /bin/bash <<'__MSCP_RULE_043__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowCloudPhotoLibrary').js
EOS
__MSCP_RULE_043__
}
raw_output="$(run_check_043 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "icloud_photos_disable" "$normalized_output"

# icloud_private_relay_disable
run_check_044() {
  /bin/bash <<'__MSCP_RULE_044__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowCloudPrivateRelay').js
EOS
__MSCP_RULE_044__
}
raw_output="$(run_check_044 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "icloud_private_relay_disable" "$normalized_output"

# icloud_reminders_disable
run_check_045() {
  /bin/bash <<'__MSCP_RULE_045__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowCloudReminders').js
EOS
__MSCP_RULE_045__
}
raw_output="$(run_check_045 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "icloud_reminders_disable" "$normalized_output"

# icloud_sync_disable
run_check_046() {
  /bin/bash <<'__MSCP_RULE_046__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowCloudDesktopAndDocuments').js
EOS
__MSCP_RULE_046__
}
raw_output="$(run_check_046 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "icloud_sync_disable" "$normalized_output"

# os_account_modification_disable
run_check_047() {
  /bin/bash <<'__MSCP_RULE_047__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowAccountModification').js
EOS
__MSCP_RULE_047__
}
raw_output="$(run_check_047 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_account_modification_disable" "$normalized_output"

# os_airdrop_disable
run_check_048() {
  /bin/bash <<'__MSCP_RULE_048__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowAirDrop').js
EOS
__MSCP_RULE_048__
}
raw_output="$(run_check_048 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_airdrop_disable" "$normalized_output"

# os_appleid_prompt_disable
run_check_049() {
  /bin/bash <<'__MSCP_RULE_049__'
/usr/bin/osascript -l JavaScript 2>/dev/null << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.SetupAssistant.managed')\
.objectForKey('SkipSetupItems').containsObject("AppleID")
EOS
__MSCP_RULE_049__
}
raw_output="$(run_check_049 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_appleid_prompt_disable" "$normalized_output"

# os_asl_log_files_owner_group_configure
run_check_050() {
  /bin/bash <<'__MSCP_RULE_050__'
/usr/bin/stat -f '%Su:%Sg:%N' $(/usr/bin/grep -e '^>' /etc/asl.conf /etc/asl/* | /usr/bin/awk '{ print $2 }') 2> /dev/null | /usr/bin/awk '!/^root:wheel:/{print $1}' | /usr/bin/wc -l | /usr/bin/tr -d ' '
__MSCP_RULE_050__
}
raw_output="$(run_check_050 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_asl_log_files_owner_group_configure" "$normalized_output"

# os_asl_log_files_permissions_configure
run_check_051() {
  /bin/bash <<'__MSCP_RULE_051__'
/usr/bin/stat -f '%A:%N' $(/usr/bin/grep -e '^>' /etc/asl.conf /etc/asl/* | /usr/bin/awk '{ print $2 }') 2> /dev/null | /usr/bin/awk '!/640/{print $1}' | /usr/bin/wc -l | /usr/bin/tr -d ' '
__MSCP_RULE_051__
}
raw_output="$(run_check_051 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_asl_log_files_permissions_configure" "$normalized_output"

# os_authenticated_root_enable
run_check_052() {
  /bin/bash <<'__MSCP_RULE_052__'
/sbin/mount | /usr/bin/grep ' / ' | /usr/bin/grep -o 'sealed'
__MSCP_RULE_052__
}
raw_output="$(run_check_052 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_authenticated_root_enable" "$normalized_output"

# os_blank_bluray_disable
run_check_053() {
  /bin/bash <<'__MSCP_RULE_053__'
/usr/bin/osascript -l JavaScript << EOS
ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.systemuiserver')\
.objectForKey('mount-controls'))["blankbd"]
EOS
__MSCP_RULE_053__
}
raw_output="$(run_check_053 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_blank_bluray_disable" "$normalized_output"

# os_blank_cd_disable
run_check_054() {
  /bin/bash <<'__MSCP_RULE_054__'
/usr/bin/osascript -l JavaScript << EOS
ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.systemuiserver')\
.objectForKey('mount-controls'))["blankcd"]
EOS
__MSCP_RULE_054__
}
raw_output="$(run_check_054 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_blank_cd_disable" "$normalized_output"

# os_blank_dvd_disable
run_check_055() {
  /bin/bash <<'__MSCP_RULE_055__'
/usr/bin/osascript -l JavaScript << EOS
ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.systemuiserver')\
.objectForKey('mount-controls'))["blankdvd"]
EOS
__MSCP_RULE_055__
}
raw_output="$(run_check_055 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_blank_dvd_disable" "$normalized_output"

# os_bluray_read_only_enforce
run_check_056() {
  /bin/bash <<'__MSCP_RULE_056__'
/usr/bin/osascript -l JavaScript << EOS
ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.systemuiserver')\
.objectForKey('mount-controls'))["bd"]
EOS
__MSCP_RULE_056__
}
raw_output="$(run_check_056 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_bluray_read_only_enforce" "$normalized_output"

# os_bonjour_disable
run_check_057() {
  /bin/bash <<'__MSCP_RULE_057__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.mDNSResponder')\
.objectForKey('NoMulticastAdvertisements').js
EOS
__MSCP_RULE_057__
}
raw_output="$(run_check_057 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_bonjour_disable" "$normalized_output"

# os_burn_support_disable
run_check_058() {
  /bin/bash <<'__MSCP_RULE_058__'
/usr/bin/profiles -P -o stdout | /usr/bin/grep -Ec '(BurnSupport = off;|ProhibitBurn = 1;)'
__MSCP_RULE_058__
}
raw_output="$(run_check_058 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_burn_support_disable" "$normalized_output"

# os_calendar_app_disable
run_check_059() {
  /bin/bash <<'__MSCP_RULE_059__'
/usr/bin/osascript -l JavaScript << EOS
function run() {
  let pref1 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess.new')\
  .objectForKey('familyControlsEnabled'))
  let pathlist = $.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess.new')\
  .objectForKey('pathBlackList').js
  for ( let app in pathlist ) {
      if ( ObjC.unwrap(pathlist[app]) == "/Applications/Calendar.app" && pref1 == true ){
          return("true")
      }
  }
  return("false")
  }
EOS
__MSCP_RULE_059__
}
raw_output="$(run_check_059 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_calendar_app_disable" "$normalized_output"

# os_cd_read_only_enforce
run_check_060() {
  /bin/bash <<'__MSCP_RULE_060__'
/usr/bin/osascript -l JavaScript << EOS
ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.systemuiserver')\
.objectForKey('mount-controls'))["cd"]
EOS
__MSCP_RULE_060__
}
raw_output="$(run_check_060 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_cd_read_only_enforce" "$normalized_output"

# os_certificate_authority_trust
run_check_061() {
  /bin/bash <<'__MSCP_RULE_061__'
/usr/bin/security dump-keychain /Library/Keychains/System.keychain | /usr/bin/awk -F'"' '/labl/ {print $4}'
__MSCP_RULE_061__
}
raw_output="$(run_check_061 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_certificate_authority_trust" "$normalized_output"

# os_config_data_install_enforce
run_check_062() {
  /bin/bash <<'__MSCP_RULE_062__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.SoftwareUpdate')\
.objectForKey('ConfigDataInstall').js
EOS
__MSCP_RULE_062__
}
raw_output="$(run_check_062 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_config_data_install_enforce" "$normalized_output"

# os_config_profile_ui_install_disable
run_check_063() {
  /bin/bash <<'__MSCP_RULE_063__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowUIConfigurationProfileInstallation').js
EOS
__MSCP_RULE_063__
}
raw_output="$(run_check_063 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_config_profile_ui_install_disable" "$normalized_output"

# os_dictation_disable
run_check_064() {
  /bin/bash <<'__MSCP_RULE_064__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowDictation').js
EOS
__MSCP_RULE_064__
}
raw_output="$(run_check_064 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_dictation_disable" "$normalized_output"

# os_disk_image_disable
run_check_065() {
  /bin/bash <<'__MSCP_RULE_065__'
/usr/bin/osascript -l JavaScript << EOS
ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.systemuiserver')\
.objectForKey('mount-controls'))["disk-image"]
EOS
__MSCP_RULE_065__
}
raw_output="$(run_check_065 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_disk_image_disable" "$normalized_output"

# os_dvdram_disable
run_check_066() {
  /bin/bash <<'__MSCP_RULE_066__'
/usr/bin/osascript -l JavaScript << EOS
ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.systemuiserver')\
.objectForKey('mount-controls'))["dvdram"]
EOS
__MSCP_RULE_066__
}
raw_output="$(run_check_066 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_dvdram_disable" "$normalized_output"

# os_erase_content_and_settings_disable
run_check_067() {
  /bin/bash <<'__MSCP_RULE_067__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowEraseContentAndSettings').js
EOS
__MSCP_RULE_067__
}
raw_output="$(run_check_067 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_erase_content_and_settings_disable" "$normalized_output"

# os_external_storage_access_defined
run_check_068() {
  /bin/bash <<'__MSCP_RULE_068__'
/usr/bin/plutil -convert json /var/db/ManagedConfigurationFiles/DiskManagement/DiskManagement_Settings.plist -o - | /usr/bin/jq --raw-output '.Restrictions.ExternalStorage'
__MSCP_RULE_068__
}
raw_output="$(run_check_068 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_external_storage_access_defined" "$normalized_output"

# os_facetime_app_disable
run_check_069() {
  /bin/bash <<'__MSCP_RULE_069__'
/usr/bin/osascript -l JavaScript << EOS
function run() {
  let pref1 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess.new')\
  .objectForKey('familyControlsEnabled'))
  let pathlist = $.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess.new')\
  .objectForKey('pathBlackList').js
  for ( let app in pathlist ) {
      if ( ObjC.unwrap(pathlist[app]) == "/Applications/FaceTime.app" && pref1 == true ){
          return("true")
      }
  }
  return("false")
  }
EOS
__MSCP_RULE_069__
}
raw_output="$(run_check_069 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_facetime_app_disable" "$normalized_output"

# os_filevault_authorized_users
run_check_070() {
  /bin/bash <<'__MSCP_RULE_070__'
/usr/bin/fdesetup list | /usr/bin/awk -F',' '{print $1}'
__MSCP_RULE_070__
}
raw_output="$(run_check_070 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_filevault_authorized_users" "$normalized_output"

# os_filevault_autologin_disable
run_check_071() {
  /bin/bash <<'__MSCP_RULE_071__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.loginwindow')\
.objectForKey('DisableFDEAutoLogin').js
EOS
__MSCP_RULE_071__
}
raw_output="$(run_check_071 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_filevault_autologin_disable" "$normalized_output"

# os_firewall_default_deny_require
run_check_072() {
  /bin/bash <<'__MSCP_RULE_072__'
/sbin/pfctl -a '*' -sr 2> /dev/null | /usr/bin/grep -c "block drop in all"
__MSCP_RULE_072__
}
raw_output="$(run_check_072 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_firewall_default_deny_require" "$normalized_output"

# os_gatekeeper_enable
run_check_073() {
  /bin/bash <<'__MSCP_RULE_073__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.systempolicy.control')\
.objectForKey('EnableAssessment').js
EOS
__MSCP_RULE_073__
}
raw_output="$(run_check_073 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_gatekeeper_enable" "$normalized_output"

# os_genmoji_disable
run_check_074() {
  /bin/bash <<'__MSCP_RULE_074__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowGenmoji').js
EOS
__MSCP_RULE_074__
}
raw_output="$(run_check_074 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_genmoji_disable" "$normalized_output"

# os_handoff_disable
run_check_075() {
  /bin/bash <<'__MSCP_RULE_075__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowActivityContinuation').js
EOS
__MSCP_RULE_075__
}
raw_output="$(run_check_075 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_handoff_disable" "$normalized_output"

# os_home_folders_secure
run_check_076() {
  /bin/bash <<'__MSCP_RULE_076__'
/usr/bin/find /System/Volumes/Data/Users -mindepth 1 -maxdepth 1 -type d ! \( -perm 700 -o -perm 711 \) | /usr/bin/grep -v "Shared" | /usr/bin/grep -v "Guest" | /usr/bin/wc -l | /usr/bin/xargs
__MSCP_RULE_076__
}
raw_output="$(run_check_076 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_home_folders_secure" "$normalized_output"

# os_httpd_disable
run_check_077() {
  /bin/bash <<'__MSCP_RULE_077__'
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
__MSCP_RULE_077__
}
raw_output="$(run_check_077 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_httpd_disable" "$normalized_output"

# os_icloud_storage_prompt_disable
run_check_078() {
  /bin/bash <<'__MSCP_RULE_078__'
/usr/bin/osascript -l JavaScript 2>/dev/null << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.SetupAssistant.managed')\
.objectForKey('SkipSetupItems').containsObject("iCloudStorage")
EOS
__MSCP_RULE_078__
}
raw_output="$(run_check_078 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_icloud_storage_prompt_disable" "$normalized_output"

# os_image_playground_disable
run_check_079() {
  /bin/bash <<'__MSCP_RULE_079__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowImagePlayground').js
EOS
__MSCP_RULE_079__
}
raw_output="$(run_check_079 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_image_playground_disable" "$normalized_output"

# os_install_log_retention_configure
run_check_080() {
  /bin/bash <<'__MSCP_RULE_080__'
/usr/sbin/aslmanager -dd 2>&1 | /usr/bin/awk '/\/var\/log\/install.log$/ {count++} /Processing module com.apple.install/,/Finished/ { for (i=1;i<=NR;i++) { if ($i == "TTL" && $(i+2) >= 365) { ttl="True" }; if ($i == "MAX") {max="True"}}} END{if (count > 1) { print "Multiple config files for /var/log/install, manually remove the extra files"} else if (max == "True") { print "all_max setting is configured, must be removed" } if (ttl != "True") { print "TTL not configured" } else { print "Yes" }}'
__MSCP_RULE_080__
}
raw_output="$(run_check_080 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_install_log_retention_configure" "$normalized_output"

# os_iphone_mirroring_disable
run_check_081() {
  /bin/bash <<'__MSCP_RULE_081__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowiPhoneMirroring').js
EOS
__MSCP_RULE_081__
}
raw_output="$(run_check_081 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_iphone_mirroring_disable" "$normalized_output"

# os_ir_support_disable
run_check_082() {
  /bin/bash <<'__MSCP_RULE_082__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.driver.AppleIRController')\
.objectForKey('DeviceEnabled').js
EOS
__MSCP_RULE_082__
}
raw_output="$(run_check_082 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_ir_support_disable" "$normalized_output"

# os_loginwindow_adminhostinfo_disabled
run_check_083() {
  /bin/bash <<'__MSCP_RULE_083__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.loginwindow')\
.integerForKey('AdminHostInfo')
EOS
__MSCP_RULE_083__
}
raw_output="$(run_check_083 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_loginwindow_adminhostinfo_disabled" "$normalized_output"

# os_mail_app_disable
run_check_084() {
  /bin/bash <<'__MSCP_RULE_084__'
/usr/bin/osascript -l JavaScript << EOS
function run() {
  let pref1 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess.new')\
  .objectForKey('familyControlsEnabled'))
  let pathlist = $.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess.new')\
  .objectForKey('pathBlackList').js
  for ( let app in pathlist ) {
      if ( ObjC.unwrap(pathlist[app]) == "/Applications/Mail.app" && pref1 == true ){
          return("true")
      }
  }
  return("false")
  }
EOS
__MSCP_RULE_084__
}
raw_output="$(run_check_084 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_mail_app_disable" "$normalized_output"

# os_mail_smart_reply_disable
run_check_085() {
  /bin/bash <<'__MSCP_RULE_085__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowMailSmartReplies').js
EOS
__MSCP_RULE_085__
}
raw_output="$(run_check_085 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_mail_smart_reply_disable" "$normalized_output"

# os_mail_summary_disable
run_check_086() {
  /bin/bash <<'__MSCP_RULE_086__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowMailSummary').js
EOS
__MSCP_RULE_086__
}
raw_output="$(run_check_086 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_mail_summary_disable" "$normalized_output"

# os_mdm_require
run_check_087() {
  /bin/bash <<'__MSCP_RULE_087__'
/usr/bin/profiles status -type enrollment | /usr/bin/awk -F: '/MDM enrollment/ {print $2}' | /usr/bin/grep -c "Yes (User Approved)"
__MSCP_RULE_087__
}
raw_output="$(run_check_087 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_mdm_require" "$normalized_output"

# os_messages_app_disable
run_check_088() {
  /bin/bash <<'__MSCP_RULE_088__'
/usr/bin/osascript -l JavaScript << EOS
function run() {
  let pref1 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess.new')\
  .objectForKey('familyControlsEnabled'))
  let pathlist = $.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess.new')\
  .objectForKey('pathBlackList').js
  for ( let app in pathlist ) {
      if ( ObjC.unwrap(pathlist[app]) == "/Applications/Messages.app" && pref1 == true ){
          return("true")
      }
  }
  return("false")
  }
EOS
__MSCP_RULE_088__
}
raw_output="$(run_check_088 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_messages_app_disable" "$normalized_output"

# os_newsyslog_files_owner_group_configure
run_check_089() {
  /bin/bash <<'__MSCP_RULE_089__'
/usr/bin/stat -f '%Su:%Sg:%N' $(/usr/bin/grep -v '^#' /etc/newsyslog.conf | /usr/bin/awk '{ print $1 }') 2> /dev/null | /usr/bin/awk '!/^root:wheel:/{print $1}' | /usr/bin/wc -l | /usr/bin/tr -d ' '
__MSCP_RULE_089__
}
raw_output="$(run_check_089 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_newsyslog_files_owner_group_configure" "$normalized_output"

# os_newsyslog_files_permissions_configure
run_check_090() {
  /bin/bash <<'__MSCP_RULE_090__'
/usr/bin/stat -f '%A:%N' $(/usr/bin/grep -v '^#' /etc/newsyslog.conf | /usr/bin/awk '{ print $1 }') 2> /dev/null | /usr/bin/awk '!/640/{print $1}' | /usr/bin/wc -l | /usr/bin/tr -d ' '
__MSCP_RULE_090__
}
raw_output="$(run_check_090 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_newsyslog_files_permissions_configure" "$normalized_output"

printf '}'
