# Intune macOS Shell Script Samples

This repository is for macOS Intune sample scripts and custom configuration profiles. There are many cases where it is necessary to use a custom profile or shell script to accomplish a task.

To get started, check out the following documentation
- [Set up enrollment for macOS devices in Intune](https://docs.microsoft.com/en-us/mem/intune/enrollment/macos-enroll)
- ***[Use shell scripts on macOS devices in Intune](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts)***
- [macOS settings to mark devices as compliant or not compliant using Intune](https://docs.microsoft.com/en-us/mem/intune/protect/compliance-policy-create-mac-os)
- [macOS device settings to allow or restrict features using Intune](https://docs.microsoft.com/en-us/mem/intune/configuration/device-restrictions-macos)
- [Add macOS system and kernel extensions in Intune](https://docs.microsoft.com/en-us/mem/intune/configuration/kernel-extensions-overview-macos)
- [Add a property list file to macOS devices using Microsoft Intune](https://docs.microsoft.com/en-us/mem/intune/configuration/preference-file-settings-macos)
- [Add and use wired networks settings on your macOS devices in Microsoft Intune](https://docs.microsoft.com/en-us/mem/intune/configuration/wired-networks-configure)
- [Create a profile with custom settings in Intune](https://docs.microsoft.com/en-us/mem/intune/configuration/custom-settings-configure)
- [Add iOS, iPadOS, or macOS device feature settings in Intune](https://docs.microsoft.com/en-us/mem/intune/configuration/device-features-configure)
- [How to manage iOS and macOS apps purchased through Apple Volume Purchase Program with Microsoft Intune](https://docs.microsoft.com/en-us/mem/intune/apps/vpp-apps-ios)

To make things a little easier to navigate the repo has been split up into three main sections:

## Apps

This section is for scripts that install or configure applications on the Mac. There are many reasons to deploy apps via shell script rather than via the macOS mdmclient. Our preferred method of app deployment is via the [Mac App Store VPP](https://docs.microsoft.com/en-us/mem/intune/apps/vpp-apps-ios), but the Intune Scripting agent provides an almost infinte level of possibilities where the apps you need on your Macs can't be deployed via VPP.

```
|-Apps
|---Company Portal
|---Minecraft Education Edition
|---Office for Mac
|---Remote Desktop
|---Skype
|---Teams
|---Visual Studio Code
|---Yammer
|---gitHub Desktop
```
## Misc

This section is for scripts that do general macOS configurations. This is an Alladin's cave of scripts to get your Macs in shape. Feel free to submit your own examples too, we'd love to get contributions.

```
|-Misc
|---CompanyPortalPreferences
|---Dock
|---EnableOneDriveFinderSync
|---MDATP
|---Wallpaper
|---setTimeZone
```

## Custom Profiles

This section is for example Custom Profiles for deployment via Intune. These come from various places, either hand written, Apple Condigurator 2 or OS X Server Manager's Profile Manager. Our aim is to have everything in here written into the Intune UI directly, but while we're working on that we're storing some useful profiles here.

```
├── Custom\ Profiles
│   └── Disable\ External\ Storage
├── LOBAppPrep
```

### Disclaimer
Understand the impact of each sample script prior to running it; samples should be run in a non-production or "test" environment.

### Contributing
This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
