# Disable Remote Apple Events
This Custom Script is required when implementing following CIS or NIST Recommendations for macOS: 
- **CIS**: Ensure Remote Apple Events Is Disabled (Automated)
- **NIST**: Disable Remote Apple Events

## Pre-requisities
It is required to deploy these policies to managed Mac-devices via Intune before deploying this script.

| Platform | Profile type | Setting | Value | More information |
| -------- | ------- | -------- | ------- | ------- |
| macOS | Settings catalog | Allow Remote Apple Events Modifications | False | This setting will make sure that users cannot turn on Remote Application Scripting from System Settings. **Note:** This key will disable the ability to modify this sharing setting in the GUI only. They do not modify or disable modification through the binary or the disable the service. Therefore, script is also require to be deployed. |

| Custom Profile | Hyperlink | More information |
| -------- | ------- | -------- |
| Terminal - Full Disk Access.mobileconfig | [Link](https://github.com/microsoft/shell-intune-samples/tree/master/macOS/Custom%20Profiles/Terminal) | This Custom Profile will provide Full Disk Access to Terminal that is required when implementing this custom script to disable remote apple events. Otherwise, script is unable to disable remote apple events.  |

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not configured (**Note:** If users have and uses admin rights on their day-to-day tasks, you should consider to run this more frequently such as "Every 1 day")
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/DisableRemoteAppleEvents.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Fri Nov 29 09:11:27 EET 2023 | Starting running of script DisableRemoteAppleEvents
############################################################

setremoteappleevents: Off
Fri Nov 29 09:11:27 EET 2023 | Remote Apple Events is now disabled or already disabled. Closing script...
```
