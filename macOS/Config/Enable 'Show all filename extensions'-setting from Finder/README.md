# Enable "Show all filename extensions" -Setting from Finder
This Custom Script is required when implementing following CIS or NIST Recommendations for macOS: 
- **CIS**: Ensure Show All Filename Extensions Setting is Enabled (Automated)
- **NIST**: N/A

## Script Settings

- Run script as signed-in user : Yes
- Hide script notifications on devices : Yes
- Script frequency : Every 1 day
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***~/Library/Logs/Microsoft/IntuneScripts/ShowAllFilenameExtensions/ShowAllFilenameExtensions.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

**Note:** Please notice that on actual log, variable *$USER* is replaced with actual username of the user where script will be run.

```
##############################################################
# Fri Nov 29 10:18:46 EET 2023  | Starting running of script ShowAllFilenameExtensions
############################################################

Fri Nov 29 10:18:46 EET 2023 | 'Show all filename extensions' -setting is now enabled or it is already enabled from Finder for user $USER. Closing script..."
```
