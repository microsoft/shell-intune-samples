# Qualys Cloud Agent Installation & Qualys Subsription Installer

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the Qualys Cloud Agent pkg file from your download server and then install it onto the Mac. Also, in order to apply Qualys Subscription to devices that already have Qualys installed, we are also providing separate script for that.

## Things you'll need to do

1. From file "installQualys.zsh", modify lines 42 and 45 with the URLs to the storage location you are using for Qualys Cloud Agent.PKG ( Azure Blob Storage is handy for this) for appropriate architecture.
2. From file "qualysSubscriptionInstaller.zsh", modify lines 33 and 34 with your Activation ID and Customer ID.

## Script Settings (installQualys.zsh)

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Script Settings (qualysSubscriptionInstaller.zsh)

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Every 15 minutes
- Number of times to retry if script fails : 3

## Log File (installQualys.zsh)

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/QualysCloudAgent.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Mon Nov 13 14:33:24 EET 2023 | Logging install of [QualysCloudAgent] to [/Library/Logs/Microsoft/IntuneScripts/QualysCloudAgent/QualysCloudAgent.log]
############################################################

Mon Nov 13 14:33:24 EET 2023 | Checking if we need Rosetta 2 or not
Mon Nov 13 14:33:24 EET 2023 | Waiting for other [/usr/sbin/softwareupdate] processes to end
Mon Nov 13 14:33:24 EET 2023 | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Mon Nov 13 14:33:25 EET 2023 | Checking if we need to install or update [QualysCloudAgent]
Mon Nov 13 14:33:25 EET 2023 | [QualysCloudAgent] not installed, need to download and install
Mon Nov 13 14:33:25 EET 2023 | Dock is here, lets carry on
Mon Nov 13 14:33:25 EET 2023 | Starting downlading of [QualysCloudAgent]
Mon Nov 13 14:33:25 EET 2023 | Waiting for other [curl -f] processes to end
Mon Nov 13 14:33:26 EET 2023 | No instances of [curl -f] found, safe to proceed
Mon Nov 13 14:33:26 EET 2023 | Downloading QualysCloudAgent
Mon Nov 13 14:33:28 EET 2023 | Found downloaded tempfile [QualysCloudAgent-ARM.pkg]
Mon Nov 13 14:33:28 EET 2023 | Downloaded [QualysCloudAgent.app] to [QualysCloudAgent-ARM.pkg]
Mon Nov 13 14:33:28 EET 2023 | Detected install type as [PKG]
Mon Nov 13 14:33:28 EET 2023 | Waiting for other [/Applications/QualysCloudAgent.app/Contents/MacOS/QualysCloudAgent] processes to end
Mon Nov 13 14:33:28 EET 2023 | No instances of [/Applications/QualysCloudAgent.app/Contents/MacOS/QualysCloudAgent] found, safe to proceed
Mon Nov 13 14:33:28 EET 2023 | Installing QualysCloudAgent
installer: Package name is Qualys Cloud Agent
installer: Installing at base path /
installer: The install was successful.
Mon Nov 13 14:33:31 EET 2023 | QualysCloudAgent Installed
Mon Nov 13 14:33:31 EET 2023 | Cleaning Up
Mon Nov 13 14:33:31 EET 2023 | Application [QualysCloudAgent] succesfully installed
Mon Nov 13 14:33:31 EET 2023 | Writing last modifieddate [Tue, 17 Oct 2023 11:31:35 GMT] to [/Library/Logs/Microsoft/IntuneScripts/QualysCloudAgent/QualysCloudAgent.meta]
```
## Log File (qualysSubscriptionInstaller.zsh)

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/QualysSubscriptionInstaller.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Mon Nov 13 15:39:45 EET 2023 | Logging install of [QualysSubscriptionInstaller] to [/Library/Logs/Microsoft/IntuneScripts/QualysSubscriptionInstaller/QualysSubscriptionInstaller.log]
############################################################

Mon Nov 13 15:39:45 EET 2023 | Qualys is installed. Let's continue...
Mon Nov 13 15:39:45 EET 2023 | Qualys subscription is not applied. Let's apply subscription...
Mon Nov 13 15:39:45 EET 2023 | Applying Qualys subscription ...
Setting permission for user: root
Setting permission for group: wheel
hostid search path: /etc
Mon Nov 13 15:40:16 EET 2023 | Qualys subscription applied. Creating subscription detection file...
Mon Nov 13 15:40:16 EET 2023 | Done. Closing script...
```