# Setup Assistant Skip Keys
Apple provides the capability to skip screens during onboarding of devices using configuration. In Intune, skip keys are available on an enrollment profile, but can also be sent down with custom configuration or plists if the keys aren't available in Intune enrollment profiles yet.

For a full list of skip keys available, see [SkipKeys](https://github.com/apple/device-management/blob/release/other/skipkeys.yaml).

These settings can be deployed alongside the existing enrollment profile configuration using custom profiles or preference files.

As of March 2025, the following skip keys are missing as options in Intune for macOS:
 - Welcome
 - SoftwareUpdate

A sample plist is available in this folder that skips those two screens and can be deployed as a [preference file in Intune](https://learn.microsoft.com/mem/intune-service/configuration/preference-file-settings-macos) with the **com.apple.SetupAssistant.managed** preference domain.
