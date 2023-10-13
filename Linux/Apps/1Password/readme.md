# 1Password Install Script

This script installs the latest version of 1Password for Linux.

## Description

1Password is a password manager that keeps all your passwords and other sensitive information safe and secure. This script automates the installation process for 1Password on Linux.

## Prerequisites

Before running the script, make sure you have the following installed:

- Linux operating system
- Bash shell
- Root privileges

## Usage

### Manual Deployment
To use this script, follow these steps:

1. Download the `1PasswordInstall.sh` script to your local machine.
2. Open a terminal window and navigate to the directory where the script is saved.
3. Run the script with root privileges:

### Enpoint Management Deployment
To use this script, follow these steps:

1. Download the `1PasswordInstall.sh` script to your local machine.
2. Open the Microsoft Endpoint Manager admin center and navigate to **Devices > Lunux > Configuration Scripts**.
3. Click **Add** to create a new script.
4. In the **Create profile** pane, enter a name and description for the script and click **Next**.
5. Under **Configuration Settings**
	- Select **Root** as the script **Execution context**.
	- Set **Execution frequency** to **Every 1 day**
	- Set **Execution retries** to **3 times**
	- Select the download bash script `1PasswordInstall.sh` as the **Execution Script** then click **Next**
6. Under **Scope tags**, select prefered tag or just click **Next**.
7. On the **Assignments** page, select the device or user group you want to deploy the script to, then click **Next**.
8. Click **Create** to deploy the script.

The script will now be deployed to the selected device group via Microsoft Intune Endpoint Management.

## Troubleshooting

If you encounter any issues while running the script, try the following:

- Make sure you have the necessary prerequisites installed.
- Check that you have root privileges.
- Verify that the script is saved in the correct directory.


## Disclaimer

This script is provided AS IS without warranty of any kind. The entire risk arising out of the use or performance of the script remains with you. In no event shall the author be liable for any damages whatsoever arising out of the use of or inability to use the script.

## Feedback

If you have any feedback or suggestions, please contact the author at neiljohn@microsoft.com.

## Change Log

- 2023-10-13  -  Installation script created