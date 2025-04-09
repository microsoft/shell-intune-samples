# Figma
This folder contains custom scripts for Figma for mass deployment via Intune.

## Uninstall Figma
This custom script uninstalls Figma from Intune-managed Mac-device.

> [!IMPORTANT]  
> Uninstalling Figma does not uninstall Figma Agent. Hence, you also need to deploy uninstallation script that will uninstall Figma Agent. Figma Agent is usually installed alonside Figma. 

### Script Settings
- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Every 1 day (Selecting this will make sure that if user installs Figma without permission of IT-department, installation will be uninstalled automatically.)
- Number of times to retry if script fails : 3

### Log File
The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/UninstallFigma/UninstallFigma.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Sat Mar  8 14:55:59 EET 2025 | Starting running of script UninstallFigma
############################################################

Sat Mar  8 14:55:59 EET 2025 | Uninstalling Figma...
Sat Mar  8 14:56:01 EET 2025 | Figma has been uninstalled. Closing script...
```
## Uninstall Figma Agent
This custom script uninstalls Figma Agent if Figma is no longer installed from Intune-managed Mac-device.

> [!IMPORTANT]  
> - Uninstalling Figma Agent does not uninstall Figma. Hence, you also need to deploy uninstallation script that will uninstall Figma. Figma is usually installed alonside Figma Agent.
> - Make sure, that you have also first deployed this [configuration profile](https://github.com/microsoft/shell-intune-samples/tree/master/macOS/Custom%20Profiles/Microsoft%20Intune%20Agent) so users is not getting confusing prompts regarding to allowing system events access when deploying uninstallation script of Figma Agent via Intune. **It is strongly recommended to deploy this configuration profile first to Intune-managed Mac-devices before deploying uninstallation script of Figma Agent (and Figma of course).** 

### Script Settings
- Run script as signed-in user : Yes
- Hide script notifications on devices : Yes
- Script frequency : Every 1 day (Selecting this will make sure that if user installs Figma without permission of IT-department, installation will be uninstalled automatically.)
- Number of times to retry if script fails : 3

### Log File
The log file will output to ***~/Library/Logs/Microsoft/IntuneScripts/UninstallFigmaAgent/UninstallFigmaAgent.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Sat Mar  8 15:09:51 EET 2025 | Starting running of script UninstallFigmaAgent
############################################################

Sat Mar  8 15:09:51 EET 2025 | Figma is not installed. We can proceed...
Sat Mar  8 15:09:51 EET 2025 | There is no daemon plist on this device. Let's continue...
Sat Mar  8 15:09:51 EET 2025 | There is no Figma Daemon installation on this device. Let's continue...
Sat Mar  8 15:09:51 EET 2025 | Uninstalling Figma Agent...
Sat Mar  8 15:09:59 EET 2025 | Figma Agent has been uninstalled. All needed files have been deleted. Closing script...
```
