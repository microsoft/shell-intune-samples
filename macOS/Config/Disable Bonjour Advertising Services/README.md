# Disable Bonjour Advertising Services
This Custom Script is required when implementing following CIS or NIST Recommendations for macOS: 
- **CIS**: Ensure Bonjour Advertising Services Is Disabled (Automated)
- **NIST**: Disable Bonjour Multicast

## Pre-requisities
**It is strongly recommended to deployed [this script](https://github.com/microsoft/shell-intune-samples/tree/master/macOS/Config/Disable%20File%20Sharing), that will disable file sharing before disabling Bonjour Advertiding Service.**

**It also strongly recommended to deploy these policies below to managed Mac-devices via Intune before disabling Bonjour Advertising Services.**

| Platform | Profile type | Setting | Value | More information |
| -------- | ------- | -------- | ------- | ------- |
| macOS | Settings catalog | Allow File Sharing Modifications | False | This setting will make sure that users cannot turn on File Sharing from System Settings. **Note:** This key will disable the ability to modify this sharing setting in the GUI only. They do not modify or disable modification through the binary or the disable the service. Therefore, script is also require to be deployed.  |
| macOS | Settings catalog | Allow Media Sharing Modifications | False | This setting will make sure that users cannot turn on Media Sharing from System Settings. |

## Script Settings
- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not configured (**Note:** If users have and uses admin rights on their day-to-day tasks, you should consider to run this more frequently such as "Every 1 day")
- Number of times to retry if script fails : 3

## Log File
The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/DisableBonjourAdvertisingServices/DisableBonjourAdvertisingServices.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Sat Mar  8 15:42:57 EET 2025 | Starting running of script DisableBonjourAdvertisingServices
############################################################

Sat Mar  8 15:42:57 EET 2025 | Bonjour Advertising Services is now disabled or already disabled. Closing script...
```