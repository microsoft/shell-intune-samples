# Script for Microsoft Defender Advanced Thread Protection

This script is am example showing how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install a macOS LaunchDaemon.

## installMDATPQuickScanJob.sh

This scripts intended usage scenario is to install a LaunchDaemon that will run an MDATP quick scan job every day at 3am.


### Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Every 6 hours
- Mac number of times to retry if script fails : 3
