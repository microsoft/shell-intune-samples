# Google Chrome Installation Script for macOS

This script automates the deployment of Google Chrome on macOS devices through Microsoft Intune. It performs a clean installation of the latest version from Google's official distribution source.

## Features

- **Direct Download**: Downloads Google Chrome package directly from Google's official source
- **Universal Binary Support**: Installs on both Intel and Apple Silicon Macs without requiring Rosetta 2
- **Auto-Update Detection**: Skips installation if Chrome is already installed (as Chrome handles its own updates)
- **Self-Healing**: Includes retry logic for failed installations
- **Visual Feedback**: Supports Swift Dialog for user-visible progress updates (when Dialog is running)
- **Process Management**: Can terminate running Chrome instances during installation
- **Comprehensive Logging**: Detailed logs for troubleshooting

## Requirements

- macOS 10.13 or later
- Administrative privileges
- Internet connectivity to download the Chrome package

## Configuration Variables

The script uses several key variables that can be customized if needed:

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `weburl` | https://dl.google.com/chrome/mac/universal/stable/gcem/GoogleChrome.pkg | Direct download URL for Google Chrome package |
| `appname` | Google Chrome | Display name used in logs and Swift Dialog |
| `app` | Google Chrome.app | Folder of the application as installed |
| `logandmetadir` | /Library/Logs/Microsoft/IntuneScripts/GoogleChrome | Directory where logs are stored |
| `processpath` | /Applications/Google Chrome.app/Contents/MacOS/Google Chrome | Full path to the Chrome process |
| `terminateprocess` | true | Whether to terminate Chrome if running during installation |
| `autoUpdate` | true | Whether to skip installation if Chrome is already installed |

## Microsoft Single Sign-On Configuration

The included `Microsoft Single Sign On for Chrome.mobileconfig` file is necessary to support Platform Single Sign-On with Chrome. This configuration profile installs the Microsoft Single Sign-On extension for Chrome (ID: ppnbnpeolgkicgegkbkbjmhlideopiji), which allows users to seamlessly sign into Microsoft services and Azure AD-connected applications.

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file outputs to ***/Library/Logs/Microsoft/IntuneScripts/GoogleChrome*** by default. Exit status is either 0 or 1.

To gather this log with Intune remotely, see [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

### Example Log Output:
```
##############################################################
#                                                            #
#           Google Chrome Installation Script                #
#                                                            #
##############################################################
# Thu Apr  3 09:52:25 BST 2025 | Starting installation of Google Chrome
# Thu Apr  3 09:52:25 BST 2025 | Log file: /Library/Logs/Microsoft/IntuneScripts/GoogleChrome/Google Chrome.log
##############################################################

Thu Apr  3 09:52:25 BST 2025 | Checking if Google Chrome needs to be installed or updated
Thu Apr  3 09:52:25 BST 2025 | [Google Chrome] is not currently installed
Thu Apr  3 09:52:25 BST 2025 | Waiting for Desktop environment to be ready...
Thu Apr  3 09:52:25 BST 2025 | Desktop environment is ready, proceeding with installation
Thu Apr  3 09:52:25 BST 2025 | Starting download of Google Chrome installer package
Thu Apr  3 09:52:25 BST 2025 | Downloading from: https://dl.google.com/chrome/mac/universal/stable/gcem/GoogleChrome.pkg
Thu Apr  3 09:52:56 BST 2025 | Successfully downloaded Google Chrome installer to /var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.BoZVU1Vpzm/chrome.pkg
Thu Apr  3 09:52:56 BST 2025 | Checking if [/Applications/Google Chrome.app/Contents/MacOS/Google Chrome] is running
Thu Apr  3 09:52:56 BST 2025 | No instances of [/Applications/Google Chrome.app/Contents/MacOS/Google Chrome] found, safe to proceed
Thu Apr  3 09:52:56 BST 2025 | Beginning installation of Google Chrome
Thu Apr  3 09:52:56 BST 2025 | Installation attempt 1 of 5
installer: Package name is Google Chrome
installer: Upgrading at base path /
installer: The upgrade was successful.
Thu Apr  3 09:53:00 BST 2025 | SUCCESS: Google Chrome installed successfully
Thu Apr  3 09:53:00 BST 2025 | Cleaning up temporary files
Thu Apr  3 09:53:00 BST 2025 | Installation of Google Chrome completed successfully

##############################################################
# Thu Apr  3 09:53:00 BST 2025 | Google Chrome installation completed
##############################################################
```
