# Cisco AMP for Endpoints Mac Connector Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download Cisco AMP for Endpoints Mac Connector from secure Azure Blob Storage servers and then install it onto the Mac.

## Custom Config

As Cisco documents [here](https://www.cisco.com/c/en/us/support/docs/security/amp-endpoints/216089-advisory-for-amp-for-endpoints-mac-conne.html), the AMP Endpoint Connect requires certain permissions before it will work correctly.

The file Cisco AMP Config.mobileconfig is an Intune macOS custom configuration profile that will pre-configure your Mac to allow the AMP connector to launch and run correctly.

For more information on deploying these files, see the following: [Use custom settings for macOS devices in Microsoft Intune](https://docs.microsoft.com/en-us/mem/intune/configuration/custom-settings-macos).

Note: If you assign the script and custom profile to the same group of users, the profile will always be installed before the application due to the time taken to download the binary and run through the installation.

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/CiscoAMP/Cisco AMP.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
Fri 30 Jul 2021 13:37:33 BST | Creating [/Library/Logs/Microsoft/IntuneScripts/CiscoAMP] to store logs

##############################################################
# Fri 30 Jul 2021 13:37:33 BST | Logging install of [Cisco AMP] to [/Library/Logs/Microsoft/IntuneScripts/CiscoAMP/Cisco AMP.log]
############################################################

Fri 30 Jul 2021 13:37:33 BST | Checking if we need Rosetta 2 or not
Fri 30 Jul 2021 13:37:33 BST | Waiting for other [/usr/sbin/softwareupdate] processes to end
Fri 30 Jul 2021 13:37:33 BST | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Fri 30 Jul 2021 13:37:33 BST | [Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz] found, Rosetta not needed
Fri 30 Jul 2021 13:37:33 BST | Dock is here, lets carry on
Fri 30 Jul 2021 13:37:33 BST | Starting downlading of [Cisco AMP]
Fri 30 Jul 2021 13:37:33 BST | Waiting for other [curl -f] processes to end
Fri 30 Jul 2021 13:37:33 BST | No instances of [curl -f] found, safe to proceed
Fri 30 Jul 2021 13:37:33 BST | Downloading Cisco AMP
Fri 30 Jul 2021 13:37:39 BST | Unknown file type [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.TkSNLbUh/cisco_amp.dmg?sp=r&st=2021-07-30T08:48:03Z&se=2099-07-30T16:48:03Z&spr=https&sv=2020-08-04&sr=b&sig=1J%2BajhmmTcZ7QCp3KR0rsfYhWIDITbbGJ4PBbSvt57E%3D], analysing metadata
Fri 30 Jul 2021 13:37:39 BST | Downloaded [Cisco AMP for Endpoints.app] to [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.TkSNLbUh/install.dmg]
Fri 30 Jul 2021 13:37:39 BST | Detected install type as [DMG]
Fri 30 Jul 2021 13:37:39 BST | Mounting Image
installer: Package name is AMP for Endpoints Connector v1.15.5.837
installer: Installing at base path /
installer: The install was successful.
Fri 30 Jul 2021 13:37:55 BST | Un-mounting [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.TkSNLbUh/Cisco AMP]
```
