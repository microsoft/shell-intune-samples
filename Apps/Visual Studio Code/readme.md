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

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/installVSCode/Visual Studio Code.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
Tue  6 Apr 2021 18:46:28 BST | Creating [/Library/Logs/Microsoft/IntuneScripts/installVSCode] to store logs

##############################################################
# Tue  6 Apr 2021 18:46:28 BST | Logging install of [Visual Studio Code] to [/Library/Logs/Microsoft/IntuneScripts/installVSCode/Visual Studio Code.log]
############################################################

Tue  6 Apr 2021 18:46:28 BST | Checking if we need Rosetta 2 or not
Tue  6 Apr 2021 18:46:29 BST | [Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz] found, Rosetta not needed
Tue  6 Apr 2021 18:46:29 BST | Checking if we need to install or update [Visual Studio Code]
Tue  6 Apr 2021 18:46:29 BST | [Visual Studio Code] not installed, need to download and install
Tue  6 Apr 2021 18:46:29 BST | Starting downlading of [Visual Studio Code]
Tue  6 Apr 2021 18:46:29 BST | Waiting for other Curl processes to end
Tue  6 Apr 2021 18:46:29 BST | No instances of Curl found, safe to proceed
Tue  6 Apr 2021 18:46:29 BST | Downloading Visual Studio Code
Tue  6 Apr 2021 18:46:46 BST | Downloaded [Visual Studio Code.app]
Tue  6 Apr 2021 18:46:46 BST | Checking if the application is running
Tue  6 Apr 2021 18:46:46 BST | [Visual Studio Code] isn't running, lets carry on
Tue  6 Apr 2021 18:46:46 BST | Installing Visual Studio Code
Tue  6 Apr 2021 18:46:52 BST | /tmp/vscode.zip unzipped
Tue  6 Apr 2021 18:47:15 BST | Visual Studio Code moved into /Applications
Tue  6 Apr 2021 18:47:15 BST | Fix up permissions
Tue  6 Apr 2021 18:47:15 BST | correctly applied permissions to Visual Studio Code
Tue  6 Apr 2021 18:47:15 BST | Visual Studio Code Installed
Tue  6 Apr 2021 18:47:16 BST | Cleaning Up
Tue  6 Apr 2021 18:47:16 BST | Writing last modifieddate  to /Library/Logs/Microsoft/IntuneScripts/installVSCode/Visual Studio Code.meta
Tue  6 Apr 2021 18:47:16 BST | Fixing up permissions
```
