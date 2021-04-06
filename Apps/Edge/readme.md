# Microsoft Edge Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download Edge from the Microsoft download servers and then install it onto the Mac.

## Quick Run

```
sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/Apps/Edge/installEdge.sh)" ; open "/Applications/Microsoft Edge.app"
```

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/installEdge/Microsoft Edge.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
Tue  6 Apr 2021 18:13:12 BST | Creating [/Library/Logs/Microsoft/IntuneScripts/installEdge] to store logs

##############################################################
# Tue  6 Apr 2021 18:13:12 BST | Logging install of [Microsoft Edge] to [/Library/Logs/Microsoft/IntuneScripts/installEdge/Microsoft Edge.log]
############################################################

Tue  6 Apr 2021 18:13:12 BST | Checking if we need Rosetta 2 or not
Tue  6 Apr 2021 18:13:12 BST | [Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz] found, Rosetta not needed
Tue  6 Apr 2021 18:13:12 BST | Checking if we need to install or update [Microsoft Edge]
Tue  6 Apr 2021 18:13:12 BST | [Microsoft Edge] not installed, need to download and install
Tue  6 Apr 2021 18:13:12 BST | Starting downlading of [Microsoft Edge]
Tue  6 Apr 2021 18:13:12 BST | Waiting for other Curl processes to end
Tue  6 Apr 2021 18:13:12 BST | No instances of Curl found, safe to proceed
Tue  6 Apr 2021 18:13:13 BST | Updating Octory monitor for [Microsoft Edge] to [installing]
Tue  6 Apr 2021 18:13:13 BST | Downloading Microsoft Edge
Tue  6 Apr 2021 18:13:58 BST | Downloaded [Microsoft Edge.app]
Tue  6 Apr 2021 18:13:58 BST | Checking if the application is running
Tue  6 Apr 2021 18:13:58 BST | [Microsoft Edge] isn't running, lets carry on
Tue  6 Apr 2021 18:13:58 BST | Installing Microsoft Edge
Tue  6 Apr 2021 18:13:58 BST | Installer not running, safe to start installing
Tue  6 Apr 2021 18:13:58 BST | Updating Octory monitor for [Microsoft Edge] to [installing]
installer: Package name is Microsoft Edge
installer: Upgrading at base path /
installer: The upgrade was successful.
Tue  6 Apr 2021 18:14:15 BST | Microsoft Edge Installed
Tue  6 Apr 2021 18:14:15 BST | Cleaning Up
Tue  6 Apr 2021 18:14:15 BST | Writing last modifieddate  to /Library/Logs/Microsoft/IntuneScripts/installEdge/Microsoft Edge.meta
Tue  6 Apr 2021 18:14:15 BST | Application [Microsoft Edge] succesfully installed
Tue  6 Apr 2021 18:14:15 BST | Writing last modifieddate [Thu, 01 Apr 2021 19:17:52 GMT] to [/Library/Logs/Microsoft/IntuneScripts/installEdge/Microsoft Edge.meta]
Tue  6 Apr 2021 18:14:15 BST | Updating Octory monitor for [Microsoft Edge] to [installed]

```