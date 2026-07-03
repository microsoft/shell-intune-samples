# Google Drive Installation Script for macOS

This script automates the deployment of [Google Drive for desktop](https://www.google.com/drive/download/) on macOS devices through Microsoft Intune. It downloads the latest Google Drive `.dmg` from Google's official distribution source and installs it.

## Features

- **Direct Download**: Downloads the Google Drive disk image directly from Google's official source
- **DMG/PKG Handling**: Mounts the DMG and installs whether the payload is a `.app` bundle or a `.pkg` installer
- **Auto-Update Detection**: Skips installation if Google Drive is already installed (Google Drive handles its own updates)
- **Process Management**: Can terminate a running Google Drive instance during installation
- **Comprehensive Logging**: Detailed logs for troubleshooting

## Requirements

- macOS 10.13 or later
- Administrative privileges
- Internet connectivity to download the Google Drive package

## Configuration Variables

The script uses several key variables that can be customized if needed:

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `weburl` | https://dl.google.com/drive-file-stream/GoogleDrive.dmg | Direct download URL for the Google Drive disk image |
| `appname` | Google Drive | Display name used in logs |
| `app` | Google Drive.app | Folder of the application as installed |
| `logandmetadir` | /Library/Logs/Microsoft/IntuneScripts/GoogleDrive | Directory where logs and the meta file are stored |
| `processpath` | /Applications/Google Drive.app/Contents/MacOS/Google Drive | Full path to the Google Drive process |
| `terminateprocess` | true | Whether to terminate Google Drive if running during installation |
| `autoUpdate` | true | Whether to skip installation if Google Drive is already installed |

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file outputs to ***/Library/Logs/Microsoft/IntuneScripts/GoogleDrive/Google Drive.log*** by default. Exit status is either 0 or 1.

To gather this log with Intune remotely, see [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection).
