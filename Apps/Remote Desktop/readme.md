# Microsoft Remote Desktop Installation Script

This script is am example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the Microsoft Remote Desktop app from the Microsoft download servers and then install it onto the Mac.

## Scenario

This scripts intended usage scenario is for customers who wish to use a shell script to deploy the Microsoft Remote Desktop app.

## Quick Run

```
sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/Apps/Remote%20Desktop/installRemoteDesktop.sh)"
```

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/installRemoteDesktop/Remote Desktop.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
Tue  6 Apr 2021 19:18:14 BST | Creating [/Library/Logs/Microsoft/IntuneScripts/installRemoteDesktop] to store logs

##############################################################
# Tue  6 Apr 2021 19:18:14 BST | Logging install of [Remote Desktop] to [/Library/Logs/Microsoft/IntuneScripts/installRemoteDesktop/Remote Desktop.log]
############################################################

Tue  6 Apr 2021 19:18:14 BST | Checking if we need Rosetta 2 or not
Tue  6 Apr 2021 19:18:15 BST | [Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz] found, Rosetta not needed
Tue  6 Apr 2021 19:18:15 BST | Checking if we need to install or update [Remote Desktop]
Tue  6 Apr 2021 19:18:15 BST | [Remote Desktop] not installed, need to download and install
Tue  6 Apr 2021 19:18:15 BST | Starting downlading of [Remote Desktop]
Tue  6 Apr 2021 19:18:15 BST | Waiting for other Curl processes to end
Tue  6 Apr 2021 19:18:16 BST | No instances of Curl found, safe to proceed
Tue  6 Apr 2021 19:18:16 BST | Updating Octory monitor for [Remote Desktop] to [installing]
Tue  6 Apr 2021 19:18:16 BST | Downloading Remote Desktop
Tue  6 Apr 2021 19:18:22 BST | Downloaded [Microsoft Remote Desktop.app]
Tue  6 Apr 2021 19:18:22 BST | Checking if the application is running
Tue  6 Apr 2021 19:18:23 BST | [Remote Desktop] isn't running, lets carry on
Tue  6 Apr 2021 19:18:23 BST | Installing Remote Desktop
Tue  6 Apr 2021 19:18:23 BST | Installer not running, safe to start installing
Tue  6 Apr 2021 19:18:23 BST | Updating Octory monitor for [Remote Desktop] to [installing]
installer: Package name is Microsoft Remote Desktop v10.5.2
installer: Upgrading at base path /
installer: The upgrade was successful.
Tue  6 Apr 2021 19:18:39 BST | Remote Desktop Installed
Tue  6 Apr 2021 19:18:39 BST | Cleaning Up
Tue  6 Apr 2021 19:18:39 BST | Writing last modifieddate  to /Library/Logs/Microsoft/IntuneScripts/installRemoteDesktop/Remote Desktop.meta
Tue  6 Apr 2021 19:18:39 BST | Application [Remote Desktop] succesfully installed
Tue  6 Apr 2021 19:18:40 BST | Writing last modifieddate [Fri, 26 Mar 2021 14:43:35 GMT] to [/Library/Logs/Microsoft/IntuneScripts/installRemoteDesktop/Remote Desktop.meta]
Tue  6 Apr 2021 19:18:40 BST | Updating Octory monitor for [Remote Desktop] to [installed]
```
