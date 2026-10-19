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

# system_settings_screensaver_ask_for_password_delay_enforce
run_check_001() {
  /bin/bash <<'__MSCP_RULE_001__'
/usr/bin/osascript -l JavaScript << EOS
function run() {
  let delay = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.screensaver')\
.objectForKey('askForPasswordDelay'))
  if ( delay <= 5 ) {
    return("true")
  } else {
    return("false")
  }
}
EOS
__MSCP_RULE_001__
}
raw_output="$(run_check_001 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_screensaver_ask_for_password_delay_enforce" "$normalized_output"

# system_settings_screensaver_password_enforce
run_check_002() {
  /bin/bash <<'__MSCP_RULE_002__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.screensaver')\
.objectForKey('askForPassword').js
EOS
__MSCP_RULE_002__
}
raw_output="$(run_check_002 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_screensaver_password_enforce" "$normalized_output"

# system_settings_screensaver_timeout_enforce
run_check_003() {
  /bin/bash <<'__MSCP_RULE_003__'
/usr/bin/osascript -l JavaScript << EOS
function run() {
  let timeout = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.screensaver')\
.objectForKey('idleTime'))
  if ( timeout <= 1200 ) {
    return("true")
  } else {
    return("false")
  }
}
EOS
__MSCP_RULE_003__
}
raw_output="$(run_check_003 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_screensaver_timeout_enforce" "$normalized_output"

# system_settings_security_update_install
run_check_004() {
  /bin/bash <<'__MSCP_RULE_004__'
/usr/bin/plutil -convert json /var/db/softwareupdate/SoftwareUpdateDDMStatePersistence.plist -o - | /usr/bin/jq --raw-output .'SUCorePersistedStatePolicyFields.SUCoreDDMDeclarationGlobalSettings.automaticallyInstallSystemAndSecurityUpdates'
__MSCP_RULE_004__
}
raw_output="$(run_check_004 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_security_update_install" "$normalized_output"

# system_settings_siri_disable
run_check_005() {
  /bin/bash <<'__MSCP_RULE_005__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowAssistant').js
EOS
__MSCP_RULE_005__
}
raw_output="$(run_check_005 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_siri_disable" "$normalized_output"

# system_settings_siri_settings_disable
run_check_006() {
  /bin/bash <<'__MSCP_RULE_006__'
/usr/bin/profiles show -output stdout-xml | /usr/bin/xmllint --xpath '//key[text()="DisabledSystemSettings"]/following-sibling::*[1]' - | /usr/bin/grep -c com.apple.Siri-Settings.extension
__MSCP_RULE_006__
}
raw_output="$(run_check_006 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_siri_settings_disable" "$normalized_output"

# system_settings_smbd_disable
run_check_007() {
  /bin/bash <<'__MSCP_RULE_007__'
/bin/launchctl print-disabled system | /usr/bin/grep -c '"com.apple.smbd" => disabled'
__MSCP_RULE_007__
}
raw_output="$(run_check_007 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_smbd_disable" "$normalized_output"

# system_settings_ssh_disable
run_check_008() {
  /bin/bash <<'__MSCP_RULE_008__'
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
__MSCP_RULE_008__
}
raw_output="$(run_check_008 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_ssh_disable" "$normalized_output"

# system_settings_ssh_enable
run_check_009() {
  /bin/bash <<'__MSCP_RULE_009__'
/bin/launchctl print-disabled system | /usr/bin/grep -c '"com.openssh.sshd" => enabled'
__MSCP_RULE_009__
}
raw_output="$(run_check_009 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_ssh_enable" "$normalized_output"

# system_settings_system_wide_preferences_configure
run_check_010() {
  /bin/bash <<'__MSCP_RULE_010__'
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
__MSCP_RULE_010__
}
raw_output="$(run_check_010 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_system_wide_preferences_configure" "$normalized_output"

# system_settings_time_server_configure
run_check_011() {
  /bin/bash <<'__MSCP_RULE_011__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.MCX')\
.objectForKey('timeServer').js
EOS
__MSCP_RULE_011__
}
raw_output="$(run_check_011 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_time_server_configure" "$normalized_output"

# system_settings_time_server_enforce
run_check_012() {
  /bin/bash <<'__MSCP_RULE_012__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.timed')\
.objectForKey('TMAutomaticTimeOnlyEnabled').js
EOS
__MSCP_RULE_012__
}
raw_output="$(run_check_012 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_time_server_enforce" "$normalized_output"

# system_settings_token_removal_enforce
run_check_013() {
  /bin/bash <<'__MSCP_RULE_013__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.security.smartcard')\
.objectForKey('tokenRemovalAction').js
EOS
__MSCP_RULE_013__
}
raw_output="$(run_check_013 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_token_removal_enforce" "$normalized_output"

# system_settings_touch_id_settings_disable
run_check_014() {
  /bin/bash <<'__MSCP_RULE_014__'
/usr/bin/profiles show -output stdout-xml | /usr/bin/xmllint --xpath '//key[text()="DisabledSystemSettings"]/following-sibling::*[1]' - | /usr/bin/grep -c "com.apple.Touch-ID-Settings.extension"
__MSCP_RULE_014__
}
raw_output="$(run_check_014 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_touch_id_settings_disable" "$normalized_output"

# system_settings_usb_restricted_mode
run_check_015() {
  /bin/bash <<'__MSCP_RULE_015__'
/usr/bin/osascript -l JavaScript << EOS
  function run() {
    let pref1 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
  .objectForKey('allowUSBRestrictedMode'))
    if ( pref1 == false ) {
      return("false")
    } else {
      return("true")
    }
  }
EOS
__MSCP_RULE_015__
}
raw_output="$(run_check_015 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_usb_restricted_mode" "$normalized_output"

# system_settings_wallet_applepay_settings_disable
run_check_016() {
  /bin/bash <<'__MSCP_RULE_016__'
/usr/bin/profiles show -output stdout-xml | /usr/bin/xmllint --xpath '//key[text()="DisabledSystemSettings"]/following-sibling::*[1]' - | /usr/bin/grep -c "com.apple.WalletSettingsExtension"
__MSCP_RULE_016__
}
raw_output="$(run_check_016 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_wallet_applepay_settings_disable" "$normalized_output"

# system_settings_wifi_disable
run_check_017() {
  /bin/bash <<'__MSCP_RULE_017__'
/usr/sbin/networksetup -listallnetworkservices | /usr/bin/grep -c "*Wi-Fi"
__MSCP_RULE_017__
}
raw_output="$(run_check_017 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_wifi_disable" "$normalized_output"

# os_secure_enclave
run_check_018() {
  /bin/bash <<'__MSCP_RULE_018__'
/usr/sbin/ioreg -w 0 -c AppleSEPManager | /usr/bin/grep -q 'AppleSEPManager'; /bin/echo $?
__MSCP_RULE_018__
}
raw_output="$(run_check_018 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_secure_enclave" "$normalized_output"

printf '}'
