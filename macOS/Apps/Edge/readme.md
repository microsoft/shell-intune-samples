# Microsoft Edge Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download Edge from the Microsoft download servers and then install it onto the Mac.

## Quick Run

```
sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/macOS/Apps/Edge/installEdge.sh)" ; open "/Applications/Microsoft Edge.app"
```

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/installEdge/Microsoft Edge.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Fri  9 Apr 2021 13:28:18 BST | Logging install of [Microsoft Edge] to [/Library/Logs/Microsoft/IntuneScripts/installEdge/Microsoft Edge.log]
############################################################

Fri  9 Apr 2021 13:28:18 BST | Checking if we need Rosetta 2 or not
Fri  9 Apr 2021 13:28:18 BST | Waiting for other [/usr/sbin/softwareupdate] processes to end
Fri  9 Apr 2021 13:28:18 BST | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Fri  9 Apr 2021 13:28:18 BST | [Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz] found, Rosetta not needed
Fri  9 Apr 2021 13:28:18 BST | Checking if we need to install or update [Microsoft Edge]
Fri  9 Apr 2021 13:28:18 BST | [Microsoft Edge] not installed, need to download and install
Fri  9 Apr 2021 13:28:18 BST | Dock is here, lets carry on
Fri  9 Apr 2021 13:28:18 BST | Starting downlading of [Microsoft Edge]
Fri  9 Apr 2021 13:28:18 BST | Waiting for other [curl] processes to end
Fri  9 Apr 2021 13:28:19 BST | No instances of [curl] found, safe to proceed
Fri  9 Apr 2021 13:28:19 BST | Downloading Microsoft Edge
Fri  9 Apr 2021 13:29:06 BST | Downloaded [Microsoft Edge.app] to [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.iFzMeb1n/MicrosoftEdge-89.0.774.75.pkg]
Fri  9 Apr 2021 13:29:06 BST | Detected install type as [PKG]
Fri  9 Apr 2021 13:29:06 BST | Waiting for other [/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge] processes to end
Fri  9 Apr 2021 13:29:06 BST | No instances of [/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge] found, safe to proceed
Fri  9 Apr 2021 13:29:06 BST | Installing Microsoft Edge
Fri  9 Apr 2021 13:29:06 BST | Waiting for other [installer -pkg] processes to end
Fri  9 Apr 2021 13:29:06 BST | No instances of [installer -pkg] found, safe to proceed
Fri  9 Apr 2021 13:29:06 BST | Waiting for other [rsync -a] processes to end
Fri  9 Apr 2021 13:29:06 BST | No instances of [rsync -a] found, safe to proceed
Fri  9 Apr 2021 13:29:06 BST | Waiting for other [unzip] processes to end
Fri  9 Apr 2021 13:29:06 BST | No instances of [unzip] found, safe to proceed
installer: Package name is Microsoft Edge
installer: Upgrading at base path /
installer: The upgrade was successful.
Fri  9 Apr 2021 13:29:25 BST | Microsoft Edge Installed
Fri  9 Apr 2021 13:29:25 BST | Cleaning Up
Fri  9 Apr 2021 13:29:25 BST | Application [Microsoft Edge] succesfully installed
Fri  9 Apr 2021 13:29:25 BST | Writing last modifieddate [Thu, 08 Apr 2021 18:49:49 GMT] to [/Library/Logs/Microsoft/IntuneScripts/installEdge/Microsoft Edge.meta]
```
