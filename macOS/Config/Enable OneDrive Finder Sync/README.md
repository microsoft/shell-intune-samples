# Enable OneDrive Finder Sync

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to configure Finder Sync extensions. 

## Description

This script enables the Finder Sync extension for Microsoft OneDrive so that when a user signs in to OneDrive they can configure Files on-demand without needing to approve the extension in settings. The script will work for OneDrive installed by downloading the PKG or the VPP version.

The extension ID of the OneDrive client is different for the standalone version compared to the VPP version:
 - **Standalone** - com.microsoft.OneDrive.FinderSync
 - **VPP** - com.microsoft.OneDrive-mac.FinderSync

## Script Settings

- Run script as signed-in user : **Yes**
- Hide script notifications on devices : Yes
- Script frequency : 
  - **Not configured** (which will cause the script to run once)
- Number of times to retry if script fails : 3

## Log File

The log file will output to **~/Library/Logs/Microsoft/IntuneScripts/EnableOneDriveFinderSync/EnableOneDriveFinderSync.log** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection).
```
##############################################################
# Fri Jan  8 14:21:01 AEST 2021 | Starting config of EnableOneDriveFinderSync
############################################################

Fri Jan  8 14:21:01 AEST 2021 | OneDrive config: Looking for required applications... 
Fri Jan  8 14:21:01 AEST 2021 | /Applications/OneDrive.app found!
Fri Jan  8 14:21:01 AEST 2021 | Finding installed OneDrive type (VPP or standalone)
     com.microsoft.OneDrive.FinderSync(20.169.0823)
Fri Jan  8 14:21:03 AEST 2021 | OneDrive installed standalone. Extension name is com.microsoft.OneDrive.FinderSync
Fri Jan  8 14:21:03 AEST 2021 | Checking extension status
Fri Jan  8 14:21:04 AEST 2021 | OneDrive config: Enabling FinderSync
Fri Jan  8 14:21:04 AEST 2021 | running pluginkit -e use -i com.microsoft.OneDrive.FinderSync
Fri Jan  8 14:21:04 AEST 2021 | Script finished
```
