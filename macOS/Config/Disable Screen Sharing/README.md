# Disable Screen Sharing
This Custom Script is required when implementing following CIS or NIST Recommendations for macOS: 
- **CIS**: Ensure Screen Sharing Is Disabled (Automated)
- **NIST**: Disable Screen Sharing and Apple Remote Desktop

## Prerequisities
**It is strongly recommended to deployed [this script](https://github.com/microsoft/shell-intune-samples/tree/master/macOS/Config/Disable%20Remote%20Login), that will disable Apple Remote Desktop (ADR) before disabling screen sharing.**

**It also strongly recommended to deploy this policy below to managed Mac-devices via Intune before disabling screen sharing.**

| Platform | Profile type | Setting | Value | More information |
| -------- | ------- | -------- | ------- | ------- |
| macOS | Settings catalog | Allow ADR Remote Management Modifications | False | This setting will make sure that users cannot turn on Remote Management from System Settings. **Note:** This key will disable the ability to modify this sharing setting in the GUI only. They do not modify or disable modification through the binary or the disable the service. Therefore, script is also require to be deployed. |

## Script Settings
- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not configured (**Note:** If users have and uses admin rights on their day-to-day tasks, you should consider to run this more frequently such as "Every 1 day")
- Number of times to retry if script fails : 3

## Log File
The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/DisableScreenSharing/DisableScreenSharing.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Sat Mar  8 15:32:42 EET 2025 | Starting running of script DisableScreenSharing
############################################################

Sat Mar  8 15:32:42 EET 2025 | Screen Sharing via VNC is now disabled or already disabled. Closing script...
```
