# Pilot control mapping

This pilot focuses on controls that map cleanly to Intune custom compliance and have stable local signals on macOS.

| Policy | Intune setting | mSCP rule | Example NIST references |
| --- | --- | --- | --- |
| Root | `AutomaticLoginDisabled` | `system_settings_automatic_login_disable` | IA-2, IA-5(13) |
| Root | `AutomaticLogoutEnabled` | `system_settings_automatic_logout_enforce` | AC-12, AC-2(5) |
| Root | `AutomaticLogoutSeconds` | `system_settings_automatic_logout_enforce` | AC-12, AC-2(5) |
| Root | `SshPasswordAuthenticationDisabled` | `auth_ssh_password_authentication_disable` | IA-2, IA-5(2), MA-4 |
| Root | `FailedLoginAttemptsMaximum` | `pwpolicy_account_lockout_enforce` | AC-7 |
| Root | `FailedLoginLockoutMinutes` | `pwpolicy_account_lockout_timeout_enforce` | AC-7 |
| Root | `PasswordHistoryDepth` | `pwpolicy_history_enforce` | IA-5(1) |
| Root | `FirewallEnabled` | `system_settings_firewall_enable` | AC-4, SC-7, CM-7 |
| Root | `FirewallStealthModeEnabled` | `system_settings_firewall_stealth_mode_enable` | SC-7, SC-7(16), CM-7 |
| Root | `ScreenSharingDisabled` | `system_settings_screen_sharing_disable` | AC-3, AC-17 |
| Root | `PrinterSharingDisabled` | `system_settings_printer_sharing_disable` | CM-7, CM-7(1) |
| Root | `GatekeeperEnabled` | `os_gatekeeper_enable` | CM-14, CM-5, SI-3, SI-7(1) |
| User | `BluetoothSharingDisabled` | `system_settings_bluetooth_sharing_disable` | AC-3, AC-18(4), CM-7 |
| User | `AirDropDisabled` | `os_airdrop_disable` | AC-3, AC-20, CM-7 |

## Notes

- `AutomaticLogoutEnabled` and `AutomaticLogoutSeconds` are split into two Intune rules so `0` does not incorrectly pass a maximum-seconds comparison.
- Password policy values are returned as numbers so the same script can support stricter or looser operands later.
- This pilot intentionally skips some mSCP rules that are better enforced by configuration profiles or whose observable local state is ambiguous without a profile-specific signal.
