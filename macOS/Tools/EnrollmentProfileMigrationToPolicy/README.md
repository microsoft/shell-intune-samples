# Enrollment Profile Migration To Enrollment Policy (Convert-ECv1ToECv2)

A PowerShell script that converts **ECv1** Apple Automated Device Enrollment (ADE) enrollment profiles into **ECv2** device configuration policies in Microsoft Intune via the Microsoft Graph API.

## What it does

The script reads ECv1 enrollment profiles (`depIOSEnrollmentProfile` and `depMacOSEnrollmentProfile`) and converts them to equivalent ECv2 device configuration policies. It maps each ECv1 setting (Setup Assistant screens, user affinity, authentication method, device name templates, etc.) to the corresponding ECv2 setting definitions and creates the new policies in your tenant.

Key capabilities:

- Converts **iOS/iPadOS** and **macOS** ADE enrollment profiles.
- Supports converting a **single profile**, **all profiles under one ADE token**, or **all profiles across all ADE tokens** in the tenant.
- **Dry-run mode** to analyze what can/can't be converted without creating anything.
- Generates an **HTML conversion report** documenting results, including the IDs of any ECv2 policies created.
- **Cleanup mode** to delete ECv2 policies that a previous run created, using the report as input.
- Works across multiple cloud environments: **Commercial, Canary, USGov, USGovDoD, and China**.

## Prerequisites

- **PowerShell** (5.1 or PowerShell 7+).
- The **Microsoft Graph PowerShell SDK** (provides `Connect-MgGraph`, `Invoke-MgGraphRequest`, etc.):
  ```powershell
  Install-Module Microsoft.Graph -Scope CurrentUser
  ```
- An account with permission to consent to / use the following Graph scopes:
  - `DeviceManagementConfiguration.ReadWrite.All`
  - `DeviceManagementServiceConfig.ReadWrite.All`

The script calls `Connect-MgGraph` automatically and will prompt you to sign in.

## Parameters

| Parameter | Description |
|-----------|-------------|
| `-Environment` | Cloud environment to target. One of `Commercial` (default), `Canary`, `USGov`, `USGovDoD`, `China`. |
| `-CanaryApiVersion` | Canary API version path segment (e.g. `testprodbeta_Intune_SH`). **Required** when `-Environment Canary`. |
| `-TenantName` | Entra ID tenant name (domain, e.g. `contoso.onmicrosoft.com`) or tenant ID (GUID) to authenticate against. If omitted, the signed-in account's default/home tenant is used. |
| `-ConversionMode` | What to convert: `Single`, `Token`, or `All`. If omitted, an interactive menu is shown. |
| `-TokenId` | The ADE token ID. Required for `Single` and `Token` modes. |
| `-ProfileId` | The enrollment profile ID. Required for `Single` mode. |
| `-OutputPath` | Path for the HTML conversion report. Defaults to the script directory. |
| `-V2PolicyPrefix` | Prefix for converted ECv2 policy names. Defaults to `ECv2`. Resulting name is `<prefix> <ECv1 profile name>`. |
| `-DryRun` | Analyze only — no policies are created. Produces a report of what can/can't convert. |
| `-CleanupFromReport` | Path to a previously generated HTML report. Deletes the ECv2 policies it created (after confirmation). |

## Usage

### Interactive menu (default)
```powershell
.\Convert-ECv1ToECv2.ps1
```

### Convert a single profile
```powershell
.\Convert-ECv1ToECv2.ps1 -ConversionMode Single -TokenId "abc-123" -ProfileId "def-456"
```

### Convert all profiles under a specific ADE token
```powershell
.\Convert-ECv1ToECv2.ps1 -ConversionMode Token -TokenId "abc-123"
```

### Convert all profiles across all ADE tokens
```powershell
.\Convert-ECv1ToECv2.ps1 -ConversionMode All
```

### Dry-run analysis (no policies created)
```powershell
.\Convert-ECv1ToECv2.ps1 -ConversionMode All -DryRun
```

### Custom ECv2 policy name prefix
```powershell
.\Convert-ECv1ToECv2.ps1 -ConversionMode All -V2PolicyPrefix "Converted"
```

### Canary environment
```powershell
.\Convert-ECv1ToECv2.ps1 -Environment Canary -CanaryApiVersion "testprodbeta_Intune_SH"
```

### US Government environment
```powershell
.\Convert-ECv1ToECv2.ps1 -Environment USGov -ConversionMode All
```

### Authenticate against a specific tenant
```powershell
.\Convert-ECv1ToECv2.ps1 -TenantName "contoso.onmicrosoft.com" -ConversionMode All
```

### Clean up ECv2 policies created by a previous conversion
```powershell
.\Convert-ECv1ToECv2.ps1 -CleanupFromReport "C:\reports\ECv1-to-ECv2-ConversionReport_20260609_103138.html"
```

## Output

Each conversion run produces a timestamped **HTML report** (e.g. `ECv1-to-ECv2-ConversionReport_<timestamp>.html`) in the output directory. The report includes:

- Tenant and signed-in user information.
- Per-profile conversion status (success, skipped, or failed) for iOS and macOS.
- The names and IDs of any ECv2 policies created — used later by `-CleanupFromReport`.

## Recommended workflow

1. Run with `-DryRun` first to review what will be converted.
2. Run the actual conversion (`-ConversionMode Single | Token | All`).
3. Review the generated HTML report and validate the new ECv2 policies in Intune.
4. If you need to roll back, run with `-CleanupFromReport` and the report file to delete the created policies.

## License

See LICENSE file for details.
