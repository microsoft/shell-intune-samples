# Visual Studio Code Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download Microsoft Visual Studio Code and then install it onto the Mac.

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
##############################################################
# Fri  9 Apr 2021 13:08:26 BST | Logging install of [Visual Studio Code] to [/Library/Logs/Microsoft/IntuneScripts/installVSCode/Visual Studio Code.log]
############################################################

Fri  9 Apr 2021 13:08:26 BST | Checking if we need Rosetta 2 or not
Fri  9 Apr 2021 13:08:26 BST | Waiting for other [/usr/sbin/softwareupdate] processes to end
Fri  9 Apr 2021 13:08:26 BST | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Fri  9 Apr 2021 13:08:26 BST | [Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz] found, Rosetta not needed
Fri  9 Apr 2021 13:08:26 BST | Checking if we need to install or update [Visual Studio Code]
Fri  9 Apr 2021 13:08:26 BST | [Visual Studio Code] not installed, need to download and install
Fri  9 Apr 2021 13:08:26 BST | Dock is here, lets carry on
Fri  9 Apr 2021 13:08:26 BST | Starting downlading of [Visual Studio Code]
Fri  9 Apr 2021 13:08:26 BST | Waiting for other [curl] processes to end
Fri  9 Apr 2021 13:08:26 BST | No instances of [curl] found, safe to proceed
Fri  9 Apr 2021 13:08:27 BST | Downloading Visual Studio Code
Fri  9 Apr 2021 13:08:43 BST | Downloaded [Visual Studio Code.app] to [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.Ojp6rUym/VSCode-darwin.zip]
Fri  9 Apr 2021 13:08:43 BST | Detected install type as [ZIP]
Fri  9 Apr 2021 13:08:43 BST | Waiting for other [/Applications/Visual Studio Code.app/Contents/MacOS/Electron] processes to end
Fri  9 Apr 2021 13:08:44 BST | No instances of [/Applications/Visual Studio Code.app/Contents/MacOS/Electron] found, safe to proceed
Fri  9 Apr 2021 13:08:44 BST | Waiting for other [installer -pkg] processes to end
Fri  9 Apr 2021 13:08:44 BST | No instances of [installer -pkg] found, safe to proceed
Fri  9 Apr 2021 13:08:44 BST | Waiting for other [cp -Rf] processes to end
Fri  9 Apr 2021 13:08:44 BST | No instances of [cp -Rf] found, safe to proceed
Fri  9 Apr 2021 13:08:44 BST | Waiting for other [unzip] processes to end
Fri  9 Apr 2021 13:08:44 BST | No instances of [unzip] found, safe to proceed
Fri  9 Apr 2021 13:08:44 BST | Installing Visual Studio Code
Fri  9 Apr 2021 13:08:48 BST | /var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.Ojp6rUym/VSCode-darwin.zip unzipped
Fri  9 Apr 2021 13:08:55 BST | Visual Studio Code moved into /Applications
Fri  9 Apr 2021 13:08:55 BST | Fix up permissions
Fri  9 Apr 2021 13:08:56 BST | correctly applied permissions to Visual Studio Code
Fri  9 Apr 2021 13:08:56 BST | Visual Studio Code Installed
Fri  9 Apr 2021 13:08:56 BST | Cleaning Up
Fri  9 Apr 2021 13:08:56 BST | Writing last modifieddate  to /Library/Logs/Microsoft/IntuneScripts/installVSCode/Visual Studio Code.meta
Fri  9 Apr 2021 13:08:56 BST | Fixing up permissions
Fri  9 Apr 2021 13:08:56 BST | Application [Visual Studio Code] succesfully installed
```
