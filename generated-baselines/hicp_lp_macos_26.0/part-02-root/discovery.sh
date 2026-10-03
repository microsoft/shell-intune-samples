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

# system_settings_bluetooth_disable
run_check_001() {
  /bin/bash <<'__MSCP_RULE_001__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.MCXBluetooth')\
.objectForKey('DisableBluetooth').js
EOS
__MSCP_RULE_001__
}
raw_output="$(run_check_001 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_bluetooth_disable" "$normalized_output"

# system_settings_bluetooth_settings_disable
run_check_002() {
  /bin/bash <<'__MSCP_RULE_002__'
/usr/bin/profiles show -output stdout-xml | /usr/bin/xmllint --xpath '//key[text()="DisabledSystemSettings"]/following-sibling::*[1]' - | /usr/bin/grep -c com.apple.BluetoothSettings
__MSCP_RULE_002__
}
raw_output="$(run_check_002 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_bluetooth_settings_disable" "$normalized_output"

# system_settings_content_caching_disable
run_check_003() {
  /bin/bash <<'__MSCP_RULE_003__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowContentCaching').js
EOS
__MSCP_RULE_003__
}
raw_output="$(run_check_003 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_content_caching_disable" "$normalized_output"

# system_settings_critical_update_install_enforce
run_check_004() {
  /bin/bash <<'__MSCP_RULE_004__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.SoftwareUpdate')\
.objectForKey('CriticalUpdateInstall').js
EOS
__MSCP_RULE_004__
}
raw_output="$(run_check_004 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_critical_update_install_enforce" "$normalized_output"

# system_settings_diagnostics_reports_disable
run_check_005() {
  /bin/bash <<'__MSCP_RULE_005__'
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
__MSCP_RULE_005__
}
raw_output="$(run_check_005 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_diagnostics_reports_disable" "$normalized_output"

# system_settings_external_intelligence_disable
run_check_006() {
  /bin/bash <<'__MSCP_RULE_006__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowExternalIntelligenceIntegrations').js
EOS
__MSCP_RULE_006__
}
raw_output="$(run_check_006 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_external_intelligence_disable" "$normalized_output"

# system_settings_external_intelligence_sign_in_disable
run_check_007() {
  /bin/bash <<'__MSCP_RULE_007__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowExternalIntelligenceIntegrationsSignIn').js
EOS
__MSCP_RULE_007__
}
raw_output="$(run_check_007 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_external_intelligence_sign_in_disable" "$normalized_output"

# system_settings_filevault_enforce
run_check_008() {
  /bin/bash <<'__MSCP_RULE_008__'
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
__MSCP_RULE_008__
}
raw_output="$(run_check_008 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_filevault_enforce" "$normalized_output"

# system_settings_find_my_disable
run_check_009() {
  /bin/bash <<'__MSCP_RULE_009__'
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
__MSCP_RULE_009__
}
raw_output="$(run_check_009 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_find_my_disable" "$normalized_output"

# system_settings_firewall_enable
run_check_010() {
  /bin/bash <<'__MSCP_RULE_010__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.security.firewall')\
.objectForKey('EnableFirewall').js
EOS
__MSCP_RULE_010__
}
raw_output="$(run_check_010 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_firewall_enable" "$normalized_output"

# system_settings_firewall_stealth_mode_enable
run_check_011() {
  /bin/bash <<'__MSCP_RULE_011__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.security.firewall')\
.objectForKey('EnableStealthMode').js
EOS
__MSCP_RULE_011__
}
raw_output="$(run_check_011 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_firewall_stealth_mode_enable" "$normalized_output"

# system_settings_guest_account_disable
run_check_012() {
  /bin/bash <<'__MSCP_RULE_012__'
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
__MSCP_RULE_012__
}
raw_output="$(run_check_012 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_guest_account_disable" "$normalized_output"

# system_settings_improve_assistive_voice_disable
run_check_013() {
  /bin/bash <<'__MSCP_RULE_013__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.Accessibility')\
.objectForKey('AXSAudioDonationSiriImprovementEnabled').js
EOS
__MSCP_RULE_013__
}
raw_output="$(run_check_013 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_improve_assistive_voice_disable" "$normalized_output"

# system_settings_improve_search_disable
run_check_014() {
  /bin/bash <<'__MSCP_RULE_014__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.assistant.support')\
.objectForKey('Search Queries Data Sharing Status').js
EOS
__MSCP_RULE_014__
}
raw_output="$(run_check_014 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_improve_search_disable" "$normalized_output"

# system_settings_improve_siri_dictation_disable
run_check_015() {
  /bin/bash <<'__MSCP_RULE_015__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.assistant.support')\
.objectForKey('Siri Data Sharing Opt-In Status').js
EOS
__MSCP_RULE_015__
}
raw_output="$(run_check_015 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_improve_siri_dictation_disable" "$normalized_output"

# system_settings_internet_accounts_disable
run_check_016() {
  /bin/bash <<'__MSCP_RULE_016__'
/usr/bin/profiles show -output stdout-xml | /usr/bin/xmllint --xpath '//key[text()="DisabledSystemSettings"]/following-sibling::*[1]' - | /usr/bin/grep -c com.apple.Internet-Accounts-Settings.extension
__MSCP_RULE_016__
}
raw_output="$(run_check_016 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_internet_accounts_disable" "$normalized_output"

# system_settings_internet_sharing_disable
run_check_017() {
  /bin/bash <<'__MSCP_RULE_017__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.MCX')\
.objectForKey('forceInternetSharingOff').js
EOS
__MSCP_RULE_017__
}
raw_output="$(run_check_017 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_internet_sharing_disable" "$normalized_output"

# system_settings_media_sharing_disabled
run_check_018() {
  /bin/bash <<'__MSCP_RULE_018__'
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
__MSCP_RULE_018__
}
raw_output="$(run_check_018 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_media_sharing_disabled" "$normalized_output"

# system_settings_personalized_advertising_disable
run_check_019() {
  /bin/bash <<'__MSCP_RULE_019__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowApplePersonalizedAdvertising').js
EOS
__MSCP_RULE_019__
}
raw_output="$(run_check_019 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_personalized_advertising_disable" "$normalized_output"

# system_settings_printer_sharing_disable
run_check_020() {
  /bin/bash <<'__MSCP_RULE_020__'
/usr/sbin/cupsctl | /usr/bin/grep -c "_share_printers=0"
__MSCP_RULE_020__
}
raw_output="$(run_check_020 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_printer_sharing_disable" "$normalized_output"

# system_settings_rae_disable
run_check_021() {
  /bin/bash <<'__MSCP_RULE_021__'
/bin/launchctl print-disabled system | /usr/bin/grep -c '"com.apple.AEServer" => disabled'
__MSCP_RULE_021__
}
raw_output="$(run_check_021 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_rae_disable" "$normalized_output"

# system_settings_remote_management_disable
run_check_022() {
  /bin/bash <<'__MSCP_RULE_022__'
/usr/libexec/mdmclient QuerySecurityInfo 2>/dev/null | /usr/bin/grep -c "RemoteDesktopEnabled = 0"
__MSCP_RULE_022__
}
raw_output="$(run_check_022 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_remote_management_disable" "$normalized_output"

# system_settings_security_update_install
run_check_023() {
  /bin/bash <<'__MSCP_RULE_023__'
/usr/bin/plutil -convert json /var/db/softwareupdate/SoftwareUpdateDDMStatePersistence.plist -o - | /usr/bin/jq --raw-output .'SUCorePersistedStatePolicyFields.SUCoreDDMDeclarationGlobalSettings.automaticallyInstallSystemAndSecurityUpdates'
__MSCP_RULE_023__
}
raw_output="$(run_check_023 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_security_update_install" "$normalized_output"

# system_settings_siri_disable
run_check_024() {
  /bin/bash <<'__MSCP_RULE_024__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowAssistant').js
EOS
__MSCP_RULE_024__
}
raw_output="$(run_check_024 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_siri_disable" "$normalized_output"

# system_settings_siri_settings_disable
run_check_025() {
  /bin/bash <<'__MSCP_RULE_025__'
/usr/bin/profiles show -output stdout-xml | /usr/bin/xmllint --xpath '//key[text()="DisabledSystemSettings"]/following-sibling::*[1]' - | /usr/bin/grep -c com.apple.Siri-Settings.extension
__MSCP_RULE_025__
}
raw_output="$(run_check_025 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_siri_settings_disable" "$normalized_output"

# system_settings_smbd_disable
run_check_026() {
  /bin/bash <<'__MSCP_RULE_026__'
/bin/launchctl print-disabled system | /usr/bin/grep -c '"com.apple.smbd" => disabled'
__MSCP_RULE_026__
}
raw_output="$(run_check_026 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_smbd_disable" "$normalized_output"

# system_settings_ssh_disable
run_check_027() {
  /bin/bash <<'__MSCP_RULE_027__'
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
__MSCP_RULE_027__
}
raw_output="$(run_check_027 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_ssh_disable" "$normalized_output"

# system_settings_ssh_enable
run_check_028() {
  /bin/bash <<'__MSCP_RULE_028__'
/bin/launchctl print-disabled system | /usr/bin/grep -c '"com.openssh.sshd" => enabled'
__MSCP_RULE_028__
}
raw_output="$(run_check_028 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_ssh_enable" "$normalized_output"

# system_settings_system_wide_preferences_configure
run_check_029() {
  /bin/bash <<'__MSCP_RULE_029__'
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
__MSCP_RULE_029__
}
raw_output="$(run_check_029 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_system_wide_preferences_configure" "$normalized_output"

# system_settings_touch_id_settings_disable
run_check_030() {
  /bin/bash <<'__MSCP_RULE_030__'
/usr/bin/profiles show -output stdout-xml | /usr/bin/xmllint --xpath '//key[text()="DisabledSystemSettings"]/following-sibling::*[1]' - | /usr/bin/grep -c "com.apple.Touch-ID-Settings.extension"
__MSCP_RULE_030__
}
raw_output="$(run_check_030 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_touch_id_settings_disable" "$normalized_output"

# system_settings_wallet_applepay_settings_disable
run_check_031() {
  /bin/bash <<'__MSCP_RULE_031__'
/usr/bin/profiles show -output stdout-xml | /usr/bin/xmllint --xpath '//key[text()="DisabledSystemSettings"]/following-sibling::*[1]' - | /usr/bin/grep -c "com.apple.WalletSettingsExtension"
__MSCP_RULE_031__
}
raw_output="$(run_check_031 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_wallet_applepay_settings_disable" "$normalized_output"

# system_settings_wifi_disable
run_check_032() {
  /bin/bash <<'__MSCP_RULE_032__'
/usr/sbin/networksetup -listallnetworkservices | /usr/bin/grep -c "*Wi-Fi"
__MSCP_RULE_032__
}
raw_output="$(run_check_032 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_wifi_disable" "$normalized_output"

# os_secure_enclave
run_check_033() {
  /bin/bash <<'__MSCP_RULE_033__'
/usr/sbin/ioreg -w 0 -c AppleSEPManager | /usr/bin/grep -q 'AppleSEPManager'; /bin/echo $?
__MSCP_RULE_033__
}
raw_output="$(run_check_033 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_secure_enclave" "$normalized_output"

printf '}'
