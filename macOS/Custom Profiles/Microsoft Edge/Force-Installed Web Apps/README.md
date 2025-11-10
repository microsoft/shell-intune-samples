# Force-Installed Web Apps for Microsoft Edge

In corporate environments, you might come across situations where you need to deploy managed Web Apps to different user groups or regions. In such cases, you should not deploy Web Apps using your baseline policy, as it applies to all users. Instead, deploy managed Web Apps to specific user groups or regions using a custom profile.

This custom profile provides an example of how to deploy managed Web Apps for Microsoft Edge to a specific user group or region.

## Things You'll Need to Do
- In lines 52 and 59, replace the placeholder URL `https://www.contoso.com/maps` with the URL of your Web App.
- If you need to deploy multiple Web Apps or want to understand what the settings in this custom profile do (and what other options are available), refer to the Microsoft documentation and modify the custom policy as needed:
  - **[WebAppInstallForceList](https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/webappsettings)**
  - **[WebAppSettings](https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/webappsettings)**
- In Intune, deploy the custom profile to a specific security group that contains members of the desired user group or region.

## Configuration Settings for Intune
- **Custom configuration profile name:** *Microsoft Edge - Force-Installed Web Apps*
- **Deployment channel:** *Device Channel*
- **Configuration profile file name:** *Microsoft Edge - Force-Installed Web Apps.mobileconfig*
