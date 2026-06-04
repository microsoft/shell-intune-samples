<#

.COPYRIGHT
Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.
See LICENSE in the project root for license information.

Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
(including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
of such damages.
Feedback: marc.nahum@microsoft.com

#>

<#
.SYNOPSIS
    PSSOForge — Generates Platform SSO (PSSO) Settings Catalog JSON profiles for Microsoft Entra ID / Intune.

.DESCRIPTION
    Interactive wizard that creates a Microsoft Graph Settings Catalog JSON file
    containing Extensible SSO and Platform SSO settings, ready for Intune import.

    Can also push the profile directly to an Intune tenant via Microsoft Graph.

.PARAMETER InputFile
    Path to a JSON configuration file. Skips interactive questions.

.PARAMETER TenantId
    Azure AD / Entra tenant ID. When provided, pushes the generated profile to Intune
    via Microsoft Graph PowerShell SDK.

.PARAMETER OutputPath
    Custom output directory for generated JSON files.
    Defaults to the current directory.

.PARAMETER ProfileName
    Custom profile name for the generated JSON. Overrides the default naming convention.
    Default: "macOS | PSSO <TenantName> (<SE or PSync>)"

.EXAMPLE
    ./pssoforge.ps1

.EXAMPLE
    ./pssoforge.ps1 -InputFile config.json

.EXAMPLE
    ./pssoforge.ps1 -TenantId "00000000-0000-0000-0000-000000000000"

.EXAMPLE
    ./pssoforge.ps1 -ProfileName "My Custom PSSO Profile"

.NOTES
    Requires PowerShell 7+ for cross-platform support.
    Requires the Microsoft.Graph.Authentication module for -TenantId functionality.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$InputFile,

    [Parameter(Mandatory = $false)]
    [string]$TenantId,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = (Get-Location).Path,

    [Parameter(Mandatory = $false)]
    [string]$ProfileName
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Version ──────────────────────────────────────────────────────────────────
$script:Version = '1.2.3'

# ── Helpers ──────────────────────────────────────────────────────────────────

function Write-Banner {
    $width = 47
    $line1 = "PSSOForge v$($script:Version)"
    $line2 = "Platform SSO Profile Generator"
    $pad1  = [math]::Max(0, [math]::Floor(($width - $line1.Length) / 2))
    $pad2  = [math]::Max(0, [math]::Floor(($width - $line2.Length) / 2))
    $row1  = $line1.PadLeft($pad1 + $line1.Length).PadRight($width)
    $row2  = $line2.PadLeft($pad2 + $line2.Length).PadRight($width)
    $border = "═" * $width
    $banner = @"

  ╔═${border}═╗
  ║ ${row1} ║
  ║ ${row2} ║
  ╚═${border}═╝

"@
    Write-Host $banner -ForegroundColor Cyan
}

function Read-YesNo {
    <#
    .SYNOPSIS
        Prompts the user for a Yes/No answer and returns a boolean.
    #>
    param(
        [string]$Prompt,
        [bool]$Default = $true
    )
    $hint = if ($Default) { '[Y/n]' } else { '[y/N]' }
    while ($true) {
        $answer = Read-Host "$Prompt $hint"
        if ([string]::IsNullOrWhiteSpace($answer)) { return $Default }
        switch ($answer.Trim().ToLower()) {
            'y'   { return $true  }
            'yes' { return $true  }
            'n'   { return $false }
            'no'  { return $false }
            default { Write-Host "  Please enter Y or N." -ForegroundColor Yellow }
        }
    }
}

function Read-Choice {
    <#
    .SYNOPSIS
        Prompts the user to pick from numbered options. Returns the selected value.
    #>
    param(
        [string]$Prompt,
        [string[]]$Options,
        [int]$Default = 1
    )
    Write-Host ""
    Write-Host $Prompt -ForegroundColor White
    for ($i = 0; $i -lt $Options.Count; $i++) {
        $marker = if ($i + 1 -eq $Default) { ' (default)' } else { '' }
        Write-Host "  [$($i + 1)] $($Options[$i])$marker" -ForegroundColor Gray
    }
    while ($true) {
        $answer = Read-Host "  Enter choice [1-$($Options.Count)]"
        if ([string]::IsNullOrWhiteSpace($answer)) { return $Options[$Default - 1] }
        if ($answer -match '^\d+$') {
            $idx = [int]$answer
            if ($idx -ge 1 -and $idx -le $Options.Count) {
                return $Options[$idx - 1]
            }
        }
        Write-Host "  Please enter a number between 1 and $($Options.Count)." -ForegroundColor Yellow
    }
}

function Read-MultipleStrings {
    <#
    .SYNOPSIS
        Prompts the user to enter one or more strings. Returns an array.
    #>
    param([string]$Prompt)
    Write-Host ""
    Write-Host "$Prompt (enter one per line, empty line to finish):" -ForegroundColor White
    $results = @()
    while ($true) {
        $entry = Read-Host "  >"
        if ([string]::IsNullOrWhiteSpace($entry)) {
            if ($results.Count -eq 0) {
                Write-Host "  At least one entry is required." -ForegroundColor Yellow
                continue
            }
            break
        }
        $results += $entry.Trim()
    }
    return $results
}

# ── Configuration Model ─────────────────────────────────────────────────────

function Get-ConfigFromWizard {
    <#
    .SYNOPSIS
        Runs the interactive wizard and returns a configuration hashtable.
    #>

    Write-Host "Answer the following questions to generate your PSSO profile." -ForegroundColor White
    Write-Host "Refer to: https://learn.microsoft.com/en-us/mem/intune/configuration/platform-sso-macos" -ForegroundColor DarkGray
    Write-Host ""

    # Q1: Tenant name
    Write-Host ""
    $accountDisplayName = $null
    while ([string]::IsNullOrWhiteSpace($accountDisplayName)) {
        $accountDisplayName = (Read-Host "Enter the tenant display name for the profile").Trim()
        if ([string]::IsNullOrWhiteSpace($accountDisplayName)) {
            Write-Host "  A tenant name is required." -ForegroundColor Yellow
        }
    }

    # Q2: Authentication method
    $authChoice = Read-Choice -Prompt "Select authentication method:" `
        -Options @('Secure Enclave (recommended)', 'Password Sync') -Default 1
    $authenticationMethod = if ($authChoice -like 'Secure*') { 'UserSecureEnclaveKey' } else { 'Password' }

    # Q3: Registration during setup
    $enableRegistrationDuringSetup = Read-YesNo -Prompt "Run Platform SSO registration during Setup Assistant?" -Default $true

    # Q4: LAPS / first user creation (INVERTED: LAPS used = do NOT create first user)
    # Also forced to false when registration during setup is disabled (Q3=No)
    $createFirstUserDuringSetup = $false
    if ($enableRegistrationDuringSetup) {
        $lapsUsed = Read-YesNo -Prompt "Is the SAMAccountName used by LAPS? (if yes, first-user creation is disabled)" -Default $false
        $createFirstUserDuringSetup = -not $lapsUsed
    }

    # Q5: User authorization mode
    $userAuthChoice = Read-Choice -Prompt "Should the main user be admin or standard?" `
        -Options @('Standard (recommended)', 'Admin') -Default 1
    $userAuthorizationMode = if ($userAuthChoice -like 'Admin*') { 'Admin' } else { 'Standard' }

    # Q6: Multi-user Mac
    $enableCreateUserAtLogin = Read-YesNo -Prompt "Enable multi-user Mac (create new users at login)?" -Default $false

    # Q7: New user authorization (only if multi-user)
    $newUserAuthorizationMode = $null
    if ($enableCreateUserAtLogin) {
        $newUserChoice = Read-Choice -Prompt "Should new users created at login be admin or standard?" `
            -Options @('Standard (recommended)', 'Admin') -Default 1
        $newUserAuthorizationMode = if ($newUserChoice -like 'Admin*') { 'Admin' } else { 'Standard' }
    }

    # Q8 & Q9: Managed admin accounts
    $nonPlatformSSOAccounts = @()
    $hasManagedAdmin = Read-YesNo -Prompt "Do you have managed admin account(s) to exclude from PSSO?" -Default $false
    if ($hasManagedAdmin) {
        $nonPlatformSSOAccounts = Read-MultipleStrings -Prompt "Enter the managed admin account name(s)"
    }

    return @{
        SchemaVersion                 = 1
        AccountDisplayName            = $accountDisplayName
        AuthenticationMethod          = $authenticationMethod
        EnableRegistrationDuringSetup = $enableRegistrationDuringSetup
        CreateFirstUserDuringSetup    = $createFirstUserDuringSetup
        UserAuthorizationMode         = $userAuthorizationMode
        EnableCreateUserAtLogin       = $enableCreateUserAtLogin
        NewUserAuthorizationMode      = $newUserAuthorizationMode
        NonPlatformSSOAccounts        = $nonPlatformSSOAccounts
    }
}

function Get-ConfigFromFile {
    <#
    .SYNOPSIS
        Reads configuration from a JSON file and returns a validated hashtable.
    #>
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Input file not found: $Path"
    }

    $json = Get-Content -LiteralPath $Path -Raw -Encoding utf8 | ConvertFrom-Json

    # Helper to safely read a property under StrictMode
    function Get-JsonProp { param($Obj, [string]$Name)
        if ($Obj.PSObject.Properties[$Name]) { return $Obj.$Name }
        return $null
    }

    # Validate required fields
    $required = @('accountDisplayName', 'authenticationMethod', 'enableRegistrationDuringSetup',
                   'createFirstUserDuringSetup', 'userAuthorizationMode', 'enableCreateUserAtLogin')
    foreach ($field in $required) {
        if ($null -eq (Get-JsonProp $json $field)) {
            throw "Missing required field in input file: $field"
        }
    }

    # Validate enums
    if ($json.authenticationMethod -notin @('UserSecureEnclaveKey', 'Password')) {
        throw "Invalid authenticationMethod: $($json.authenticationMethod). Must be 'UserSecureEnclaveKey' or 'Password'."
    }
    if ($json.userAuthorizationMode -notin @('Admin', 'Standard')) {
        throw "Invalid userAuthorizationMode: $($json.userAuthorizationMode). Must be 'Admin' or 'Standard'."
    }
    $newUserAuth = Get-JsonProp $json 'newUserAuthorizationMode'
    if ($json.enableCreateUserAtLogin -and $newUserAuth) {
        if ($newUserAuth -notin @('Admin', 'Standard')) {
            throw "Invalid newUserAuthorizationMode: $newUserAuth. Must be 'Admin' or 'Standard'."
        }
    }

    return @{
        SchemaVersion                 = if (Get-JsonProp $json 'schemaVersion') { $json.schemaVersion } else { 1 }
        AccountDisplayName            = [string]$json.accountDisplayName
        AuthenticationMethod          = $json.authenticationMethod
        EnableRegistrationDuringSetup = [bool]$json.enableRegistrationDuringSetup
        CreateFirstUserDuringSetup    = [bool]$json.createFirstUserDuringSetup
        UserAuthorizationMode         = $json.userAuthorizationMode
        EnableCreateUserAtLogin       = [bool]$json.enableCreateUserAtLogin
        NewUserAuthorizationMode      = $newUserAuth
        NonPlatformSSOAccounts        = if ((Get-JsonProp $json 'nonPlatformSSOAccounts')) { [string[]]$json.nonPlatformSSOAccounts } else { @() }
    }
}

# ── Settings Catalog JSON Helpers ────────────────────────────────────────────

function New-ChoiceSetting {
    param(
        [string]$DefinitionId,
        [string]$Value,
        [array]$Children = @()
    )
    return [ordered]@{
        '@odata.type'                    = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
        settingDefinitionId              = $DefinitionId
        settingInstanceTemplateReference = $null
        auditRuleInformation             = $null
        choiceSettingValue               = [ordered]@{
            settingValueTemplateReference = $null
            value                         = $Value
            children                      = @($Children)
        }
    }
}

function New-SimpleStringSetting {
    param(
        [string]$DefinitionId,
        [string]$Value
    )
    return [ordered]@{
        '@odata.type'                    = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
        settingDefinitionId              = $DefinitionId
        settingInstanceTemplateReference = $null
        auditRuleInformation             = $null
        simpleSettingValue               = [ordered]@{
            '@odata.type'                 = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
            settingValueTemplateReference = $null
            value                         = $Value
        }
    }
}

function New-SimpleIntegerSetting {
    param(
        [string]$DefinitionId,
        [int]$Value
    )
    return [ordered]@{
        '@odata.type'                    = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
        settingDefinitionId              = $DefinitionId
        settingInstanceTemplateReference = $null
        auditRuleInformation             = $null
        simpleSettingValue               = [ordered]@{
            '@odata.type'                 = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
            settingValueTemplateReference = $null
            value                         = $Value
        }
    }
}

function New-StringCollectionSetting {
    param(
        [string]$DefinitionId,
        [string[]]$Values
    )
    $items = @($Values | ForEach-Object {
        [ordered]@{
            '@odata.type'                 = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
            settingValueTemplateReference = $null
            value                         = $_
        }
    })
    return [ordered]@{
        '@odata.type'                    = '#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance'
        settingDefinitionId              = $DefinitionId
        settingInstanceTemplateReference = $null
        auditRuleInformation             = $null
        simpleSettingCollectionValue      = $items
    }
}

function New-GroupCollectionSetting {
    param(
        [string]$DefinitionId,
        [array]$GroupValues
    )
    return [ordered]@{
        '@odata.type'                    = '#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance'
        settingDefinitionId              = $DefinitionId
        settingInstanceTemplateReference = $null
        auditRuleInformation             = $null
        groupSettingCollectionValue       = @($GroupValues)
    }
}

function New-GroupValue {
    param([array]$Children)
    return [ordered]@{
        settingValueTemplateReference = $null
        children                      = @($Children)
    }
}

function New-ExtensionDataEntry {
    param(
        [string]$KeyName,
        [string]$TypePickerValue,
        [object]$ChildSetting
    )
    $typePickerDefId = 'com.apple.extensiblesso_ignored_$typepicker'
    return New-GroupValue -Children @(
        (New-SimpleStringSetting `
            -DefinitionId 'com.apple.extensiblesso_extensiondata_generickey_keytobereplaced' `
            -Value $KeyName),
        (New-ChoiceSetting `
            -DefinitionId $typePickerDefId `
            -Value "com.apple.extensiblesso_ignored_$TypePickerValue" `
            -Children @($ChildSetting))
    )
}

# ── Settings Catalog JSON Generator ─────────────────────────────────────────

function New-SettingsCatalogJson {
    <#
    .SYNOPSIS
        Generates a Settings Catalog JSON string for a single tenant/display name.
    #>
    param(
        [string]$AccountDisplayName,
        [hashtable]$Config,
        [string]$CustomProfileName
    )

    $p  = 'com.apple.extensiblesso'
    $pp = 'com.apple.extensiblesso_platformsso'

    # Mapping helpers
    $authSuffix  = if ($Config.AuthenticationMethod -eq 'UserSecureEnclaveKey') { '1' } else { '0' }
    $authLabel   = if ($Config.AuthenticationMethod -eq 'UserSecureEnclaveKey') { 'SE' } else { 'PSync' }
    $userAuthSuffix = if ($Config.UserAuthorizationMode -eq 'Admin') { '1' } else { '0' }

    # ── PlatformSSO children ──
    $pssoChildren = [System.Collections.ArrayList]::new()

    # AccountDisplayName
    [void]$pssoChildren.Add(
        (New-SimpleStringSetting -DefinitionId "${pp}_accountdisplayname" -Value $AccountDisplayName))

    # AuthenticationMethod (platformsso level)
    [void]$pssoChildren.Add(
        (New-ChoiceSetting -DefinitionId "${pp}_authenticationmethod" `
            -Value "${pp}_authenticationmethod_$authSuffix"))

    # EnableCreateFirstUserDuringSetup
    $createFirstSuffix = if ($Config.CreateFirstUserDuringSetup) { 'true' } else { 'false' }
    [void]$pssoChildren.Add(
        (New-ChoiceSetting -DefinitionId "${pp}_enablecreatefirstuserduringsetup" `
            -Value "${pp}_enablecreatefirstuserduringsetup_$createFirstSuffix"))

    # EnableCreateUserAtLogin
    $createAtLoginSuffix = if ($Config.EnableCreateUserAtLogin) { 'true' } else { 'false' }
    [void]$pssoChildren.Add(
        (New-ChoiceSetting -DefinitionId "${pp}_enablecreateuseratlogin" `
            -Value "${pp}_enablecreateuseratlogin_$createAtLoginSuffix"))

    # EnableRegistrationDuringSetup
    $regSuffix = if ($Config.EnableRegistrationDuringSetup) { 'true' } else { 'false' }
    [void]$pssoChildren.Add(
        (New-ChoiceSetting -DefinitionId "${pp}_enableregistrationduringsetup" `
            -Value "${pp}_enableregistrationduringsetup_$regSuffix"))

    # NonPlatformSSOAccounts (conditional)
    if ($null -ne $Config.NonPlatformSSOAccounts -and @($Config.NonPlatformSSOAccounts).Count -gt 0) {
        [void]$pssoChildren.Add(
            (New-StringCollectionSetting -DefinitionId "${pp}_nonplatformssoaccounts" `
                -Values $Config.NonPlatformSSOAccounts))
    }

    # TokenToUserMapping
    $tokenMappingChildren = @(
        (New-SimpleStringSetting -DefinitionId "${pp}_tokentousermapping_accountname" `
            -Value 'com.apple.PlatformSSO.AccountShortName'),
        (New-SimpleStringSetting -DefinitionId "${pp}_tokentousermapping_fullname" `
            -Value 'name')
    )
    [void]$pssoChildren.Add(
        (New-GroupCollectionSetting -DefinitionId "${pp}_tokentousermapping" `
            -GroupValues @((New-GroupValue -Children $tokenMappingChildren))))

    # UseSharedDeviceKeys
    [void]$pssoChildren.Add(
        (New-ChoiceSetting -DefinitionId "${pp}_useshareddevicekeys" `
            -Value "${pp}_useshareddevicekeys_true"))

    # UserAuthorizationMode
    [void]$pssoChildren.Add(
        (New-ChoiceSetting -DefinitionId "${pp}_userauthorizationmode" `
            -Value "${pp}_userauthorizationmode_$userAuthSuffix"))

    # NewUserAuthorizationMode (only if multi-user enabled)
    if ($Config.EnableCreateUserAtLogin -and $Config.NewUserAuthorizationMode) {
        $newUserSuffix = if ($Config.NewUserAuthorizationMode -eq 'Admin') { '1' } else { '0' }
        [void]$pssoChildren.Add(
            (New-ChoiceSetting -DefinitionId "${pp}_newuserauthorizationmode" `
                -Value "${pp}_newuserauthorizationmode_$newUserSuffix"))
    }

    # ── ExtensionData entries (4 fixed generic keys) ──
    $extDataEntries = @(
        (New-ExtensionDataEntry -KeyName 'disable_explicit_app_prompt' -TypePickerValue '1' `
            -ChildSetting (New-SimpleIntegerSetting `
                -DefinitionId "${p}_extensiondata_generickey_integer" -Value 1)),
        (New-ExtensionDataEntry -KeyName 'browser_sso_interaction_enabled' -TypePickerValue '1' `
            -ChildSetting (New-SimpleIntegerSetting `
                -DefinitionId "${p}_extensiondata_generickey_integer" -Value 1)),
        (New-ExtensionDataEntry -KeyName 'AppPrefixAllowList' -TypePickerValue '0' `
            -ChildSetting (New-SimpleStringSetting `
                -DefinitionId "${p}_extensiondata_generickey_string" `
                -Value 'com.microsoft.,com.apple.')),
        (New-ExtensionDataEntry -KeyName 'use_most_secure_storage' -TypePickerValue '2' `
            -ChildSetting (New-ChoiceSetting `
                -DefinitionId "${p}_extensiondata_generickey_boolean" `
                -Value "${p}_extensiondata_generickey_true"))
    )

    # ── Root children (ordered as in sample) ──
    $rootChildren = @(
        (New-ChoiceSetting -DefinitionId "${p}_authenticationmethod" `
            -Value "${p}_authenticationmethod_$authSuffix"),
        (New-GroupCollectionSetting -DefinitionId "${p}_extensiondata" `
            -GroupValues $extDataEntries),
        (New-SimpleStringSetting -DefinitionId "${p}_extensionidentifier" `
            -Value 'com.microsoft.CompanyPortalMac.ssoextension'),
        (New-GroupCollectionSetting -DefinitionId "${p}_platformsso" `
            -GroupValues @((New-GroupValue -Children $pssoChildren.ToArray()))),
        (New-SimpleStringSetting -DefinitionId "${p}_registrationtoken" `
            -Value '{{DEVICEREGISTRATION}}'),
        (New-ChoiceSetting -DefinitionId "${p}_screenlockedbehavior" `
            -Value "${p}_screenlockedbehavior_0"),
        (New-SimpleStringSetting -DefinitionId "${p}_teamidentifier" `
            -Value 'UBF8T346G9'),
        (New-ChoiceSetting -DefinitionId "${p}_type" `
            -Value "${p}_type_1"),
        (New-StringCollectionSetting -DefinitionId "${p}_urls" -Values @(
            'https://login.microsoftonline.com',
            'https://login.microsoft.com',
            'https://sts.windows.net'
        ))
    )

    # ── Assemble root setting ──
    $rootSetting = [ordered]@{
        id              = '0'
        settingInstance = New-GroupCollectionSetting `
            -DefinitionId "${p}_${p}" `
            -GroupValues @((New-GroupValue -Children $rootChildren))
    }

    # ── Build profile name ──
    $policyName = if ($CustomProfileName) { $CustomProfileName } else {
        "macOS | PSSO $AccountDisplayName ($authLabel)"
    }

    # ── Assemble policy document ──
    $policy = [ordered]@{
        name              = $policyName
        description       = "Platform SSO profile generated by PSSOForge v$($script:Version)"
        platforms         = 'macOS'
        technologies      = 'mdm,appleRemoteManagement'
        roleScopeTagIds   = @('0')
        templateReference = [ordered]@{
            templateId             = ''
            templateFamily         = 'none'
            templateDisplayName    = $null
            templateDisplayVersion = $null
        }
        settings          = @($rootSetting)
    }

    return $policy | ConvertTo-Json -Depth 30
}

# ── Intune Graph Push ────────────────────────────────────────────────────────

function Push-ProfileToIntune {
    <#
    .SYNOPSIS
        Creates a Settings Catalog policy in Intune via Microsoft Graph.
    #>
    param(
        [string]$TenantId,
        [string]$DisplayName,
        [string]$JsonBody
    )

    # Check for the Microsoft Graph module. The cmdlets used here
    # (Connect-MgGraph, Invoke-MgGraphRequest, Disconnect-MgGraph) all live in
    # Microsoft.Graph.Authentication, so that is the only hard dependency.
    if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Authentication)) {
        Write-Host ""
        Write-Host "Microsoft.Graph.Authentication module is required for Intune push." -ForegroundColor Yellow
        Write-Host "Install it with: Install-Module Microsoft.Graph -Scope CurrentUser" -ForegroundColor Yellow
        throw "Missing required module: Microsoft.Graph.Authentication"
    }

    Import-Module Microsoft.Graph.Authentication -ErrorAction Stop

    Write-Host ""
    Write-Host "Connecting to Microsoft Graph for tenant: $TenantId" -ForegroundColor Cyan
    Connect-MgGraph -TenantId $TenantId -Scopes 'DeviceManagementConfiguration.ReadWrite.All' -ErrorAction Stop

    Write-Host "Creating Settings Catalog policy: $DisplayName" -ForegroundColor Cyan

    $uri = 'https://graph.microsoft.com/beta/deviceManagement/configurationPolicies'
    try {
        $result = Invoke-MgGraphRequest -Method POST -Uri $uri `
            -Body $JsonBody -ContentType 'application/json' -ErrorAction Stop

        Write-Host "✓ Policy created successfully!" -ForegroundColor Green
        Write-Host "  Policy ID: $($result.id)" -ForegroundColor Gray
        Write-Host "  Display Name: $DisplayName" -ForegroundColor Gray
        Write-Host "  Note: the policy is created unassigned — assign it to a group in Intune to deploy it." -ForegroundColor Gray

        return $result
    }
    finally {
        # Always tear down the Graph session, even if the request above throws,
        # so the cached token is not left behind.
        Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
    }
}

# ── Main ─────────────────────────────────────────────────────────────────────

function Main {
    Write-Banner

    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Warning "PSSOForge requires PowerShell 7 or later. Current version: $($PSVersionTable.PSVersion)"
        Write-Host "Download from: https://github.com/PowerShell/PowerShell/releases" -ForegroundColor Yellow
        exit 1
    }

    # Get configuration
    $config = $null
    if ($InputFile) {
        Write-Host "Loading configuration from: $InputFile" -ForegroundColor Cyan
        $config = Get-ConfigFromFile -Path $InputFile
        Write-Host "✓ Configuration loaded." -ForegroundColor Green
    }
    else {
        $config = Get-ConfigFromWizard
    }

    # Validate output directory
    if (-not (Test-Path -LiteralPath $OutputPath -PathType Container)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    }

    # Generate profile
    $authLabel = if ($config.AuthenticationMethod -eq 'UserSecureEnclaveKey') { 'SE' } else { 'PSync' }
    $tenantName = $config.AccountDisplayName

    $policyName = if ($ProfileName) { $ProfileName } else {
        "macOS | PSSO $tenantName ($authLabel)"
    }

    $json = New-SettingsCatalogJson -AccountDisplayName $tenantName `
        -Config $config -CustomProfileName $policyName

    # Build output filename: "macOS_PSSO_<Name>_<SE|PSync>_<timestamp>.json" (no spaces)
    $timestamp = (Get-Date).ToUniversalTime().ToString('yyyy_MM_dd_HH_mm_ss')
    $safeName  = ($tenantName -replace '[^\w.-]+', '_').Trim('_')
    if ([string]::IsNullOrWhiteSpace($safeName)) { $safeName = 'Tenant' }
    $fileName = "macOS_PSSO_${safeName}_${authLabel}_${timestamp}.json"
    $filePath = Join-Path -Path $OutputPath -ChildPath $fileName

    # Write file as UTF-8 without BOM
    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($filePath, $json, $utf8NoBom)

    Write-Host ""
    Write-Host "✓ Profile generated: $filePath" -ForegroundColor Green

    # Push to Intune — via parameter or interactive prompt
    $pushTenantId = $TenantId
    if (-not $pushTenantId) {
        Write-Host ""
        $wantPush = Read-YesNo -Prompt "Do you want to upload this profile directly to an Intune tenant?" -Default $false
        if ($wantPush) {
            do {
                $pushTenantId = (Read-Host "  Enter the Tenant ID (GUID)").Trim()
                if ($pushTenantId -notmatch '^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$') {
                    Write-Host "  Invalid GUID format. Please enter a valid Tenant ID." -ForegroundColor Yellow
                    $pushTenantId = ''
                }
            } while (-not $pushTenantId)
        }
    }

    if ($pushTenantId) {
        Write-Host ""
        Write-Host "Pushing profile to Intune..." -ForegroundColor Cyan
        try {
            Push-ProfileToIntune -TenantId $pushTenantId `
                -DisplayName $policyName `
                -JsonBody $json
        }
        catch {
            Write-Host "✗ Failed to push '$policyName': $_" -ForegroundColor Red
        }
    }

    # Summary
    Write-Host ""
    Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  PSSOForge complete!" -ForegroundColor Cyan
    Write-Host "  Profile generated: $policyName" -ForegroundColor Cyan
    if ($pushTenantId) {
        Write-Host "  Profile pushed to tenant: $pushTenantId" -ForegroundColor Cyan
    }
    Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
}

# Run
Main
