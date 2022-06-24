# Nudge Installation

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the Nudge Suite pkg file from their download servers and then install it onto the Mac.

# What is Nudge?

[Nudge](https://github.com/macadmins/nudge) is an open source tool for encouraging your end users to install macOS updates. It provides rich configuration potential and is simple to deploy. This is an example of how to get it up and running with Intune.

This sample provides two items.

1. Installation script for the Nudge Suite package that includes the Logger LaunchDaemon, Nudge 30 minute LaunchAgent and Nudge.app
2. Nudge (12.x).mobileconfig

The installation scripts both do exactly the same thing. Both are provided currently as I move the repo over to ZSH. If you have no preference, use the ZSH version. You need to deploy the script to your test users as described in the [Intune documentation](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts).

The mobileconfig file is an Intune Custom configuration policy that contains some configuration parameters for Nudge to use. For this sample, we are just working with macOS 12.x and encouraging all of our users to install 12.4 by the 1st October 2022. You'll need to edit the mobileconfig for your own requirements. There is a [nudge wiki](https://github.com/macadmins/nudge/wiki) available, plus [iMazing Profile Editor](https://imazing.com/profile-editor) has a built-in profile editor for Nudge too.

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
Once deployed and configured, the following dialog will be shown to users that do not meet the requirements defined in the mobileconfig file.

![Nudge UI](https://github.com/microsoft/shell-intune-samples/raw/master/img/NudgeSample.png)

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/Nudge/Nudge.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Fri 24 Jun 2022 15:37:05 BST | Logging install of [Nudge] to [/Library/Logs/Microsoft/IntuneScripts/Nudge/Nudge.log]
############################################################

Fri 24 Jun 2022 15:37:05 BST | Checking if we need Rosetta 2 or not
Fri 24 Jun 2022 15:37:05 BST | Waiting for other [/usr/sbin/softwareupdate] processes to end
Fri 24 Jun 2022 15:37:05 BST | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Fri 24 Jun 2022 15:37:05 BST | Rosetta is already installed and running. Nothing to do.
Fri 24 Jun 2022 15:37:05 BST | Checking if we need to install or update [Nudge]
Fri 24 Jun 2022 15:37:05 BST | [Nudge] not installed, need to download and install
Fri 24 Jun 2022 15:37:05 BST | Dock is here, lets carry on
Fri 24 Jun 2022 15:37:05 BST | Starting downlading of [Nudge]
Fri 24 Jun 2022 15:37:05 BST | Waiting for other [curl -f] processes to end
Fri 24 Jun 2022 15:37:05 BST | No instances of [curl -f] found, safe to proceed
Fri 24 Jun 2022 15:37:05 BST | Downloading Nudge [https://github.com/macadmins/nudge/releases/download/v1.1.7.81411/Nudge_Suite-1.1.7.81411.pkg]
Fri 24 Jun 2022 15:37:06 BST | Found downloaded tempfile [Nudge_Suite-1.1.7.81411.pkg]
Fri 24 Jun 2022 15:37:06 BST | Downloaded [Nudge.app] to [Nudge_Suite-1.1.7.81411.pkg]
Fri 24 Jun 2022 15:37:06 BST | Detected install type as [PKG]
Fri 24 Jun 2022 15:37:06 BST | Waiting for other [/Applications/Utilities/Nudge.app/Contents/MacOS/Nudge] processes to end
Fri 24 Jun 2022 15:37:06 BST | No instances of [/Applications/Utilities/Nudge.app/Contents/MacOS/Nudge] found, safe to proceed
Fri 24 Jun 2022 15:37:06 BST | Installing Nudge
installer: Package name is 
installer: Upgrading at base path /
installer: The upgrade was successful.
Fri 24 Jun 2022 15:37:08 BST | Nudge Installed
Fri 24 Jun 2022 15:37:08 BST | Cleaning Up
Fri 24 Jun 2022 15:37:08 BST | Application [Nudge] succesfully installed
Fri 24 Jun 2022 15:37:09 BST | Writing last modifieddate [Fri, 03 Jun 2022 13:16:02 GMT] to [/Library/Logs/Microsoft/IntuneScripts/Nudge/Nudge.meta]
```
