#!/bin/bash

read_jxa_preference() {
  local suite="$1"
  local key="$2"

  /usr/bin/osascript -l JavaScript 2>/dev/null <<EOF
const defaults = $.NSUserDefaults.alloc.initWithSuiteName('$suite');
const value = defaults.objectForKey('$key');
if (value === null || value === undefined) {
  "";
} else {
  ObjC.unwrap(value).toString();
}
EOF
}

safe_int() {
  if [[ "$1" =~ ^[0-9]+$ ]]; then
    printf '%s' "$1"
  else
    printf '0'
  fi
}

bool_literal() {
  if [[ "$1" == "true" ]]; then
    printf 'true'
  else
    printf 'false'
  fi
}

automatic_login_disabled="true"
auto_login_user="$(/usr/bin/defaults read /Library/Preferences/com.apple.loginwindow autoLoginUser 2>/dev/null || true)"
if [[ -n "$auto_login_user" ]]; then
  automatic_login_disabled="false"
fi

automatic_logout_seconds_raw="$(read_jxa_preference '.GlobalPreferences' 'com.apple.autologout.AutoLogOutDelay')"
automatic_logout_seconds="$(safe_int "$automatic_logout_seconds_raw")"
automatic_logout_enabled="false"
if (( automatic_logout_seconds > 0 )); then
  automatic_logout_enabled="true"
fi

ssh_password_authentication_disabled="false"
ssh_password_setting_count="$(/usr/sbin/sshd -G 2>/dev/null | /usr/bin/grep -Ec '^(passwordauthentication\s+no|kbdinteractiveauthentication\s+no)' || true)"
if [[ "$ssh_password_setting_count" == "2" ]]; then
  ssh_password_authentication_disabled="true"
fi

failed_login_attempts_maximum="$(/usr/bin/pwpolicy -getaccountpolicies 2>/dev/null | /usr/bin/tail +2 | /usr/bin/xmllint --xpath "string(//dict/key[text()='policyAttributeMaximumFailedAuthentications']/following-sibling::integer[1])" - 2>/dev/null)"
failed_login_attempts_maximum="$(safe_int "$failed_login_attempts_maximum")"

failed_login_lockout_seconds="$(/usr/bin/pwpolicy -getaccountpolicies 2>/dev/null | /usr/bin/tail +2 | /usr/bin/xmllint --xpath "string(//dict/key[text()='autoEnableInSeconds']/following-sibling::integer[1])" - 2>/dev/null)"
failed_login_lockout_seconds="$(safe_int "$failed_login_lockout_seconds")"
failed_login_lockout_minutes="$(( failed_login_lockout_seconds / 60 ))"

password_history_depth="$(/usr/bin/pwpolicy -getaccountpolicies 2>/dev/null | /usr/bin/tail +2 | /usr/bin/xmllint --xpath "string(//dict/key[text()='policyAttributePasswordHistoryDepth']/following-sibling::*[1])" - 2>/dev/null)"
password_history_depth="$(safe_int "$password_history_depth")"

firewall_enabled="false"
firewall_state="$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null || true)"
if printf '%s' "$firewall_state" | /usr/bin/grep -Eiq 'enabled|state *= *[12]'; then
  firewall_enabled="true"
fi

firewall_stealth_mode_enabled="false"
firewall_stealth_state="$(/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode 2>/dev/null || true)"
if printf '%s' "$firewall_stealth_state" | /usr/bin/grep -iq 'enabled'; then
  firewall_stealth_mode_enabled="true"
fi

screen_sharing_disabled="false"
screen_sharing_enabled_line="$(/bin/launchctl print-disabled system 2>/dev/null | /usr/bin/grep '\"com.apple.screensharing\" => enabled' || true)"
screen_sharing_running_line="$(/bin/launchctl print system/com.apple.screensharing 2>/dev/null || true)"
if [[ -z "$screen_sharing_enabled_line" && -z "$screen_sharing_running_line" ]]; then
  screen_sharing_disabled="true"
fi

printer_sharing_disabled="false"
if /usr/sbin/cupsctl 2>/dev/null | /usr/bin/grep -q '_share_printers=0'; then
  printer_sharing_disabled="true"
fi

gatekeeper_enabled="false"
if /usr/sbin/spctl --status 2>/dev/null | /usr/bin/grep -q 'assessments enabled'; then
  gatekeeper_enabled="true"
fi

printf '{'
printf '"AutomaticLoginDisabled":%s,' "$(bool_literal "$automatic_login_disabled")"
printf '"AutomaticLogoutEnabled":%s,' "$(bool_literal "$automatic_logout_enabled")"
printf '"AutomaticLogoutSeconds":%s,' "$automatic_logout_seconds"
printf '"SshPasswordAuthenticationDisabled":%s,' "$(bool_literal "$ssh_password_authentication_disabled")"
printf '"FailedLoginAttemptsMaximum":%s,' "$failed_login_attempts_maximum"
printf '"FailedLoginLockoutMinutes":%s,' "$failed_login_lockout_minutes"
printf '"PasswordHistoryDepth":%s,' "$password_history_depth"
printf '"FirewallEnabled":%s,' "$(bool_literal "$firewall_enabled")"
printf '"FirewallStealthModeEnabled":%s,' "$(bool_literal "$firewall_stealth_mode_enabled")"
printf '"ScreenSharingDisabled":%s,' "$(bool_literal "$screen_sharing_disabled")"
printf '"PrinterSharingDisabled":%s,' "$(bool_literal "$printer_sharing_disabled")"
printf '"GatekeeperEnabled":%s' "$(bool_literal "$gatekeeper_enabled")"
printf '}'
