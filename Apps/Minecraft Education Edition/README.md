# Minecraft: Education Edition Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install DMG applications. In this example the script will download the Minecraft Education Edition dmg file from the Microsoft download servers (https://aka.ms/meeclientmacos) and then install it onto the Mac. To reduce unnecessary re-downloads, the script monitors the date-modified attrbiute on the HTTP header of https://aka.ms/meeclientmacos rather than checking if the file stored there is actually changed.

For Minecraft: Education Edition support, see [Minecraft: Education Edition Support](https://educommunity.minecraft.net/).

## Scenarios
The script can be used for two scenarios:

 - Install - The script can be used to install Minecraft: Education Edition
 
 - Update - The script can run once or scheduled to update the installed version of Minecraft: Education Edition. You can schedule the script to run once a week to check for updates.

## Description

The script performs the following actions if **Minecraft Education Edition** is not already installed:
1. Downloads the DMG from **https://aka.ms/meeclientmacos** to **/tmp/mee.dmg**.
2. Mounts the DMG file at **/tmp/InstallMEE**.
3. Copies (installs) the application to the **/Applications** directory.
4. Unmounts the DMG file.
5. Deletes the DMG file.
6. Records the date-modified attribute of **https://aka.ms/meeclientmacos** so it can be checked at future script executions.

If **Minecraft Education Edition** is already installed, it will compare the date-modified of **https://aka.ms/meeclientmacos** against the recorded version. 
 - If the date-modified of **https://aka.ms/meeclientmacos** is newer, it will download and install the new version.
 - If no date-modified was previously recorded, it will download and attempt to install.

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : 
  - **Not configured** to run once
  - **Every 1 week** to check for and install updates once a week
- Number of times to retry if script fails : 3

## Log File

The log file will output to **/Library/Logs/Microsoft/IntuneScripts/installMinecraftEE/Minecraft EE.log** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection).
```
##############################################################
# Fri  9 Apr 2021 13:45:28 BST | Logging install of [Minecraft EE] to [/Library/Logs/Microsoft/IntuneScripts/installMinecraftEE/Minecraft EE.log]
############################################################

Fri  9 Apr 2021 13:45:28 BST | Checking if we need Rosetta 2 or not
Fri  9 Apr 2021 13:45:28 BST | Waiting for other [/usr/sbin/softwareupdate] processes to end
Fri  9 Apr 2021 13:45:29 BST | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Fri  9 Apr 2021 13:45:29 BST | [Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz] found, Rosetta not needed
Fri  9 Apr 2021 13:45:29 BST | Checking if we need to install or update [Minecraft EE]
Fri  9 Apr 2021 13:45:29 BST | [Minecraft EE] not installed, need to download and install
Fri  9 Apr 2021 13:45:29 BST | Dock is here, lets carry on
Fri  9 Apr 2021 13:45:29 BST | Starting downlading of [Minecraft EE]
Fri  9 Apr 2021 13:45:29 BST | Waiting for other [curl] processes to end
Fri  9 Apr 2021 13:45:29 BST | No instances of [curl] found, safe to proceed
Fri  9 Apr 2021 13:45:29 BST | Downloading Minecraft EE
Fri  9 Apr 2021 13:46:11 BST | Downloaded [Minecraft EE.app] to [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.55URlgHh/Minecraft_Education_Edition_1-14-50-0.dmg]
Fri  9 Apr 2021 13:46:11 BST | Detected install type as [DMG]
Fri  9 Apr 2021 13:46:11 BST | Waiting for other [minecraftpe] processes to end
Fri  9 Apr 2021 13:46:11 BST | No instances of [minecraftpe] found, safe to proceed
Fri  9 Apr 2021 13:46:11 BST | Waiting for other [installer -pkg] processes to end
Fri  9 Apr 2021 13:46:12 BST | No instances of [installer -pkg] found, safe to proceed
Fri  9 Apr 2021 13:46:12 BST | Waiting for other [rsync -a] processes to end
Fri  9 Apr 2021 13:46:12 BST | No instances of [rsync -a] found, safe to proceed
Fri  9 Apr 2021 13:46:12 BST | Waiting for other [unzip] processes to end
Fri  9 Apr 2021 13:46:12 BST | No instances of [unzip] found, safe to proceed
Fri  9 Apr 2021 13:46:12 BST | Installing [Minecraft EE]
Fri  9 Apr 2021 13:46:12 BST | Mounting Image
Fri  9 Apr 2021 13:46:17 BST | Copying app files to /Applications/Minecraft EE.app
Fri  9 Apr 2021 13:52:01 BST | Un-mounting [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.55URlgHh/Minecraft EE]
Fri  9 Apr 2021 13:52:01 BST | [Minecraft EE] Installed
Fri  9 Apr 2021 13:52:01 BST | Cleaning Up
Fri  9 Apr 2021 13:52:01 BST | Fixing up permissions
Fri  9 Apr 2021 13:52:02 BST | Application [Minecraft EE] succesfully installed
Fri  9 Apr 2021 13:52:02 BST | Writing last modifieddate [Fri, 09 Apr 2021 12:40:22 GMT] to [/Library/Logs/Microsoft/IntuneScripts/installMinecraftEE/Minecraft EE.meta]
```
