# macOS Compatibility Checker for Microsoft Intune

This script automatically determines the maximum supported macOS version for any Mac by querying Apple's official GDMF (Global Device Management Framework) API using the device's hardware board identifier.

## Features

✅ **Universal Compatibility** - Works with both Intel and Apple Silicon Macs  
✅ **Zero Maintenance** - No hardcoded device mappings to update  
✅ **Real-time Data** - Queries Apple's live compatibility database  
✅ **Intune Ready** - Clean output format for Custom Attributes  
✅ **Virtual Machine Detection** - Handles VM environments gracefully  
✅ **Robust Fallbacks** - Multiple detection methods for maximum reliability  

## How It Works

The script uses a two-tier hardware detection approach:

### Primary Detection: Board ID Extraction
- **Apple Silicon Macs**: Extracts `target-sub-type` property (e.g., `J514sAP`)
- **Intel Macs**: Extracts `board-id` property and converts to `Mac-XXXXXXXXXXXXXXXX` format

### Fallback Detection: Model ID
- Uses `sysctl hw.model` if board ID extraction fails
- Provides compatibility for edge cases and older systems

### API Query Process
1. Queries Apple's GDMF API at `https://gdmf.apple.com/v2/pmv`
2. Searches for the device identifier in supported device lists
3. Returns the highest compatible macOS version
4. Converts version numbers to marketing names (e.g., "15.0" → "macOS Sequoia")

## Requirements

- **System**: macOS (any version)
- **Architecture**: Intel or Apple Silicon
- **Dependencies**: `curl`, `jq`
- **Network**: Internet connectivity to `gdmf.apple.com`
- **Permissions**: Standard user (no admin required)

### Installing Dependencies

If `jq` is not installed:

```bash
# Using Homebrew
brew install jq

# Using MacPorts
sudo port install jq
```

## Usage

### Command Line
```bash
# Make executable
chmod +x macOSCompatibilityChecker.zsh

# Run the script
./macOSCompatibilityChecker.zsh
```

### Microsoft Intune Custom Attribute

1. **Upload Script**: Add `macOSCompatibilityChecker.zsh` to Intune as a Shell Script
2. **Configuration**:
   - **Run script as**: Standard User
   - **Script**: Upload the `.zsh` file
   - **Max retries**: 3
3. **Deployment**: Assign to target Mac groups

## Sample Output

The script returns clean, human-readable version names:

```bash
macOS Sequoia      # Mac supports macOS 15.x
macOS Sonoma       # Mac supports macOS 14.x  
macOS Ventura      # Mac supports macOS 13.x
macOS Monterey     # Mac supports macOS 12.x
macOS Big Sur      # Mac supports macOS 11.x
Virtual Machine    # Running in VM environment
```

## Architecture Support

| Mac Type | Detection Method | Example Board ID | Status |
|----------|------------------|------------------|--------|
| Apple Silicon | `target-sub-type` | `J514sAP` | ✅ Supported |
| Intel Mac | `board-id` → ASCII | `Mac-1E7E29AD0135F9BC` | ✅ Supported |
| Virtual Machine | Model detection | `VirtualMac*` | ✅ Handled |

## Error Handling

The script includes comprehensive error handling:

- **Network Issues**: Graceful failure with fallback methods
- **Missing Dependencies**: Clear error messages for missing tools
- **Unknown Hardware**: Reports device ID for troubleshooting
- **API Changes**: Robust JSON parsing with validation

## Troubleshooting

### Common Issues

**Script returns "Unknown Model"**
- Check internet connectivity to `gdmf.apple.com`
- Verify `jq` is installed and accessible
- Run with debug: `bash -x ./macOSCompatibilityChecker.zsh`

**Permission errors**
- Script should run as standard user
- Ensure file is executable: `chmod +x macOSCompatibilityChecker.zsh`

**Network connectivity**
```bash
# Test GDMF API access
curl -fsSL https://gdmf.apple.com/v2/pmv | jq '.PublicAssetSets.macOS[0].ProductVersion'
```

### Manual Board ID Check

```bash
# Apple Silicon
ioreg -rd1 -c IOPlatformExpertDevice | grep "target-sub-type"

# Intel Mac  
ioreg -rd1 -c IOPlatformExpertDevice | grep "board-id"
```

## Technical Details

### Apple GDMF API Structure
The script leverages Apple's official device compatibility API:
- **Endpoint**: `https://gdmf.apple.com/v2/pmv`
- **Format**: JSON with nested device arrays
- **Update Frequency**: Real-time with Apple releases
- **Coverage**: All supported Mac hardware

### Version Mapping
| macOS Version | Marketing Name | Major Version |
|---------------|----------------|---------------|
| 15.x | macOS Sequoia | 15 |
| 14.x | macOS Sonoma | 14 |
| 13.x | macOS Ventura | 13 |
| 12.x | macOS Monterey | 12 |
| 11.x | macOS Big Sur | 11 |

## Benefits Over Static Approaches

### ❌ Previous Method (Hardcoded Mappings)
- Required manual updates for new hardware
- Maintenance overhead with each Mac release
- Risk of outdated compatibility data
- Separate scripts for different macOS versions

### ✅ Current Method (Dynamic API Query)
- Automatically supports new hardware
- Always current with Apple's official data
- Single script for all macOS versions
- Zero maintenance requirements

## Enterprise Deployment

### Intune Custom Attributes Benefits
- **Inventory Reporting**: Track Mac compatibility across fleet
- **Upgrade Planning**: Identify devices ready for new macOS versions
- **Compliance Monitoring**: Ensure devices meet version requirements
- **Automated Grouping**: Create dynamic groups based on compatibility

### Example Intune Use Cases
1. **Pre-Upgrade Assessment**: Identify Macs ready for macOS Sequoia
2. **Hardware Lifecycle**: Track aging devices approaching EOL
3. **Compliance Reporting**: Document supported versions for audits
4. **Conditional Access**: Restrict access based on OS compatibility

## License

This script is part of the Microsoft Intune Shell Script Samples repository and follows the same licensing terms.

## Contributing

For issues, improvements, or questions:
1. Check existing issues in the parent repository
2. Submit detailed bug reports with system information
3. Include script output and error messages
4. Test proposed changes across Intel and Apple Silicon Macs

---

**Last Updated**: Compatible with all macOS versions through Sequoia (15.x)
**Supported Hardware**: All Intel and Apple Silicon Mac models
**API Dependency**: Apple GDMF v2 (gdmf.apple.com)
