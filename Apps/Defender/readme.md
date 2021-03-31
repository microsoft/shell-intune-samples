# Microsoft Defender Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download Defender from the Microsoft download servers and then install it onto the Mac.

## Quick Run

```
sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/Apps/Company%20Portal/installCompanyPortal.sh)" ; open "/Applications/Company Portal.app"
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
# Wed 31 Mar 2021 05:53:50 PDT | Starting install of Defender
############################################################

Wed 31 Mar 2021 05:53:50 PDT | Checking if we need Rosetta 2 or not
Wed 31 Mar 2021 05:53:50 PDT | Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz processor detected, no need to install Rosetta.
Wed 31 Mar 2021 05:53:50 PDT | No instances of Curl found, safe to proceed
Wed 31 Mar 2021 05:53:50 PDT | Downloading Defender
Wed 31 Mar 2021 05:54:46 PDT | Downloaded https://go.microsoft.com/fwlink/?linkid=2097502 to /tmp/defender.pkg
Wed 31 Mar 2021 05:54:46 PDT | Microsoft Defender ATP.app isn't running, lets carry on
Wed 31 Mar 2021 05:54:47 PDT | No instances of Curl found, safe to proceed
Wed 31 Mar 2021 05:54:47 PDT | Installer not running, safe to start installing
Wed 31 Mar 2021 05:54:47 PDT | Installing Defender
installer: Package name is Microsoft Defender ATP
installer: Upgrading at base path /
installer: The upgrade was successful.
Wed 31 Mar 2021 05:55:34 PDT | Defender Installed
Wed 31 Mar 2021 05:55:34 PDT | Cleaning Up
Wed 31 Mar 2021 05:55:34 PDT | Writing last modifieddate Tue, 02 Mar 2021 10:22:11 GMT to /Library/Logs/Microsoft/IntuneScripts/installDefender/Defender.meta
Wed 31 Mar 2021 05:55:34 PDT | Fixing up permissions
Wed 31 Mar 2021 05:55:34 PDT | Application [Defender] succesfully installed
```