# Microsoft Teams

Here are some example scripts showing how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install or uninstall an application. In this folder, we provide some scripts for Citrix Workspace.

## Install Microsoft Teams (installTeamsClassic.zsh, installTeamsV2.zsh)

These scripts installs Microsoft Teams. There are two versions of the Teams Clients and you'll find a sample script for each.

- Microsoft Teams classic
- Microsoft Teams

More information about [The new Microsoft Teams desktop client](https://learn.microsoft.com/en-us/microsoftteams/new-teams-desktop-admin).

### Audio Driver for Microsoft Teams classic

To share system audio in a teams classic call, you also need to install the Teams Audio Driver. This is included with the standard package but on older packages didn't used to be installed since it interrupted any audio that was playing. Both of the sample packages shared here will force the Audio Driver to automatically install to prevent standard desktop users not being able to install it later.

### Quick Run

Classic
```
sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/macOS/Apps/Teams/installTeamsClassic.zsh)"
```

Teams V2
```
sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/macOS/Apps/Teams/installTeamsV2.zsh)"
```


### Script Settings (installTeamsClassic.zsh, installTeamsV2.zsh)

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3

### Log File (installTeamsClassic.zsh, installTeamsV2.zsh)

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/Microsoft Teams*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Fri 10 Nov 2023 05:12:01 PST | Logging install of [Microsoft Teams] to [/Library/Logs/Microsoft/IntuneScripts/Microsoft Teams/Microsoft Teams.log]
############################################################

Fri 10 Nov 2023 05:12:01 PST | Checking if we need Rosetta 2 or not
Fri 10 Nov 2023 05:12:01 PST | Waiting for other [/usr/sbin/softwareupdate] processes to end
Fri 10 Nov 2023 05:12:01 PST | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Fri 10 Nov 2023 05:12:01 PST | Rosetta is already installed and running. Nothing to do.
Fri 10 Nov 2023 05:12:01 PST | Aria2 already installed, nothing to do
Fri 10 Nov 2023 05:12:01 PST | Checking if we need to install or update [Microsoft Teams][/Applications//Microsoft Teams (work or school).app]
Fri 10 Nov 2023 05:12:01 PST | [Microsoft Teams] not installed, need to download and install
Fri 10 Nov 2023 05:12:01 PST | Dock is here, lets carry on
Fri 10 Nov 2023 05:12:01 PST | Starting downlading of [Microsoft Teams]
Fri 10 Nov 2023 05:12:01 PST | Waiting for other [/usr/local/aria2/bin/aria2c] processes to end
Fri 10 Nov 2023 05:12:01 PST | No instances of [/usr/local/aria2/bin/aria2c] found, safe to proceed
Fri 10 Nov 2023 05:12:01 PST | Downloading Microsoft Teams [https://go.microsoft.com/fwlink/?linkid=2249065]
Fri 10 Nov 2023 05:12:06 PST | Found downloaded tempfile [MicrosoftTeams.pkg]
Fri 10 Nov 2023 05:12:06 PST | Downloaded [Microsoft Teams (work or school).app] to [MicrosoftTeams.pkg]
Fri 10 Nov 2023 05:12:06 PST | Detected install type as [PKG]
Fri 10 Nov 2023 05:12:06 PST | Waiting for other [/Applications/Microsoft Teams (work or school).app/Contents/MacOS/Teams] processes to end
Fri 10 Nov 2023 05:12:06 PST | No instances of [/Applications/Microsoft Teams (work or school).app/Contents/MacOS/Teams] found, safe to proceed
Fri 10 Nov 2023 05:12:06 PST | Installing Microsoft Teams
Fri 10 Nov 2023 05:12:06 PST | Install Microsoft Teams with Teams Audio Driver
installer: Package name is Microsoft Teams (work or school)
installer: choices changes file '/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.OcrVseIxM0/TeamsChoiceChanges.xml' applied
installer: Upgrading at base path /
installer: The upgrade was successful.
Fri 10 Nov 2023 05:12:12 PST | Microsoft Teams Installed
Fri 10 Nov 2023 05:12:12 PST | Cleaning Up
Fri 10 Nov 2023 05:12:12 PST | Application [Microsoft Teams] succesfully installed
Fri 10 Nov 2023 05:12:12 PST | Writing last modifieddate [Wed, 08 Nov 2023 16:08:39 GMT] to [/Library/Logs/Microsoft/IntuneScripts/Microsoft Teams/Microsoft Teams.meta]
```
 
## Uninstall Microsoft Teams classic (uninstallTeamsClassic.zsh)

This script uninstalls Microsoft Teams classic.

### Quick Run

```
sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/macOS/Apps/Teams/uninstallTeamsClassic.zsh)"
```

### Script Settings (uninstallTeamsClassic.zsh)

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not configured (**Note:** If users have and uses admin rights on their day-to-day tasks, you should consider to run this more frequently such as "Every 1 day")
- Number of times to retry if script fails : 3

### Log File (uninstallMicrosoftTeamsClassic.zsh)

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/UninstallMicrosoftTeamsClassic/UninstallMicrosoftTeamsClassic.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Sun Sep  1 17:58:17 EEST 2024 | Starting running of script UninstallMicrosoftTeamsClassic
############################################################

Sun Sep  1 17:58:17 EEST 2024 | Uninstalling Microsoft Teams classic...
Sun Sep  1 17:58:19 EEST 2024 | Microsoft Teams classic has been uninstalled. Closing script...
```