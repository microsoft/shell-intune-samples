# Disable Media Sharing
This Custom Profile is required when implementing following CIS or NIST Recommendations for macOS: 
- **CIS**: Ensure Media Sharing Is Disabled (Automated)
- **NIST**: Disable Media Sharing

**Note**: The Media Sharing preference panel will still allow "Home Sharing" and "Share media with guests" to be checked but the service will not be enabled.

## Configuration settings for Intune
- **Custom configuration profile name:** *System Settings - Disable Media Sharing*
- **Deployment channel:** *Device Channel*
- **Configuration profile name:** *Disable Media Sharing.mobileconfig*
