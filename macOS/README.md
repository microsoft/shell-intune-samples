        ____      __                                           ____  _____
       /  _/___  / /___  ______  ___     ____ ___  ____ ______/ __ \/ ___/
       / // __ \/ __/ / / / __ \/ _ \   / __ `__ \/ __ `/ ___/ / / /\__ \ 
     _/ // / / / /_/ /_/ / / / /  __/  / / / / / / /_/ / /__/ /_/ /___/ / 
    /___/_/ /_/\__/\__,_/_/ /_/\___/  /_/ /_/ /_/\__,_/\___/\____//____/  
                                                                      

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
   |---AdobeAcrobatReaderDC
   |---Cisco AMP
   |---Citrix Workspace
   |---Company Portal
   |---Defender
   |---Edge
   |---FileZilla
   |---Gimp
   |---Google Drive
   |---ImageOptim
   |---LatestSampleScript
   |---Minecraft Education Edition
   |---Nudge
   |---Office for Mac
   |-----MAU Plist
   |-----Outlook
   |---Palo Alto Global Protect
   |---Parallels Desktop Tools
   |---Python
   |---Remote Desktop
   |---Skype for Business
   |---Sonos S2
   |---Teams
   |---VMware Horizon Client
   |---Visual Studio Code
   |---WhatsApp
   |---Zoom
   |---Zscaler
   |---gitHub Desktop
```

## Config

This section is for scripts that do general macOS configurations. This is an Alladin's cave of scripts to get your Macs in shape. Feel free to submit your own examples too, we'd love to get contributions.

```
   |-Config
   |---DeviceRename
   |---Dock
   |---EnableOneDriveFinderSync
   |---FileVault
   |---MDATP
   |---Manage Accounts
   |---Octory
   |---Rosetta2
   |---Wallpaper
   |---enableScreenSharing
   |---mdmDiagnose
   |---setTimeZone
```

## Custom Attributes

This section is for example [Custom Attributes](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#custom-attributes-for-macos) for deployment via Intune. These come from customer requirements and are stored here for the community.

```
   |---Battery Condition
   |---CPU Architecture
   |---Check bootstrap token escrow status
   |---Fetch Defender Version
   |---Fetch OneDrive Version
   |---Fetch Sidecar Version
   |---Gimp
   |---Hackintosh
   |---Physical RAM
   |---checkDefenderRunning
```

## Custom Profiles

This section is for example Custom Profiles for deployment via Intune. These come from various places, either hand written, Apple Condigurator 2 or OS X Server Manager's Profile Manager. Our aim is to have everything in here written into the Intune UI directly, but while we're working on that we're storing some useful profiles here.

```
   |-Custom Profiles
   |---Disable External Storage
   |---Notifications
   |---SoftwareUpdate
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
