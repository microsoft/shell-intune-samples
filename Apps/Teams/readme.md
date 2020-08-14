# Microsoft Teams Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the Teams pkg file from the Microsoft download servers and then install it onto the Mac.

## Scenario

This script is intended for customers who need to deploy Teams via the Intune Scripting Agent.

## Quick Run

```
sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/Apps/Teams/installTeams.sh)"
```

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/var/log/installteams.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Wed Aug  5 12:13:32 PDT 2020 | Starting install of Microsoft Teams
############################################################

Wed Aug  5 12:13:32 PDT 2020 | Downloading Microsoft Teams
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  0     0    0     0    0     0      0      0 --:--:--  0:00:01 --:--:--     0
100   195  100   195    0     0    124      0  0:00:01  0:00:01 --:--:--   124
100 78.6M  100 78.6M    0     0   945k      0  0:01:25  0:01:25 --:--:-- 1240k
Wed Aug  5 20:14:57 BST 2020 | Installing Microsoft Teams
Aug  5 20:14:58  installer[3635] <Debug>: Product archive /tmp/teams.pkg trustLevel=350
Aug  5 20:14:58  installer[3635] <Debug>: External component packages (1) trustLevel=350
Aug  5 20:14:58  installer[3635] <Debug>: -[IFDInstallController(Private) _buildInstallPlanReturningError:]: location = file://localhost
Aug  5 20:14:58  installer[3635] <Debug>: -[IFDInstallController(Private) _buildInstallPlanReturningError:]: file://localhost/tmp/teams.pkg#Teams_osx_app.pkg
Aug  5 20:14:58  installer[3635] <Debug>: Set authorization level to root for session
Aug  5 20:14:58  installer[3635] <Info>: Administrator authorization granted.
Aug  5 20:14:58  installer[3635] <Debug>: Will use PK session
Aug  5 20:14:58  installer[3635] <Debug>: Using authorization level of root for IFPKInstallElement
Aug  5 20:14:59  installer[3635] <Info>: Starting installation:
Aug  5 20:14:59  installer[3635] <Notice>: Configuring volume "Macintosh HD"
Aug  5 20:14:59  installer[3635] <Info>: Preparing disk for local booted install.
Aug  5 20:14:59  installer[3635] <Notice>: Free space on "Macintosh HD": 18.96 GB (18955206656 bytes).
Aug  5 20:14:59  installer[3635] <Notice>: Create temporary directory "/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T//Install.3635YuKCH8"
Aug  5 20:14:59  installer[3635] <Notice>: IFPKInstallElement (1 packages)
Aug  5 20:14:59  installer[3635] <Info>: Current Path: /usr/sbin/installer
Aug  5 20:14:59  installer[3635] <Info>: Current Path: /bin/bash
Aug  5 20:14:59  installer[3635] <Info>: Current Path: /Library/Intune/Microsoft Intune Agent.app/Contents/MacOS/IntuneMdmDaemon
Aug  5 20:14:59  installer[3635] <Notice>: PackageKit: Enqueuing install with framework-specified quality of service (utility)
Aug  5 20:15:12  installer[3635] <Info>: PackageKit: Registered bundle file:///Applications/Microsoft%20Teams.app/ for uid 0
Aug  5 20:15:12  installer[3635] <Info>: PackageKit: Registered bundle file:///Applications/Microsoft%20Teams.app/Contents/Frameworks/Microsoft%20Teams%20Helper.app/ for uid 0
Aug  5 20:15:12  installer[3635] <Notice>: Running install actions
Aug  5 20:15:12  installer[3635] <Notice>: Removing temporary directory "/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T//Install.3635YuKCH8"
Aug  5 20:15:12  installer[3635] <Notice>: Finalize disk "Macintosh HD"
Aug  5 20:15:12  installer[3635] <Notice>: Notifying system of updated components
Aug  5 20:15:12  installer[3635] <Notice>:
Aug  5 20:15:12  installer[3635] <Notice>: **** Summary Information ****
Aug  5 20:15:12  installer[3635] <Notice>:   Operation      Elapsed time
Aug  5 20:15:12  installer[3635] <Notice>: -----------------------------
Aug  5 20:15:12  installer[3635] <Notice>:        disk      0.03 seconds
Aug  5 20:15:12  installer[3635] <Notice>:      script      0.00 seconds
Aug  5 20:15:12  installer[3635] <Notice>:        zero      0.09 seconds
Aug  5 20:15:12  installer[3635] <Notice>:     install      13.46 seconds
Aug  5 20:15:12  installer[3635] <Notice>:     -total-      13.57 seconds
Aug  5 20:15:12  installer[3635] <Notice>:
installer: Package name is Microsoft Teams
installer: Installing at base path /
installer: The install was successful.
Wed Aug  5 20:15:12 BST 2020 | Microsoft Teams Installed
Wed Aug  5 20:15:12 BST 2020 | Cleaning Up
```
