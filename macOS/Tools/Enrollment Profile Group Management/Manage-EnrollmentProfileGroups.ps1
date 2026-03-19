<#
.SYNOPSIS
    Manages Entra groups for Intune Enrollment Program Tokens and Profiles.

.DESCRIPTION
    This script authenticates to Microsoft Entra and Intune, retrieves enrollment program tokens,
    allows the user to select one, and creates/manages groups for each enrollment profile.
    It adds devices enrolled via specific profiles to their corresponding groups.

.PARAMETER Prefix
    Optional prefix to add to group names. If not provided, user will be prompted.

.PARAMETER TokenName
    Optional name of the Enrollment Program Token to use. If not provided, user will be prompted to select from available tokens.

.PARAMETER CreateGroups
    Switch parameter to automatically create groups without prompting for confirmation.

.PARAMETER TenantId
    The Tenant ID for certificate-based authentication.

.PARAMETER ClientId
    The Application (Client) ID for certificate-based authentication.

.PARAMETER CertificateThumbprint
    The certificate thumbprint for certificate-based authentication.

.PARAMETER Verbose
    Switch parameter to enable detailed logging output.

.PARAMETER LogRetentionDays
    Number of days to keep log files. Default is 7 days.

.PARAMETER LogPath
    Optional path to directory where log files will be stored. If not specified, logs will be stored in the same directory as the script.

.EXAMPLE
    .\Manage-EnrollmentProfileGroups.ps1
    .\Manage-EnrollmentProfileGroups.ps1 -Prefix "AutoPilot-"
    .\Manage-EnrollmentProfileGroups.ps1 -Prefix "DEP-" -TokenName "[CK]UEMCATLABS"
    .\Manage-EnrollmentProfileGroups.ps1 -Prefix "DEP-" -TokenName "[CK]UEMCATLABS" -CreateGroups
    .\Manage-EnrollmentProfileGroups.ps1 -Prefix "DEP-" -TokenName "[CK]UEMCATLABS" -CreateGroups -Verbose
    .\Manage-EnrollmentProfileGroups.ps1 -Prefix "DEP-" -TokenName "[CK]UEMCATLABS" -CreateGroups -TenantId "your-tenant-id" -ClientId "your-app-id" -CertificateThumbprint "ABCD1234..."
    .\Manage-EnrollmentProfileGroups.ps1 -Prefix "DEP-" -TokenName "[CK]UEMCATLABS" -CreateGroups -TenantId "your-tenant-id" -ClientId "your-app-id" -CertificateThumbprint "ABCD1234..." -LogRetentionDays 14
    .\Manage-EnrollmentProfileGroups.ps1 -Prefix "DEP-" -TokenName "[CK]UEMCATLABS" -CreateGroups -TenantId "your-tenant-id" -ClientId "your-app-id" -CertificateThumbprint "ABCD1234..." -LogPath "C:\Logs"

.NOTES
    Requires Microsoft.Graph.Authentication, Microsoft.Graph.Groups, and Microsoft.Graph.DeviceManagement modules.
    
    For certificate authentication, you need:
    1. An Azure AD App Registration with required API permissions
    2. A certificate uploaded to the app registration
    3. The certificate installed in the local certificate store (CurrentUser\My or LocalMachine\My)
#>

# Run this script every 6 hours via Task Scheduler or a similar tool for best results.
# .\Manage-EnrollmentProfileGroups.ps1 -Prefix "[CK]-DG-" -TokenName "[CK]UEMCATLABS" -CreateGroups -TenantId "4c252310-e8bc-4601-939c-eec227985cad" -ClientId "a905ecd5-8b93-42f0-9c9a-aeeb300abee0" -CertificateThumbprint "1B7A715A761634904E9C4471CDEADD7FD19176A8" -verbose
# Run this one every 1 minute to catch newly enrolled devices after the main script has created the groups.
# .\AddNewlyEnrolledDevicesToGroup.ps1 -Prefix "[CK]-DG-" -TokenName "[CK]UEMCATLABS" -TenantId "4c252310-e8bc-4601-939c-eec227985cad" -ClientId "a905ecd5-8b93-42f0-9c9a-aeeb300abee0" -CertificateThumbprint "1B7A715A761634904E9C4471CDEADD7FD19176A8" -MinutesBack 10  

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Prefix,
    
    [Parameter(Mandatory = $false)]
    [string]$TokenName,
    
    [Parameter(Mandatory = $false)]
    [switch]$CreateGroups,
    
    [Parameter(Mandatory = $false)]
    [string]$TenantId,
    
    [Parameter(Mandatory = $false)]
    [string]$ClientId,
    
    [Parameter(Mandatory = $false)]
    [string]$CertificateThumbprint,

    [Parameter(Mandatory = $false)]
    [int]$LogRetentionDays = 7,

    [Parameter(Mandatory = $false)]
    [string]$LogPath
)

#Requires -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Groups, Microsoft.Graph.DeviceManagement

# Global variable to track Graph API calls
$script:GraphCallCount = 0

# Setup logging
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Determine log directory
if ($LogPath) {
    # Use specified log path
    if (-not (Test-Path $LogPath)) {
        try {
            New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
        }
        catch {
            Write-Warning "Could not create log directory '$LogPath'. Using script directory instead. Error: $_"
            $LogPath = $scriptPath
        }
    }
    $logDirectory = $LogPath
}
else {
    # Use script directory
    $logDirectory = $scriptPath
}

$logFileName = "Manage-EnrollmentProfileGroups_$(Get-Date -Format 'yyyyMMdd').log"
$logFilePath = Join-Path $logDirectory $logFileName

# Function to write to log file and console
function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Warning', 'Error', 'Success')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Write to file
    Add-Content -Path $logFilePath -Value $logMessage -ErrorAction SilentlyContinue
    
    # Write to console with appropriate color (only for non-verbose or errors/warnings)
    if ($Level -eq 'Error' -or $Level -eq 'Warning' -or -not ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose'))) {
        $color = switch ($Level) {
            'Info'    { 'White' }
            'Warning' { 'Yellow' }
            'Error'   { 'Red' }
            'Success' { 'Green' }
            default   { 'White' }
        }
        
        # Don't duplicate console output for verbose messages
        if ($Level -ne 'Info' -or -not ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose'))) {
            Write-Host $logMessage -ForegroundColor $color
        }
    }
}

# Function to clean up old log files
function Remove-OldLogFiles {
    param(
        [Parameter(Mandatory = $true)]
        [string]$LogDirectory,
        
        [Parameter(Mandatory = $true)]
        [int]$RetentionDays
    )
    
    try {
        $cutoffDate = (Get-Date).AddDays(-$RetentionDays)
        $logFiles = Get-ChildItem -Path $LogDirectory -Filter "Manage-EnrollmentProfileGroups_*.log" -ErrorAction SilentlyContinue
        
        foreach ($file in $logFiles) {
            if ($file.LastWriteTime -lt $cutoffDate) {
                Remove-Item -Path $file.FullName -Force -ErrorAction SilentlyContinue
                Write-Log "Removed old log file: $($file.Name)" -Level Info
            }
        }
    }
    catch {
        Write-Log "Error cleaning up old log files: $_" -Level Warning
    }
}

# Function to display menu and get user selection
function Show-Menu {
    param(
        [Parameter(Mandatory = $true)]
        [array]$Items,
        [Parameter(Mandatory = $true)]
        [string]$Property,
        [Parameter(Mandatory = $true)]
        [string]$Title
    )
    
    Write-Host "`n$Title" -ForegroundColor Cyan
    Write-Host ("=" * 60) -ForegroundColor Cyan
    
    for ($i = 0; $i -lt $Items.Count; $i++) {
        Write-Host "$($i + 1). $($Items[$i].$Property)" -ForegroundColor Yellow
    }
    Write-Host ("=" * 60) -ForegroundColor Cyan
    
    do {
        $selection = Read-Host "`nEnter selection (1-$($Items.Count))"
        $valid = $selection -match '^\d+$' -and [int]$selection -ge 1 -and [int]$selection -le $Items.Count
        if (-not $valid) {
            Write-Host "Invalid selection. Please enter a number between 1 and $($Items.Count)." -ForegroundColor Red
        }
    } while (-not $valid)
    
    return $Items[[int]$selection - 1]
}

# Function to batch add members to a group using Graph batch API
function Add-DevicesToGroupBatch {
    param(
        [Parameter(Mandatory = $true)]
        [string]$GroupId,
        [Parameter(Mandatory = $true)]
        [array]$DeviceIds
    )
    
    if ($DeviceIds.Count -eq 0) {
        return @{ Added = 0; Errors = 0 }
    }
    
    $addedCount = 0
    $errorCount = 0
    $batchSize = 20  # Graph API batch limit is 20 requests per batch
    
    if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
        Write-Host "    Processing $($DeviceIds.Count) device(s) in batches of $batchSize..." -ForegroundColor Gray
    }
    
    # Process in batches
    for ($i = 0; $i -lt $DeviceIds.Count; $i += $batchSize) {
        $batch = $DeviceIds[$i..[Math]::Min($i + $batchSize - 1, $DeviceIds.Count - 1)]
        
        if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
            Write-Host "    Sending batch $([Math]::Floor($i / $batchSize) + 1) with $($batch.Count) device(s)..." -ForegroundColor Gray
        }
        
        # Create batch requests
        $requests = @()
        $requestId = 1
        
        foreach ($deviceId in $batch) {
            $requests += @{
                id = "$requestId"
                method = "POST"
                url = "/groups/$GroupId/members/`$ref"
                body = @{
                    "@odata.id" = "https://graph.microsoft.com/beta/directoryObjects/$deviceId"
                }
                headers = @{
                    "Content-Type" = "application/json"
                }
            }
            $requestId++
        }
        
        # Send batch request
        try {
            $batchBody = @{
                requests = $requests
            }
            
            $batchResponse = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/beta/`$batch" -Body ($batchBody | ConvertTo-Json -Depth 10) -Verbose:$false
            $script:GraphCallCount++
            
            # Process responses
            foreach ($response in $batchResponse.responses) {
                if ($response.status -eq 204 -or ($response.status -ge 200 -and $response.status -lt 300)) {
                    $addedCount++
                } else {
                    # Check for benign errors that can be ignored
                    $isIgnorableError = $false
                    
                    if ($response.body.error) {
                        $errorMsg = $response.body.error.message
                        $errorCode = $response.body.error.code
                        
                        # Device already in group - treat as success
                        if ($errorMsg -match "already exist" -or $errorCode -eq "Request_BadRequest") {
                            if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
                                Write-Host "    Device already in group (skipped): Request $($response.id)" -ForegroundColor Gray
                            }
                            $addedCount++  # Count as success since device is in group
                            $isIgnorableError = $true
                        }
                        
                        # Only count as error and display if not ignorable
                        if (-not $isIgnorableError) {
                            $errorCount++
                            Write-Host "    Batch error for request $($response.id): $errorMsg" -ForegroundColor Red
                        }
                    } else {
                        $errorCount++
                    }
                }
            }
            
            if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
                $successCount = $addedCount
                $failedCount = $errorCount
                Write-Host "    Batch complete: $successCount succeeded, $failedCount failed" -ForegroundColor Gray
            }
        }
        catch {
            Write-Host "    Batch request error: $($_.Exception.Message)" -ForegroundColor Red
            $errorCount += $batch.Count
        }
    }
    
    if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
        Write-Host "    Total: $addedCount added, $errorCount errors" -ForegroundColor Gray
    }
    
    return @{ Added = $addedCount; Errors = $errorCount }
}

# Function to create Entra group if it doesn't exist
function New-EntraGroupIfNotExists {
    param(
        [Parameter(Mandatory = $true)]
        [string]$GroupName,
        [Parameter(Mandatory = $true)]
        [string]$Description,
        [Parameter(Mandatory = $false)]
        [System.Collections.Generic.Dictionary[string,object]]$GroupLookup
    )
    
    try {
        # Check if group already exists in lookup first
        if ($GroupLookup -and $GroupLookup.ContainsKey($GroupName)) {
            $existingGroup = $GroupLookup[$GroupName]
            if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
                Write-Host "  Group '$GroupName' already exists (ID: $($existingGroup.Id))" -ForegroundColor Gray
            }
            return $existingGroup
        }
        
        # Fallback to Graph query if not in lookup
        $filter = [System.Web.HttpUtility]::UrlEncode("displayName eq '$GroupName'")
        $uri = "https://graph.microsoft.com/v1.0/groups?`$filter=$filter"
        $response = Invoke-MgGraphRequest -Method GET -Uri $uri -ErrorAction Stop
        $script:GraphCallCount++
        $existingGroup = if ($response.value -and $response.value.Count -gt 0) { $response.value[0] } else { $null }
        
        if ($existingGroup) {
            if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
                Write-Host "  Group '$GroupName' already exists (ID: $($existingGroup.Id))" -ForegroundColor Gray
            }
            return $existingGroup
        }
        else {
            # Create new group
            if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
                Write-Host "  Creating new group '$GroupName'..." -ForegroundColor Yellow
            }
            
            $groupParams = @{
                displayName = $GroupName
                description = $Description
                mailEnabled = $false
                mailNickname = ($GroupName -replace '[^a-zA-Z0-9]', '').ToLower()
                securityEnabled = $true
                groupTypes = @()
            }
            
            $newGroup = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/groups" -Body ($groupParams | ConvertTo-Json) -ErrorAction Stop
            $script:GraphCallCount++
            if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
                Write-Host "  Created new group '$GroupName' (ID: $($newGroup.Id))" -ForegroundColor Green
            }
            
            # Add to lookup for future reference
            if ($GroupLookup) {
                $GroupLookup[$GroupName] = $newGroup
            }
            
            return $newGroup
        }
    }
    catch {
        Write-Host "  ERROR creating group '$GroupName': $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Function to get group members
function Get-GroupDeviceMembers {
    param(
        [Parameter(Mandatory = $true)]
        [string]$GroupId
    )
    
    try {
        if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
            Write-Host "  Retrieving group members for group ID: $GroupId..." -ForegroundColor Gray
        }
        
        $uri = "https://graph.microsoft.com/v1.0/groups/$GroupId/members"
        $members = @()
        
        do {
            $response = Invoke-MgGraphRequest -Method GET -Uri $uri -ErrorAction Stop
            $script:GraphCallCount++
            if ($response.value) {
                $members += $response.value
            }
            $uri = $response.'@odata.nextLink'
        } while ($uri)
        
        if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
            Write-Host "  Found $($members.Count) member(s)" -ForegroundColor Gray
        }
        
        return $members
    }
    catch {
        # If group doesn't exist (404), return empty array silently
        if ($_.Exception.Message -match "does not exist" -or $_.Exception.Message -match "404") {
            if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
                Write-Host "  Group not found or newly created - treating as empty group" -ForegroundColor Gray
            }
            return @()
        }
        
        Write-Host "  ERROR getting group members: $($_.Exception.Message)" -ForegroundColor Red
        return @()
    }
}

# Main script execution
try {
    # Clean up old log files
    Remove-OldLogFiles -LogDirectory $scriptPath -RetentionDays $LogRetentionDays
    
    Write-Log "========================================" -Level Info
    Write-Log "Script started - Manage Enrollment Profile Groups" -Level Info
    Write-Log "Log file: $logFilePath" -Level Info
    Write-Log "Log retention: $LogRetentionDays days" -Level Info
    Write-Log "========================================" -Level Info
    
    if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
        Write-Host "`nStarting Enrollment Profile Group Management Script" -ForegroundColor Cyan
        Write-Host ("=" * 60) -ForegroundColor Cyan
    }
    
    # Connect to Microsoft Graph
    Write-Log "Authenticating to Microsoft Graph..." -Level Info
    if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
        Write-Host "`nAuthenticating to Microsoft Graph..." -ForegroundColor Yellow
    }
    
    $requiredScopes = @(
        'DeviceManagementServiceConfig.ReadWrite.All',
        'DeviceManagementManagedDevices.Read.All',
        'Group.ReadWrite.All',
        'Directory.Read.All'
    )
    
    # Check if certificate authentication parameters are provided
    $useCertAuth = $TenantId -and $ClientId -and $CertificateThumbprint
    
    if ($useCertAuth) {
        Write-Log "Using certificate-based authentication" -Level Info
        if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
            Write-Host "Authenticating with certificate..." -ForegroundColor Yellow
        }
        Connect-MgGraph -TenantId $TenantId -ClientId $ClientId -CertificateThumbprint $CertificateThumbprint -NoWelcome
    } else {
        Write-Log "Using interactive authentication" -Level Info
        if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
            Write-Host "Authenticating interactively..." -ForegroundColor Yellow
        }
        Connect-MgGraph -Scopes $requiredScopes -NoWelcome
    }
    
    $context = Get-MgContext
    Write-Log "Connected to tenant: $($context.TenantId) as $($context.Account)" -Level Success
    if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
        Write-Host "Connected as: $($context.Account)" -ForegroundColor Green
    }
    
    # Get all enrollment program tokens (Apple DEP tokens)
    Write-Log "Retrieving Enrollment Program Tokens..." -Level Info
    if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
        Write-Host "`nRetrieving Enrollment Program Tokens..." -ForegroundColor Yellow
    }
    
    $enrollmentTokens = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/depOnboardingSettings"
    $script:GraphCallCount++
    
    if (-not $enrollmentTokens.value -or $enrollmentTokens.value.Count -eq 0) {
        Write-Log "No enrollment program tokens found" -Level Error
        Write-Host "No enrollment program tokens found." -ForegroundColor Red
        Disconnect-MgGraph
        exit
    }
    
    Write-Log "Found $($enrollmentTokens.value.Count) enrollment program token(s)" -Level Info
    if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
        Write-Host "Found $($enrollmentTokens.value.Count) enrollment program token(s)." -ForegroundColor Green
    }
    
    # Let user choose an enrollment token or use provided TokenName
    if ($TokenName) {
        $selectedToken = $enrollmentTokens.value | Where-Object { $_.tokenName -eq $TokenName }
        if (-not $selectedToken) {
            Write-Log "Enrollment Program Token '$TokenName' not found" -Level Error
            Write-Host "ERROR: Enrollment Program Token '$TokenName' not found." -ForegroundColor Red
            Write-Host "Available tokens:" -ForegroundColor Yellow
            $enrollmentTokens.value | ForEach-Object { Write-Host "  - $($_.tokenName)" -ForegroundColor Gray }
            Disconnect-MgGraph | Out-Null
            exit 1
        }
        Write-Log "Using specified token: $($selectedToken.tokenName)" -Level Info
        if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
            Write-Host "Using specified token: $($selectedToken.tokenName)" -ForegroundColor Green
        }
    }
    else {
        $selectedToken = Show-Menu -Items $enrollmentTokens.value -Property 'tokenName' -Title "Select an Enrollment Program Token"
        Write-Log "Selected token: $($selectedToken.tokenName)" -Level Info
        if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
            Write-Host "`nSelected Token: $($selectedToken.tokenName)" -ForegroundColor Green
        }
    }
    
    if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
        Write-Host "Token ID: $($selectedToken.id)" -ForegroundColor Gray
    }
    
    # Get enrollment profiles for the selected token
    Write-Log "Retrieving Enrollment Profiles for token: $($selectedToken.tokenName)" -Level Info
    if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
        Write-Host "`nRetrieving Enrollment Profiles for selected token..." -ForegroundColor Yellow
    }
    
    $enrollmentProfiles = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/depOnboardingSettings/$($selectedToken.id)/enrollmentProfiles"
    $script:GraphCallCount++
    
    if (-not $enrollmentProfiles.value -or $enrollmentProfiles.value.Count -eq 0) {
        Write-Log "No enrollment profiles found for token: $($selectedToken.tokenName)" -Level Error
        Write-Host "No enrollment profiles found for this token." -ForegroundColor Red
        Disconnect-MgGraph
        exit
    }
    
    Write-Log "Found $($enrollmentProfiles.value.Count) enrollment profile(s)" -Level Info
    if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
        Write-Host "Found $($enrollmentProfiles.value.Count) enrollment profile(s)." -ForegroundColor Green
        foreach ($enrollProfile in $enrollmentProfiles.value) {
            Write-Host "  - $($enrollProfile.displayName)" -ForegroundColor Gray
        }
    }
    
    # Ask user if they want to create groups (unless CreateGroups switch is provided)
    if (-not $CreateGroups) {
        Write-Host "`n"
        $createGroupsResponse = Read-Host "Do you want to create Entra groups for each enrollment profile? (Y/N)"
        
        if ($createGroupsResponse -ne 'Y' -and $createGroupsResponse -ne 'y') {
            Write-Host "`nOperation cancelled by user." -ForegroundColor Yellow
            Disconnect-MgGraph | Out-Null
            exit
        }
    }
    else {
        if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
            Write-Host "`nCreateGroups parameter specified - proceeding with group creation." -ForegroundColor Green
        }
    }
    
    # Get prefix for group names
    if (-not $Prefix) {
        Write-Host "`n"
        $Prefix = Read-Host "Enter a prefix for the group names (e.g., 'AutoPilot-', 'DEP-')"
    }
    
    Write-Log "Group prefix: '$Prefix'" -Level Info
    if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
        Write-Host "`nGroup prefix: '$Prefix'" -ForegroundColor Green
    }
    
    # Pre-fetch all groups to avoid multiple queries
    Write-Log "Retrieving existing groups..." -Level Info
    if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
        Write-Host "`nRetrieving existing groups..." -ForegroundColor Yellow
    }
    $uri = "https://graph.microsoft.com/v1.0/groups"
    $allGroups = @()
    
    do {
        $response = Invoke-MgGraphRequest -Method GET -Uri $uri
        $script:GraphCallCount++
        if ($response.value) {
            $allGroups += $response.value
        }
        $uri = $response.'@odata.nextLink'
    } while ($uri)
    
    Write-Log "Retrieved $($allGroups.Count) existing groups" -Level Info
    $groupLookup = [System.Collections.Generic.Dictionary[string,object]]::new()
    foreach ($grp in $allGroups) {
        $groupLookup[$grp.displayName] = $grp
    }
    
    # Create all groups first (before downloading devices)
    Write-Log "Creating/verifying groups for $($enrollmentProfiles.value.Count) enrollment profiles" -Level Info
    if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
        Write-Host "`nCreating all groups first..." -ForegroundColor Cyan
    }
    
    $profileGroups = [System.Collections.Generic.Dictionary[string,object]]::new()
    $newGroupsCreated = $false
    $newlyCreatedGroups = [System.Collections.Generic.HashSet[string]]::new()
    
    foreach ($enrollProfile in $enrollmentProfiles.value) {
        $groupName = "$Prefix$($enrollProfile.displayName)"
        $description = "Devices enrolled via enrollment profile: $($enrollProfile.displayName) (Token: $($selectedToken.tokenName))"
        
        # Check if group already exists before creating
        $groupExists = $groupLookup.ContainsKey($groupName)
        
        # Create or get existing group
        $group = New-EntraGroupIfNotExists -GroupName $groupName -Description $description -GroupLookup $groupLookup
        
        if ($group) {
            $profileGroups[$enrollProfile.displayName] = $group
            # Track if we created a new group
            if (-not $groupExists) {
                $newGroupsCreated = $true
                $newlyCreatedGroups.Add($group.Id) | Out-Null
                Write-Log "Created new group: $groupName" -Level Success
            }
        } else {
            Write-Log "Error creating group: $groupName" -Level Error
            Write-Host "  Error creating group '$groupName'" -ForegroundColor Red
        }
    }
    
    # Wait for groups to sync in Azure AD only if new groups were created
    if ($newGroupsCreated) {
        if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
            Write-Host "`n  Waiting for groups to sync in Azure AD..." -ForegroundColor Gray
            Write-Host "  New groups will be skipped for member addition this run." -ForegroundColor Yellow
        }
        Start-Sleep -Seconds 5
    }
    
    # Retrieve all Apple devices from Entra ID
    Write-Log "Retrieving all Apple devices from Entra ID..." -Level Info
    if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
        Write-Host "`nRetrieving all Apple devices from Entra ID..." -ForegroundColor Yellow
    }
    $uri = "https://graph.microsoft.com/beta/devices?`$filter=operatingSystem eq 'iOS' or operatingSystem eq 'iPadOS' or operatingSystem eq 'macOS' or operatingSystem eq 'MacMDM'"
    $allAppleDevices = @()
    
    $pageCount = 0
    do {
        $response = Invoke-MgGraphRequest -Method GET -Uri $uri
        $script:GraphCallCount++
        if ($response.value) {
            $allAppleDevices += $response.value
            $pageCount++
            if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
                Write-Host "  Retrieved page $pageCount - Total devices so far: $($allAppleDevices.Count)" -ForegroundColor Gray
            }
        }
        $uri = $response.'@odata.nextLink'
    } while ($uri)
    
    Write-Log "Found $($allAppleDevices.Count) Apple device(s) in Entra ID" -Level Info
    if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
        Write-Host "Found $($allAppleDevices.Count) Apple device(s) in Entra ID." -ForegroundColor Green
        
        # Show enrollment profile distribution
        $profileCounts = $allAppleDevices | Where-Object { -not [string]::IsNullOrWhiteSpace($_.enrollmentProfileName) } | Group-Object -Property enrollmentProfileName
        Write-Host "`n  Enrollment Profile Distribution:" -ForegroundColor Gray
        foreach ($profileGroup in $profileCounts) {
            Write-Host "    - $($profileGroup.Name): $($profileGroup.Count) device(s)" -ForegroundColor Gray
        }
        $noProfile = ($allAppleDevices | Where-Object { [string]::IsNullOrWhiteSpace($_.enrollmentProfileName) }).Count
        if ($noProfile -gt 0) {
            Write-Host "    - (No enrollment profile): $noProfile device(s)" -ForegroundColor Gray
        }
    }
    
    # Create a lookup dictionary for fast verification later
    $deviceLookup = [System.Collections.Generic.Dictionary[string,object]]::new($allAppleDevices.Count)
    foreach ($dev in $allAppleDevices) {
        if ($dev.Id) {
            $deviceLookup[$dev.Id] = $dev
        }
    }
    
    # Process enrollment profiles and add members
    Write-Log "Processing enrollment profiles and managing group memberships..." -Level Info
    if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
        Write-Host "`nProcessing enrollment profiles and adding members..." -ForegroundColor Cyan
    }
    
    $results = @()
    foreach ($enrollProfile in $enrollmentProfiles.value) {
        Write-Log "Processing enrollment profile: $($enrollProfile.displayName)" -Level Info
        Write-Host "`nProcessing: $($enrollProfile.displayName)" -ForegroundColor Cyan
        
        $groupName = "$Prefix$($enrollProfile.displayName)"
        
        # Get the group from our cache
        if (-not $profileGroups.ContainsKey($enrollProfile.displayName)) {
            Write-Host "  Error: Group not found - skipping" -ForegroundColor Red
            continue
        }
        
        $group = $profileGroups[$enrollProfile.displayName]
        
        # Skip newly created groups for member addition
        if ($newlyCreatedGroups.Contains($group.Id)) {
            Write-Log "Group '$groupName' was just created - skipping member addition for this run" -Level Info
            Write-Host "  Group was just created - skipping member addition for this run" -ForegroundColor Yellow
            Write-Host "  Run the script again to add members to this group" -ForegroundColor Yellow
            
            $results += [PSCustomObject]@{
                Profile = $enrollProfile.displayName
                Group = $groupName
                Found = 0
                Added = 0
                Removed = 0
                Errors = 0
                TotalMembers = 0
                Status = "New group created"
            }
            continue
        }
        
        # Filter devices by enrollment profile name from the already-retrieved Apple devices
        $enrolledDevices = @($allAppleDevices | Where-Object { 
            (-not [string]::IsNullOrWhiteSpace($_.enrollmentProfileName)) -and
            ($_.enrollmentProfileName -eq $enrollProfile.displayName)
        })
        
        if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
            Write-Host "  Found $($enrolledDevices.Count) device(s) with enrollment profile '$($enrollProfile.displayName)'" -ForegroundColor Gray
            if ($enrolledDevices.Count -gt 0 -and $enrolledDevices.Count -le 10) {
                foreach ($dev in $enrolledDevices) {
                    Write-Host "    - $($dev.displayName) ($($dev.operatingSystem))" -ForegroundColor Gray
                }
            } elseif ($enrolledDevices.Count -gt 10) {
                Write-Host "    (Showing first 10 of $($enrolledDevices.Count) devices)" -ForegroundColor Gray
                for ($i = 0; $i -lt 10; $i++) {
                    Write-Host "    - $($enrolledDevices[$i].displayName) ($($enrolledDevices[$i].operatingSystem))" -ForegroundColor Gray
                }
            }
        }
        
        # Get current group members
        $currentMembers = Get-GroupDeviceMembers -GroupId $group.Id
        
        # Initialize HashSet for current members
        $currentMemberIds = [System.Collections.Generic.HashSet[string]]::new()
        if ($currentMembers) {
            foreach ($member in $currentMembers) {
                if ($member.Id) {
                    $currentMemberIds.Add($member.Id) | Out-Null
                }
            }
        }
        
        $initialMemberCount = $currentMemberIds.Count
        if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
            Write-Host "  Current group has $initialMemberCount member(s)" -ForegroundColor Gray
        }
        
        # Determine which devices need to be added and removed using HashSet for O(1) lookups
        $devicesToAdd = [System.Collections.Generic.List[string]]::new()
        $skippedCount = 0
        $enrolledDeviceIds = [System.Collections.Generic.HashSet[string]]::new()
        
        if ($enrolledDevices -and $enrolledDevices.Count -gt 0) {
            foreach ($device in $enrolledDevices) {
                if ($device -and $device.Id) {
                    $enrolledDeviceIds.Add($device.Id) | Out-Null
                    if (-not $currentMemberIds.Contains($device.Id)) {
                        $devicesToAdd.Add($device.Id)
                    } else {
                        $skippedCount++
                    }
                } else {
                    if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
                        Write-Host "    Skipping device with null ID: $($device.displayName)" -ForegroundColor Yellow
                    }
                }
            }
        }
        
        if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
            Write-Host "  Analysis: Found $($enrolledDevices.Count) devices, $($devicesToAdd.Count) to add, $skippedCount already members" -ForegroundColor Gray
            if ($devicesToAdd.Count -gt 0 -and $devicesToAdd.Count -le 5) {
                Write-Host "  Sample devices to add:" -ForegroundColor Gray
                $sampleCount = [Math]::Min(5, $devicesToAdd.Count)
                for ($i = 0; $i -lt $sampleCount; $i++) {
                    $deviceId = $devicesToAdd[$i]
                    if ($deviceLookup.ContainsKey($deviceId)) {
                        $deviceInfo = $deviceLookup[$deviceId]
                        Write-Host "    - $($deviceInfo.displayName) (ObjectId: $deviceId)" -ForegroundColor Gray
                    }
                }
            }
        }
        
        if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
            Write-Host "  Devices to add: $($devicesToAdd.Count), already members: $skippedCount" -ForegroundColor Gray
        }
        
        # Batch add devices to group
        $addedCount = 0
        $errorCount = 0
        
        if ($devicesToAdd.Count -gt 0) {
            if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
                Write-Host "  Adding devices to group using batch API..." -ForegroundColor Yellow
            }
            $batchResult = Add-DevicesToGroupBatch -GroupId $group.Id -DeviceIds $devicesToAdd
            $addedCount = $batchResult.Added
            $errorCount = $batchResult.Errors
        }
        
        # Verify group membership using already-retrieved device data (no additional API calls)
        if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
            Write-Host "  Verifying group membership..." -ForegroundColor Yellow
        }
        $updatedMembers = Get-GroupDeviceMembers -GroupId $group.Id
        $invalidMembers = [System.Collections.Generic.List[object]]::new()
        
        foreach ($member in $updatedMembers) {
            # Check if member should be in this group using HashSet lookup (O(1))
            if (-not $enrolledDeviceIds.Contains($member.Id)) {
                $invalidMembers.Add($member)
                if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
                    if ($deviceLookup.ContainsKey($member.Id)) {
                        $memberEntraDevice = $deviceLookup[$member.Id]
                        Write-Host "    Will remove: '$($memberEntraDevice.displayName)' (enrollmentProfileName: '$($memberEntraDevice.EnrollmentProfileName)')" -ForegroundColor Yellow
                    } else {
                        Write-Host "    Will remove: Device ID $($member.Id) (not an Apple device)" -ForegroundColor Yellow
                    }
                }
            }
        }
        
        # Remove invalid members from group using batch API if possible
        $removedCount = 0
        $removeErrorCount = 0
        
        if ($invalidMembers.Count -gt 0) {
            if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
                Write-Host "  Removing $($invalidMembers.Count) invalid member(s) from group..." -ForegroundColor Yellow
            }
            
            # Note: Graph API doesn't support batch DELETE for group members, must be individual calls
            foreach ($invalidMember in $invalidMembers) {
                try {
                    $uri = "https://graph.microsoft.com/v1.0/groups/$($group.Id)/members/$($invalidMember.Id)/`$ref"
                    Invoke-MgGraphRequest -Method DELETE -Uri $uri -ErrorAction Stop
                    $script:GraphCallCount++
                    $removedCount++
                    if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
                        $deviceName = if ($deviceLookup.ContainsKey($invalidMember.Id)) { $deviceLookup[$invalidMember.Id].displayName } else { $invalidMember.Id }
                        Write-Host "    Removed: $deviceName" -ForegroundColor Green
                    }
                } catch {
                    $removeErrorCount++
                    $deviceName = if ($deviceLookup.ContainsKey($invalidMember.Id)) { $deviceLookup[$invalidMember.Id].displayName } else { $invalidMember.Id }
                    Write-Host "    ERROR removing '$deviceName': $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
        
        if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
            if ($invalidMembers.Count -gt 0) {
                Write-Host "  Removed $removedCount invalid member(s), $removeErrorCount errors" -ForegroundColor $(if ($removeErrorCount -gt 0) { 'Yellow' } else { 'Green' })
            } else {
                Write-Host "  All members verified successfully" -ForegroundColor Green
            }
        }
        
        # Calculate expected member count (avoids Azure AD replication delay)
        # Initial members + additions - removals = expected final count
        $expectedMemberCount = $initialMemberCount + $addedCount - $removedCount
        
        # Summary for this profile
        $result = [PSCustomObject]@{
            Profile = $enrollProfile.displayName
            Group = $groupName
            Found = $enrolledDevices.Count
            Added = $addedCount
            Removed = $removedCount
            Errors = ($errorCount + $removeErrorCount)
            TotalMembers = $expectedMemberCount
        }
        
        $results += $result
        
        # Show status
        $totalErrors = $errorCount + $removeErrorCount
        $status = if ($totalErrors -gt 0) { "⚠ $totalErrors errors" } 
                  elseif ($addedCount -gt 0 -or $removedCount -gt 0) { 
                      $changes = @()
                      if ($addedCount -gt 0) { $changes += "Added $addedCount" }
                      if ($removedCount -gt 0) { $changes += "Removed $removedCount" }
                      "✓ " + ($changes -join ", ")
                  }
                  elseif ($enrolledDevices.Count -eq 0) { "- No devices" }
                  else { "✓ Up to date" }
        
        Write-Log "Profile '$($enrollProfile.displayName)' complete - Found: $($enrolledDevices.Count), Added: $addedCount, Removed: $removedCount, Errors: $totalErrors, Final members: $expectedMemberCount" -Level $(if ($totalErrors -gt 0) { 'Warning' } elseif ($addedCount -gt 0 -or $removedCount -gt 0) { 'Success' } else { 'Info' })
        Write-Host "  $status" -ForegroundColor $(if ($totalErrors -gt 0) { 'Yellow' } elseif ($addedCount -gt 0 -or $removedCount -gt 0) { 'Green' } else { 'Gray' })
    }
    
    # Final summary
    Write-Host "`n=== Summary ===" -ForegroundColor Cyan
    $results | Format-Table -AutoSize
    Write-Host "Total Graph API calls made: $script:GraphCallCount" -ForegroundColor Cyan
    
    # Log summary
    Write-Log "========================================" -Level Info
    Write-Log "Script completed successfully" -Level Success
    $totalFound = ($results | Measure-Object -Property Found -Sum).Sum
    $totalAdded = ($results | Measure-Object -Property Added -Sum).Sum
    $totalRemoved = ($results | Measure-Object -Property Removed -Sum).Sum
    $totalErrors = ($results | Measure-Object -Property Errors -Sum).Sum
    Write-Log "Summary - Profiles: $($results.Count), Total devices: $totalFound, Added: $totalAdded, Removed: $totalRemoved, Errors: $totalErrors, API calls: $script:GraphCallCount" -Level Info
    Write-Log "========================================" -Level Info
    
    # Disconnect from Graph
    Disconnect-MgGraph | Out-Null
}
catch {
    Write-Log "Script error: $($_.Exception.Message)" -Level Error
    Write-Log $_.ScriptStackTrace -Level Error
    Write-Host "`nERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    
    # Attempt to disconnect
    try {
        Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
    }
    catch {
        # Ignore disconnect errors
    }
    
    exit 1
}
