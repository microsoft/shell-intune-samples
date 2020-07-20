# Scripts for Microsoft Defender Advanced Thread Protection

These scripts provide examples of how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to solve some common MDATP tasks.

## installMDATPQuickScanJob.sh

This scripts intended usage scenario is to install a LaunchDaemon that will run an MDATP quick scan job every day at 3am. This uses the native macOS LaunchDamon process to run the scan at the specified time. If the device is asleep at that time the scan will not run.

### Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not Configured
- Number of times to retry if script fails : 3

## runMDATPQuickScan.sh

This script uses the Intune Scripting Agent 'Script Frequency' feature to run the MDATP quick scan. The benefit of this approach is that if the device is asleep during the scheduled runtime, the script will execute when it next wakes up.

### Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Every 6 hours
- Mac number of times to retry if script fails : 3
