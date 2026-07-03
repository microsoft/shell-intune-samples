# Microsoft 365 Copilot Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the Microsoft 365 Copilot PKG from the Microsoft CDN and then install it onto the Mac.

## Quick Run

```
sudo /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/macOS/Apps/M365%20Copilot/install%20M365%20Copilot.zsh)"
```

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/installM365Copilot/Microsoft 365 Copilot.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Thu Apr  9 11:10:48 BST 2026 | Starting install of [Microsoft 365 Copilot]
##############################################################

Thu Apr  9 11:10:48 BST 2026 | Checking if Microsoft 365 Copilot is already installed
Thu Apr  9 11:10:48 BST 2026 | Microsoft 365 Copilot not installed
Thu Apr  9 11:10:48 BST 2026 | Desktop ready
Thu Apr  9 11:10:48 BST 2026 | Downloading Microsoft 365 Copilot
Thu Apr  9 11:10:49 BST 2026 | Resolved URL: https://m365copilotformac.blob.core.windows.net/releases/Microsoft_365_Copilot_universal_1.2603.1601_Installer.pkg
Thu Apr  9 11:11:19 BST 2026 | Download complete
Thu Apr  9 11:11:19 BST 2026 | Waiting for [/Applications/Microsoft 365 Copilot.app/Contents/MacOS/Microsoft 365 Copilot] to close
Thu Apr  9 11:11:19 BST 2026 | No running [/Applications/Microsoft 365 Copilot.app/Contents/MacOS/Microsoft 365 Copilot]
Thu Apr  9 11:11:19 BST 2026 | Installing Microsoft 365 Copilot
installer: Package name is Microsoft 365 Copilot
installer: Installing at base path /
installer: The install was successful.
Thu Apr  9 11:11:25 BST 2026 | Install complete
```
