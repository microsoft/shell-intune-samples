# Citrix Workspace
Here are some example scripts showing how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install or uninstall an application. In this folder, we provide some scripts for Citrix Workspace.

## Install Citrix Workspace (installCitrixWorkspace.sh)

This script installs Citrix Workspace.
 
### Script Settings (installCitrixWorkspace.sh)

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3

### Log File (installCitrixWorkspace.sh)

The log file will output to **/Library/Logs/Microsoft/IntuneScripts/Citrix Workspace/Citrix Workspace.log** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection).

```
##############################################################
# Mon 28 Feb 2022 15:10:34 GMT | Logging install of [Citrix Workspace] to [/Library/Logs/Microsoft/IntuneScripts/Citrix Workspace/Citrix Workspace.log]
############################################################

Mon 28 Feb 2022 15:10:34 GMT | Checking if we need Rosetta 2 or not
Mon 28 Feb 2022 15:10:34 GMT | Waiting for other [/usr/sbin/softwareupdate] processes to end
Mon 28 Feb 2022 15:10:34 GMT | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Mon 28 Feb 2022 15:10:34 GMT | Rosetta is already installed and running. Nothing to do.
Mon 28 Feb 2022 15:10:34 GMT | Checking if we need to install or update [Citrix Workspace]
Mon 28 Feb 2022 15:10:34 GMT | [Citrix Workspace] not installed, need to download and install
Mon 28 Feb 2022 15:10:34 GMT | Dock is here, lets carry on
Mon 28 Feb 2022 15:10:34 GMT | Starting downlading of [Citrix Workspace]
Mon 28 Feb 2022 15:10:34 GMT | Waiting for other [curl -f] processes to end
Mon 28 Feb 2022 15:10:34 GMT | No instances of [curl -f] found, safe to proceed
Mon 28 Feb 2022 15:10:34 GMT | Downloading Citrix Workspace [https://downloads.citrix.com/20341/CitrixWorkspaceApp.dmg?__gda__=exp=1646063402~acl=/*~hmac=96b60eb8eacb0a7b0bfc10f8ee12399ce0f5dc333bbc277423d9b6588caf18c9]
Mon 28 Feb 2022 15:10:39 GMT | Found DMG, looking inside...
Mon 28 Feb 2022 15:10:39 GMT | Mounting Image [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.ig7jobi1/Citrix Workspace] [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.ig7jobi1/CitrixWorkspaceApp.dmg]
Mon 28 Feb 2022 15:10:40 GMT | Mounted succesfully to [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.ig7jobi1/Citrix Workspace]
Mon 28 Feb 2022 15:10:40 GMT | Detected both APP and PKG in same DMG (this is normal for Citrix Workspace)
Mon 28 Feb 2022 15:10:40 GMT | Un-mounting [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.ig7jobi1/Citrix Workspace]
Mon 28 Feb 2022 15:10:40 GMT | Downloaded [Citrix Workspace.app] to [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.ig7jobi1/CitrixWorkspaceApp.dmg]
Mon 28 Feb 2022 15:10:40 GMT | Detected install type as [DMGPKG]
Mon 28 Feb 2022 15:10:40 GMT | Waiting for other [/Applications/Citrix Workspace.app/Contents/MacOS/Citrix Workspace] processes to end
Mon 28 Feb 2022 15:10:41 GMT | No instances of [/Applications/Citrix Workspace.app/Contents/MacOS/Citrix Workspace] found, safe to proceed
Mon 28 Feb 2022 15:10:41 GMT | Installing [Citrix Workspace]
Mon 28 Feb 2022 15:10:41 GMT | Mounting Image
Mon 28 Feb 2022 15:10:41 GMT | Starting installer for [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.ig7jobi1/Citrix Workspace/Install Citrix Workspace.pkg]
```

## Uninstall Citrix Workspace (uninstallCitrixWorkspace.zsh)

This script uninstalls Citrix Workspace.
 
### Script Settings (uninstallCitrixWorkspace.zsh)

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not configured (**Note:** If users have and uses admin rights on their day-to-day tasks, you should consider to run this more frequently such as "Every 1 day")
- Number of times to retry if script fails : 3

### Log File (uninstallCitrixWorkspace.zsh)

The log file will output to **/Library/Logs/Microsoft/IntuneScripts/UninstallCitrixWorkspace/UninstallCitrixWorkspace.log** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection).

```
##############################################################
# Sun Sep  1 17:32:57 EEST 2024 | Starting running of script UninstallCitrixWorkspace
############################################################

Sun Sep  1 17:32:57 EEST 2024 | Uninstalling Citrix Workspace...
Sun Sep  1 17:34:04 EEST 2024 | Citrix Workspace has been uninstalled. Closing script...
```