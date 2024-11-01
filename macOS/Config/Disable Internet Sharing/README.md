# Disable Internet Sharing
This Custom Script is required when implementing following CIS or NIST Recommendations for macOS: 
- **CIS**: Ensure an Administrator Password Is Required to Access System-Wide Preferences (Automated)
- **NIST**: Disable Internet Sharing

## Pre-requisities
It is strongly recommended to deploy these policies to managed Mac-devices via Intune before deploying this script.

| Platform | Profile type | Setting | Value | More information |
| -------- | ------- | -------- | ------- | ------- |
| macOS | Settings catalog | Allow Internet Sharing Modifications | False | This setting will make sure that users cannot turn on Internet Sharing from System Settings. **Note:** This key will disable the ability to modify these sharing settings in the GUI only. They do not modify or disable modification through the binary or the disable the service. Therefore, script is also require to be deployed. |

## Script Settings
- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not configured (**Note:** If users have and uses admin rights on their day-to-day tasks, you should consider to run this more frequently such as "Every 1 day")
- Number of times to retry if script fails : 3

## Log File
The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/DisableInternetSharing/DisableInternetSharing.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Fri Nov 29 10:18:46 EET 2023  | Starting running of script DisableInternetSharing
############################################################

Fri Nov 29 10:18:46 EET 2023 | Underlying service of Internet Sharing is now disabled or already disabled. Closing script...
```
