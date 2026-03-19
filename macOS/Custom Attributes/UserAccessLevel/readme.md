# User Access Level Custom Attribute

## Overview

This custom attribute script determines whether the current console user on a macOS device has administrator or standard user privileges. This is useful for compliance reporting, conditional access policies, and device inventory management in Microsoft Intune.

## Script Details

- **File**: `UserAccessLevel.zsh`
- **Language**: zsh
- **Execution Context**: User context
- **Output Values**: 
  - `admin` - User has administrator privileges
  - `standard` - User has standard user privileges
  - `No user logged in` - No user is currently logged in

## Deployment in Microsoft Intune

### Prerequisites

- Microsoft Intune tenant with macOS device management
- Devices enrolled in Intune
- Appropriate permissions to create and deploy shell scripts

### Steps to Deploy

1. **Navigate to Intune Admin Center**
   - Go to [https://intune.microsoft.com](https://intune.microsoft.com)
   - Navigate to **Devices** > **macOS** > **Custom Attributes**

2. **Create New Custom Attribute**
   - Click **+ Add**
   - Configure the following settings:

3. **Basic Information**
   - **Name**: `User Access Level`
   - **Description**: `Detects if the current console user is an admin or standard user`

4. **Script Settings**
   - **Upload the script file**: `UserAccessLevel.zsh`
   - **Run script as signed-in user**: `No` (script needs to run in system context to query user privileges)
   - **Hide script notifications on devices**: `Yes`
   - **Script frequency**: Choose based on your needs (e.g., Every 1 day)
   - **Max number of times to retry if script fails**: `3`

5. **Assign to Groups**
   - Select the device groups or users you want to target
   - Click **Next** and then **Create**

## Using the Custom Attribute

### Viewing Results

After deployment, you can view the results:

1. Go to **Devices** > **All devices**
2. Select a macOS device
3. Click on **Custom Attributes**
4. Look for the "User Access Level" attribute

### Creating Dynamic Groups

Use this attribute to create dynamic device groups:

**Example Rule for Admin Users:**
```
(device.extensionAttribute1 -eq "admin")
```

**Example Rule for Standard Users:**
```
(device.extensionAttribute1 -eq "standard")
```

*Note: The extension attribute number may vary based on your configuration.*

### Compliance Policies

You can reference this custom attribute in compliance policies to:
- Ensure certain devices only have standard users
- Identify devices where users have excessive privileges
- Trigger conditional access based on user privilege level

## Use Cases

- **Security Compliance**: Identify devices where users shouldn't have admin rights
- **Privilege Management**: Track admin vs. standard user distribution
- **Conditional Access**: Restrict access to sensitive resources based on user privilege level
- **Reporting**: Generate reports on user privilege levels across your fleet
- **Automated Remediation**: Trigger actions based on detected privilege levels

## Troubleshooting

### Script Returns "No user logged in"

This occurs when:
- No user is currently logged into the device
- The device is at the login screen
- The script runs before a user session is established

**Solution**: This is expected behavior. The script will return proper values once a user logs in.

### Unexpected Results

If the script returns unexpected results:

1. **Verify script execution**: Check Intune logs for script execution errors
2. **Test locally**: Run the script manually on a test device:
   ```bash
   sudo zsh /path/to/UserAccessLevel.zsh
   ```
3. **Check permissions**: Ensure the script has execute permissions

### Script Not Running

If the custom attribute isn't updating:

1. Verify the device is checking in with Intune regularly
2. Check the script frequency settings
3. Review device sync status in Intune

## Technical Details

### How It Works

1. Retrieves the current console user using `stat -f '%Su' /dev/console`
2. Checks if the user exists and is logged in
3. Queries the `dseditgroup` command to check admin group membership
4. Returns "admin" or "standard" based on membership status

### Compatibility

- **macOS Versions**: 10.15 (Catalina) and later
- **Shell**: zsh (macOS default shell since Catalina)
- **Intune Compatibility**: All versions supporting macOS custom attributes

## Additional Resources

- [Microsoft Intune macOS Device Management Documentation](https://docs.microsoft.com/en-us/mem/intune/configuration/custom-settings-macos)
- [Shell Scripts in Intune](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts)

## Support

For issues or questions:
- Review Intune device logs
- Check script execution history in Intune portal
- Test script execution locally on affected devices

## Version History

- **v1.0** - Initial release with admin/standard user detection
