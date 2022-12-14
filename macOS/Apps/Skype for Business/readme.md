# Microsoft Skype for Business Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the Company Portal pkg file from the Microsoft download servers and then install it onto the Mac.

## Scenario

This scripts intended usage scenario is for DEP/ADE enrolled Macs that need to complete their device registration for conditional access.

## Quick Run

```
sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/Apps/Skype%20for%20Business/installSFB.sh)"
```

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/installSkypeForBusiness/Skype for Business.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Fri  9 Apr 2021 13:11:01 BST | Logging install of [Skype for Business] to [/Library/Logs/Microsoft/IntuneScripts/installSkypeForBusiness/Skype for Business.log]
############################################################

Fri  9 Apr 2021 13:11:01 BST | Checking if we need Rosetta 2 or not
Fri  9 Apr 2021 13:11:01 BST | Waiting for other [/usr/sbin/softwareupdate] processes to end
Fri  9 Apr 2021 13:11:01 BST | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Fri  9 Apr 2021 13:11:01 BST | [Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz] found, Rosetta not needed
Fri  9 Apr 2021 13:11:01 BST | Checking if we need to install or update [Skype for Business]
Fri  9 Apr 2021 13:11:01 BST | [Skype for Business] not installed, need to download and install
Fri  9 Apr 2021 13:11:01 BST | Dock is here, lets carry on
Fri  9 Apr 2021 13:11:01 BST | Starting downlading of [Skype for Business]
Fri  9 Apr 2021 13:11:01 BST | Waiting for other [curl] processes to end
Fri  9 Apr 2021 13:11:01 BST | No instances of [curl] found, safe to proceed
Fri  9 Apr 2021 13:11:01 BST | Downloading Skype for Business
Fri  9 Apr 2021 13:11:17 BST | Downloaded [Skype for Business.app] to [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.mTzdqv6Q/SkypeForBusinessUpdater-16.29.42.pkg]
Fri  9 Apr 2021 13:11:17 BST | Detected install type as [PKG]
Fri  9 Apr 2021 13:11:17 BST | Waiting for other [/Applications/Skype for Business.app/Contents/MacOS/Skype for Business] processes to end
Fri  9 Apr 2021 13:11:17 BST | No instances of [/Applications/Skype for Business.app/Contents/MacOS/Skype for Business] found, safe to proceed
Fri  9 Apr 2021 13:11:17 BST | Installing Skype for Business
Fri  9 Apr 2021 13:11:17 BST | Waiting for other [installer -pkg] processes to end
Fri  9 Apr 2021 13:11:18 BST | No instances of [installer -pkg] found, safe to proceed
Fri  9 Apr 2021 13:11:18 BST | Waiting for other [cp -Rf] processes to end
Fri  9 Apr 2021 13:11:18 BST | No instances of [cp -Rf] found, safe to proceed
Fri  9 Apr 2021 13:11:18 BST | Waiting for other [unzip] processes to end
Fri  9 Apr 2021 13:11:18 BST | No instances of [unzip] found, safe to proceed
installer: Package name is Skype for Business
installer: Upgrading at base path /
installer: The upgrade was successful.
Fri  9 Apr 2021 13:11:25 BST | Skype for Business Installed
Fri  9 Apr 2021 13:11:25 BST | Cleaning Up
Fri  9 Apr 2021 13:11:25 BST | Application [Skype for Business] succesfully installed
Fri  9 Apr 2021 13:11:26 BST | Writing last modifieddate [Sat, 23 Jan 2021 00:15:16 GMT] to [/Library/Logs/Microsoft/IntuneScripts/installSkypeForBusiness/Skype for Business.meta]
```
