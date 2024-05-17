# Custom Profiles for Terminal - Full Disk Access

This Custom Profile is required when implementing following CIS or NIST Recommendations for macOS:
- **CIS:** Ensure Remote Login Is Disabled (Automated)
- **CIS:** Ensure Remote Apple Events Is Disabled (Automated)
- **NIST:** Disable SSH Server for Remote Access Sessions
- **NIST:** Disable Remote Apple Events

**NOTE:** This Custom Profile will provide Full Disk Access to Terminal that is required when implementing custom script to disable remote apple events. Otherwise, script is unable to disable remote apple events. Script can be found [here](https://github.com/microsoft/shell-intune-samples/tree/master/macOS/Config/Disable%20Remote%20Apple%20Events)

## Configuration settings for Intune
- **Custom configuration profile name:** *Terminal - Full Disk Access*
- **Deployment channel:** *Device Channel*
- **Configuration profile name:** *Terminal - Full Disk Access.mobileconfig*
