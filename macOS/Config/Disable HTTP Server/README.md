# Disable HTTP Server
This Custom Script is required when implementing following CIS or NIST Recommendations for macOS: 
- **CIS**: Ensure HTTP Server Is Disabled (Automated)
- **NIST**: Disable the Built-in Web Server

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not configured (Note: If users have and uses admin rights on their day-to-day tasks, you should consider to run this more frequently such as "Every 1 day")
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/DisableHTTPServer.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Fri Nov 29 10:18:46 EET 2023  | Starting running of script DisableHTTPServer
############################################################

Fri Nov 29 10:18:46 EET 2023 | HTTP Server is disabled or already disabled. Closing script..."
```