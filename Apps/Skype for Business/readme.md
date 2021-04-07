# Microsoft Skype for Business Installation Script

This script is am example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the Company Portal pkg file from the Microsoft download servers and then install it onto the Mac.

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
# Wed  7 Apr 2021 12:57:26 BST | Logging install of [Skype for Business] to [/Library/Logs/Microsoft/IntuneScripts/installSkypeForBusiness/Skype for Business.log]
############################################################

Wed  7 Apr 2021 12:57:26 BST | Checking if we need Rosetta 2 or not
Wed  7 Apr 2021 12:57:26 BST | Waiting for other [/usr/sbin/softwareupdate] processes to end
Wed  7 Apr 2021 12:57:26 BST | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Wed  7 Apr 2021 12:57:26 BST | [Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz] found, Rosetta not needed
Wed  7 Apr 2021 12:57:26 BST | Checking if we need to install or update [Skype for Business]
Wed  7 Apr 2021 12:57:26 BST | [Skype for Business] already installed, let's see if we need to update
Wed  7 Apr 2021 12:57:27 BST | Meta file [/Library/Logs/Microsoft/IntuneScripts/installSkypeForBusiness/Skype for Business.meta] not found
Wed  7 Apr 2021 12:57:27 BST | Unable to determine if update required, updating [Skype for Business] anyway
Wed  7 Apr 2021 12:57:27 BST | Starting downlading of [Skype for Business]
Wed  7 Apr 2021 12:57:27 BST | Waiting for other [curl] processes to end
Wed  7 Apr 2021 12:57:27 BST | No instances of [curl] found, safe to proceed
Wed  7 Apr 2021 12:57:27 BST | Downloading Skype for Business
Wed  7 Apr 2021 12:57:33 BST | Downloaded [Skype for Business.app]
Wed  7 Apr 2021 12:57:33 BST | Waiting for other [/Applications/Skype for Business.app/Contents/MacOS/Skype for Business] processes to end
Wed  7 Apr 2021 12:57:33 BST | No instances of [/Applications/Skype for Business.app/Contents/MacOS/Skype for Business] found, safe to proceed
Wed  7 Apr 2021 12:57:33 BST | Installing Skype for Business
Wed  7 Apr 2021 12:57:33 BST | Waiting for other [installer] processes to end
Wed  7 Apr 2021 12:57:33 BST | No instances of [installer] found, safe to proceed
Wed  7 Apr 2021 12:57:33 BST | Waiting for other [cp -Rf] processes to end
Wed  7 Apr 2021 12:57:33 BST | No instances of [cp -Rf] found, safe to proceed
Wed  7 Apr 2021 12:57:33 BST | Waiting for other [unzip] processes to end
Wed  7 Apr 2021 12:57:33 BST | No instances of [unzip] found, safe to proceed
installer: Package name is Skype for Business
installer: Upgrading at base path /
installer: The upgrade was successful.
Wed  7 Apr 2021 12:57:40 BST | Skype for Business Installed
Wed  7 Apr 2021 12:57:40 BST | Cleaning Up
Wed  7 Apr 2021 12:57:40 BST | Application [Skype for Business] succesfully installed
Wed  7 Apr 2021 12:57:41 BST | Writing last modifieddate [Sat, 23 Jan 2021 00:15:16 GMT] to [/Library/Logs/Microsoft/IntuneScripts/installSkypeForBusiness/Skype for Business.meta]
```
