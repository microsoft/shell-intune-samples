# Disable creation of ".DS_Store" -files on network shares and removable drives
This Custom Script disables creation of ".DS_Store" -files on network shares and removable drives. Running this frequently via Intune to managed Mac-devices will make sure that ".DS_Store" -files are not polluting network shares and removable drives that are irritating for non-Mac users.

## Script Settings

- Run script as signed-in user : Yes
- Hide script notifications on devices : Yes
- Script frequency : Every 1 day
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***~/Library/Logs/Microsoft/IntuneScripts/DisableCreationOfDS_StoreFilesOnNetworkSharesAndRemovableDrives/DisableCreationOfDS_StoreFilesOnNetworkSharesAndRemovableDrives.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

**Note:** Please notice that on actual log, variable *$USER* is replaced with actual username of the user where script will be run.

```
##############################################################
# Sun Sep 15 14:29:37 EEST 2024 | Starting running of script DisableCreationOfDS_StoreFilesOnNetworkSharesAndRemovableDrives
############################################################

Sun Sep 15 14:29:37 EEST 2024 | Checking if creation of '.DS_Store' -files have been disabled on network shares for user $USER...
Sun Sep 15 14:29:37 EEST 2024 | Creation of '.DS_Store' -files have been enabled on network shares for user $USER. Disabling it...
Sun Sep 15 14:29:37 EEST 2024 | Creation of '.DS_Store' -files have been disabled on network shares for user $USER. This change will take effect the next time you log in to your Mac-device. Let's continue...
Sun Sep 15 14:29:37 EEST 2024 | Checking if creation of '.DS_Store' -files have been disabled on removable drives for user $USER...
Sun Sep 15 14:29:37 EEST 2024 | Creation of '.DS_Store' -files have been enabled on removable drives for user $USER. Disabling it...
Sun Sep 15 14:29:37 EEST 2024 | Creation of '.DS_Store' -files have been disabled on removable drives for user $USER. All done! This change will take effect the next time you log in to your Mac-device. Closing script...
```