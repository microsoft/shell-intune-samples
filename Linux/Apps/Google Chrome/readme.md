# Google Chrome Install Script

This script installs the latest version of Google Chrome on Linux.

## Description

Google Chrome is a popular web browser that provides fast and secure browsing experience. This script automates the installation process for Google Chrome on Linux.

## Prerequisites

Before running the script, make sure you have the following installed:

- Linux operating system
- Bash shell
- Root privileges

## Usage

### Manual Deployment
To use this script, follow these steps:

1. Download the `googleChromeInstall.sh` script to your local machine.
2. Open a terminal window and navigate to the directory where the script is saved.
3. Run the script with root privileges:
    - chmod +x ./googleChromeInstall.sh
    - sudo ./googleChromeInstall.sh

## Endpoint Management Deployment
To deploy this script via Microsoft Endpoint Manager, follow these steps:

1. Download the googleChromeInstall.sh script to your local machine.
2. Open the Microsoft Endpoint Manager admin center and navigate to Devices > Linux > Configuration Scripts.
3. Click Add to create a new script.
4. In the Create profile pane, enter a name and description for the script and click Next.
5. Under Configuration Settings
    - Select Root as the script Execution context.
    - Set Execution frequency to Every 1 day
    - Set Execution retries to 3 times
    - Select the downloaded bash script googleChromeInstall.sh as the Execution Script then click Next
6. Under Scope tags, select preferred tag or just click Next.
7. On the Assignments page, select the device or user group you want to deploy the script to, then click Next.
8. Click Create to deploy the script.

The script will now be deployed to the selected device group via Microsoft Endpoint Manager.

## Troubleshooting
If you encounter any issues while running the script, try the following:
- Make sure you have the necessary prerequisites installed.
- Check that you have root privileges.
- Verify that the script is saved in the correct directory.

## Disclaimer
This script is not supported under any Microsoft standard support program or service. The script is provided AS IS without warranty of any kind. Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the script and documentation remains with you. In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the script be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample script or documentation, even if Microsoft has been advised of the possibility of such damages.

## Feedback
If you have any feedback or suggestions, please contact the author at neiljohn@microsoft.com.

## Change Log
- 2020-06-01 - Installation script created
- 2020-07-03 - Stopped using apt in favor of apt-get to remove additional warnings
- 2020-07-12 - Implemented new error handling and improved if statements
- 2020-07-14 - Fixed if statement for chrome validation to work on install status
- 2020-10-13 - Created readme.md
