# Intune Company Portal Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the Company Portal pkg file from the Microsoft download servers and then install it onto the Mac.

## Scenario

This script has a few scenarios

- DEP/ADE enrolled Macs that need to complete their device registration for conditional access. In this scenario the script should be deployed [via Intune]((https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts)).

- Provide end users with a quick and easy way to get started with their Mac enrollment. In this scenario the end users should be provided with the following to copy and paste into Terminal on their Mac.


## Quick Run

```
sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/Apps/Company%20Portal/installCompanyPortal.sh)" ; open "/Applications/Company Portal.app"
```

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/var/log/installcp.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
Tue  6 Apr 2021 16:58:54 BST | Creating [/Library/Logs/Microsoft/IntuneScripts/installCompanyPortal] to store logs

##############################################################
# Tue  6 Apr 2021 16:58:54 BST | Logging install of [Company Portal] to [/Library/Logs/Microsoft/IntuneScripts/installCompanyPortal/Company Portal.log]
############################################################

Tue  6 Apr 2021 16:58:54 BST | Checking if we need Rosetta 2 or not
Tue  6 Apr 2021 16:58:54 BST | [Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz] found, Rosetta not needed
Tue  6 Apr 2021 16:58:54 BST | Checking if we need to install or update [Company Portal]
Tue  6 Apr 2021 16:58:54 BST | [Company Portal] not installed, need to download and install
Tue  6 Apr 2021 16:58:54 BST | Starting downlading of [Company Portal]
Tue  6 Apr 2021 16:58:54 BST | Waiting for other Curl processes to end
Tue  6 Apr 2021 16:58:54 BST | No instances of Curl found, safe to proceed
Tue  6 Apr 2021 16:58:54 BST | Octory found, attempting to send status updates
Tue  6 Apr 2021 16:58:54 BST | Updating Octory monitor for [Company Portal] to [installing]
Tue  6 Apr 2021 16:58:54 BST | Downloading Company Portal
Tue  6 Apr 2021 16:58:58 BST | Downloaded [Company Portal.app]
Tue  6 Apr 2021 16:58:58 BST | Checking if the application is running
Tue  6 Apr 2021 16:58:58 BST | [Company Portal] isn't running, lets carry on
Tue  6 Apr 2021 16:58:58 BST | Installing Company Portal
Tue  6 Apr 2021 16:58:58 BST | Installer not running, safe to start installing
Tue  6 Apr 2021 16:58:58 BST | Octory found, attempting to send status updates
Tue  6 Apr 2021 16:58:58 BST | Updating Octory monitor for [Company Portal] to [installing]
installer: Package name is Intune Company Portal
installer: Upgrading at base path /
installer: The upgrade was successful.
Tue  6 Apr 2021 16:59:08 BST | Company Portal Installed
Tue  6 Apr 2021 16:59:08 BST | Cleaning Up
Tue  6 Apr 2021 16:59:08 BST | Writing last modifieddate  to /Library/Logs/Microsoft/IntuneScripts/installCompanyPortal/Company Portal.meta
Tue  6 Apr 2021 16:59:08 BST | Application [Company Portal] succesfully installed
Tue  6 Apr 2021 16:59:08 BST | Writing last modifieddate [Thu, 25 Mar 2021 16:38:38 GMT] to [/Library/Logs/Microsoft/IntuneScripts/installCompanyPortal/Company Portal.meta]
Tue  6 Apr 2021 16:59:08 BST | Octory found, attempting to send status updates
Tue  6 Apr 2021 16:59:08 BST | Updating Octory monitor for [Company Portal] to [installed]
```
