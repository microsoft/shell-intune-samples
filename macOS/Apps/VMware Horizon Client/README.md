# VMware Horizon Client Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the VMware Horizon Client dmg file from VMWare download servers and then install it onto the Mac.

## Scenario

This script is intended for customers who need to deploy Horizon Client via the Intune Scripting Agent.

## Quick Run

```
sudo /bin/bash -c "$(curl -fsSL 'https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/Apps/VMware%20Horizon%20Client/installHorizonClient.sh')"
```

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : Not configured

## Log File

The log file will output to ***/var/log/installHorizonClient.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
Fri Feb 11 13:33:37 CET 2022 | Creating [/Library/Logs/Microsoft/IntuneScripts/installHorizonClient] to store logs

##############################################################
# Fri Feb 11 13:33:37 CET 2022 | Logging install of [VMware Horizon Client] to [/Library/Logs/Microsoft/IntuneScripts/installHorizonClient/VMware Horizon Client.log]
############################################################

Fri Feb 11 13:33:37 CET 2022 | Checking if we need Rosetta 2 or not
Fri Feb 11 13:33:37 CET 2022 | Waiting for other [/usr/sbin/softwareupdate] processes to end
Fri Feb 11 13:33:37 CET 2022 | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Fri Feb 11 13:33:37 CET 2022 | Intel processor installed. No need to install Rosetta.
Fri Feb 11 13:33:37 CET 2022 | Checking if we need to install or update [VMware Horizon Client]
Fri Feb 11 13:33:37 CET 2022 | [VMware Horizon Client] not installed, need to download and install
Fri Feb 11 13:33:37 CET 2022 | Dock is here, lets carry on
Fri Feb 11 13:33:37 CET 2022 | Starting downlading of [VMware Horizon Client]
Fri Feb 11 13:33:37 CET 2022 | Waiting for other [curl -f] processes to end
Fri Feb 11 13:33:38 CET 2022 | No instances of [curl -f] found, safe to proceed
Fri Feb 11 13:33:38 CET 2022 | Downloading VMware Horizon Client
Fri Feb 11 13:33:39 CET 2022 | Downloaded [VMware Horizon Client.app] to [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.LOFfS2KH/VMware-Horizon-Client-2111-8.4.0-18968281.dmg]
Fri Feb 11 13:33:46 CET 2022 | Detected install type as [DMG]
Fri Feb 11 13:33:46 CET 2022 | Waiting for other [/Applications/VMware Horizon Client.app/Contents/MacOS/vmware-view] processes to end
Fri Feb 11 13:33:46 CET 2022 | No instances of [/Applications/VMware Horizon Client.app/Contents/MacOS/vmware-view] found, safe to proceed
Fri Feb 11 13:33:46 CET 2022 | Installing [VMware Horizon Client]
Fri Feb 11 13:33:46 CET 2022 | Mounting Image
Fri Feb 11 13:33:50 CET 2022 | Copying app files to /Applications/VMware Horizon Client.app
Fri Feb 11 13:33:57 CET 2022 | Un-mounting [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.LOFfS2KH/VMware Horizon Client]
Fri Feb 11 13:33:58 CET 2022 | [VMware Horizon Client] Installed
Fri Feb 11 13:33:58 CET 2022 | Cleaning Up
Fri Feb 11 13:33:58 CET 2022 | Fixing up permissions
Fri Feb 11 13:33:58 CET 2022 | Application [VMware Horizon Client] succesfully installed
Fri Feb 11 13:33:58 CET 2022 | Writing last modifieddate [Thu, 25 Nov 2021 09:07:06 GMT] to [/Library/Logs/Microsoft/IntuneScripts/installHorizonClient/VMware Horizon Client.meta]
```
