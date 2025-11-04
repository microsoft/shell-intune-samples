# iManage Work Desktop Policy Enforcer
In generally, Mobile Device Management systems like Microsoft Intune [support the distribution of standardized plist files to managed users](https://learn.microsoft.com/en-us/intune/intune-service/configuration/preference-file-settings-macos). This also makes it easy to distribute updated plist files to users when a specific setting needs to be changed, removed, or added. These plist files are typically deployed to the `/Library/Managed Preferences` location. 

Unfortunately, some applications, such as iManage Work Desktop for macOS, do not support reading plist files from this location. Instead, they read from `/Library/Application Support/iManage/Configuration/` and/or `~/Library/Application Support/iManage/Configuration/`. These policy enforcer scripts are specifically developed for such applications that do not support reading deployed plist files from `/Library/Managed Preferences`. The goal is to provide an easy way to distribute configuration values to these applications, whether it's for deploying new settings, modifying existing ones, or removing deprecated entries.

In this example, we provide policy enforcer script for iManage.

## iManage Work Desktop Policy Enforcer (Machine Level)
> [!NOTE]  
> This script can be deployed as separate script deployment but also with post-install script during iManage Work Desktop installation via Intune. We recommended to use both of the options.

This custom script is designed to **automate the configuration of iManage Work Desktop policies** on macOS devices. It is especially useful in **MDM deployment scenarios** such as Microsoft Intune, where consistent and secure configuration across devices is critical.

### Purpose

This script ensures that key iManage Work Desktop settings are **created, updated, or removed** at the machine level using `PlistBuddy`. It helps enforce security, compliance, and user experience standards by:

- Disabling unnecessary or insecure features.
- Enabling enterprise-grade protections.
- Pre-configuring baseline settings of iManage Work Desktop to corporate environment.
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

#### Policies (com.imanage.configuration.plist)

> [!NOTE]  
> - These are example settings and their values for example purposes. Feel free to do needed modifications before deploying this script to managed devices.
> - It is recommeded to check [iManage Work Desktop for Mac Documentation](https://docs.imanage.com/wdm-install-help/10.8.3/en/Managing_preferences.html), before defining your settings and values. Please also check [this documentation](https://docs.imanage.com/wdm-install-help/10.8.3/en/Centralized_deployment_of_configuration_settings.html).
> - From the script, we have commented some example how to delete value.
> - This policy enforcer can deploy settings only to all users from the managed Mac-device.

| Key Path | Type | Value | Notes
|----------|------|-------|-------|
| `CheckIn Default` | `integer` | `2` | The behavior when an iManage Work document is checked in from your Mac to iManage Work. Value 2 is "New Version" (default value).<br>[More information](https://docs.imanage.com/wdm-install-help/10.8.3/en/Setting_default_value_for_Preferences.html). |
| `Email Client Configuration` | `integer` | `3` | The default email client that is used when sending documents, links, or both from the iManage Work web client. Value 3 is "Microsoft Outlook".<br>[More information](https://docs.imanage.com/wdm-install-help/10.8.3/en/Setting_default_value_for_Preferences.html). |
| `MDM Payload` | `bool` | `true` | If you want all iManage Work Desktop for Mac users in your organization use the default configuration settings you provide, set the MDM Payload option in the com.imanage.configuration.plist file to true.<br>[More information](https://docs.imanage.com/wdm-install-help/10.8.3/en/Centralized_deployment_of_configuration_settings.html). |
| `ServerURL` | `string` | `https://dms.example.com` | The URL of the iManage Work Server to which the application must connect. Replace exmaple URL with your URL of the iManage Work Server. Please note, that URL must use https-protocol.<br>[More information](https://docs.imanage.com/wdm-install-help/10.8.3/en/Setting_default_value_for_Preferences.html). |

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

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/iManageWorkDesktopPolicyEnforcerMachineLevel/iManageWorkDesktopPolicyEnforcerMachineLevel.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Sat Jun 14 19:57:02 EEST 2025 | Starting running of script iManageWorkDesktopPolicyEnforcerMachineLevel
##############################################################

Sat Jun 14 19:57:02 EEST 2025 | Applying iManage Work Desktop policies...
Sat Jun 14 19:57:02 EEST 2025 | Creating directory: /Library/Application Support/iManage/Configuration
Sat Jun 14 19:57:02 EEST 2025 | [CREATE] Creating empty plist at /Library/Application Support/iManage/Configuration/com.imanage.configuration.plist
Sat Jun 14 19:57:02 EEST 2025 | [ADD] CheckIn Default = 2
Sat Jun 14 19:57:02 EEST 2025 | [ADD] Email Client Configuration = 3
Sat Jun 14 19:57:02 EEST 2025 | [ADD] MDM Payload = true
Sat Jun 14 19:57:02 EEST 2025 | [ADD] ServerURL = https://dms.example.com

Sat Jun 14 19:57:02 EEST 2025 | Script iManageWorkDesktopPolicyEnforcerMachineLevel completed.
##############################################################

##############################################################
# Sat Jun 14 20:00:06 EEST 2025 | Starting running of script iManageWorkDesktopPolicyEnforcerMachineLevel
##############################################################

Sat Jun 14 20:00:06 EEST 2025 | Applying iManage Work Desktop policies...
Sat Jun 14 20:00:06 EEST 2025 | Directory already exists: /Library/Application Support/iManage/Configuration
Sat Jun 14 20:00:06 EEST 2025 | [OK] CheckIn Default is already set to 2
Sat Jun 14 20:00:06 EEST 2025 | [UPDATE] Email Client Configuration: 3 -> 1
Sat Jun 14 20:00:06 EEST 2025 | [OK] MDM Payload is already set to true
Sat Jun 14 20:00:06 EEST 2025 | [OK] ServerURL is already set to https://dms.example.com

Sat Jun 14 20:00:07 EEST 2025 | Script iManageWorkDesktopPolicyEnforcerMachineLevel completed.
```