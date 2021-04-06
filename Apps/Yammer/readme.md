# Intune Company Portal Installation Script

This script is am example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the Yammer dmg file from the Azure Blob Storage URL servers and then install it onto the Mac.


## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Mac number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/installYammer/Yammer.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
Tue  6 Apr 2021 18:26:52 BST | Creating [/Library/Logs/Microsoft/IntuneScripts/installYammer] to store logs

##############################################################
# Tue  6 Apr 2021 18:26:52 BST | Logging install of [Yammer] to [/Library/Logs/Microsoft/IntuneScripts/installYammer/Yammer.log]
############################################################

Tue  6 Apr 2021 18:26:52 BST | Checking if we need Rosetta 2 or not
Tue  6 Apr 2021 18:26:53 BST | [Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz] found, Rosetta not needed
Tue  6 Apr 2021 18:26:53 BST | Checking if we need to install or update [Yammer]
Tue  6 Apr 2021 18:26:53 BST | [Yammer] not installed, need to download and install
Tue  6 Apr 2021 18:26:53 BST | Starting downlading of [Yammer]
Tue  6 Apr 2021 18:26:53 BST | Waiting for other Curl processes to end
Tue  6 Apr 2021 18:26:53 BST | No instances of Curl found, safe to proceed
Tue  6 Apr 2021 18:26:53 BST | Downloading Yammer
Tue  6 Apr 2021 18:27:04 BST | Downloaded [Yammer.app]
Tue  6 Apr 2021 18:27:04 BST | Checking if the application is running
Tue  6 Apr 2021 18:27:04 BST | [Yammer] isn't running, lets carry on
Tue  6 Apr 2021 18:27:04 BST | Installing [Yammer]
Tue  6 Apr 2021 18:27:04 BST | Mounting [/tmp/yammer.dmg] to [/tmp/Yammer]
Tue  6 Apr 2021 18:27:13 BST | Copying /tmp/Yammer/*.app to /Applications/Yammer.app
Tue  6 Apr 2021 18:27:31 BST | Un-mounting [/tmp/Yammer]
Tue  6 Apr 2021 18:27:31 BST | [Yammer] Installed
Tue  6 Apr 2021 18:27:31 BST | Cleaning Up
Tue  6 Apr 2021 18:27:31 BST | Fixing up permissions
Tue  6 Apr 2021 18:27:31 BST | Application [Yammer] succesfully installed
Tue  6 Apr 2021 18:27:31 BST | Writing last modifieddate [Fri, 26 Mar 2021 13:35:33 GMT] to [/Library/Logs/Microsoft/IntuneScripts/installYammer/Yammer.meta]
```
