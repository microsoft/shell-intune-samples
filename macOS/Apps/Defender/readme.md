# Microsoft Defender Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download Defender from the Microsoft download servers and then install it onto the Mac.

The main scenario for this script is to have Defender install last during initial enrollment to avoid any issues when the MDE network extension is loaded. The script
has an array of apps that it will wait for before beginning the Defender install. Edit this list as appropriate for your deployment.

```
waitForTheseApps=(  "/Applications/Microsoft Edge.app"
                    "/Applications/Microsoft Outlook.app"
                    "/Applications/Microsoft Word.app"
                    "/Applications/Microsoft Excel.app"
                    "/Applications/Microsoft PowerPoint.app"
                    "/Applications/Microsoft OneNote.app"
                    "/Applications/Microsoft Teams.app"
                    "/Applications/Visual Studio Code.app"
                    "/Applications/Company Portal.app")
```

## Quick Run

```
sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/refs/heads/master/macOS/Apps/Defender/installDefender.sh)" 
```

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/installDefender*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Fri  9 Apr 2021 13:31:24 BST | Logging install of [Microsoft Defender ATP] to [/Library/Logs/Microsoft/IntuneScripts/installDefender/Microsoft Defender ATP.log]
############################################################

Fri  9 Apr 2021 13:31:24 BST | Checking if we need Rosetta 2 or not
Fri  9 Apr 2021 13:31:24 BST | Waiting for other [/usr/sbin/softwareupdate] processes to end
Fri  9 Apr 2021 13:31:24 BST | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Fri  9 Apr 2021 13:31:24 BST | [Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz] found, Rosetta not needed
Fri  9 Apr 2021 13:31:25 BST | Checking if we need to install or update [Microsoft Defender ATP]
Fri  9 Apr 2021 13:31:25 BST | [Microsoft Defender ATP] not installed, need to download and install
Fri  9 Apr 2021 13:31:25 BST | Dock is here, lets carry on
Fri  9 Apr 2021 13:31:25 BST | Starting downlading of [Microsoft Defender ATP]
Fri  9 Apr 2021 13:31:25 BST | Waiting for other [curl] processes to end
Fri  9 Apr 2021 13:31:25 BST | No instances of [curl] found, safe to proceed
Fri  9 Apr 2021 13:31:25 BST | Downloading Microsoft Defender ATP
Fri  9 Apr 2021 13:32:22 BST | Downloaded [Microsoft Defender ATP.app] to [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.apfkvUMX/wdav.pkg]
Fri  9 Apr 2021 13:32:22 BST | Detected install type as [PKG]
Fri  9 Apr 2021 13:32:22 BST | Waiting for other [/Applications/Microsoft Defender ATP.app/Contents/MacOS/Microsoft Defender.app/Contents/MacOS/Microsoft Defender] processes to end
Fri  9 Apr 2021 13:32:22 BST | No instances of [/Applications/Microsoft Defender ATP.app/Contents/MacOS/Microsoft Defender.app/Contents/MacOS/Microsoft Defender] found, safe to proceed
Fri  9 Apr 2021 13:32:22 BST | Installing Microsoft Defender ATP
Fri  9 Apr 2021 13:32:22 BST | Waiting for other [installer -pkg] processes to end
Fri  9 Apr 2021 13:32:22 BST | No instances of [installer -pkg] found, safe to proceed
Fri  9 Apr 2021 13:32:22 BST | Waiting for other [rsync -a] processes to end
Fri  9 Apr 2021 13:32:22 BST | No instances of [rsync -a] found, safe to proceed
Fri  9 Apr 2021 13:32:22 BST | Waiting for other [unzip] processes to end
Fri  9 Apr 2021 13:32:22 BST | No instances of [unzip] found, safe to proceed
installer: Package name is Microsoft Defender ATP
installer: Upgrading at base path /
installer: The upgrade was successful.
Fri  9 Apr 2021 13:33:04 BST | Microsoft Defender ATP Installed
Fri  9 Apr 2021 13:33:04 BST | Cleaning Up
Fri  9 Apr 2021 13:33:04 BST | Application [Microsoft Defender ATP] succesfully installed
Fri  9 Apr 2021 13:33:05 BST | Writing last modifieddate [Tue, 02 Mar 2021 10:22:11 GMT] to [/Library/Logs/Microsoft/IntuneScripts/installDefender/Microsoft Defender ATP.meta]
```
