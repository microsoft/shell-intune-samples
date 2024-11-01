# Disable Remote Login
This Custom Script is required when implementing following CIS or NIST Recommendations for macOS: 
- **CIS**: Ensure Remote Login Is Disabled (Automated)
- **NIST**: N/A

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not configured (**Note:** If users have and uses admin rights on their day-to-day tasks, you should consider to run this more frequently such as "Every 1 day")
- Number of times to retry if script fails : 3

## Pre-requisities
It is required to deploy this Custom Profile first to managed Mac-devices via Intune before deploying this script.

| Custom Profile | Hyperlink | More information |
| -------- | ------- | -------- |
| Terminal - Full Disk Access.mobileconfig | [Link](https://github.com/microsoft/shell-intune-samples/tree/master/macOS/Custom%20Profiles/Terminal) | This Custom Profile will provide Full Disk Access to Terminal that is required when implementing this custom script to disable remote login. Otherwise, script is unable to disable remote login.  |

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/DisableRemoteLogin/DisableRemoteLogin.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Fri Nov 29 09:11:27 EET 2023 | Starting running of script DisableRemoteLogin
############################################################
Do you want to turn off remote login? If you do, you will lose this connection and only turn it back on locally at the server (yes/no)?
 
Fri Nov 29 09:11:27 EET 2023 | Remote Login is now disabled or already disabled. Closing script...
```
