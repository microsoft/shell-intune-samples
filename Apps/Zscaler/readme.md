## Zscaler Client Connector Installation Script

This script is based on [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install Zscaler Client Connector.

The script will download the Zscaler installation file from Zscaler's CDN using the version specified in the script, and install it onto the Mac.

Because the installation package is always a zip the unnecessary installation functions (pkg, dmg etc) have been removed.

The script is intended to install Zscaler on a fresh macOS device. Once installed Zscaler can be managed and updated via the Zscaler Client Connector portal. Therefore, no update is attempted; if Zscaler is already installed the script will exit indicating success.


## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : As required
- Mac number of times to retry if script fails : As required

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/Zscaler/Zscaler.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)
