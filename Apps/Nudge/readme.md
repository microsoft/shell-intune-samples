# Nudge Installation

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the Nudge Suite pkg file from their download servers and then install it onto the Mac.

# What is Nudge?

[Nudge](https://github.com/macadmins/nudge) is an open source tool for encouraging your end users to install macOS updates. It provides rich configuration potential and is simple to deploy. This is an example of how to get it up and running with Intune.

This sample provides two items.

1. Installation script for the Nudge Suite package that includes the Logger LaunchDaemon, Nudge 30 minute LaunchAgent and Nudge.app
2. Nudge (12.x).mobileconfig

The installation scripts both do exactly the same thing. Both are provided currently as I move the repo over to ZSH. If you have no preference, use the ZSH version. You need to deploy the script to your test users as described in the [Intune documentation](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts).

The mobileconfig file is an Intune Custom configuration policy that contains some configuration parameters for Nudge to use. For this sample, we are just working with macOS 12.x and encouraging all of our users to install 12.4 by the 1st October 2022. You'll need to edit the mobilecofig for your own requirements. There is a [nudge wiki](https://github.com/macadmins/nudge/wiki) available, plus [iMazing Profile Editor](https://imazing.com/profile-editor) has a built-in profile editor for Nudge too.

Once you've configured the mobileconfig file according to your needs, deploy it to your test users according to our [Use custom settings for macOS devices in Microsoft Intune](https://docs.microsoft.com/en-us/mem/intune/configuration/custom-settings-macos) documentation.

```
<dict>
    <key>aboutUpdateURLs</key>
    <array/>
    <key>majorUpgradeAppPath</key>
    <string>/Applications/Install macOS Monterey.app</string>
    <key>requiredInstallationDate</key>
    <string>2022-10-1T00:00:00Z</string>
    <key>requiredMinimumOSVersion</key>
    <string>12.4</string>
    <key>targetedOSVersions</key>
    <array/>
</dict>
</array>
```

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3




## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/Python3.9/Python3.9.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Wed 23 Feb 2022 15:07:35 GMT | Logging install of [Python3.9] to [/Library/Logs/Microsoft/IntuneScripts/Python3.9/Python3.9.log]
############################################################

Wed 23 Feb 2022 15:07:35 GMT | Checking if we need Rosetta 2 or not
Wed 23 Feb 2022 15:07:35 GMT | Waiting for other [/usr/sbin/softwareupdate] processes to end
Wed 23 Feb 2022 15:07:35 GMT | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Wed 23 Feb 2022 15:07:35 GMT | Rosetta is already installed and running. Nothing to do.
Wed 23 Feb 2022 15:07:35 GMT | Checking if we need to install or update [Python3.9]
Wed 23 Feb 2022 15:07:35 GMT | [Python3.9] not installed, need to download and install
Wed 23 Feb 2022 15:07:35 GMT | Dock is here, lets carry on
Wed 23 Feb 2022 15:07:35 GMT | Starting downlading of [Python3.9]
Wed 23 Feb 2022 15:07:35 GMT | Waiting for other [curl -f] processes to end
Wed 23 Feb 2022 15:07:35 GMT | No instances of [curl -f] found, safe to proceed
Wed 23 Feb 2022 15:07:35 GMT | Downloading Python3.9 [https://www.python.org/ftp/python/3.9.10/python-3.9.10-macos11.pkg]
Wed 23 Feb 2022 15:07:36 GMT | Downloaded [/Python 3.9/IDLE.app ] to [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.Y6bDWQkJ/python-3.9.10-macos11.pkg]
Wed 23 Feb 2022 15:07:36 GMT | Detected install type as [PKG]
Wed 23 Feb 2022 15:07:36 GMT | Waiting for other [/Applications/Python 3.9/IDLE.app/Contents/MacOS/IDLE ] processes to end
Wed 23 Feb 2022 15:07:36 GMT | No instances of [/Applications/Python 3.9/IDLE.app/Contents/MacOS/IDLE ] found, safe to proceed
Wed 23 Feb 2022 15:07:36 GMT | Installing Python3.9
installer: Package name is Python
installer: Upgrading at base path /
installer: The upgrade was successful.
Wed 23 Feb 2022 15:08:07 GMT | Python3.9 Installed
Wed 23 Feb 2022 15:08:07 GMT | Cleaning Up
Wed 23 Feb 2022 15:08:07 GMT | Application [Python3.9] succesfully installed
Wed 23 Feb 2022 15:08:07 GMT | Writing last modifieddate [Thu, 13 Jan 2022 22:13:41 GMT] to [/Library/Logs/Microsoft/IntuneScripts/Python3.9/Python3.9.meta]
Wed 23 Feb 2022 15:08:07 GMT | Setting default python version
```
