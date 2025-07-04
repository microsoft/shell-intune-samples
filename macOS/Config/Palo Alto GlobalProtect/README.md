# Palo Alto GlobalProtect Policy Enforcer

In generally, Mobile Device Management systems like Microsoft Intune [support the distribution of standardized plist files to managed users](https://learn.microsoft.com/en-us/intune/intune-service/configuration/preference-file-settings-macos). This makes it easy to distribute updated plist files to users when specific settings need to be changed, removed, or added. These plist files are typically deployed to the `/Library/Managed Preferences` location.

Unfortunately, some applications, such as GlobalProtect for macOS, do not support reading plist files from this location. Instead, they read directly from `/Library/Preferences/com.paloaltonetworks.GlobalProtect.settings.plist`. These policy enforcer scripts are specifically developed for such applications that do not support reading deployed plist files from `/Library/Managed Preferences`. The goal is to provide an easy way to distribute configuration values to these applications — whether it's for deploying new settings, modifying existing ones, or removing deprecated entries.

In this example, we provide a policy enforcer script for GlobalProtect on macOS.

## Palo Alto GlobalProtect Policy Enforcer (Machine Level)

> [!NOTE]  
> This script can be deployed as a separate script deployment or with a post-install script during GlobalProtect installation via Intune. We recommend using both options to ensure proper configuration.

This custom script is designed to **automate the configuration of GlobalProtect VPN policies** on macOS devices. It is especially useful in **MDM deployment scenarios** such as Microsoft Intune, where consistent and secure configuration across devices is critical.

### Purpose

This script ensures that key GlobalProtect settings are **created, updated, or removed** at the machine level using `PlistBuddy`. It helps enforce security, compliance, and user experience standards by:

- Disabling unnecessary or insecure features.
- Enabling enterprise-grade protections.
- Pre-configuring baseline settings of GlobalProtect to corporate environment.
- Preventing users from changing critical settings. If user change those settings, they will be enforced back to defined values.

### Benefits

- ✅ Ensures **consistent policy enforcement** across all managed Macs
- ✅ Reduces **manual configuration errors**
- ✅ Supports **CIS/NIST-aligned hardening**
- ✅ Fully **automated and silent** when deployed via Intune
- ✅ Logs all actions for **auditability and troubleshooting**

---
### What the Script Does

The script uses `PlistBuddy` to:

- **Create** missing `.plist` files and directories
- **Add or update** specific keys and values
- **Delete** obsolete or undesired keys (optional)

#### Policies (`com.paloaltonetworks.GlobalProtect.settings.plist`)

> [!NOTE]  
> - These are example settings and values. Modify as needed before deploying this script to managed devices.  
> - Please refer to [GlobalProtect Documentation](https://docs.paloaltonetworks.com/globalprotect/10-1/globalprotect-admin/globalprotect-apps/deploy-app-settings-transparently/customizable-app-settings#idd39ecf6d-6771-4ee3-a4d1-2ba5bbbad1bc) from Palo Alto Networks to validate which key/value pairs are supported and required.  
> - The script includes a commented-out example of how to delete values.  
> - This script enforces **machine-level** policies and does not target individual users.

| Key Path | Type | Value | Notes |
|----------|------|-------|-------|
| `Palo Alto Networks:GlobalProtect:PanSetup:Portal` | string | `vpn.example.com` | Set your GlobalProtect portal address. [More information](https://docs.paloaltonetworks.com/globalprotect/10-1/globalprotect-admin/globalprotect-apps/deploy-app-settings-transparently/customizable-app-settings/app-behavior-options). |
| `Palo Alto Networks:GlobalProtect:PanSetup:Prelogon` | string | `1` | Enables pre-logon feature. [More information](https://docs.paloaltonetworks.com/globalprotect/10-1/globalprotect-admin/globalprotect-apps/deploy-app-settings-transparently/customizable-app-settings/app-behavior-options). |
| `Palo Alto Networks:GlobalProtect:Settings:connect-method` | string | `pre-logon` | Connection method setting. [More information](https://docs.paloaltonetworks.com/globalprotect/10-1/globalprotect-admin/globalprotect-apps/deploy-app-settings-transparently/customizable-app-settings/app-behavior-options). |
| `Palo Alto Networks:GlobalProtect:Settings:default-browser` | string | `no` | Prevents launching default browser. [More information](https://docs.paloaltonetworks.com/globalprotect/10-1/globalprotect-admin/globalprotect-apps/deploy-app-settings-transparently/customizable-app-settings/app-behavior-options). |

---

### Customization

To **modify or extend** the script:

- To **add a new key or update existing key**, use the `enforce_value` function.
- To **delete a key**, use the `delete_key` or function.

---

### Script Settings

| Setting | Value |
|--------|-------|
| Run script as signed-in user | ❌ No |
| Hide script notifications on devices | ✅ Yes |
| Script frequency | Every 1 day |
| Number of times to retry if script fails | 3 |

---

### Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/PaloAltoGlobalProtectPolicyEnforcerMachineLevel/PaloAltoGlobalProtectPolicyEnforcerMachineLevel.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Fri Jul  4 17:12:51 EEST 2025 | Starting running of script PaloAltoGlobalProtectPolicyEnforcerMachineLevel
##############################################################

Fri Jul  4 17:12:51 EEST 2025 | Applying Palo Alto GlobalProtect policies...
Fri Jul  4 17:12:51 EEST 2025 | Directory already exists: /Library/Preferences
Fri Jul  4 17:12:51 EEST 2025 | [CREATE] Creating empty plist at /Library/Preferences/com.paloaltonetworks.GlobalProtect.settings.plist
Fri Jul  4 17:12:51 EEST 2025 | [ADD] Creating missing dictionary: Palo Alto Networks
Fri Jul  4 17:12:51 EEST 2025 | [ADD] Creating missing dictionary: Palo Alto Networks:GlobalProtect
Fri Jul  4 17:12:51 EEST 2025 | [ADD] Creating missing dictionary: Palo Alto Networks:GlobalProtect:PanSetup
Fri Jul  4 17:12:51 EEST 2025 | [ADD] Palo Alto Networks:GlobalProtect:PanSetup:Portal = vpn.example.com
Fri Jul  4 17:12:51 EEST 2025 | [ADD] Palo Alto Networks:GlobalProtect:PanSetup:Prelogon = 1
Fri Jul  4 17:12:51 EEST 2025 | [ADD] Creating missing dictionary: Palo Alto Networks:GlobalProtect:Settings
Fri Jul  4 17:12:51 EEST 2025 | [ADD] Palo Alto Networks:GlobalProtect:Settings:connect-method = pre-logon
Fri Jul  4 17:12:51 EEST 2025 | [ADD] Palo Alto Networks:GlobalProtect:Settings:default-browser = no

Fri Jul  4 17:12:51 EEST 2025 | Script PaloAltoGlobalProtectPolicyEnforcerMachineLevel completed.

##############################################################
# Fri Jul  4 18:12:40 EEST 2025 | Starting running of script PaloAltoGlobalProtectPolicyEnforcerMachineLevel
##############################################################

Fri Jul  4 18:12:40 EEST 2025 | Applying Palo Alto GlobalProtect policies...
Fri Jul  4 18:12:40 EEST 2025 | Directory already exists: /Library/Preferences
Fri Jul  4 18:12:40 EEST 2025 | [OK] Palo Alto Networks:GlobalProtect:PanSetup:Portal is already set to vpn.example.com
Fri Jul  4 18:12:40 EEST 2025 | [UPDATE] Palo Alto Networks:GlobalProtect:PanSetup:Prelogon: 1 -> 0
Fri Jul  4 18:12:40 EEST 2025 | [OK] Palo Alto Networks:GlobalProtect:Settings:connect-method is already set to pre-logon
Fri Jul  4 18:12:40 EEST 2025 | [OK] Palo Alto Networks:GlobalProtect:Settings:default-browser is already set to no

Fri Jul  4 18:12:40 EEST 2025 | Script PaloAltoGlobalProtectPolicyEnforcerMachineLevel completed.
##############################################################
```