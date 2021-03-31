# Intune Company Portal Installation Script

This script is am example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the Yammer dmg file from the Azure Blob Storage URL servers and then install it onto the Mac.

## Scenario

This scripts intended usage scenario is for DEP/ADE enrolled Macs that need to complete their device registration for conditional access.


## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Mac number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/installYammer/installyammer.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Fri 26 Mar 2021 15:11:46 GMT | Starting install of Yammer
############################################################

Fri 26 Mar 2021 15:11:46 GMT | Downloading Yammer
Fri 26 Mar 2021 15:11:59 GMT | Downloaded https://neiljohn.blob.core.windows.net/macapps/yammer.dmg to /tmp/yammer.dmg
Fri 26 Mar 2021 15:11:59 GMT | Yammer.app isn't running, lets carry on
Fri 26 Mar 2021 15:11:59 GMT | Installing Yammer
Fri 26 Mar 2021 15:11:59 GMT | Mounting /tmp/yammer.dmg to /tmp/YAMMER
Fri 26 Mar 2021 15:12:06 GMT | Copying /tmp/YAMMER/*.app to /Applications/Yammer.app
Fri 26 Mar 2021 15:12:13 GMT | Un-mounting /tmp/YAMMER
Fri 26 Mar 2021 15:12:14 GMT | Yammer Installed
Fri 26 Mar 2021 15:12:14 GMT | Cleaning Up
Fri 26 Mar 2021 15:12:14 GMT | Writing last modifieddate Fri, 26 Mar 2021 13:35:33 GMT to /Library/Logs/Microsoft/IntuneScripts/installYammer/Yammer.meta
Fri 26 Mar 2021 15:12:14 GMT | Fixing up permissions
Fri 26 Mar 2021 15:12:14 GMT | Application [Yammer] succesfully installed
```
