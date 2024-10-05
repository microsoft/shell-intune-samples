# Disable Bluetooth Sharing
This Custom Script is required when implementing following CIS or NIST Recommendations for macOS: 
- **CIS**: Ensure Bluetooth Sharing Is Disabled (Automated)
- **NIST**: Disable Bluetooth Sharing

## Pre-requisities
It is strongly recommended to deploy these policies to managed Mac-devices via Intune before deploying this script.

| Platform | Profile type | Setting | Value | More information |
| -------- | ------- | -------- | ------- | ------- |
| macOS | Settings catalog | Allow Bluetooth Sharing Modifications | False | This setting will make sure that users cannot turn on Bluetooth Sharing from System Settings. **Note:** This key will disable the ability to modify this sharing setting in the GUI only. They do not modify or disable modification through the binary or the disable the service. Therefore, script is also require to be deployed. |

## Script Settings
- Run script as signed-in user : Yes
- Hide script notifications on devices : Yes
- Script frequency : Not configured (**Note:** If users have and uses admin rights on their day-to-day tasks, you should consider to run this more frequently such as "Every 1 day")
- Number of times to retry if script fails : 3

## Log File
The log file will output to ***~/Library/Logs/Microsoft/IntuneScripts/DisableBluetoothSharing/DisableBluetoothSharing.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)
 
**Note:** Please notice that on actual log, variable *$USER* is replaced with actual username of the user where script will be run.
 
```
##############################################################
# Fri Nov 29 09:11:27 EET 2023 | Starting running of script DisableBluetoothSharing
############################################################

Fri Nov 29 09:11:27 EET 2023 | Bluetooth Sharing is disabled or already disabled from user $USER. Closing script...
```
