# Microsoft Remote Desktop Installation Script

This script is am example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the Microsoft Remote Desktop app from the Microsoft download servers and then install it onto the Mac.

## Scenario

This scripts intended usage scenario is for customers who wish to use a shell script to deploy the Microsoft Remote Desktop app.


## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/var/log/remotedesktop.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Wed Aug  5 12:13:31 PDT 2020 | Starting install of Microsoft Remote Desktop
############################################################

Wed Aug  5 12:13:31 PDT 2020 | Downloading Microsoft Remote Desktop
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 26.0M  100 26.0M    0     0   739k      0  0:00:36  0:00:36 --:--:--  777k
Wed Aug  5 20:14:07 BST 2020 | Installing Microsoft Remote Desktop
Aug  5 20:14:08  installer[3503] <Debug>: JS: mau path: /Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app
Aug  5 20:14:08  installer[3503] <Debug>: JS: installing mau version: 4.25.20071300
Aug  5 20:14:08  installer[3503] <Debug>: JS: mau already installed, version: 4.25.20071300
Aug  5 20:14:08  installer[3503] <Debug>: JS: compareVersions result: false
Aug  5 20:14:08  installer[3503] <Debug>: JS: installed version 4.25.20071300, is newer than 4.25.20071300. not installing mau
Aug  5 20:14:08  installer[3503] <Debug>: JS: mau path: /Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app
Aug  5 20:14:08  installer[3503] <Debug>: JS: installing mau version: 4.25.20071300
Aug  5 20:14:08  installer[3503] <Debug>: JS: mau already installed, version: 4.25.20071300
Aug  5 20:14:08  installer[3503] <Debug>: JS: compareVersions result: false
Aug  5 20:14:08  installer[3503] <Debug>: JS: installed version 4.25.20071300, is newer than 4.25.20071300. not installing mau
Aug  5 20:14:09  installer[3503] <Debug>: Product archive /tmp/remotedesktop.pkg trustLevel=350
Aug  5 20:14:09  installer[3503] <Debug>: External component packages (2) trustLevel=350
Aug  5 20:14:09  installer[3503] <Debug>: -[IFDInstallController(Private) _buildInstallPlanReturningError:]: location = file://localhost
Aug  5 20:14:09  installer[3503] <Debug>: -[IFDInstallController(Private) _buildInstallPlanReturningError:]: file://localhost/tmp/remotedesktop.pkg#com.microsoft.rdc.macos.pkg
Aug  5 20:14:09  installer[3503] <Debug>: -[IFDInstallController(Private) _buildInstallPlanReturningError:]: file://localhost/tmp/remotedesktop.pkg#scripts.pkg
Aug  5 20:14:09  installer[3503] <Debug>: Set authorization level to root for session
Aug  5 20:14:09  installer[3503] <Info>: Administrator authorization granted.
Aug  5 20:14:09  installer[3503] <Debug>: Will use PK session
Aug  5 20:14:09  installer[3503] <Debug>: Using authorization level of root for IFPKInstallElement
Aug  5 20:14:09  installer[3503] <Info>: Starting installation:
Aug  5 20:14:09  installer[3503] <Notice>: Configuring volume "Macintosh HD"
Aug  5 20:14:09  installer[3503] <Info>: Preparing disk for local booted install.
Aug  5 20:14:09  installer[3503] <Notice>: Free space on "Macintosh HD": 19.42 GB (19415412736 bytes).
Aug  5 20:14:09  installer[3503] <Notice>: Create temporary directory "/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T//Install.3503hvw9qx"
Aug  5 20:14:09  installer[3503] <Notice>: IFPKInstallElement (2 packages)
Aug  5 20:14:10  installer[3503] <Info>: Current Path: /usr/sbin/installer
Aug  5 20:14:10  installer[3503] <Info>: Current Path: /bin/bash
Aug  5 20:14:10  installer[3503] <Info>: Current Path: /Library/Intune/Microsoft Intune Agent.app/Contents/MacOS/IntuneMdmDaemon
Aug  5 20:14:10  installer[3503] <Notice>: PackageKit: Enqueuing install with framework-specified quality of service (utility)
Aug  5 20:14:16  installer[3503] <Info>: PackageKit: Registered bundle file:///Applications/Microsoft%20Remote%20Desktop.app/ for uid 0
Aug  5 20:14:17  installer[3503] <Notice>: Running install actions
Aug  5 20:14:17  installer[3503] <Notice>: Removing temporary directory "/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T//Install.3503hvw9qx"
Aug  5 20:14:17  installer[3503] <Notice>: Finalize disk "Macintosh HD"
Aug  5 20:14:17  installer[3503] <Notice>: Notifying system of updated components
Aug  5 20:14:17  installer[3503] <Notice>:
Aug  5 20:14:17  installer[3503] <Notice>: **** Summary Information ****
Aug  5 20:14:17  installer[3503] <Notice>:   Operation      Elapsed time
Aug  5 20:14:17  installer[3503] <Notice>: -----------------------------
Aug  5 20:14:17  installer[3503] <Notice>:        disk      0.02 seconds
Aug  5 20:14:17  installer[3503] <Notice>:      script      0.00 seconds
Aug  5 20:14:17  installer[3503] <Notice>:        zero      0.07 seconds
Aug  5 20:14:17  installer[3503] <Notice>:     install      7.12 seconds
Aug  5 20:14:17  installer[3503] <Notice>:     -total-      7.21 seconds
Aug  5 20:14:17  installer[3503] <Notice>:
installer: Package name is Microsoft Remote Desktop v10.4.0
installer: Installing at base path /
installer: The install was successful.
Wed Aug  5 20:14:17 BST 2020 | Microsoft Remote Desktop Installed
Wed Aug  5 20:14:17 BST 2020 | Cleaning Up
```
