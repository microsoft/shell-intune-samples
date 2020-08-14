# Visual Studio Code Installation Script

This script is am example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download Microsoft Visual Studio Code and then install it onto the Mac.

## Scenario

This scripts intended usage scenario is to install Visual Studio Code via the Intune Scripting Agent.

## Quick Run

```
sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/Apps/Visual%20Studio%20Code/installVSCode.sh)"
```

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Mac number of times to retry if script fails : 3

## Log File

The log file will output to ***/var/log/installvscode.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Fri 14 Aug 2020 14:51:37 BST | Starting install of Visual Studio Code
############################################################

Fri 14 Aug 2020 14:51:37 BST | Downloading Visual Studio Code
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100   125  100   125    0     0    350      0 --:--:-- --:--:-- --:--:--   350
100 84.3M  100 84.3M    0     0  5953k      0  0:00:14  0:00:14 --:--:-- 6138k
Fri 14 Aug 2020 14:51:51 BST | Unzipping /tmp/vscode.zip
Fri 14 Aug 2020 14:51:57 BST | Copying files to /Applications
Fri 14 Aug 2020 14:51:58 BST | Fixing up permissions
Fri 14 Aug 2020 14:51:58 BST | Cleaning up tmp files
```
