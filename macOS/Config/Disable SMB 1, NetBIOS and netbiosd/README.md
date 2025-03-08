# Disable SMB 1, NetBIOS and netbiosd
According to [Apple](https://support.apple.com/en-us/102050), When making outbound connections to servers, SMB 1 and NetBIOS are enabled by default in macOS to improve compatibility with third-party products. macOS will attempt to use the later versions of SMB, as well as DNS and port 445, with failover to port 139 and SMB 1 as needed. You can disable SMB 1 or NetBIOS to prevent this failover.

This Custom Script will do this. It disables following automated manner:
- SMB 1
- NetBIOS
- netbiosd

> [!IMPORTANT]  
> **Using SMB 1 (Also known as SMBv1) is no longer secure and hence, it is strongly recommeded to disable it completely! Check more information [here](https://techcommunity.microsoft.com/blog/filecab/stop-using-smb1/425858).
and [here](https://techcommunity.microsoft.com/blog/filecab/smb-is-dead-long-live-smb/1185401).**
## Pre-requisities
It is recommended to deploy this policy to managed Mac-devices via Intune before deploying this script if you want to permanenly block mounting network drives.

| Platform | Profile type | Setting | Value | More information |
| -------- | ------- | -------- | ------- | ------- |
| macOS | Settings catalog | Declarative Device Management (DDM) &rarr; Network Storage | Disallowed | This setting will disable possibility to mount network drives.  |

## Script Settings
- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not configured (**Note:** If users have and uses admin rights on their day-to-day tasks, you should consider to run this more frequently such as "Every 1 day")
- Number of times to retry if script fails : 3

## Log File
The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/DisableSMB1NetBIOSAndNetbiosd/DisableSMB1NetBIOSAndNetbiosd.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Sat Mar  8 15:57:21 EET 2025 | Starting running of script DisableSMB1NetBIOSAndNetbiosd
############################################################

Sat Mar  8 15:57:21 EET 2025 | Disabling SMB1 and NetBIOS...
Sat Mar  8 15:57:21 EET 2025 | /etc/nsmb.conf does not exist. Creating file...
Sat Mar  8 15:57:21 EET 2025 | SMB1, NetBIOS and netbiosd is now disabled or already disabled. Closing script...
```