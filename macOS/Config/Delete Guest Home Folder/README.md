# Delete Guest Home Folder
This Custom Script is required when implementing following CIS or NIST Recommendations for macOS: 
- **CIS**: Ensure the Guest Home Folder Does Not Exist (Automated)
- **NIST**: N/A

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not configured (Note: If users have and uses admin rights on their day-to-day tasks, you should consider to run this more frequently such as "Every 1 day")
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/DeleteGuestHomeFolder.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Fri Nov 29 10:18:46 EET 2023  | Starting running of script DeleteGuestHomeFolder
############################################################

Fri Nov 29 10:18:46 EET 2023 | Guest Home Folder is deleted or already deleted. Closing script..."
```
