# Intune Company Portal Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the Company Portal pkg file from the Microsoft download servers and then install it onto the Mac.

## Scenario

This script has a few scenarios

- DEP/ADE enrolled Macs that need to complete their device registration for conditional access. In this scenario the script should be deployed [via Intune]((https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts)).

- Provide end users with a quick and easy way to get started with their Mac enrollment. In this scenario the end users should be provided with the following to copy and paste into Terminal on their Mac.
```
sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/Apps/Company%20Portal/installCompanyPortal.sh)" ; open "/Applications/Company Portal.app"
```

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3

### Log File

The log file will output to ***/var/log/installcp.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Fri 14 Aug 2020 12:39:54 BST | Starting install of Intune Company Portal
############################################################

Fri 14 Aug 2020 12:39:54 BST | Downloading Intune Company Portal
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 18.5M  100 18.5M    0     0  5324k      0  0:00:03  0:00:03 --:--:-- 5842k
Fri 14 Aug 2020 12:39:57 BST | Installing Intune Company Portal
Aug 14 12:40:00  installer[28841] <Debug>: Product archive /tmp/cp.pkg trustLevel=350
Aug 14 12:40:00  installer[28841] <Debug>: External component packages (2) trustLevel=350
Aug 14 12:40:00  installer[28841] <Debug>: -[IFDInstallController(Private) _buildInstallPlanReturningError:]: location = file://localhost
Aug 14 12:40:00  installer[28841] <Debug>: -[IFDInstallController(Private) _buildInstallPlanReturningError:]: file://localhost/tmp/cp.pkg#Office16_autoupdate_updater.pkg
Aug 14 12:40:00  installer[28841] <Debug>: -[IFDInstallController(Private) _buildInstallPlanReturningError:]: file://localhost/tmp/cp.pkg#CompanyPortal-Component.pkg
Aug 14 12:40:00  installer[28841] <Debug>: Set authorization level to root for session
Aug 14 12:40:00  installer[28841] <Info>: Administrator authorization granted.
Aug 14 12:40:00  installer[28841] <Debug>: Will use PK session
Aug 14 12:40:00  installer[28841] <Debug>: Using authorization level of root for IFPKInstallElement
Aug 14 12:40:00  installer[28841] <Info>: PackageKit: Skipping component "com.microsoft.autoupdate2" (4.20.0-4.20.20021103-*) because the version 4.26.0-4.26.20081000-* is already installed at /Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app.
Aug 14 12:40:00  installer[28841] <Info>: PackageKit: Skipping component "com.microsoft.CompanyPortalMac" (2.7.200700-52.2007010.0-*) because the version 2.8.200800-52.2008057.0-* is already installed at /Applications/Company Portal.app.
Aug 14 12:40:00  installer[28841] <Info>: Starting installation:
Aug 14 12:40:00  installer[28841] <Notice>: Configuring volume "OS X"
Aug 14 12:40:00  installer[28841] <Info>: Preparing disk for local booted install.
Aug 14 12:40:00  installer[28841] <Notice>: Free space on "OS X": 583.44 GB (583443931136 bytes).
Aug 14 12:40:00  installer[28841] <Notice>: Create temporary directory "/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T//Install.28841unCkZL"
Aug 14 12:40:00  installer[28841] <Notice>: IFPKInstallElement (2 packages)
Aug 14 12:40:00  installer[28841] <Info>: Current Path: /usr/sbin/installer
Aug 14 12:40:00  installer[28841] <Info>: Current Path: /bin/bash
Aug 14 12:40:00  installer[28841] <Info>: Current Path: /usr/bin/sudo
Aug 14 12:40:00  installer[28841] <Notice>: PackageKit: Enqueuing install with framework-specified quality of service (utility)
Aug 14 12:40:14  installer[28841] <Notice>: Running install actions
Aug 14 12:40:14  installer[28841] <Notice>: Removing temporary directory "/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T//Install.28841unCkZL"
Aug 14 12:40:14  installer[28841] <Notice>: Finalize disk "OS X"
Aug 14 12:40:14  installer[28841] <Notice>: Notifying system of updated components
Aug 14 12:40:14  installer[28841] <Notice>:
Aug 14 12:40:14  installer[28841] <Notice>: **** Summary Information ****
Aug 14 12:40:14  installer[28841] <Notice>:   Operation      Elapsed time
Aug 14 12:40:14  installer[28841] <Notice>: -----------------------------
Aug 14 12:40:14  installer[28841] <Notice>:        disk      0.02 seconds
Aug 14 12:40:14  installer[28841] <Notice>:      script      0.00 seconds
Aug 14 12:40:14  installer[28841] <Notice>:        zero      0.00 seconds
Aug 14 12:40:14  installer[28841] <Notice>:     install      14.37 seconds
Aug 14 12:40:14  installer[28841] <Notice>:     -total-      14.39 seconds
Aug 14 12:40:14  installer[28841] <Notice>:
installer: Package name is Intune Company Portal
installer: Upgrading at base path /
installer: The upgrade was successful.
Fri 14 Aug 2020 12:40:14 BST | Intune Company Portal Installed
Fri 14 Aug 2020 12:40:14 BST | Cleaning Up
```
