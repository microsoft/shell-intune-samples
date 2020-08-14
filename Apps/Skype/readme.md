# Microsoft Skype for Business Installation Script

This script is am example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the Company Portal pkg file from the Microsoft download servers and then install it onto the Mac.

## Scenario

This scripts intended usage scenario is for DEP/ADE enrolled Macs that need to complete their device registration for conditional access.

## Quick Run

```
sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/Apps/Skype/installSkype.sh)"
```

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/var/log/installskype.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Fri 14 Aug 2020 13:01:43 BST | Starting install of Skype
############################################################

Fri 14 Aug 2020 13:01:43 BST | Downloading Skype
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 35.1M  100 35.1M    0     0  5208k      0  0:00:06  0:00:06 --:--:-- 6112k
Fri 14 Aug 2020 13:01:50 BST | Installing Skype
installer: Package name is Skype for Business
Aug 14 13:01:51  installer[727] <Debug>: Product archive /tmp/skype.pkg trustLevel=350
Aug 14 13:01:51  installer[727] <Debug>: External component packages (1) trustLevel=350
installer: Upgrading at base path /
Aug 14 13:01:51  installer[727] <Debug>: -[IFDInstallController(Private) _buildInstallPlanReturningError:]: location = file://localhost
Aug 14 13:01:51  installer[727] <Debug>: -[IFDInstallController(Private) _buildInstallPlanReturningError:]: file://localhost/tmp/skype.pkg#SkypeForBusiness.pkg
Aug 14 13:01:51  installer[727] <Debug>: -[IFDInstallController(Private) _buildInstallPlanReturningError:]: file://localhost/tmp/skype.pkg#Office16_all_autoupdate_bootstrapper_updater.pkg
Aug 14 13:01:51  installer[727] <Debug>: Set authorization level to root for session
Aug 14 13:01:51  installer[727] <Info>: Administrator authorization granted.
Aug 14 13:01:51  installer[727] <Debug>: Will use PK session
Aug 14 13:01:51  installer[727] <Debug>: Using authorization level of root for IFPKInstallElement
Aug 14 13:01:52  installer[727] <Info>: Starting installation:
Aug 14 13:01:52  installer[727] <Notice>: Configuring volume "Macintosh HD"
Aug 14 13:01:52  installer[727] <Info>: Preparing disk for local booted install.
Aug 14 13:01:52  installer[727] <Notice>: Free space on "Macintosh HD": 10.52 GB (10518274048 bytes).
Aug 14 13:01:52  installer[727] <Notice>: Create temporary directory "/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T//Install.727lhkPGD"
Aug 14 13:01:52  installer[727] <Notice>: IFPKInstallElement (2 packages)
Aug 14 13:01:52  installer[727] <Info>: Current Path: /usr/sbin/installer
Aug 14 13:01:52  installer[727] <Info>: Current Path: /bin/bash
Aug 14 13:01:52  installer[727] <Info>: Current Path: /usr/bin/sudo
Aug 14 13:01:53  installer[727] <Notice>: PackageKit: Enqueuing install with framework-specified quality of service (utility)
Aug 14 13:02:12  installer[727] <Info>: Error getting application status info for file:///Library/Application%20Support/Microsoft/MAU2.0/bootstrapper/Microsoft%20AU%20Bootstrapper.app: Error Domain=NSCocoaErrorDomain Code=260 "The file “Microsoft AU Bootstrapper.app” couldn’t be opened because there is no such file." UserInfo={NSURL=file:///Library/Application%20Support/Microsoft/MAU2.0/bootstrapper/Microsoft%20AU%20Bootstrapper.app, NSFilePath=/Library/Application Support/Microsoft/MAU2.0/bootstrapper/Microsoft AU Bootstrapper.app, NSUnderlyingError=0x7f9a1c454550 {Error Domain=NSPOSIXErrorDomain Code=2 "No such file or directory"}}
Aug 14 13:02:13  installer[727] <Notice>: Running install actions
Aug 14 13:02:13  installer[727] <Notice>: Removing temporary directory "/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T//Install.727lhkPGD"
Aug 14 13:02:13  installer[727] <Notice>: Finalize disk "Macintosh HD"
Aug 14 13:02:13  installer[727] <Notice>: Notifying system of updated components
Aug 14 13:02:13  installer[727] <Notice>:
Aug 14 13:02:13  installer[727] <Notice>: **** Summary Information ****
Aug 14 13:02:13  installer[727] <Notice>:   Operation      Elapsed time
Aug 14 13:02:13  installer[727] <Notice>: -----------------------------
Aug 14 13:02:13  installer[727] <Notice>:        disk      0.03 seconds
Aug 14 13:02:13  installer[727] <Notice>:      script      0.00 seconds
Aug 14 13:02:13  installer[727] <Notice>:        zero      0.00 seconds
Aug 14 13:02:13  installer[727] <Notice>:     install      20.90 seconds
Aug 14 13:02:13  installer[727] <Notice>:     -total-      20.94 seconds
Aug 14 13:02:13  installer[727] <Notice>:
installer: The upgrade was successful.
Fri 14 Aug 2020 13:02:13 BST | Skype Installed
Fri 14 Aug 2020 13:02:13 BST | Cleaning Up
```
