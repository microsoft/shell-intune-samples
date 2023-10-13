## Contents <!-- omit in toc -->

- [Deployment](#deployment)
    - [Profile: FileVault Escrow](#profile-filevault-escrow)
    - [Shell script: Install Escrow Buddy](#shell-script-install-escrow-buddy)
- [Authorization database maintenance](#authorization-database-maintenance)
- [Removal](#removal)

## Deployment

For initial deployment of Escrow Buddy, Intune administrators can follow this template:

### Profile: FileVault Escrow

This profile ensures all new FileVault keys are escrowed to Intune at next MDM Protocol Checkin. If you already have a FileVault profile deployed, you can skip this part.

- **Endpoint security** > **Disk encryption** > **Create Policy** > **Platform: macOS** > **Profile: FileVault** 
    - **Enable FileVault**: Yes
    - **Personal recovery key rotation**: Configure how often they key should be rotated
    - **Escrow location description of personal recovery key**: (Company name)
    - **Assignments**: All Devices

### Shell script: Install Escrow Buddy

To deploy Escrow Buddy to devices managed by Intune, a shell script will be used. This script performs several key functions to install and maintain Escrow Buddy on macOS devices,
- Installs the application
- Updates the application if needed
- Checks that Escrow Buddy is in the Authorization Database, if not, installs again
- Checks if a FileVault profile has been installed and that the key has been escrowed. If it hasn't Escrow Buddy is configured to generate a new key

Download the current version of the deployment script [here](https://github.com/microsoft/shell-intune-samples/blob/master/macOS/Config/Escrow%20Buddy/installEscrowBuddyIntune.sh).

To deploy the script below, follow these steps:
- Navigate to **Devices** > **Scripts**, click **Add** > **macOS** 
    - Give the script policy a **Name**, for example **Escrow Buddy**
    - Upload the downloaded deployment script
    - **Run script as signed-in user**: No
    - **Hide script notifications on devices**: Yes
    - **Script frequency**: Every 1 week
    - **Max number of times to retry if script fails**: 3 times
    - **Assignments**: All Devices
        - If you have devices enrolled as Personal on which a FileVault key will not be shown either way, a dynamic group can be used to only target Corporate macOS devices. To target Corporate macOS devices, create a dynamic device group with the following Rule syntax: (device.deviceOSType -eq "MacMDM") and (device.deviceOwnership -eq "Company")

## Authorization database maintenance
As stated in the Shell Script part, this maintenance is handled by the script deployed in Intune running on a recurring schedule.

## Removal
To uninstall Escrow Buddy using Intune, you can use a shell script policy without any Script Frequency configured with the [uninstall script here](https://github.com/macadmins/escrow-buddy/blob/main/scripts/uninstall.sh) attached.