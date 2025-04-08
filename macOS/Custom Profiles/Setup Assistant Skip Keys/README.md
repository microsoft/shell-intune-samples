# Setup Assistant Skip Keys
In Intune, skip keys are available on an [enrollment profile](https://learn.microsoft.com/en-us/intune/intune-service/enrollment/device-enrollment-program-enroll-macos#setup-assistant-screen-reference), but can also be sent down with custom configuration or plists if the keys aren't available in Intune enrollment profiles yet.

For a full list of skip keys available, see [SkipKeys](https://github.com/apple/device-management/blob/release/other/skipkeys.yaml).

**Note:** Whenever possible, use the [built-in Setup Assistant options in the enrollment profile](https://learn.microsoft.com/en-us/intune/intune-service/enrollment/device-enrollment-program-enroll-macos#setup-assistant-screen-reference). The configurations in this folder should only be used for skip keys that aren't yet available in the Intune enrollment profile interface. Where there is a clash, the setting from the enrollment profile will take precendence over the custom policy.

## Sample Configuration Files

### Individual Skip Keys
The `skipKeyExample.plist` file is available in this folder that skips Welcome and SoftwareUpdate and can be deployed as a [preference file in Intune](https://learn.microsoft.com/mem/intune-service/configuration/preference-file-settings-macos) with the **com.apple.SetupAssistant.managed** preference domain.

### Skip All Screens
For environments where you want to bypass as much of the Setup Assistant experience, you can use the `SkipAllmacOS.mobileconfig` file included in this folder. This configuration sets all available skip keys to true.

The `SkipAllmacOS.mobileconfig` can be deployed as a [custom configuration profile](https://learn.microsoft.com/en-us/mem/intune/configuration/custom-settings-macos) in Intune, providing a completely silent onboarding experience.
