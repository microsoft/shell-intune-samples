# Apple Device Enrollment Profile Group Management

A pair of PowerShell scripts for automatically managing Microsoft Entra ID (Azure AD) security groups based on Apple Device Enrollment Program (DEP) profiles in Microsoft Intune.

## Overview

These scripts work together to maintain dynamic security groups for Apple devices (macOS, iOS, iPadOS) enrolled through specific DEP enrollment profiles. Devices are automatically added to groups based on their enrollment profile, enabling targeted policy deployment and configuration management.

## Scripts

### 1. Manage-EnrollmentProfileGroups.ps1
**Primary synchronization script - Run every 6 hours**

This is the main script that performs comprehensive group management:

- **Creates security groups** for each enrollment profile (if they don't exist)
- **Adds devices** enrolled via specific profiles to their corresponding groups
- **Removes devices** that no longer match the enrollment profile (cleanup)
- **Verifies membership** to ensure all groups are accurate
- Uses **batch API operations** for efficient processing of large device sets
- Provides detailed logging and progress reporting

**Typical Usage:**
```powershell
.\Manage-EnrollmentProfileGroups.ps1 -Prefix "[prefix]" -TokenName "[TokenName]" -CreateGroups -TenantId "your-tenant-id" -ClientId "your-app-id" -CertificateThumbprint "your-cert-thumbprint"
```

### 2. AddNewlyEnrolledDevicesToGroup.ps1
**Fast catch-up script - Run every 1 minute**

This lightweight companion script handles newly enrolled devices between main synchronizations:

- **Monitors for new enrollments** in the last N minutes (configurable, default 10)
- **Quickly adds new devices** to their appropriate groups
- **Skips devices** already in groups (no duplicates)
- Designed for **high-frequency execution** with minimal overhead
- Supports **continuous running mode** for unattended operation
- Does NOT create groups (relies on main script)

**Typical Usage:**
```powershell
.\AddNewlyEnrolledDevicesToGroup.ps1 -Prefix "[prefix]" -TokenName "[TokenName]" -TenantId "your-tenant-id" -ClientId "your-app-id" -CertificateThumbprint "your-cert-thumbprint" -MinutesBack 10
```

## How They Work Together

```
Main Script (Every 6 hours)           Fast Catch-up (Every 1 minute)
┌─────────────────────────┐          ┌──────────────────────────┐
│ • Create missing groups │          │ • Check for new devices  │
│ • Full device inventory │          │   (last 10 minutes)      │
│ • Add missing devices   │    ┌────→│ • Add to existing groups │
│ • Remove invalid members│    │     │ • Skip if already member │
│ • Comprehensive cleanup │    │     │ • Fast, minimal queries  │
└─────────────────────────┘    │     └──────────────────────────┘
         ↓                      │                ↓
   Creates groups and     ─────┘          Fills gaps
   ensures accuracy                    between main runs
```

**Why two scripts?**
- **Main script** is thorough but resource-intensive (queries all devices, all groups)
- **Fast script** is lightweight and handles the most common scenario (new enrollments)
- Together they provide near-real-time group membership with efficient resource usage

## Features

### Both Scripts
- ✅ **Certificate-based authentication** for unattended automation
- ✅ **Interactive authentication** support for manual runs
- ✅ **Configurable logging** with automatic retention management
- ✅ **Custom log directory** support
- ✅ **Graph API optimization** with batch requests
- ✅ **Detailed progress reporting** and verbose mode
- ✅ **Error handling** with automatic retry logic

### Main Script Specific
- ✅ Group creation with customizable naming prefix
- ✅ Full membership reconciliation (add AND remove)
- ✅ HashSet-based lookups for O(1) performance
- ✅ Support for multiple enrollment tokens
- ✅ Interactive or fully automated operation

### Fast Script Specific
- ✅ Time-based filtering (only recent enrollments)
- ✅ Continuous running mode (run for X hours)
- ✅ Configurable check interval
- ✅ Minimal Graph API calls
- ✅ Idempotent (safe to run multiple times)

## Requirements

- **PowerShell 7+** (cross-platform)
- **Microsoft.Graph.Authentication** module
- **Microsoft.Graph.Groups** module (main script)
- **Microsoft.Graph.DeviceManagement** module (main script)
- **Permissions Required:**
  - `DeviceManagementServiceConfig.ReadWrite.All`
  - `DeviceManagementManagedDevices.Read.All`
  - `Group.ReadWrite.All`
  - `Directory.Read.All`

## Setup for Automation

### Option 1: Windows Task Scheduler

**Main Script Task:**
```powershell
# Run every 6 hours
.\Manage-EnrollmentProfileGroups.ps1 -Prefix "[YourPrefix]-" -TokenName "YourTokenName" -CreateGroups -TenantId "tenant-id" -ClientId "app-id" -CertificateThumbprint "cert-thumbprint" -LogPath "C:\Logs" -LogRetentionDays 7
```

**Fast Script Task:**
```powershell
# Run every 1 minute
.\AddNewlyEnrolledDevicesToGroup.ps1 -Prefix "[YourPrefix]-" -TokenName "YourTokenName" -TenantId "tenant-id" -ClientId "app-id" -CertificateThumbprint "cert-thumbprint" -MinutesBack 10 -LogPath "C:\Logs"
```

### Option 2: Azure Automation Runbook

This has not been tested yet but should work. Upload both scripts as runbooks and schedule accordingly using Azure Automation schedules.

## Parameters

### Common Parameters
| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `-Prefix` | Yes | - | Prefix for group names (e.g., "DEP-", "[Company]-") |
| `-TokenName` | No | - | Enrollment token name (prompted if not provided) |
| `-TenantId` | No | - | Azure AD Tenant ID (for cert auth) |
| `-ClientId` | No | - | App Registration Client ID (for cert auth) |
| `-CertificateThumbprint` | No | - | Certificate thumbprint (for cert auth) |
| `-LogRetentionDays` | No | 7 | Days to keep log files |
| `-LogPath` | No | Script dir | Custom directory for log files |

### Main Script Only
| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `-CreateGroups` | No | False | Skip confirmation prompt for group creation |
| `-Verbose` | No | False | Enable detailed console output |

### Fast Script Only
| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `-MinutesBack` | No | 10 | How far back to check for new devices |
| `-RunDurationHours` | No | 0 | Run continuously for N hours (0 = single run) |
| `-CheckIntervalMinutes` | No | 1 | Minutes between checks in continuous mode |

## Example Workflow

1. **Initial Setup** - Run main script manually to create groups:
   ```powershell
   .\Manage-EnrollmentProfileGroups.ps1 -Prefix "DEP-" -TokenName "MyToken" -CreateGroups
   ```

2. **Schedule Main Script** - Every 6 hours via Task Scheduler:
   - Ensures all devices are in correct groups
   - Removes devices that changed profiles
   - Creates any new groups for new profiles

3. **Schedule Fast Script** - Every 1 minute via Task Scheduler:
   - Catches newly enrolled devices immediately
   - Adds them to groups within 1 minute of enrollment
   - Minimal overhead on Graph API

4. **Monitor Logs** - Check log files for issues:
   - `Manage-EnrollmentProfileGroups_YYYYMMDD.log`
   - `AddNewlyEnrolledDevices_YYYYMMDD.log`

## Group Naming Convention

Groups are named using the pattern: `{Prefix}{EnrollmentProfileName}`

**Example:**
- Prefix: `"[prefix]"`
- Enrollment Profile: `"Corporate MacBooks"`
- Resulting Group: `"[prefix]Corporate MacBooks"`

## Performance Optimization

Both scripts use several optimization techniques:

- **Batch API requests** - Process up to 20 devices per Graph API call
- **HashSet lookups** - O(1) membership checks for large device sets
- **Pagination** - Efficient handling of large result sets
- **Caching** - Pre-fetch and reuse group/device data
- **Conditional execution** - Skip unnecessary operations

**Typical Performance:**
- Main script: 1000 devices across 10 groups ≈ 2-3 minutes
- Fast script: 10 new devices ≈ 5-10 seconds

## Logging

Both scripts generate daily log files with:
- Timestamp for each operation
- Log levels: Info, Warning, Error, Success
- Automatic rotation based on retention policy
- Color-coded console output
- Detailed API call tracking

**Log file names:**
- `Manage-EnrollmentProfileGroups_YYYYMMDD.log`
- `AddNewlyEnrolledDevices_YYYYMMDD.log`

## Troubleshooting

**Groups not created:**
- Ensure `-CreateGroups` switch is used in main script
- Check API permissions include `Group.ReadWrite.All`

**Devices not added:**
- Verify devices have `enrollmentProfileName` property populated
- Check that fast script's `-Prefix` matches main script's prefix
- Ensure groups exist (run main script first)

**Authentication failures:**
- Verify certificate is installed in certificate store
- Check app registration has required API permissions with admin consent
- Ensure certificate hasn't expired

**Performance issues:**
- Reduce `-MinutesBack` value in fast script (try 5 minutes)
- Increase main script interval to 12 hours if needed
- Check Graph API throttling limits

## License

MIT License - Feel free to modify and distribute

## Author

Chris Kunze

## Contributing

Issues and pull requests welcome!
