# Uninstall Apple Bloatware Apps (iMovie, GarageBand, Pages, Numbers, and Keynote)
This Custom Script uninstalls following pre-installed bloatware application from Mac-devices that are usually installed when device is purchased from retailer:
- iMovie
- Garageband
- Pages
- Numbers
- Keynote

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/UninstallAppleBloatwareApps/UninstallAppleBloatwareApps.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Sun Sep 15 14:29:37 EEST 2024 | Starting running of script DisableCreationOfDS_StoreFilesOnNetworkSharesAndRemovableDrives
############################################################

Sun Sep 15 14:29:37 EEST 2024 | Checking if creation of '.DS_Store' -files have been disabled on network shares for user $USER...
Sun Sep 15 14:29:37 EEST 2024 | Creation of '.DS_Store' -files have been enabled on network shares for user $USER. Disabling it...
Sun Sep 15 14:29:37 EEST 2024 | Creation of '.DS_Store' -files have been disabled on network shares for user $USER. This change will take effect the next time when you log in to your Mac-device. Let's continue...
Sun Sep 15 14:29:37 EEST 2024 | Checking if creation of '.DS_Store' -files have been disabled on removable drives for user $USER...
Sun Sep 15 14:29:37 EEST 2024 | Creation of '.DS_Store' -files have been enabled on removable drives for user $USER. Disabling it...
Sun Sep 15 14:29:37 EEST 2024 | Creation of '.DS_Store' -files have been disabled on removable drives for user $USER. This change will take effect the next time when you log in to your Mac-device. All done! Closing script...
```