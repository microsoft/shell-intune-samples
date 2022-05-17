# Intune Company Portal Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the Yammer dmg file from the Azure Blob Storage URL servers and then install it onto the Mac.


## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Mac number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/installYammer/Yammer.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Fri  9 Apr 2021 13:22:40 BST | Logging install of [Yammer] to [/Library/Logs/Microsoft/IntuneScripts/installYammer/Yammer.log]
############################################################

Fri  9 Apr 2021 13:22:40 BST | Checking if we need Rosetta 2 or not
Fri  9 Apr 2021 13:22:40 BST | Waiting for other [/usr/sbin/softwareupdate] processes to end
Fri  9 Apr 2021 13:22:41 BST | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Fri  9 Apr 2021 13:22:41 BST | [Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz] found, Rosetta not needed
Fri  9 Apr 2021 13:22:41 BST | Checking if we need to install or update [Yammer]
Fri  9 Apr 2021 13:22:41 BST | [Yammer] not installed, need to download and install
Fri  9 Apr 2021 13:22:41 BST | Dock is here, lets carry on
Fri  9 Apr 2021 13:22:41 BST | Starting downlading of [Yammer]
Fri  9 Apr 2021 13:22:41 BST | Waiting for other [curl] processes to end
Fri  9 Apr 2021 13:22:41 BST | No instances of [curl] found, safe to proceed
Fri  9 Apr 2021 13:22:41 BST | Downloading Yammer
Fri  9 Apr 2021 13:22:54 BST | Downloaded [Yammer.app] to [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.Iq3g24Zj/yammer.dmg]
Fri  9 Apr 2021 13:22:54 BST | Detected install type as [DMG]
Fri  9 Apr 2021 13:22:54 BST | Waiting for other [/Applications/Yammer.app/Contents/MacOS/Yammer] processes to end
Fri  9 Apr 2021 13:22:54 BST | No instances of [/Applications/Yammer.app/Contents/MacOS/Yammer] found, safe to proceed
Fri  9 Apr 2021 13:22:54 BST | Waiting for other [installer -pkg] processes to end
Fri  9 Apr 2021 13:22:55 BST | No instances of [installer -pkg] found, safe to proceed
Fri  9 Apr 2021 13:22:55 BST | Waiting for other [rsync -a] processes to end
Fri  9 Apr 2021 13:22:55 BST | No instances of [rsync -a] found, safe to proceed
Fri  9 Apr 2021 13:22:55 BST | Waiting for other [unzip] processes to end
Fri  9 Apr 2021 13:22:55 BST | No instances of [unzip] found, safe to proceed
Fri  9 Apr 2021 13:22:55 BST | Installing [Yammer]
Fri  9 Apr 2021 13:22:55 BST | Mounting Image
Fri  9 Apr 2021 13:23:02 BST | Copying app files to /Applications/Yammer.app
Fri  9 Apr 2021 13:23:22 BST | Un-mounting [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.Iq3g24Zj/Yammer]
Fri  9 Apr 2021 13:23:22 BST | [Yammer] Installed
Fri  9 Apr 2021 13:23:22 BST | Cleaning Up
Fri  9 Apr 2021 13:23:22 BST | Fixing up permissions
Fri  9 Apr 2021 13:23:22 BST | Application [Yammer] succesfully installed
Fri  9 Apr 2021 13:23:22 BST | Writing last modifieddate [Fri, 26 Mar 2021 13:35:33 GMT] to [/Library/Logs/Microsoft/IntuneScripts/installYammer/Yammer.meta]
```
