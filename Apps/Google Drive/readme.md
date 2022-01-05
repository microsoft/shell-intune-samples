# Script to Enable Screen Sharing

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to enable screen sharing. In this case the script will enable screen sharing for Administrators only.

## Quick Run

```
sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/Misc/enableScreenSharing/enableScreenSharing.sh)"
```

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/EnableScreenSharing/EnableScreenSharing.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Fri 26 Nov 2021 12:57:06 GMT | Logging configuration of [EnableScreenSharing] to [/Library/Logs/Microsoft/IntuneScripts/EnableScreenSharing/EnableScreenSharing.log]
############################################################

Fri 26 Nov 2021 12:57:06 GMT | Writing to /var/db/launchd.db/com.apple.launchd/overrides.plist
Fri 26 Nov 2021 12:57:06 GMT | Launching com.apple.screensharing Launch Daemon
```
