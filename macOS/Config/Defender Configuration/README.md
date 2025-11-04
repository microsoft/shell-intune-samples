# Add Defender Config Profiles to Intune
This script is used to download the [mobileconfig files for Defender](https://github.com/microsoft/mdatp-xplat/tree/master/macos/mobileconfig/profiles) and add them to your Intune tenant.  

## Script Settings
This is a PowerShell script run from the console to get the [mobileconfig files for Defender](https://github.com/microsoft/mdatp-xplat/tree/master/macos/mobileconfig/profiles) and add them to your Intune tenant. You must have the Microsoft Graph PowerShell SDK installed. Run this command if you haven't installed it yet:

Install-Module Microsoft.Graph -Scope CurrentUser


