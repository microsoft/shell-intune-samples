# Figma
This folder contains custom scripts for Figma for mass deployment via Intune.

## Uninstall Figma
This custom script uninstalls Figma from Intune-managed Mac-device.

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
