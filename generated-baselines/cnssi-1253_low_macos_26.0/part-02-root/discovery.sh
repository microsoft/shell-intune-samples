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

# os_notes_transcription_disable
run_check_001() {
  /bin/bash <<'__MSCP_RULE_001__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowNotesTranscription').js
EOS
__MSCP_RULE_001__
}
raw_output="$(run_check_001 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_notes_transcription_disable" "$normalized_output"

# os_notes_transcription_summary_disable
run_check_002() {
  /bin/bash <<'__MSCP_RULE_002__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowNotesTranscriptionSummary').js
EOS
__MSCP_RULE_002__
}
raw_output="$(run_check_002 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_notes_transcription_summary_disable" "$normalized_output"

# os_on_device_dictation_enforce
run_check_003() {
  /bin/bash <<'__MSCP_RULE_003__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('forceOnDeviceOnlyDictation').js
EOS
__MSCP_RULE_003__
}
raw_output="$(run_check_003 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_on_device_dictation_enforce" "$normalized_output"

# os_parental_controls_enable
run_check_004() {
  /bin/bash <<'__MSCP_RULE_004__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess.new')\
.objectForKey('familyControlsEnabled').js
EOS
__MSCP_RULE_004__
}
raw_output="$(run_check_004 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_parental_controls_enable" "$normalized_output"

# os_password_autofill_disable
run_check_005() {
  /bin/bash <<'__MSCP_RULE_005__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowPasswordAutoFill').js
EOS
__MSCP_RULE_005__
}
raw_output="$(run_check_005 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_password_autofill_disable" "$normalized_output"

# os_password_hint_remove
run_check_006() {
  /bin/bash <<'__MSCP_RULE_006__'
HINT=$(/usr/bin/dscl . -list /Users hint | /usr/bin/awk '{ print $2 }')

if [ -z "$HINT" ]; then
  echo "PASS"
else
  echo "FAIL"
fi
__MSCP_RULE_006__
}
raw_output="$(run_check_006 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_password_hint_remove" "$normalized_output"

# os_password_proximity_disable
run_check_007() {
  /bin/bash <<'__MSCP_RULE_007__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowPasswordProximityRequests').js
EOS
__MSCP_RULE_007__
}
raw_output="$(run_check_007 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_password_proximity_disable" "$normalized_output"

# os_password_sharing_disable
run_check_008() {
  /bin/bash <<'__MSCP_RULE_008__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowPasswordSharing').js
EOS
__MSCP_RULE_008__
}
raw_output="$(run_check_008 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_password_sharing_disable" "$normalized_output"

# os_photos_enhanced_search_disable
run_check_009() {
  /bin/bash <<'__MSCP_RULE_009__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.photos.shareddefaults')\
.objectForKey('IPXDefaultEnhancedVisualSearchEnabled').js
EOS
__MSCP_RULE_009__
}
raw_output="$(run_check_009 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_photos_enhanced_search_disable" "$normalized_output"

# os_policy_banner_loginwindow_enforce
run_check_010() {
  /bin/bash <<'__MSCP_RULE_010__'
/bin/ls -ld /Library/Security/PolicyBanner.rtf* | /usr/bin/wc -l | /usr/bin/tr -d ' '
__MSCP_RULE_010__
}
raw_output="$(run_check_010 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_policy_banner_loginwindow_enforce" "$normalized_output"

# os_policy_banner_ssh_configure
run_check_011() {
  /bin/bash <<'__MSCP_RULE_011__'
bannerText="You are accessing a U.S. Government (USG) Information System (IS) that is provided for USG-authorized use only. By using this IS (which includes any device attached to this IS), you consent to the following conditions:
-The USG routinely intercepts and monitors communications on this IS for purposes including, but not limited to, penetration testing, COMSEC monitoring, network operations and defense, personnel misconduct (PM), law enforcement (LE), and counterintelligence (CI) investigations.
-At any time, the USG may inspect and seize data stored on this IS.
-Communications using, or data stored on, this IS are not private, are subject to routine monitoring, interception, and search, and may be disclosed or used for any USG authorized purpose.
-This IS includes security measures (e.g., authentication and access controls) to protect USG interests--not for your personal benefit or privacy.
-Notwithstanding the above, using this IS does not constitute consent to PM, LE or CI investigative searching or monitoring of the content of privileged communications, or work product, related to personal representation or services by attorneys, psychotherapists, or clergy, and their assistants. Such communications and work product are private and confidential. See User Agreement for details."
test "$(cat /etc/banner)" = "$bannerText" && echo "1" || echo "0"
__MSCP_RULE_011__
}
raw_output="$(run_check_011 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_policy_banner_ssh_configure" "$normalized_output"

# os_policy_banner_ssh_enforce
run_check_012() {
  /bin/bash <<'__MSCP_RULE_012__'
/usr/sbin/sshd -G | /usr/bin/grep -c "^banner /etc/banner"
__MSCP_RULE_012__
}
raw_output="$(run_check_012 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_policy_banner_ssh_enforce" "$normalized_output"

# os_power_nap_disable
run_check_013() {
  /bin/bash <<'__MSCP_RULE_013__'
/usr/bin/pmset -g custom | /usr/bin/awk '/powernap/ { sum+=$2 } END {print sum}'
__MSCP_RULE_013__
}
raw_output="$(run_check_013 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_power_nap_disable" "$normalized_output"

# os_privacy_setup_prompt_disable
run_check_014() {
  /bin/bash <<'__MSCP_RULE_014__'
/usr/bin/osascript -l JavaScript 2>/dev/null << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.SetupAssistant.managed')\
.objectForKey('SkipSetupItems').containsObject("Privacy")
EOS
__MSCP_RULE_014__
}
raw_output="$(run_check_014 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_privacy_setup_prompt_disable" "$normalized_output"

# os_recovery_lock_enable
run_check_015() {
  /bin/bash <<'__MSCP_RULE_015__'
/usr/libexec/mdmclient QuerySecurityInfo 2>/dev/null | /usr/bin/grep -c "IsRecoveryLockEnabled = 1"
__MSCP_RULE_015__
}
raw_output="$(run_check_015 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_recovery_lock_enable" "$normalized_output"

# os_removable_media_disable
run_check_016() {
  /bin/bash <<'__MSCP_RULE_016__'
/usr/bin/osascript -l JavaScript << EOS
ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.systemuiserver')\
.objectForKey('mount-controls'))["harddisk-external"]
EOS
__MSCP_RULE_016__
}
raw_output="$(run_check_016 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_removable_media_disable" "$normalized_output"

# os_root_disable
run_check_017() {
  /bin/bash <<'__MSCP_RULE_017__'
/usr/bin/dscl '/Local/Default' read '/Users/root' AuthenticationAuthority 2>/dev/null | /usr/bin/grep -c 'AuthenticationAuthority'
__MSCP_RULE_017__
}
raw_output="$(run_check_017 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_root_disable" "$normalized_output"

# os_safari_reader_summary_disable
run_check_018() {
  /bin/bash <<'__MSCP_RULE_018__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowSafariSummary').js
EOS
__MSCP_RULE_018__
}
raw_output="$(run_check_018 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_safari_reader_summary_disable" "$normalized_output"

# os_screensaver_loginwindow_enforce
run_check_019() {
  /bin/bash <<'__MSCP_RULE_019__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.screensaver')\
.objectForKey('moduleName').js
EOS
__MSCP_RULE_019__
}
raw_output="$(run_check_019 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_screensaver_loginwindow_enforce" "$normalized_output"

# os_setup_assistant_filevault_enforce
run_check_020() {
  /bin/bash <<'__MSCP_RULE_020__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.MCX.FileVault2')\
.objectForKey('ForceEnableInSetupAssistant')
EOS
__MSCP_RULE_020__
}
raw_output="$(run_check_020 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_setup_assistant_filevault_enforce" "$normalized_output"

# os_sip_enable
run_check_021() {
  /bin/bash <<'__MSCP_RULE_021__'
/usr/bin/csrutil status | /usr/bin/grep -c 'System Integrity Protection status: enabled.'
__MSCP_RULE_021__
}
raw_output="$(run_check_021 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_sip_enable" "$normalized_output"

# os_siri_prompt_disable
run_check_022() {
  /bin/bash <<'__MSCP_RULE_022__'
/usr/bin/osascript -l JavaScript 2>/dev/null << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.SetupAssistant.managed')\
.objectForKey('SkipSetupItems').containsObject("Siri")
EOS
__MSCP_RULE_022__
}
raw_output="$(run_check_022 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_siri_prompt_disable" "$normalized_output"

# os_skip_apple_intelligence_enable
run_check_023() {
  /bin/bash <<'__MSCP_RULE_023__'
/usr/bin/osascript -l JavaScript 2>/dev/null << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.SetupAssistant.managed')\
.objectForKey('SkipSetupItems').containsObject("Intelligence")
EOS
__MSCP_RULE_023__
}
raw_output="$(run_check_023 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_skip_apple_intelligence_enable" "$normalized_output"

# os_skip_screen_time_prompt_enable
run_check_024() {
  /bin/bash <<'__MSCP_RULE_024__'
/usr/bin/osascript -l JavaScript 2>/dev/null << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.SetupAssistant.managed')\
.objectForKey('SkipSetupItems').containsObject("ScreenTime")
EOS
__MSCP_RULE_024__
}
raw_output="$(run_check_024 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_skip_screen_time_prompt_enable" "$normalized_output"

# os_skip_unlock_with_watch_enable
run_check_025() {
  /bin/bash <<'__MSCP_RULE_025__'
/usr/bin/osascript -l JavaScript 2>/dev/null << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.SetupAssistant.managed')\
.objectForKey('SkipSetupItems').containsObject("WatchMigration")
EOS
__MSCP_RULE_025__
}
raw_output="$(run_check_025 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_skip_unlock_with_watch_enable" "$normalized_output"

# os_sshd_channel_timeout_configure
run_check_026() {
  /bin/bash <<'__MSCP_RULE_026__'
/usr/sbin/sshd -G | /usr/bin/awk '/channeltimeout/{print $2}'
__MSCP_RULE_026__
}
raw_output="$(run_check_026 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_sshd_channel_timeout_configure" "$normalized_output"

# os_sshd_client_alive_count_max_configure
run_check_027() {
  /bin/bash <<'__MSCP_RULE_027__'
/usr/sbin/sshd -G | /usr/bin/awk '/clientalivecountmax/{print $2}'
__MSCP_RULE_027__
}
raw_output="$(run_check_027 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_sshd_client_alive_count_max_configure" "$normalized_output"

# os_sshd_client_alive_interval_configure
run_check_028() {
  /bin/bash <<'__MSCP_RULE_028__'
/usr/sbin/sshd -G | /usr/bin/awk '/clientaliveinterval/{print $2}'
__MSCP_RULE_028__
}
raw_output="$(run_check_028 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_sshd_client_alive_interval_configure" "$normalized_output"

# os_sshd_fips_compliant
run_check_029() {
  /bin/bash <<'__MSCP_RULE_029__'
fips_sshd_config=("Ciphers aes128-gcm@openssh.com" "HostbasedAcceptedAlgorithms ecdsa-sha2-nistp256,ecdsa-sha2-nistp256-cert-v01@openssh.com" "HostKeyAlgorithms ecdsa-sha2-nistp256-cert-v01@openssh.com,sk-ecdsa-sha2-nistp256-cert-v01@openssh.com,ecdsa-sha2-nistp256,sk-ecdsa-sha2-nistp256@openssh.com" "KexAlgorithms ecdh-sha2-nistp256" "MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-256" "PubkeyAcceptedAlgorithms ecdsa-sha2-nistp256,ecdsa-sha2-nistp256-cert-v01@openssh.com,sk-ecdsa-sha2-nistp256-cert-v01@openssh.com" "CASignatureAlgorithms ecdsa-sha2-nistp256,sk-ecdsa-sha2-nistp256@openssh.com")
total=0
for config in $fips_sshd_config; do
  total=$(expr $(/usr/sbin/sshd -G | /usr/bin/grep -i -c "$config") + $total)
done

echo $total
__MSCP_RULE_029__
}
raw_output="$(run_check_029 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_sshd_fips_compliant" "$normalized_output"

# os_sshd_login_grace_time_configure
run_check_030() {
  /bin/bash <<'__MSCP_RULE_030__'
/usr/sbin/sshd -G | /usr/bin/awk '/logingracetime/{print $2}'
__MSCP_RULE_030__
}
raw_output="$(run_check_030 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_sshd_login_grace_time_configure" "$normalized_output"

# os_sshd_per_source_penalties_configure
run_check_031() {
  /bin/bash <<'__MSCP_RULE_031__'
/usr/sbin/sshd -G | /usr/bin/grep -q "persourcepenalties no" && echo "no" || echo "yes"
__MSCP_RULE_031__
}
raw_output="$(run_check_031 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_sshd_per_source_penalties_configure" "$normalized_output"

# os_sshd_permit_root_login_configure
run_check_032() {
  /bin/bash <<'__MSCP_RULE_032__'
/usr/sbin/sshd -G | /usr/bin/awk '/permitrootlogin/{print $2}'
__MSCP_RULE_032__
}
raw_output="$(run_check_032 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_sshd_permit_root_login_configure" "$normalized_output"

# os_sshd_unused_connection_timeout_configure
run_check_033() {
  /bin/bash <<'__MSCP_RULE_033__'
/usr/sbin/sshd -G | /usr/bin/awk '/unusedconnectiontimeout/{print $2}'
__MSCP_RULE_033__
}
raw_output="$(run_check_033 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_sshd_unused_connection_timeout_configure" "$normalized_output"

# os_sudo_log_enforce
run_check_034() {
  /bin/bash <<'__MSCP_RULE_034__'
/usr/bin/sudo /usr/bin/sudo -V | /usr/bin/grep -c "Log when a command is allowed by sudoers"
__MSCP_RULE_034__
}
raw_output="$(run_check_034 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_sudo_log_enforce" "$normalized_output"

# os_sudoers_timestamp_type_configure
run_check_035() {
  /bin/bash <<'__MSCP_RULE_035__'
/usr/bin/sudo /usr/bin/sudo -V | /usr/bin/awk -F": " '/Type of authentication timestamp record/{print $2}'
__MSCP_RULE_035__
}
raw_output="$(run_check_035 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_sudoers_timestamp_type_configure" "$normalized_output"

# os_system_read_only
run_check_036() {
  /bin/bash <<'__MSCP_RULE_036__'
/usr/sbin/system_profiler SPStorageDataType | /usr/bin/awk '/Mount Point: \/$/{x=NR+2}(NR==x){print $2}'
__MSCP_RULE_036__
}
raw_output="$(run_check_036 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_system_read_only" "$normalized_output"

# os_time_server_enabled
run_check_037() {
  /bin/bash <<'__MSCP_RULE_037__'
/bin/launchctl print system | /usr/bin/grep -c -E '\tcom.apple.timed'
__MSCP_RULE_037__
}
raw_output="$(run_check_037 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "os_time_server_enabled" "$normalized_output"

# os_touchid_prompt_disable
run_check_038() {
  /bin/bash <<'__MSCP_RULE_038__'
/usr/bin/osascript -l JavaScript 2>/dev/null << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.SetupAssistant.managed')\
.objectForKey('SkipSetupItems').containsObject("Biometric")
EOS
__MSCP_RULE_038__
}
raw_output="$(run_check_038 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_touchid_prompt_disable" "$normalized_output"

# os_unlock_active_user_session_disable
run_check_039() {
  /bin/bash <<'__MSCP_RULE_039__'
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
__MSCP_RULE_039__
}
raw_output="$(run_check_039 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_unlock_active_user_session_disable" "$normalized_output"

# os_user_app_installation_prohibit
run_check_040() {
  /bin/bash <<'__MSCP_RULE_040__'
/usr/bin/osascript -l JavaScript << EOS
function run() {
  let pref1 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess.new')\
  .objectForKey('familyControlsEnabled'))
  let pathlist = $.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess.new')\
  .objectForKey('pathBlackList').js
  for ( let app in pathlist ) {
      if ( ObjC.unwrap(pathlist[app]) == "/Users/" && pref1 == true ){
          return("true")
      }
  }
  return("false")
  }
EOS
__MSCP_RULE_040__
}
raw_output="$(run_check_040 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_user_app_installation_prohibit" "$normalized_output"

# os_writing_tools_disable
run_check_041() {
  /bin/bash <<'__MSCP_RULE_041__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowWritingTools').js
EOS
__MSCP_RULE_041__
}
raw_output="$(run_check_041 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "os_writing_tools_disable" "$normalized_output"

# pwpolicy_account_lockout_enforce
run_check_042() {
  /bin/bash <<'__MSCP_RULE_042__'
/usr/bin/pwpolicy -getaccountpolicies 2> /dev/null | /usr/bin/tail +2 | /usr/bin/xmllint --xpath '//dict/key[text()="policyAttributeMaximumFailedAuthentications"]/following-sibling::integer[1]/text()' - | /usr/bin/awk '{ if ($1 <= 6) {print "pass"} else {print "fail"}}' | /usr/bin/uniq
__MSCP_RULE_042__
}
raw_output="$(run_check_042 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "pwpolicy_account_lockout_enforce" "$normalized_output"

# pwpolicy_account_lockout_timeout_enforce
run_check_043() {
  /bin/bash <<'__MSCP_RULE_043__'
/usr/bin/pwpolicy -getaccountpolicies 2> /dev/null | /usr/bin/tail +2 | /usr/bin/xmllint --xpath '//dict/key[text()="autoEnableInSeconds"]/following-sibling::integer[1]/text()' - | /usr/bin/awk '{ if ($1/60 >= 15 ) {print "pass"} else {print "fail"}}' | /usr/bin/uniq
__MSCP_RULE_043__
}
raw_output="$(run_check_043 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "pwpolicy_account_lockout_timeout_enforce" "$normalized_output"

# pwpolicy_alpha_numeric_enforce
run_check_044() {
  /bin/bash <<'__MSCP_RULE_044__'
/usr/bin/pwpolicy -getaccountpolicies 2> /dev/null | /usr/bin/tail +2 | /usr/bin/xmllint --xpath '//dict/key[text()="policyIdentifier"]/following-sibling::*[1]/text()' - | /usr/bin/grep "requireAlphanumeric" -c
__MSCP_RULE_044__
}
raw_output="$(run_check_044 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "pwpolicy_alpha_numeric_enforce" "$normalized_output"

# pwpolicy_custom_regex_enforce
run_check_045() {
  /bin/bash <<'__MSCP_RULE_045__'
/usr/bin/pwpolicy -getaccountpolicies 2> /dev/null | /usr/bin/tail +2 | /usr/bin/xmllint --xpath 'boolean(//*[contains(text(),"policyAttributePassword matches '\''^(?=.*[A-Z])(?=.*[a-z]).*$'\''")])' -
__MSCP_RULE_045__
}
raw_output="$(run_check_045 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "pwpolicy_custom_regex_enforce" "$normalized_output"

# pwpolicy_history_enforce
run_check_046() {
  /bin/bash <<'__MSCP_RULE_046__'
/usr/bin/pwpolicy -getaccountpolicies 2> /dev/null | /usr/bin/tail +2 | /usr/bin/xmllint --xpath '//dict/key[text()="policyAttributePasswordHistoryDepth"]/following-sibling::*[1]/text()' - | /usr/bin/awk '{ if ($1 >= 5 ) {print "pass"} else {print "fail"}}' | /usr/bin/uniq
__MSCP_RULE_046__
}
raw_output="$(run_check_046 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "pwpolicy_history_enforce" "$normalized_output"

# pwpolicy_lower_case_character_enforce
run_check_047() {
  /bin/bash <<'__MSCP_RULE_047__'
/usr/bin/pwpolicy -getaccountpolicies 2> /dev/null | /usr/bin/tail +2 | /usr/bin/xmllint --xpath '//dict/key[text()="minimumAlphaCharactersLowerCase"]/following-sibling::integer[1]/text()' - | /usr/bin/awk '{ if ($1 >= 1 ) {print "pass"} else {print "fail"}}'
__MSCP_RULE_047__
}
raw_output="$(run_check_047 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "pwpolicy_lower_case_character_enforce" "$normalized_output"

# pwpolicy_max_lifetime_enforce
run_check_048() {
  /bin/bash <<'__MSCP_RULE_048__'
/usr/bin/pwpolicy -getaccountpolicies 2> /dev/null | /usr/bin/tail +2 | /usr/bin/xmllint --xpath '//dict/key[text()="policyAttributeExpiresEveryNDays"]/following-sibling::*[1]/text()' - | /usr/bin/awk '{ if ($1 <= 60 ) {print "pass"} else {print "fail"}}' | /usr/bin/uniq
__MSCP_RULE_048__
}
raw_output="$(run_check_048 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "pwpolicy_max_lifetime_enforce" "$normalized_output"

# pwpolicy_minimum_length_enforce
run_check_049() {
  /bin/bash <<'__MSCP_RULE_049__'
/usr/bin/pwpolicy -getaccountpolicies 2>/dev/null | tail +2 | grep -oE "policyAttributePassword matches '.\{[0-9]+," | awk -F'[{,]' -v ODV=6 '{if ($2 > max) max=$2} END {print (max >= ODV) ? "pass" : "fail"}'
__MSCP_RULE_049__
}
raw_output="$(run_check_049 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "pwpolicy_minimum_length_enforce" "$normalized_output"

# pwpolicy_minimum_lifetime_enforce
run_check_050() {
  /bin/bash <<'__MSCP_RULE_050__'
/usr/bin/pwpolicy -getaccountpolicies 2> /dev/null | /usr/bin/tail +2 | /usr/bin/xmllint --xpath '//dict/key[text()="policyAttributeMinimumLifetimeHours"]/following-sibling::integer[1]/text()' - | /usr/bin/awk '{ if ($1 >= 24 ) {print "pass"} else {print "fail"}}'
__MSCP_RULE_050__
}
raw_output="$(run_check_050 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "pwpolicy_minimum_lifetime_enforce" "$normalized_output"

# pwpolicy_simple_sequence_disable
run_check_051() {
  /bin/bash <<'__MSCP_RULE_051__'
/usr/bin/pwpolicy -getaccountpolicies 2> /dev/null | /usr/bin/tail +2 | /usr/bin/xmllint --xpath '//dict/key[text()="policyIdentifier"]/following-sibling::*[1]/text()' - | /usr/bin/grep "allowSimple" -c
__MSCP_RULE_051__
}
raw_output="$(run_check_051 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "pwpolicy_simple_sequence_disable" "$normalized_output"

# pwpolicy_special_character_enforce
run_check_052() {
  /bin/bash <<'__MSCP_RULE_052__'
/usr/bin/pwpolicy -getaccountpolicies 2>/dev/null | /usr/bin/tail -n +2 | /usr/bin/xmllint --xpath "//string[contains(text(), \"policyAttributePassword matches '(.*[^a-zA-Z0-9].*){\")]" - 2>/dev/null | /usr/bin/awk -F"{|}" '{if ($2 >= 1) {print "pass"} else {print "fail"}}'
__MSCP_RULE_052__
}
raw_output="$(run_check_052 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "pwpolicy_special_character_enforce" "$normalized_output"

# pwpolicy_upper_case_character_enforce
run_check_053() {
  /bin/bash <<'__MSCP_RULE_053__'
/usr/bin/pwpolicy -getaccountpolicies 2> /dev/null | /usr/bin/tail +2 | /usr/bin/xmllint --xpath '//dict/key[text()="minimumAlphaCharactersUpperCase"]/following-sibling::integer[1]/text()' - | /usr/bin/awk '{ if ($1 >= 1 ) {print "pass"} else {print "fail"}}'
__MSCP_RULE_053__
}
raw_output="$(run_check_053 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "pwpolicy_upper_case_character_enforce" "$normalized_output"

# system_settings_airplay_receiver_disable
run_check_054() {
  /bin/bash <<'__MSCP_RULE_054__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowAirPlayIncomingRequests').js
EOS
__MSCP_RULE_054__
}
raw_output="$(run_check_054 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_airplay_receiver_disable" "$normalized_output"

# system_settings_apple_watch_unlock_disable
run_check_055() {
  /bin/bash <<'__MSCP_RULE_055__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowAutoUnlock').js
EOS
__MSCP_RULE_055__
}
raw_output="$(run_check_055 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_apple_watch_unlock_disable" "$normalized_output"

# system_settings_automatic_login_disable
run_check_056() {
  /bin/bash <<'__MSCP_RULE_056__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.loginwindow')\
.objectForKey('com.apple.login.mcx.DisableAutoLoginClient').js
EOS
__MSCP_RULE_056__
}
raw_output="$(run_check_056 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_automatic_login_disable" "$normalized_output"

# system_settings_automatic_logout_enforce
run_check_057() {
  /bin/bash <<'__MSCP_RULE_057__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('.GlobalPreferences')\
.objectForKey('com.apple.autologout.AutoLogOutDelay').js
EOS
__MSCP_RULE_057__
}
raw_output="$(run_check_057 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_automatic_logout_enforce" "$normalized_output"

# system_settings_biometric_disable
run_check_058() {
  /bin/bash <<'__MSCP_RULE_058__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowFingerprintForUnlock').js
EOS
__MSCP_RULE_058__
}
raw_output="$(run_check_058 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_biometric_disable" "$normalized_output"

# system_settings_bluetooth_disable
run_check_059() {
  /bin/bash <<'__MSCP_RULE_059__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.MCXBluetooth')\
.objectForKey('DisableBluetooth').js
EOS
__MSCP_RULE_059__
}
raw_output="$(run_check_059 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_bluetooth_disable" "$normalized_output"

# system_settings_bluetooth_settings_disable
run_check_060() {
  /bin/bash <<'__MSCP_RULE_060__'
/usr/bin/profiles show -output stdout-xml | /usr/bin/xmllint --xpath '//key[text()="DisabledSystemSettings"]/following-sibling::*[1]' - | /usr/bin/grep -c com.apple.BluetoothSettings
__MSCP_RULE_060__
}
raw_output="$(run_check_060 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_bluetooth_settings_disable" "$normalized_output"

# system_settings_content_caching_disable
run_check_061() {
  /bin/bash <<'__MSCP_RULE_061__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowContentCaching').js
EOS
__MSCP_RULE_061__
}
raw_output="$(run_check_061 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_content_caching_disable" "$normalized_output"

# system_settings_critical_update_install_enforce
run_check_062() {
  /bin/bash <<'__MSCP_RULE_062__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.SoftwareUpdate')\
.objectForKey('CriticalUpdateInstall').js
EOS
__MSCP_RULE_062__
}
raw_output="$(run_check_062 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_critical_update_install_enforce" "$normalized_output"

# system_settings_diagnostics_reports_disable
run_check_063() {
  /bin/bash <<'__MSCP_RULE_063__'
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
__MSCP_RULE_063__
}
raw_output="$(run_check_063 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_diagnostics_reports_disable" "$normalized_output"

# system_settings_external_intelligence_disable
run_check_064() {
  /bin/bash <<'__MSCP_RULE_064__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowExternalIntelligenceIntegrations').js
EOS
__MSCP_RULE_064__
}
raw_output="$(run_check_064 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_external_intelligence_disable" "$normalized_output"

# system_settings_external_intelligence_sign_in_disable
run_check_065() {
  /bin/bash <<'__MSCP_RULE_065__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowExternalIntelligenceIntegrationsSignIn').js
EOS
__MSCP_RULE_065__
}
raw_output="$(run_check_065 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_external_intelligence_sign_in_disable" "$normalized_output"

# system_settings_filevault_enforce
run_check_066() {
  /bin/bash <<'__MSCP_RULE_066__'
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
__MSCP_RULE_066__
}
raw_output="$(run_check_066 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_filevault_enforce" "$normalized_output"

# system_settings_find_my_disable
run_check_067() {
  /bin/bash <<'__MSCP_RULE_067__'
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
__MSCP_RULE_067__
}
raw_output="$(run_check_067 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_find_my_disable" "$normalized_output"

# system_settings_firewall_enable
run_check_068() {
  /bin/bash <<'__MSCP_RULE_068__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.security.firewall')\
.objectForKey('EnableFirewall').js
EOS
__MSCP_RULE_068__
}
raw_output="$(run_check_068 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_firewall_enable" "$normalized_output"

# system_settings_firewall_stealth_mode_enable
run_check_069() {
  /bin/bash <<'__MSCP_RULE_069__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.security.firewall')\
.objectForKey('EnableStealthMode').js
EOS
__MSCP_RULE_069__
}
raw_output="$(run_check_069 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_firewall_stealth_mode_enable" "$normalized_output"

# system_settings_gatekeeper_identified_developers_allowed
run_check_070() {
  /bin/bash <<'__MSCP_RULE_070__'
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
__MSCP_RULE_070__
}
raw_output="$(run_check_070 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_gatekeeper_identified_developers_allowed" "$normalized_output"

# system_settings_gatekeeper_override_disallow
run_check_071() {
  /bin/bash <<'__MSCP_RULE_071__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.systempolicy.managed')\
.objectForKey('DisableOverride').js
EOS
__MSCP_RULE_071__
}
raw_output="$(run_check_071 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_gatekeeper_override_disallow" "$normalized_output"

# system_settings_guest_access_smb_disable
run_check_072() {
  /bin/bash <<'__MSCP_RULE_072__'
/usr/sbin/sysadminctl -smbGuestAccess status 2>&1 | /usr/bin/grep -c "SMB guest access disabled"
__MSCP_RULE_072__
}
raw_output="$(run_check_072 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_guest_access_smb_disable" "$normalized_output"

# system_settings_guest_account_disable
run_check_073() {
  /bin/bash <<'__MSCP_RULE_073__'
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
__MSCP_RULE_073__
}
raw_output="$(run_check_073 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_guest_account_disable" "$normalized_output"

# system_settings_hot_corners_disable
run_check_074() {
  /bin/bash <<'__MSCP_RULE_074__'
/usr/bin/profiles -P -o stdout | /usr/bin/grep -Ec '"wvous-bl-corner" = 0|"wvous-br-corner" = 0|"wvous-tl-corner" = 0|"wvous-tr-corner" = 0'
__MSCP_RULE_074__
}
raw_output="$(run_check_074 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_hot_corners_disable" "$normalized_output"

# system_settings_improve_assistive_voice_disable
run_check_075() {
  /bin/bash <<'__MSCP_RULE_075__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.Accessibility')\
.objectForKey('AXSAudioDonationSiriImprovementEnabled').js
EOS
__MSCP_RULE_075__
}
raw_output="$(run_check_075 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_improve_assistive_voice_disable" "$normalized_output"

# system_settings_improve_search_disable
run_check_076() {
  /bin/bash <<'__MSCP_RULE_076__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.assistant.support')\
.objectForKey('Search Queries Data Sharing Status').js
EOS
__MSCP_RULE_076__
}
raw_output="$(run_check_076 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_improve_search_disable" "$normalized_output"

# system_settings_improve_siri_dictation_disable
run_check_077() {
  /bin/bash <<'__MSCP_RULE_077__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.assistant.support')\
.objectForKey('Siri Data Sharing Opt-In Status').js
EOS
__MSCP_RULE_077__
}
raw_output="$(run_check_077 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_improve_siri_dictation_disable" "$normalized_output"

# system_settings_internet_accounts_disable
run_check_078() {
  /bin/bash <<'__MSCP_RULE_078__'
/usr/bin/profiles show -output stdout-xml | /usr/bin/xmllint --xpath '//key[text()="DisabledSystemSettings"]/following-sibling::*[1]' - | /usr/bin/grep -c com.apple.Internet-Accounts-Settings.extension
__MSCP_RULE_078__
}
raw_output="$(run_check_078 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_internet_accounts_disable" "$normalized_output"

# system_settings_internet_sharing_disable
run_check_079() {
  /bin/bash <<'__MSCP_RULE_079__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.MCX')\
.objectForKey('forceInternetSharingOff').js
EOS
__MSCP_RULE_079__
}
raw_output="$(run_check_079 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_internet_sharing_disable" "$normalized_output"

# system_settings_loginwindow_prompt_username_password_enforce
run_check_080() {
  /bin/bash <<'__MSCP_RULE_080__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.loginwindow')\
.objectForKey('SHOWFULLNAME').js
EOS
__MSCP_RULE_080__
}
raw_output="$(run_check_080 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_loginwindow_prompt_username_password_enforce" "$normalized_output"

# system_settings_media_sharing_disabled
run_check_081() {
  /bin/bash <<'__MSCP_RULE_081__'
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
__MSCP_RULE_081__
}
raw_output="$(run_check_081 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_media_sharing_disabled" "$normalized_output"

# system_settings_password_hints_disable
run_check_082() {
  /bin/bash <<'__MSCP_RULE_082__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.loginwindow')\
.objectForKey('RetriesUntilHint').js
EOS
__MSCP_RULE_082__
}
raw_output="$(run_check_082 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_password_hints_disable" "$normalized_output"

# system_settings_personalized_advertising_disable
run_check_083() {
  /bin/bash <<'__MSCP_RULE_083__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowApplePersonalizedAdvertising').js
EOS
__MSCP_RULE_083__
}
raw_output="$(run_check_083 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_personalized_advertising_disable" "$normalized_output"

# system_settings_printer_sharing_disable
run_check_084() {
  /bin/bash <<'__MSCP_RULE_084__'
/usr/sbin/cupsctl | /usr/bin/grep -c "_share_printers=0"
__MSCP_RULE_084__
}
raw_output="$(run_check_084 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_printer_sharing_disable" "$normalized_output"

# system_settings_rae_disable
run_check_085() {
  /bin/bash <<'__MSCP_RULE_085__'
/bin/launchctl print-disabled system | /usr/bin/grep -c '"com.apple.AEServer" => disabled'
__MSCP_RULE_085__
}
raw_output="$(run_check_085 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_rae_disable" "$normalized_output"

# system_settings_remote_management_disable
run_check_086() {
  /bin/bash <<'__MSCP_RULE_086__'
/usr/libexec/mdmclient QuerySecurityInfo 2>/dev/null | /usr/bin/grep -c "RemoteDesktopEnabled = 0"
__MSCP_RULE_086__
}
raw_output="$(run_check_086 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_remote_management_disable" "$normalized_output"

# system_settings_screensaver_ask_for_password_delay_enforce
run_check_087() {
  /bin/bash <<'__MSCP_RULE_087__'
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
__MSCP_RULE_087__
}
raw_output="$(run_check_087 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_screensaver_ask_for_password_delay_enforce" "$normalized_output"

# system_settings_screensaver_password_enforce
run_check_088() {
  /bin/bash <<'__MSCP_RULE_088__'
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.screensaver')\
.objectForKey('askForPassword').js
EOS
__MSCP_RULE_088__
}
raw_output="$(run_check_088 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_screensaver_password_enforce" "$normalized_output"

# system_settings_screensaver_timeout_enforce
run_check_089() {
  /bin/bash <<'__MSCP_RULE_089__'
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
__MSCP_RULE_089__
}
raw_output="$(run_check_089 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_string_field "system_settings_screensaver_timeout_enforce" "$normalized_output"

# system_settings_security_update_install
run_check_090() {
  /bin/bash <<'__MSCP_RULE_090__'
/usr/bin/plutil -convert json /var/db/softwareupdate/SoftwareUpdateDDMStatePersistence.plist -o - | /usr/bin/jq --raw-output .'SUCorePersistedStatePolicyFields.SUCoreDDMDeclarationGlobalSettings.automaticallyInstallSystemAndSecurityUpdates'
__MSCP_RULE_090__
}
raw_output="$(run_check_090 2>/dev/null || true)"
normalized_output="$(normalize_output "$raw_output")"
emit_int_field "system_settings_security_update_install" "$normalized_output"

printf '}'
