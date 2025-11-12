# Visual Studio Code Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download Microsoft Visual Studio Code and then install it onto the Mac.

## Scenario

This scripts intended usage scenario is to install Visual Studio Code via the Intune Scripting Agent.

## Quick Run

```
sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/macOS/Apps/Visual%20Studio%20Code/installVSCode.sh)"
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
# Thu 15 Dec 2022 12:42:24 GMT | Logging install of [Visual Studio Code] to [/Library/Logs/Microsoft/IntuneScripts/installVSCode/Visual Studio Code.log]
############################################################

Thu 15 Dec 2022 12:42:24 GMT | Checking if we need Rosetta 2 or not
Thu 15 Dec 2022 12:42:24 GMT | Waiting for other [/usr/sbin/softwareupdate] processes to end
Thu 15 Dec 2022 12:42:24 GMT | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Thu 15 Dec 2022 12:42:24 GMT | Rosetta is already installed and running. Nothing to do.
Thu 15 Dec 2022 12:42:24 GMT | Checking if we need to install or update [Visual Studio Code]
Thu 15 Dec 2022 12:42:24 GMT | [Visual Studio Code] not installed, need to download and install
Thu 15 Dec 2022 12:42:24 GMT | Dock is here, lets carry on
Thu 15 Dec 2022 12:42:24 GMT | Starting downlading of [Visual Studio Code]
Thu 15 Dec 2022 12:42:24 GMT | Waiting for other [curl -f] processes to end
Thu 15 Dec 2022 12:42:24 GMT | No instances of [curl -f] found, safe to proceed
Thu 15 Dec 2022 12:42:24 GMT | Downloading Visual Studio Code
Thu 15 Dec 2022 12:42:29 GMT | Downloaded [Visual Studio Code.app] to [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.slVprIIK/VSCode-darwin-universal.zip]
Thu 15 Dec 2022 12:42:29 GMT | Detected install type as [ZIP]
Thu 15 Dec 2022 12:42:29 GMT | Waiting for other [/Applications/Visual Studio Code.app/Contents/MacOS/Electron] processes to end
Thu 15 Dec 2022 12:42:29 GMT | No instances of [/Applications/Visual Studio Code.app/Contents/MacOS/Electron] found, safe to proceed
Thu 15 Dec 2022 12:42:29 GMT | Installing Visual Studio Code
Thu 15 Dec 2022 12:42:30 GMT | Changed current directory to /var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.slVprIIK
Thu 15 Dec 2022 12:42:34 GMT | /var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.slVprIIK/VSCode-darwin-universal.zip unzipped
Thu 15 Dec 2022 12:42:37 GMT | Visual Studio Code moved into /Applications
Thu 15 Dec 2022 12:42:37 GMT | Fix up permissions
Thu 15 Dec 2022 12:42:38 GMT | correctly applied permissions to Visual Studio Code
Thu 15 Dec 2022 12:42:38 GMT | Visual Studio Code Installed
Thu 15 Dec 2022 12:42:38 GMT | Cleaning Up
Thu 15 Dec 2022 12:42:38 GMT | Writing last modifieddate [Wed, 14 Dec 2022 11:35:16 GMT] to [/Library/Logs/Microsoft/IntuneScripts/installVSCode/Visual Studio Code.meta]
Thu 15 Dec 2022 12:42:38 GMT | Fixing up permissions
Thu 15 Dec 2022 12:42:38 GMT | Application [Visual Studio Code] succesfully installed
```
