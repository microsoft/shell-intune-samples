# Scripts to configure Company Portal & Intune MDM agent preferences

These scripts attempt to configure the Company Portal and Intune MDM agent user preference for sending usage data to Microsoft. The preference applies at app-launch.

>Note:
>This script applies to Company Portal version 2.6 or higher and Intune macOS MDM agent version 2011.x or higher.

## disableClientTelemetry.sh
This script attempts to disable the setting under **Company Portal > Preferences > Allow Microsoft to collect usage data.** This will disable sending usage data for both Company Portal and Intune MDM agent for macOS.

## enableClientTelemetry.sh
This script attempts to enable the setting under **Company Portal > Preferences > Allow Microsoft to collect usage data.** This will enable sending usage data for both Company Portal and Intune MDM agent for macOS.

## Script Settings

- Run script as signed-in user : Yes
- Hide script notifications on devices : Not configured
- Script frequency : Daily
- Max number of times to retry if script fails : 3
