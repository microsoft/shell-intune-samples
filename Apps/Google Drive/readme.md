# Google Drive Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the Company Portal pkg file from the Microsoft download servers and then install it onto the Mac.

## Quick Run

```
sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/Apps/Google%20Drive/installApp3.01-GoogleDrive.sh)"
```

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/installCompanyPortal/Company Portal.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Fri 19 Nov 2021 17:11:39 GMT | Logging install of [Google Drive] to [/Library/Logs/Microsoft/IntuneScripts/GoogleDrive/Google Drive.log]
############################################################

Fri 19 Nov 2021 17:11:39 GMT | Checking if we need Rosetta 2 or not
Fri 19 Nov 2021 17:11:39 GMT | Waiting for other [/usr/sbin/softwareupdate] processes to end
Fri 19 Nov 2021 17:11:39 GMT | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Fri 19 Nov 2021 17:11:39 GMT | [Apple M1] found, is Rosetta already installed?
2021-11-19 17:11:39.607 softwareupdate[79188:1181520] Package Authoring Error: 002-23768: Package reference com.apple.pkg.RosettaUpdateAuto is missing installKBytes attribute
By using the agreetolicense option, you are agreeing that you have run this tool with the license only option and have read and agreed to the terms.
If you do not agree, press CTRL-C and cancel this process immediately.
Install of Rosetta 2 finished successfully
Fri 19 Nov 2021 17:11:41 GMT | Rosetta has been successfully installed.
Fri 19 Nov 2021 17:11:41 GMT | Checking if we need to install or update [Google Drive]
Fri 19 Nov 2021 17:11:41 GMT | [Google Drive] not installed, need to download and install
Fri 19 Nov 2021 17:11:41 GMT | Dock is here, lets carry on
Fri 19 Nov 2021 17:11:41 GMT | Starting downlading of [Google Drive]
Fri 19 Nov 2021 17:11:41 GMT | Waiting for other [curl -f] processes to end
Fri 19 Nov 2021 17:11:41 GMT | No instances of [curl -f] found, safe to proceed
Fri 19 Nov 2021 17:11:41 GMT | Downloading Google Drive
Fri 19 Nov 2021 17:11:49 GMT | Found DMG, looking inside...
Fri 19 Nov 2021 17:11:49 GMT | Mounting Image
Fri 19 Nov 2021 17:12:01 GMT | Detected PKG, setting PackageType to DMGPKG
Fri 19 Nov 2021 17:12:01 GMT | Un-mounting [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.QgnXCkEC/Google Drive]
Fri 19 Nov 2021 17:12:01 GMT | Downloaded [Google Drive.app] to [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.QgnXCkEC/GoogleDrive.dmg]
Fri 19 Nov 2021 17:12:01 GMT | Detected install type as [DMGPKG]
Fri 19 Nov 2021 17:12:01 GMT | Waiting for other [/Applications/Google Drive.app/Contents/MacOS/Google Drive] processes to end
Fri 19 Nov 2021 17:12:01 GMT | No instances of [/Applications/Google Drive.app/Contents/MacOS/Google Drive] found, safe to proceed
Fri 19 Nov 2021 17:12:01 GMT | Installing [Google Drive]
Fri 19 Nov 2021 17:12:01 GMT | Mounting Image
Fri 19 Nov 2021 17:12:02 GMT | Starting installer for [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.QgnXCkEC/Google Drive/GoogleDrive.pkg]
installer: Package name is Google Drive
installer: Upgrading at base path /
installer: The upgrade was successful.
Fri 19 Nov 2021 17:12:16 GMT | Un-mounting [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.QgnXCkEC/Google Drive]
Fri 19 Nov 2021 17:12:16 GMT | [Google Drive] Installed
Fri 19 Nov 2021 17:12:16 GMT | Cleaning Up
Fri 19 Nov 2021 17:12:16 GMT | Fixing up permissions
Fri 19 Nov 2021 17:12:17 GMT | Application [Google Drive] succesfully installed
Fri 19 Nov 2021 17:12:17 GMT | Writing last modifieddate [Mon, 18 Oct 2021 19:07:24 GMT] to [/Library/Logs/Microsoft/IntuneScripts/GoogleDrive/Google Drive.meta]
```
