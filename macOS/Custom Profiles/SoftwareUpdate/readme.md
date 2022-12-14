# Custom Profile to provide controls over com.apple.SoftwareUpdate

Latest on com.apple.SoftwareUpdate can be found in the [Apple Documentation](https://developer.apple.com/documentation/devicemanagement/softwareupdate)

To understand how to use this profile with Intune, see the following doc page on [Add a property list file to macOS devices using Microsoft Intune](https://docs.microsoft.com/en-us/mem/intune/configuration/preference-file-settings-macos)

This profile grants the following

```
<key>AutomaticCheckEnabled</key>
<true/>
<key>AutomaticDownload</key>
<true/>
<key>AutomaticallyInstallMacOSUpdates</key>
<true/>
<key>ConfigDataInstall</key>
<true/>
<key>CriticalUpdateInstall</key>
<true/>
```
