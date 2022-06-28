# WhatsApp Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the WhatsApp DMG file from the WhatsApp download servers and then install it onto the Mac.

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Weekly
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/WhatsApp/WhatsApp.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
Sat  4 Jun 2022 20:46:26 BST | Creating [/Library/Logs/Microsoft/IntuneScripts/WhatsApp] to store logs

##############################################################
# Sat  4 Jun 2022 20:46:26 BST | Logging install of [WhatsApp] to [/Library/Logs/Microsoft/IntuneScripts/WhatsApp/WhatsApp.log]
############################################################

Sat  4 Jun 2022 20:46:26 BST | Checking if we need Rosetta 2 or not
Sat  4 Jun 2022 20:46:26 BST | Waiting for other [/usr/sbin/softwareupdate] processes to end
Sat  4 Jun 2022 20:46:26 BST | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Sat  4 Jun 2022 20:46:26 BST | Rosetta is already installed and running. Nothing to do.
Sat  4 Jun 2022 20:46:26 BST | Checking if we need to install or update [WhatsApp]
Sat  4 Jun 2022 20:46:26 BST | [WhatsApp] not installed, need to download and install
Sat  4 Jun 2022 20:46:26 BST | Dock is here, lets carry on
Sat  4 Jun 2022 20:46:26 BST | Starting downlading of [WhatsApp]
Sat  4 Jun 2022 20:46:26 BST | Waiting for other [curl -f] processes to end
Sat  4 Jun 2022 20:46:26 BST | No instances of [curl -f] found, safe to proceed
Sat  4 Jun 2022 20:46:26 BST | Downloading WhatsApp [https://web.whatsapp.com/desktop/mac/files/WhatsApp.dmg]
Sat  4 Jun 2022 20:46:30 BST | Found DMG, looking inside...
Sat  4 Jun 2022 20:46:30 BST | Mounting Image [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.xoucB8BH/WhatsApp] [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.xoucB8BH/WhatsApp.dmg]
Sat  4 Jun 2022 20:46:39 BST | Mounted succesfully to [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.xoucB8BH/WhatsApp]
Sat  4 Jun 2022 20:46:39 BST | Detected APP, setting PackageType to DMG
Sat  4 Jun 2022 20:46:39 BST | Un-mounting [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.xoucB8BH/WhatsApp]
Sat  4 Jun 2022 20:46:50 BST | Downloaded [WhatsApp.app] to [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.xoucB8BH/WhatsApp.dmg]
Sat  4 Jun 2022 20:46:50 BST | Detected install type as [DMG]
Sat  4 Jun 2022 20:46:50 BST | Waiting for other [/Applications/WhatsApp.app/Contents/MacOS/APPEXE] processes to end
Sat  4 Jun 2022 20:46:50 BST | No instances of [/Applications/WhatsApp.app/Contents/MacOS/APPEXE] found, safe to proceed
Sat  4 Jun 2022 20:46:50 BST | Installing [WhatsApp]
Sat  4 Jun 2022 20:46:50 BST | Mounting Image
Sat  4 Jun 2022 20:46:51 BST | Copying app files to /Applications/WhatsApp.app
Sat  4 Jun 2022 20:47:01 BST | Un-mounting [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.xoucB8BH/WhatsApp]
Sat  4 Jun 2022 20:47:01 BST | [WhatsApp] Installed
Sat  4 Jun 2022 20:47:01 BST | Cleaning Up
Sat  4 Jun 2022 20:47:01 BST | Fixing up permissions
Sat  4 Jun 2022 20:47:02 BST | Application [WhatsApp] succesfully installed
Sat  4 Jun 2022 20:47:02 BST | Writing last modifieddate [Wed, 11 May 2022 22:50:34 GMT] to [/Library/Logs/Microsoft/IntuneScripts/WhatsApp/WhatsApp.meta]
```
