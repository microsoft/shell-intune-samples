# Access to Secure User's Home Folders
This Custom Script is required when implementing following CIS or NIST Recommendations for macOS: 
- **CIS**: Ensure Home Folders Are Secure (Automated)
- **NIST**: Secure User's Home Folders

## Script Settings

- Run script as signed-in user : Yes
- Hide script notifications on devices : Yes
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/SecureUsersHomeFolders.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Fri Nov 29 09:11:27 EET 2023 | Starting running of script SecureUsersHomeFolders
############################################################

Fri Nov 29 09:11:27 EET 2023 | User's Home Folders are now secured or already secured. Closing script...
```