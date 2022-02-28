# Citrix Desktop for Mac Installation Script

This script is an example showing how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install an application. In this instance the script downloads the Citrix Desktop files, uncompresses them and installs into the /Applications directory.

## Scenario

This scripts intended usage scenario is to deploy the gitHub Desktop app to Mac devices that need to use it.


## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file will output to **/Library/Logs/Microsoft/IntuneScripts/installGitHubDesktop/GitHub Desktop.log** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection).

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