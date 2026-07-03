# PSSOForge — PowerShell Script

**Platform SSO (PSSO) Settings Catalog profile generator for Microsoft Intune.**

PSSOForge is an interactive wizard that produces a ready-to-import Microsoft Graph Settings Catalog JSON file containing Extensible SSO and Platform SSO settings for macOS devices managed through Microsoft Intune.

---

## Requirements

| Requirement | Details |
|---|---|
| **PowerShell** | 7.0 or later (cross-platform) |
| **Microsoft.Graph module** | Required only for the Intune push feature |

Install the Graph module (optional):

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
```

---

## Quick Start

```powershell
# Run the interactive wizard
./pssoforge.ps1

# Use a configuration file instead
./pssoforge.ps1 -InputFile config.json

# Set a custom output directory
./pssoforge.ps1 -OutputPath ./profiles

# Set a custom profile name
./pssoforge.ps1 -ProfileName "My Custom PSSO Profile"

# Push directly to Intune (skips the interactive upload prompt)
./pssoforge.ps1 -TenantId "00000000-0000-0000-0000-000000000000"
```

---

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `-InputFile` | `string` | No | Path to a JSON configuration file. Skips the interactive wizard. |
| `-TenantId` | `string` | No | Entra tenant ID (GUID). Pushes the profile to Intune via Microsoft Graph. |
| `-OutputPath` | `string` | No | Directory for the generated JSON file. Defaults to the current directory. |
| `-ProfileName` | `string` | No | Custom policy name. Default: `macOS \| PSSO <TenantName> (<SE\|PSync>)` |

---

## Interactive Wizard

When run without `-InputFile`, the script walks through 9 questions (some conditional):

| # | Question | Details |
|---|---|---|
| Q1 | **Tenant display name** | Used in the policy name and `AccountDisplayName`. Single entry, required. |
| Q2 | **Authentication method** | `Secure Enclave` (recommended) or `Password Sync`. |
| Q3 | **Registration during Setup Assistant** | Enables `EnableRegistrationDuringSetup`. |
| Q4 | **SAMAccountName used by LAPS?** | *Only asked if Q3 = Yes.* Controls `EnableCreateFirstUserDuringSetup` (inverted logic). Forced to `false` when Q3 = No. |
| Q5 | **Main user role** | `Standard` (recommended) or `Admin`. |
| Q6 | **Multi-user Mac** | Enables `EnableCreateUserAtLogin` for shared devices. |
| Q7 | **New user role** | *Only asked if Q6 = Yes.* Sets `NewUserAuthorizationMode`. |
| Q8 | **Managed admin account(s) exist?** | Determines whether `NonPlatformSSOAccounts` is included. |
| Q9 | **Managed admin name(s)** | *Only asked if Q8 = Yes.* Supports multiple entries. |

After generating the file, the script asks whether to upload the profile directly to an Intune tenant. If you accept, it prompts for the Tenant ID (GUID) and pushes via Microsoft Graph.

> **Note:** The upload prompt is skipped when `-TenantId` is provided as a parameter.

---

## Input File Schema

To skip the wizard, provide a JSON file with `-InputFile`:

```json
{
  "schemaVersion": 1,
  "accountDisplayName": "Contoso",
  "authenticationMethod": "UserSecureEnclaveKey",
  "enableRegistrationDuringSetup": true,
  "createFirstUserDuringSetup": true,
  "userAuthorizationMode": "Standard",
  "enableCreateUserAtLogin": false,
  "newUserAuthorizationMode": "Standard",
  "nonPlatformSSOAccounts": ["admin"]
}
```

| Field | Type | Required | Values |
|---|---|---|---|
| `schemaVersion` | `int` | No | Always `1`. Defaults to `1` if omitted. |
| `accountDisplayName` | `string` | **Yes** | Tenant display name. |
| `authenticationMethod` | `string` | **Yes** | `UserSecureEnclaveKey` or `Password` |
| `enableRegistrationDuringSetup` | `bool` | **Yes** | `true` / `false` |
| `createFirstUserDuringSetup` | `bool` | **Yes** | `true` / `false` |
| `userAuthorizationMode` | `string` | **Yes** | `Admin` or `Standard` |
| `enableCreateUserAtLogin` | `bool` | **Yes** | `true` / `false` |
| `newUserAuthorizationMode` | `string` | No | `Admin` or `Standard`. Only relevant when `enableCreateUserAtLogin` is `true`. |
| `nonPlatformSSOAccounts` | `string[]` | No | List of local accounts excluded from PSSO. |

---

## Output

The script generates a Settings Catalog JSON file in the Intune export format:

```
macOS _ PSSO Contoso (SE)_2026-05-29T14_30_00.000Z.json
```

This file can be:

- **Imported into Intune** via *Devices → Configuration → Import policy*
- **Pushed directly** using the built-in Graph upload feature

### Fixed settings (not configurable)

These values are always included and cannot be changed by the wizard:

| Setting | Value |
|---|---|
| Extension Identifier | `com.microsoft.CompanyPortalMac.ssoextension` |
| Team Identifier | `UBF8T346G9` |
| Type | Redirect |
| SSO URLs | `login.microsoftonline.com`, `login.microsoft.com`, `sts.windows.net` |
| UseSharedDeviceKeys | `true` |
| RegistrationToken | `{{DEVICEREGISTRATION}}` |
| ScreenLockedBehavior | `DoNotHandle` |
| TokenToUserMapping | AccountName + FullName |

---

## Intune Push

The script can push the generated profile directly to Intune using the Microsoft Graph PowerShell SDK.

**Via parameter:**

```powershell
./pssoforge.ps1 -TenantId "00000000-0000-0000-0000-000000000000"
```

**Via interactive prompt** (asked at the end of the wizard):

```
Do you want to upload this profile directly to an Intune tenant? [y/N]: y
  Enter the Tenant ID (GUID): 00000000-0000-0000-0000-000000000000
```

The script uses the `DeviceManagementConfiguration.ReadWrite.All` scope and authenticates interactively through `Connect-MgGraph`.

---

## Examples

### Basic wizard run

```powershell
./pssoforge.ps1
```

### Generate to a specific folder with a custom name

```powershell
./pssoforge.ps1 -OutputPath ~/Desktop/profiles -ProfileName "Corp PSSO Secure Enclave"
```

### Non-interactive with config file and direct push

```powershell
./pssoforge.ps1 -InputFile ./contoso.json -TenantId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

---

## License

Copyright (c) Microsoft Corporation. All rights reserved.  

Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
(including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
of such damages.

Feedback: marc.nahum@microsoft.com

Licensed under the [MIT License](../LICENSE).
