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

##############################################################
# Fri  9 Apr 2021 13:04:03 BST | Logging install of [Remote Desktop] to [/Library/Logs/Microsoft/IntuneScripts/installRemoteDesktop/Remote Desktop.log]
############################################################

Fri  9 Apr 2021 13:04:03 BST | Checking if we need Rosetta 2 or not
Fri  9 Apr 2021 13:04:03 BST | Waiting for other [/usr/sbin/softwareupdate] processes to end
Fri  9 Apr 2021 13:04:03 BST | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Fri  9 Apr 2021 13:04:03 BST | [Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz] found, Rosetta not needed
Fri  9 Apr 2021 13:04:03 BST | Checking if we need to install or update [Remote Desktop]
Fri  9 Apr 2021 13:04:03 BST | [Remote Desktop] not installed, need to download and install
Fri  9 Apr 2021 13:04:03 BST | Dock is here, lets carry on
Fri  9 Apr 2021 13:04:03 BST | Starting downlading of [Remote Desktop]
Fri  9 Apr 2021 13:04:03 BST | Waiting for other [curl] processes to end
Fri  9 Apr 2021 13:04:03 BST | No instances of [curl] found, safe to proceed
Fri  9 Apr 2021 13:04:03 BST | Downloading Remote Desktop
Fri  9 Apr 2021 13:04:08 BST | Downloaded [Microsoft Remote Desktop.app] to [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.6CDCpZiA/MicrosoftRemoteDesktop.pkg]
Fri  9 Apr 2021 13:04:08 BST | Detected install type as [PKG]
Fri  9 Apr 2021 13:04:08 BST | Waiting for other [/Applications/Microsoft Remote Desktop.app/Contents/MacOS/Microsoft Remote Desktop] processes to end
Fri  9 Apr 2021 13:04:09 BST | No instances of [/Applications/Microsoft Remote Desktop.app/Contents/MacOS/Microsoft Remote Desktop] found, safe to proceed
Fri  9 Apr 2021 13:04:09 BST | Installing Remote Desktop
Fri  9 Apr 2021 13:04:09 BST | Waiting for other [installer -pkg] processes to end
Fri  9 Apr 2021 13:04:09 BST | No instances of [installer -pkg] found, safe to proceed
Fri  9 Apr 2021 13:04:09 BST | Waiting for other [cp -Rf] processes to end
Fri  9 Apr 2021 13:04:09 BST | No instances of [cp -Rf] found, safe to proceed
Fri  9 Apr 2021 13:04:09 BST | Waiting for other [unzip] processes to end
Fri  9 Apr 2021 13:04:09 BST | No instances of [unzip] found, safe to proceed
installer: Package name is Microsoft Remote Desktop v10.5.2
installer: Upgrading at base path /
installer: The upgrade was successful.
Fri  9 Apr 2021 13:04:12 BST | Remote Desktop Installed
Fri  9 Apr 2021 13:04:12 BST | Cleaning Up
Fri  9 Apr 2021 13:04:12 BST | Application [Remote Desktop] succesfully installed
Fri  9 Apr 2021 13:04:12 BST | Writing last modifieddate [Fri, 26 Mar 2021 14:43:35 GMT] to [/Library/Logs/Microsoft/IntuneScripts/installRemoteDesktop/Remote Desktop.meta]
```
