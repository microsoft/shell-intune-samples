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

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/installRemoteDesktop/Remote_Desktop.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Fri 26 Mar 2021 15:02:36 GMT | Starting install of Remote_Desktop
############################################################

Fri 26 Mar 2021 15:02:36 GMT | Downloading Remote_Desktop
Fri 26 Mar 2021 15:02:42 GMT | Downloaded https://neiljohn.blob.core.windows.net/macapps/MicrosoftRemoteDesktop.pkg to /tmp/remotedesktop.pkg
Fri 26 Mar 2021 15:02:42 GMT | Microsoft Remote Desktop.app isn't running, lets carry on
Fri 26 Mar 2021 15:02:42 GMT | Installing Remote_Desktop
Fri 26 Mar 2021 15:02:42 GMT | Installer not running, safe to start installing
Mar 26 15:02:42  installer[52907] <Debug>: JS: mau path: /Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app
Mar 26 15:02:42  installer[52907] <Debug>: JS: installing mau version: 4.25.20071300
Mar 26 15:02:42  installer[52907] <Debug>: JS: mau already installed, version: 4.33.21031401
Mar 26 15:02:42  installer[52907] <Debug>: JS: compareVersions result: false
Mar 26 15:02:42  installer[52907] <Debug>: JS: installed version 4.33.21031401, is newer than 4.25.20071300. not installing mau
Mar 26 15:02:42  installer[52907] <Debug>: JS: mau path: /Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app
Mar 26 15:02:42  installer[52907] <Debug>: JS: installing mau version: 4.25.20071300
Mar 26 15:02:42  installer[52907] <Debug>: JS: mau already installed, version: 4.33.21031401
Mar 26 15:02:42  installer[52907] <Debug>: JS: compareVersions result: false
Mar 26 15:02:42  installer[52907] <Debug>: JS: installed version 4.33.21031401, is newer than 4.25.20071300. not installing mau
Mar 26 15:02:42  installer[52907] <Debug>: Product archive /tmp/remotedesktop.pkg trustLevel=350
Mar 26 15:02:43  installer[52907] <Debug>: External component packages (2) trustLevel=350
Mar 26 15:02:43  installer[52907] <Debug>: -[IFDInstallController(Private) _buildInstallPlanReturningError:]: location = file://localhost
Mar 26 15:02:43  installer[52907] <Debug>: -[IFDInstallController(Private) _buildInstallPlanReturningError:]: file://localhost/tmp/remotedesktop.pkg#com.microsoft.rdc.macos.pkg
Mar 26 15:02:43  installer[52907] <Debug>: -[IFDInstallController(Private) _buildInstallPlanReturningError:]: file://localhost/tmp/remotedesktop.pkg#scripts.pkg
Mar 26 15:02:43  installer[52907] <Debug>: Set authorization level to root for session
Mar 26 15:02:43  installer[52907] <Info>: Administrator authorization granted.
Mar 26 15:02:43  installer[52907] <Debug>: Set authorization level to root for session
Mar 26 15:02:43  installer[52907] <Debug>: Will use PK session
Mar 26 15:02:43  installer[52907] <Debug>: Using authorization level of root for IFPKInstallElement
Mar 26 15:02:43  installer[52907] <Info>: Starting installation:
Mar 26 15:02:43  installer[52907] <Notice>: Configuring volume "OSX"
Mar 26 15:02:43  installer[52907] <Info>: Preparing disk for local booted install.
Mar 26 15:02:43  installer[52907] <Notice>: Free space on "OSX": 90.56 GB (90559672320 bytes).
Mar 26 15:02:43  installer[52907] <Notice>: Create temporary directory "/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T//Install.52907icjpF7"
Mar 26 15:02:43  installer[52907] <Notice>: IFPKInstallElement (2 packages)
Mar 26 15:02:43  installer[52907] <Info>: Current Path: /usr/sbin/installer
Mar 26 15:02:43  installer[52907] <Info>: Current Path: /bin/bash
Mar 26 15:02:43  installer[52907] <Info>: Current Path: /usr/bin/sudo
Mar 26 15:02:43  installer[52907] <Notice>: PackageKit: Enqueuing install with framework-specified quality of service (utility)
Mar 26 15:02:44  installer[52907] <Info>: PackageKit: Registered bundle file:///Applications/Microsoft%20Remote%20Desktop.app/ for uid 0
Mar 26 15:02:45  installer[52907] <Notice>: Running install actions
Mar 26 15:02:45  installer[52907] <Notice>: Removing temporary directory "/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T//Install.52907icjpF7"
Mar 26 15:02:45  installer[52907] <Notice>: Finalize disk "OSX"
Mar 26 15:02:45  installer[52907] <Notice>: Notifying system of updated components
Mar 26 15:02:45  installer[52907] <Notice>: 
Mar 26 15:02:45  installer[52907] <Notice>: **** Summary Information ****
Mar 26 15:02:45  installer[52907] <Notice>:   Operation      Elapsed time
Mar 26 15:02:45  installer[52907] <Notice>: -----------------------------
Mar 26 15:02:45  installer[52907] <Notice>:        disk      0.02 seconds
Mar 26 15:02:45  installer[52907] <Notice>:      script      0.00 seconds
Mar 26 15:02:45  installer[52907] <Notice>:        zero      0.00 seconds
Mar 26 15:02:45  installer[52907] <Notice>:     install      2.40 seconds
Mar 26 15:02:45  installer[52907] <Notice>:     -total-      2.43 seconds
Mar 26 15:02:45  installer[52907] <Notice>: 
installer: Package name is Microsoft Remote Desktop v10.5.2
installer: Upgrading at base path /
installer: The upgrade was successful.
Fri 26 Mar 2021 15:02:45 GMT | Remote_Desktop Installed
Fri 26 Mar 2021 15:02:45 GMT | Cleaning Up
Fri 26 Mar 2021 15:02:45 GMT | Writing last modifieddate Fri, 26 Mar 2021 14:43:35 GMT to /Library/Logs/Microsoft/IntuneScripts/installRemoteDesktop/Remote_Desktop.meta
Fri 26 Mar 2021 15:02:45 GMT | Fixing up permissions
Fri 26 Mar 2021 15:02:45 GMT | Application [Remote_Desktop] succesfully installed
```
