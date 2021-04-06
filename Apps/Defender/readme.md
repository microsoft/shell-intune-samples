# Microsoft Defender Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download Defender from the Microsoft download servers and then install it onto the Mac.

## Quick Run

```
sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/Apps/Defender/installDefender.sh)" 
```

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/installDefender*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
Tue  6 Apr 2021 18:17:39 BST | Creating [/Library/Logs/Microsoft/IntuneScripts/installDefender] to store logs

##############################################################
# Tue  6 Apr 2021 18:17:39 BST | Logging install of [Microsoft Defender ATP] to [/Library/Logs/Microsoft/IntuneScripts/installDefender/Microsoft Defender ATP.log]
############################################################

Tue  6 Apr 2021 18:17:39 BST | Checking if we need Rosetta 2 or not
Tue  6 Apr 2021 18:17:40 BST | [Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz] found, Rosetta not needed
Tue  6 Apr 2021 18:17:40 BST | Checking if we need to install or update [Microsoft Defender ATP]
Tue  6 Apr 2021 18:17:40 BST | [Microsoft Defender ATP] not installed, need to download and install
Tue  6 Apr 2021 18:17:40 BST | Starting downlading of [Microsoft Defender ATP]
Tue  6 Apr 2021 18:17:40 BST | Waiting for other Curl processes to end
Tue  6 Apr 2021 18:17:40 BST | No instances of Curl found, safe to proceed
Tue  6 Apr 2021 18:17:40 BST | Downloading Microsoft Defender ATP
Tue  6 Apr 2021 18:18:35 BST | Downloaded [Microsoft Defender ATP.app]
Tue  6 Apr 2021 18:18:35 BST | Checking if the application is running
Tue  6 Apr 2021 18:18:35 BST | [Microsoft Defender ATP] isn't running, lets carry on
Tue  6 Apr 2021 18:18:35 BST | Installing Microsoft Defender ATP
Tue  6 Apr 2021 18:18:35 BST | Installer not running, safe to start installing
Tue  6 Apr 2021 18:18:35 BST | Waiting for other Curl processes to end
Tue  6 Apr 2021 18:18:35 BST | No instances of Curl found, safe to proceed
installer: Package name is Microsoft Defender ATP
installer: Upgrading at base path /
installer: The upgrade was successful.
Tue  6 Apr 2021 18:19:13 BST | Microsoft Defender ATP Installed
Tue  6 Apr 2021 18:19:13 BST | Cleaning Up
Tue  6 Apr 2021 18:19:13 BST | Writing last modifieddate  to /Library/Logs/Microsoft/IntuneScripts/installDefender/Microsoft Defender ATP.meta
Tue  6 Apr 2021 18:19:13 BST | Application [Microsoft Defender ATP] succesfully installed
Tue  6 Apr 2021 18:19:13 BST | Writing last modifieddate [Tue, 02 Mar 2021 10:22:11 GMT] to [/Library/Logs/Microsoft/IntuneScripts/installDefender/Microsoft Defender ATP.meta]
```