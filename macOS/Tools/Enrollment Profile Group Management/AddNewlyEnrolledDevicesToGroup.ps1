<#
.SYNOPSIS
    Adds newly enrolled macOS, iOS, and iPadOS devices to groups based on their enrollment profile.

.DESCRIPTION
    This script authenticates to Microsoft Entra/Intune using either user authentication or certificate-based authentication.
    It retrieves devices that have enrolled in the last 10 minutes and adds them to groups with names based on
    the enrollment profile name and a configurable prefix.

.PARAMETER Prefix
    The prefix to use for group names. Group names will be: Prefix + EnrollmentProfileName

.PARAMETER TokenName
    Optional token name for tracking/logging purposes.

.PARAMETER TenantId
    The Azure AD Tenant ID (required for certificate authentication).

.PARAMETER ClientId
    The Application (Client) ID (required for certificate authentication).

.PARAMETER CertificateThumbprint
    The certificate thumbprint for certificate-based authentication.

.PARAMETER MinutesBack
    Number of minutes to look back for newly enrolled devices. Default is 10.

.PARAMETER RunDurationHours
    Number of hours to continuously run the script. Default is 0 (single run). Set to run continuously for the specified duration.

.PARAMETER CheckIntervalMinutes
    Number of minutes to wait between checks when running continuously. Default is 1.

.PARAMETER LogRetentionDays
    Number of days to keep log files. Default is 7 days.

.PARAMETER LogPath
    Optional path to directory where log files will be stored. If not specified, logs will be stored in the same directory as the script.

.EXAMPLE
    .\AddNewlyEnrolledDevicesToGroup.ps1 -Prefix "[CK]-DG-" -TokenName "[CK]UEMCATLABS"
    
    Uses user authentication to connect and process devices.

.EXAMPLE
    .\AddNewlyEnrolledDevicesToGroup.ps1 -Prefix "[CK]-DG-" -TokenName "[CK]UEMCATLABS" -TenantId "4c252310-e8bc-4601-939c-eec227985cad" -ClientId "a905ecd5-8b93-42f0-9c9a-aeeb300abee0" -CertificateThumbprint "1B7A715A761634904E9C4471CDEADD7FD19176A8" -MinutesBack 10
    
    Uses certificate-based authentication to connect and process devices enrolled in the last 10 minutes.

.EXAMPLE
    .\AddNewlyEnrolledDevicesToGroup.ps1 -Prefix "[CK]-DG-" -TokenName "[CK]UEMCATLABS" -TenantId "4c252310-e8bc-4601-939c-eec227985cad" -ClientId "a905ecd5-8b93-42f0-9c9a-aeeb300abee0" -CertificateThumbprint "1B7A715A761634904E9C4471CDEADD7FD19176A8" -RunDurationHours 6 -CheckIntervalMinutes 1 -MinutesBack 10
    
    Runs continuously for 6 hours, checking every 1 minute for devices enrolled in the last 10 minutes.

.EXAMPLE
    .\AddNewlyEnrolledDevicesToGroup.ps1 -Prefix "[CK]-DG-" -TokenName "[CK]UEMCATLABS" -TenantId "4c252310-e8bc-4601-939c-eec227985cad" -ClientId "a905ecd5-8b93-42f0-9c9a-aeeb300abee0" -CertificateThumbprint "1B7A715A761634904E9C4471CDEADD7FD19176A8" -LogPath "C:\Logs" -LogRetentionDays 14

.NOTES
    Requires Microsoft.Graph.Authentication PowerShell module.
    Uses Invoke-MgGraphRequest for all Graph API calls.
    
    Log files are created daily in the script directory and automatically cleaned up based on LogRetentionDays parameter.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Prefix,

    [Parameter(Mandatory = $false)]
    [string]$TokenName,

    [Parameter(Mandatory = $false)]
    [string]$TenantId,

    [Parameter(Mandatory = $false)]
    [string]$ClientId,

    [Parameter(Mandatory = $false)]
    [string]$CertificateThumbprint,

    [Parameter(Mandatory = $false)]
    [int]$MinutesBack = 10,

    [Parameter(Mandatory = $false)]
    [int]$RunDurationHours = 0,

    [Parameter(Mandatory = $false)]
    [int]$CheckIntervalMinutes = 1,

    [Parameter(Mandatory = $false)]
    [int]$LogRetentionDays = 7,

    [Parameter(Mandatory = $false)]
    [string]$LogPath
)

#Requires -Modules Microsoft.Graph.Authentication

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

$logFileName = "AddNewlyEnrolledDevices_$(Get-Date -Format 'yyyyMMdd').log"
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
    
    # Write to console with appropriate color
    $color = switch ($Level) {
        'Info'    { 'White' }
        'Warning' { 'Yellow' }
        'Error'   { 'Red' }
        'Success' { 'Green' }
        default   { 'White' }
    }
    
    Write-Host $logMessage -ForegroundColor $color
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
        $logFiles = Get-ChildItem -Path $LogDirectory -Filter "AddNewlyEnrolledDevices_*.log" -ErrorAction SilentlyContinue
        
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

# Function to authenticate to Microsoft Graph
function Connect-ToGraph {
    param (
        [string]$TenantId,
        [string]$ClientId,
        [string]$CertificateThumbprint
    )

    Write-Log "Checking for existing Microsoft Graph connection..." -Level Info
    Write-Verbose "Checking for existing Microsoft Graph connection..."
    
    # Check if already connected
    $context = Get-MgContext
    if ($context) {
        Write-Log "Already connected to Microsoft Graph as $($context.Account)" -Level Info
        Write-Verbose "Already connected to Microsoft Graph as $($context.Account)"
        return
    }

    # Determine authentication method
    if ($CertificateThumbprint -and $ClientId -and $TenantId) {
        Write-Log "Authenticating with certificate..." -Level Info
        Write-Verbose "Authenticating with certificate..."
        Write-Host "Connecting to Microsoft Graph using certificate authentication..." -ForegroundColor Cyan
        
        try {
            Connect-MgGraph -TenantId $TenantId `
                          -ClientId $ClientId `
                          -CertificateThumbprint $CertificateThumbprint `
                          -NoWelcome
            
            Write-Log "Successfully connected using certificate authentication" -Level Success
            Write-Host "Successfully connected using certificate authentication" -ForegroundColor Green
        }
        catch {
            Write-Log "Failed to connect using certificate authentication: $_" -Level Error
            Write-Error "Failed to connect using certificate authentication: $_"
            throw
        }
    }
    else {
        Write-Log "Authenticating with user credentials..." -Level Info
        Write-Verbose "Authenticating with user credentials..."
        Write-Host "Connecting to Microsoft Graph using user authentication..." -ForegroundColor Cyan
        
        try {
            Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All", "Group.ReadWrite.All", "Device.Read.All" -NoWelcome
            
            Write-Log "Successfully connected using user authentication" -Level Success
            Write-Host "Successfully connected using user authentication" -ForegroundColor Green
        }
        catch {
            Write-Log "Failed to connect using user authentication: $_" -Level Error
            Write-Error "Failed to connect using user authentication: $_"
            throw
        }
    }

    # Verify connection
    $context = Get-MgContext
    if (-not $context) {
        Write-Log "Failed to establish connection to Microsoft Graph" -Level Error
        throw "Failed to establish connection to Microsoft Graph"
    }

    Write-Log "Connected to tenant: $($context.TenantId)" -Level Info
    Write-Verbose "Connected to tenant: $($context.TenantId)"
}

# Function to get an existing group
function Get-ExistingGroup {
    param (
        [string]$GroupName
    )

    Write-Verbose "Looking for group: $GroupName"
    
    # Search for existing group using Graph API
    $encodedGroupName = [System.Web.HttpUtility]::UrlEncode("displayName eq '$GroupName'")
    $uri = "https://graph.microsoft.com/v1.0/groups?`$filter=$encodedGroupName"
    
    try {
        $response = Invoke-MgGraphRequest -Method GET -Uri $uri
        $script:GraphCallCount++
        
        if ($response.value -and $response.value.Count -gt 0) {
            $group = $response.value[0]
            Write-Verbose "Found existing group: $GroupName (ID: $($group.id))"
            return $group
        }
        else {
            Write-Warning "Group '$GroupName' not found. Skipping devices for this profile."
            return $null
        }
    }
    catch {
        Write-Warning "Error searching for group '$GroupName': $_"
        return $null
    }
}

# Function to add devices to group in batch
function Add-DevicesToGroupBatch {
    param (
        [string]$GroupId,
        [array]$Devices,
        [string]$GroupName
    )

    Write-Verbose "Checking and adding up to $($Devices.Count) devices to group '$GroupName'"
    
    try {
        # Get current group members
        $membersUri = "https://graph.microsoft.com/v1.0/groups/$GroupId/members?`$select=id"
        $members = @()
        
        do {
            $response = Invoke-MgGraphRequest -Method GET -Uri $membersUri
            $script:GraphCallCount++
            $members += $response.value
            $membersUri = $response.'@odata.nextLink'
        } while ($membersUri)
        
        $existingMemberIds = $members | Select-Object -ExpandProperty id
        
        # Filter out devices already in the group
        $devicesToAdd = $Devices | Where-Object { $_.EntraObjectId -notin $existingMemberIds }
        $alreadyInGroup = $Devices | Where-Object { $_.EntraObjectId -in $existingMemberIds }
        
        # Report already existing members
        foreach ($device in $alreadyInGroup) {
            Write-Host "  Device '$($device.DeviceName)' is already a member of group '$GroupName'" -ForegroundColor Gray
        }
        
        if ($devicesToAdd.Count -eq 0) {
            return @{
                Added = 0
                AlreadyInGroup = $alreadyInGroup.Count
                Errors = 0
            }
        }
        
        # Add devices using batch requests (max 20 per batch)
        $batchSize = 20
        $addedCount = 0
        $errorCount = 0
        
        for ($i = 0; $i -lt $devicesToAdd.Count; $i += $batchSize) {
            $endIndex = [Math]::Min($i + $batchSize - 1, $devicesToAdd.Count - 1)
            
            # Handle single element or slice
            if ($i -eq $endIndex) {
                $batch = @($devicesToAdd[$i])
            } else {
                $batch = $devicesToAdd[$i..$endIndex]
            }
            
            $batchRequests = @()
            $requestId = 1
            foreach ($device in $batch) {
                $batchRequests += @{
                    id = "$requestId"
                    method = "POST"
                    url = "/groups/$GroupId/members/`$ref"
                    body = @{
                        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($device.EntraObjectId)"
                    }
                    headers = @{
                        "Content-Type" = "application/json"
                    }
                }
                $requestId++
            }
            
            $batchBody = @{
                requests = $batchRequests
            }
            
            $jsonPayload = $batchBody | ConvertTo-Json -Depth 10
            
            try {
                $batchResponse = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/`$batch" -Body $jsonPayload
                $script:GraphCallCount++
                
                foreach ($response in $batchResponse.responses) {
                    $requestIndex = [int]$response.id - 1
                    $device = $batch[$requestIndex]
                    
                    if ($response.status -eq 204 -or $response.status -eq 200) {
                        Write-Host "  Added device '$($device.DeviceName)' to group '$GroupName'" -ForegroundColor Green
                        $addedCount++
                    }
                    else {
                        Write-Warning "Failed to add device '$($device.DeviceName)' to group '$GroupName': Status $($response.status)"
                        $errorCount++
                    }
                }
            }
            catch {
                Write-Warning "Batch request failed: $_"
                $errorCount += $batch.Count
            }
        }
        
        return @{
            Added = $addedCount
            AlreadyInGroup = $alreadyInGroup.Count
            Errors = $errorCount
        }
    }
    catch {
        Write-Warning "Failed to process devices for group '$GroupName': $_"
        return @{
            Added = 0
            AlreadyInGroup = 0
            Errors = $Devices.Count
        }
    }
}

# Main script execution
try {
    # Clean up old log files
    Remove-OldLogFiles -LogDirectory $scriptPath -RetentionDays $LogRetentionDays
    
    Write-Log "========================================" -Level Info
    Write-Log "Script started" -Level Info
    Write-Log "Log file: $logFilePath" -Level Info
    Write-Log "Log retention: $LogRetentionDays days" -Level Info
    Write-Log "========================================" -Level Info
    
    # Determine if running continuously
    $runContinuously = $RunDurationHours -gt 0
    $endTime = if ($runContinuously) { (Get-Date).AddHours($RunDurationHours) } else { $null }
    $iterationCount = 0
    
    do {
        $iterationCount++
        
        if ($runContinuously) {
            $remainingTime = ($endTime - (Get-Date)).TotalMinutes
            Write-Log "Iteration #$iterationCount - Time remaining: $([Math]::Round($remainingTime, 1)) minutes" -Level Info
            Write-Host "`n========================================" -ForegroundColor Cyan
            Write-Host "  Iteration #$iterationCount" -ForegroundColor Cyan
            Write-Host "  Time remaining: $([Math]::Round($remainingTime, 1)) minutes" -ForegroundColor Cyan
            Write-Host "========================================`n" -ForegroundColor Cyan
        }
        else {
            Write-Log "Add Newly Enrolled Devices to Groups - Single run" -Level Info
            Write-Host "`n========================================" -ForegroundColor Cyan
            Write-Host "  Add Newly Enrolled Devices to Groups" -ForegroundColor Cyan
            Write-Host "========================================`n" -ForegroundColor Cyan
        }

        if ($TokenName) {
            Write-Log "Token Name: $TokenName" -Level Info
            Write-Host "Token Name: $TokenName" -ForegroundColor Gray
        }
        Write-Log "Group Prefix: $Prefix" -Level Info
        Write-Log "Time Window: Last $MinutesBack minutes" -Level Info
        Write-Host "Group Prefix: $Prefix" -ForegroundColor Gray
        Write-Host "Time Window: Last $MinutesBack minutes`n" -ForegroundColor Gray

        # Connect to Microsoft Graph (only on first iteration or if disconnected)
        if ($iterationCount -eq 1 -or -not (Get-MgContext)) {
            Connect-ToGraph -TenantId $TenantId -ClientId $ClientId -CertificateThumbprint $CertificateThumbprint
        }

        # Reset graph call counter for this iteration
        $script:GraphCallCount = 0

        # Calculate the cutoff time
        $cutoffTime = (Get-Date).AddMinutes(-$MinutesBack).ToUniversalTime()
        $cutoffTimeString = $cutoffTime.ToString("yyyy-MM-ddTHH:mm:ssZ")
        
        Write-Log "Searching for devices enrolled after: $cutoffTimeString" -Level Info
        Write-Host "`nSearching for devices enrolled after: $cutoffTimeString" -ForegroundColor Cyan

        # Get managed devices filtered by operating system and enrollment time
        Write-Verbose "Retrieving managed devices from Intune..."
        $filter = [System.Web.HttpUtility]::UrlEncode("(operatingSystem eq 'macOS' or operatingSystem eq 'iOS' or operatingSystem eq 'iPadOS') and enrolledDateTime ge $cutoffTimeString")
        $uri = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?`$filter=$filter"
        
        $recentDevices = @()
        do {
            $response = Invoke-MgGraphRequest -Method GET -Uri $uri
            $script:GraphCallCount++
            $recentDevices += $response.value
            $uri = $response.'@odata.nextLink'
        } while ($uri)
        
        Write-Verbose "Retrieved $($recentDevices.Count) newly enrolled Apple devices from Intune"

        Write-Log "Found $($recentDevices.Count) newly enrolled device(s)" -Level Info
        Write-Host "Found $($recentDevices.Count) newly enrolled device(s)" -ForegroundColor Cyan

        if ($recentDevices.Count -eq 0) {
            Write-Log "No newly enrolled devices found in the last $MinutesBack minutes." -Level Info
            Write-Log "Total Graph API calls made: $script:GraphCallCount" -Level Info
            Write-Host "`nNo newly enrolled devices found in the last $MinutesBack minutes." -ForegroundColor Yellow
            Write-Host "Total Graph API calls made: $script:GraphCallCount" -ForegroundColor Cyan
            
            if ($runContinuously) {
                $remainingTime = ($endTime - (Get-Date)).TotalMinutes
                
                if ($remainingTime -gt $CheckIntervalMinutes) {
                    Write-Host "`nWaiting $CheckIntervalMinutes minute(s) before next check..." -ForegroundColor Gray
                    Write-Host "Press Ctrl+C to stop the script" -ForegroundColor Gray
                    Start-Sleep -Seconds ($CheckIntervalMinutes * 60)
                    continue
                }
                else {
                    Write-Host "`nCompleted continuous run - Duration limit reached.`n" -ForegroundColor Green
                    break
                }
            }
            else {
                Write-Host "Script completed.`n" -ForegroundColor Cyan
                break
            }
        }

        # Enrich devices with Entra ID information to get enrollment profile names
        Write-Host "`nEnriching device information from Entra ID...`n" -ForegroundColor Cyan
        
        # Use batch request to get all Entra device objects at once
        $batchRequests = @()
        $batchSize = 20
        $enrichedDevices = @()
        
        for ($i = 0; $i -lt $recentDevices.Count; $i++) {
            $device = $recentDevices[$i]
            if ($device.azureADDeviceId) {
                $batchRequests += @{
                    id = "$i"
                    method = "GET"
                    url = "/devices?`$filter=deviceId eq '$($device.azureADDeviceId)'"
                }
            }
        }
        
        # Process batches
        $allEntraDevices = @{}
        for ($i = 0; $i -lt $batchRequests.Count; $i += $batchSize) {
            $batch = $batchRequests[$i..[Math]::Min($i + $batchSize - 1, $batchRequests.Count - 1)]
            
            $batchBody = @{
                requests = $batch
            }
            
            Write-Verbose "Sending batch request with $($batch.Count) device lookups..."
            
            try {
                $batchResponse = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/`$batch" -Body ($batchBody | ConvertTo-Json -Depth 10)
                $script:GraphCallCount++
                
                foreach ($response in $batchResponse.responses) {
                    if ($response.status -eq 200 -and $response.body.value -and $response.body.value.Count -gt 0) {
                        $deviceIndex = [int]$response.id
                        $allEntraDevices[$deviceIndex] = $response.body.value[0]
                    }
                }
            }
            catch {
                Write-Warning "Batch request failed: $_"
            }
        }
        
        # Create enriched device objects
        for ($i = 0; $i -lt $recentDevices.Count; $i++) {
            $device = $recentDevices[$i]
            
            if ($device.azureADDeviceId -and $allEntraDevices.ContainsKey($i)) {
                $entraDevice = $allEntraDevices[$i]
                
                # Get enrollment profile name directly from the Entra device object
                $enrollmentProfileName = $entraDevice.enrollmentProfileName
                
                # Fall back to Intune enrollment profile name if not found in Entra
                if ([string]::IsNullOrWhiteSpace($enrollmentProfileName)) {
                    $enrollmentProfileName = $device.enrollmentProfileName
                    Write-Verbose "Using Intune enrollment profile name as fallback: $enrollmentProfileName"
                }
                
                # Create enriched device object
                $enrichedDevice = [PSCustomObject]@{
                    DeviceName = $device.deviceName
                    IntuneDeviceId = $device.id
                    AzureADDeviceId = $device.azureADDeviceId
                    EntraObjectId = $entraDevice.id
                    EnrolledDateTime = $device.enrolledDateTime
                    OperatingSystem = $device.operatingSystem
                    EnrollmentProfileName = $enrollmentProfileName
                    EntraDisplayName = $entraDevice.displayName
                }
                
                $enrichedDevices += $enrichedDevice
                Write-Verbose "Enriched device: $($device.deviceName) with enrollment profile: $enrollmentProfileName"
            }
            elseif ($device.azureADDeviceId) {
                Write-Warning "Could not find Entra ID object for device '$($device.deviceName)' (Azure AD ID: $($device.azureADDeviceId))"
                
                # Add device with Intune data only
                $enrichedDevice = [PSCustomObject]@{
                    DeviceName = $device.deviceName
                    IntuneDeviceId = $device.id
                    AzureADDeviceId = $device.azureADDeviceId
                    EntraObjectId = $null
                    EnrolledDateTime = $device.enrolledDateTime
                    OperatingSystem = $device.operatingSystem
                    EnrollmentProfileName = $device.enrollmentProfileName
                    EntraDisplayName = $null
                }
                $enrichedDevices += $enrichedDevice
            }
            else {
                Write-Warning "Device '$($device.deviceName)' does not have an Azure AD Device ID. Skipping."
            }
        }

        # Group devices by enrollment profile
        $devicesByProfile = $enrichedDevices | Group-Object -Property EnrollmentProfileName

        Write-Log "Processing devices by enrollment profile..." -Level Info
        Write-Host "`nProcessing devices by enrollment profile...`n" -ForegroundColor Cyan

        $totalDevicesProcessed = 0
        $totalDevicesAdded = 0
        $totalDevicesAlreadyInGroup = 0

        foreach ($profileGroup in $devicesByProfile) {
            $enrollmentProfileName = $profileGroup.Name
            
            if ([string]::IsNullOrWhiteSpace($enrollmentProfileName)) {
                Write-Log "Skipping $($profileGroup.Count) device(s) with no enrollment profile name" -Level Warning
                Write-Warning "Skipping $($profileGroup.Count) device(s) with no enrollment profile name"
                continue
            }

            $groupName = "$Prefix$enrollmentProfileName"
            Write-Log "Processing enrollment profile: $enrollmentProfileName (Target group: $groupName, Devices: $($profileGroup.Count))" -Level Info
            Write-Host "Processing enrollment profile: $enrollmentProfileName" -ForegroundColor Yellow
            Write-Host "  Target group: $groupName" -ForegroundColor Gray
            Write-Host "  Devices to process: $($profileGroup.Count)" -ForegroundColor Gray

            # Get the existing group
            $group = Get-ExistingGroup -GroupName $groupName
            
            if (-not $group) {
                Write-Log "Group '$groupName' does not exist - skipping $($profileGroup.Count) device(s)" -Level Warning
                Write-Host "  Skipping $($profileGroup.Count) device(s) - group does not exist`n" -ForegroundColor Yellow
                continue
            }

            # Filter devices with valid Entra Object IDs
            $validDevices = $profileGroup.Group | Where-Object { $_.EntraObjectId }
            $invalidDevices = $profileGroup.Group | Where-Object { -not $_.EntraObjectId }
            
            foreach ($device in $invalidDevices) {
                Write-Log "Device '$($device.DeviceName)' does not have an Entra Object ID. Skipping." -Level Warning
                Write-Warning "Device '$($device.DeviceName)' does not have an Entra Object ID. Skipping."
            }
            
            if ($validDevices.Count -eq 0) {
                Write-Log "No valid devices to process for group '$groupName'" -Level Warning
                Write-Host "  No valid devices to process`n" -ForegroundColor Yellow
                continue
            }
            
            # Add devices to group using batch
            $result = Add-DevicesToGroupBatch -GroupId $group.id -Devices $validDevices -GroupName $groupName
            
            $totalDevicesProcessed += $validDevices.Count
            $totalDevicesAdded += $result.Added
            $totalDevicesAlreadyInGroup += $result.AlreadyInGroup

            Write-Log "Profile '$enrollmentProfileName' complete - Added: $($result.Added), Already in group: $($result.AlreadyInGroup), Errors: $($result.Errors)" -Level Info
            Write-Host ""
        }

        # Summary
        Write-Log "========================================" -Level Info
        Write-Log "Summary - Total found: $($enrichedDevices.Count), Processed: $totalDevicesProcessed, Added: $totalDevicesAdded, Already in groups: $totalDevicesAlreadyInGroup, API calls: $script:GraphCallCount" -Level Info
        Write-Log "========================================" -Level Info
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "  Summary" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "Total devices found: $($enrichedDevices.Count)" -ForegroundColor Gray
        Write-Host "Total devices processed: $totalDevicesProcessed" -ForegroundColor Gray
        Write-Host "Total devices added to groups: $totalDevicesAdded" -ForegroundColor Green
        Write-Host "Total devices already in groups: $totalDevicesAlreadyInGroup" -ForegroundColor Yellow
        Write-Host "Total Graph API calls made: $script:GraphCallCount" -ForegroundColor Cyan
        
        if ($runContinuously) {
            $remainingTime = ($endTime - (Get-Date)).TotalMinutes
            
            if ($remainingTime -gt $CheckIntervalMinutes) {
                Write-Host "`nWaiting $CheckIntervalMinutes minute(s) before next check..." -ForegroundColor Gray
                Write-Host "Press Ctrl+C to stop the script" -ForegroundColor Gray
                Start-Sleep -Seconds ($CheckIntervalMinutes * 60)
            }
            else {
                Write-Host "`nCompleted continuous run - Duration limit reached.`n" -ForegroundColor Green
            }
        }
        else {
            Write-Host "Script completed successfully!`n" -ForegroundColor Green
        }
        
    } while ($runContinuously -and (Get-Date) -lt $endTime)
    
    if ($runContinuously) {
        Write-Log "Continuous run complete - Total iterations: $iterationCount, Duration: $RunDurationHours hour(s)" -Level Success
        Write-Host "`n========================================" -ForegroundColor Cyan
        Write-Host "  Continuous Run Complete" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "Total iterations: $iterationCount" -ForegroundColor Gray
        Write-Host "Duration: $RunDurationHours hour(s)" -ForegroundColor Gray
        Write-Host "Script completed successfully!`n" -ForegroundColor Green
    }
    
    Write-Log "Script completed successfully" -Level Success
}
catch {
    Write-Log "An error occurred during script execution: $_" -Level Error
    Write-Log $_.ScriptStackTrace -Level Error
    Write-Error "An error occurred during script execution: $_"
    Write-Error $_.ScriptStackTrace
    exit 1
}
finally {
    # Disconnect from Microsoft Graph
    if (Get-MgContext) {
        Write-Log "Disconnecting from Microsoft Graph..." -Level Info
        Write-Verbose "Disconnecting from Microsoft Graph..."
        Disconnect-MgGraph | Out-Null
    }
}
