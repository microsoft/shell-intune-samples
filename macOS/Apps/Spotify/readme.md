# Spotify Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the Teams pkg file from the Microsoft download servers and then install it onto the Mac.

## Scenario

This script is intended for customers who need to deploy Spotify via the Intune Scripting Agent.

## Quick Run

```
sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/macOS/Apps/Spotify/installSpotify.zsh)"
```

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Weekly
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/var/log/installteams.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
[##############################################################
# Fri  9 Apr 2021 13:18:12 BST | Logging install of \[Microsoft Teams\] to \[/Library/Logs/Microsoft/IntuneScripts/installTeams/Microsoft Teams.log\]
############################################################

Fri  9 Apr 2021 13:18:12 BST | Checking if we need Rosetta 2 or not
Fri  9 Apr 2021 13:18:12 BST | Waiting for other \[/usr/sbin/softwareupdate\] processes to end
Fri  9 Apr 2021 13:18:12 BST | No instances of \[/usr/sbin/softwareupdate\] found, safe to proceed
Fri  9 Apr 2021 13:18:12 BST | \[Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz\] found, Rosetta not needed
Fri  9 Apr 2021 13:18:12 BST | Checking if we need to install or update \[Microsoft Teams\]
Fri  9 Apr 2021 13:18:12 BST | \[Microsoft Teams\] not installed, need to download and install
Fri  9 Apr 2021 13:18:12 BST | Dock is here, lets carry on
Fri  9 Apr 2021 13:18:12 BST | Starting downlading of \[Microsoft Teams\]
Fri  9 Apr 2021 13:18:12 BST | Waiting for other \[curl\] processes to end
Fri  9 Apr 2021 13:18:12 BST | No instances of \[curl\] found, safe to proceed
Fri  9 Apr 2021 13:18:12 BST | Downloading Microsoft Teams
Fri  9 Apr 2021 13:18:30 BST | Downloaded \[Microsoft Teams.app\] to \[/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.i76crR36/Teams_osx.pkg\]
Fri  9 Apr 2021 13:18:30 BST | Detected install type as \[PKG\]
Fri  9 Apr 2021 13:18:30 BST | Waiting for other \[/Applications/Microsoft Teams.app/Contents/MacOS/Teams\] processes to end
Fri  9 Apr 2021 13:18:30 BST | No instances of \[/Applications/Microsoft Teams.app/Contents/MacOS/Teams\] found, safe to proceed
Fri  9 Apr 2021 13:18:30 BST | Installing Microsoft Teams
Fri  9 Apr 2021 13:18:30 BST | Waiting for other \[installer -pkg\] processes to end
Fri  9 Apr 2021 13:18:30 BST | No instances of \[installer -pkg\] found, safe to proceed
Fri  9 Apr 2021 13:18:30 BST | Waiting for other \[cp -Rf\] processes to end
Fri  9 Apr 2021 13:18:30 BST | No instances of \[cp -Rf\] found, safe to proceed
Fri  9 Apr 2021 13:18:30 BST | Waiting for other \[unzip\] processes to end
Fri  9 Apr 2021 13:18:30 BST | No instances of \[unzip\] found, safe to proceed
installer: Package name is Microsoft Teams
installer: Upgrading at base path /
installer: The upgrade was successful.
Fri  9 Apr 2021 13:18:38 BST | Microsoft Teams Installed
Fri  9 Apr 2021 13:18:38 BST | Cleaning Up
Fri  9 Apr 2021 13:18:38 BST | Application \[Microsoft Teams\] succesfully installed
Fri  9 Apr 2021 13:18:38 BST | Writing last modifieddate \[Fri, 09 Apr 2021 12:17:06 GMT\] to \[/Library/Logs/Microsoft/IntuneScripts/installTeams/Microsoft Teams.meta\]](../Teams/readme.md)
```
