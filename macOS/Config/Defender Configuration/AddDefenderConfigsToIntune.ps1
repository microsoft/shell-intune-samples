############################################################################################
##
## This script uploads custom macOS configuration profiles to Microsoft Intune using the Microsoft Graph API.
##
############################################################################################

## Copyright (c) 2025 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: ckunze@microsoft.com
# 

#################################################
# Configuration Variables
#################################################

# Modify the $policyPrefix variable to change the prefix for the configuration names.
# This prefix will be prepended to each configuration profile name in Intune
$policyPrefix = "MDE (imported) - "

# Array of Microsoft Defender for Endpoint (MDE) mobile configuration files to upload
# These files contain various security and permission settings for macOS devices
$files = @(
    "accessibility.mobileconfig",       # Accessibility permissions for MDE
    "background_services.mobileconfig", # Background service permissions
    "bluetooth.mobileconfig",           # Bluetooth access permissions
    "fulldisk.mobileconfig",           # Full disk access permissions
    "kext.mobileconfig",               # Kernel extension permissions
    "netfilter.mobileconfig",          # Network filter permissions
    "notif.mobileconfig",              # Notification permissions
    "sysext.mobileconfig",             # System extension permissions
    "sysext_restricted.mobileconfig"   # Restricted system extension permissions
)

#################################################
# Prerequisites and Authentication
#################################################

# Ensure you have the Microsoft Graph PowerShell SDK installed
# Run this command if you haven't installed it yet:
# Install-Module Microsoft.Graph -Scope CurrentUser

# Connect to Microsoft Graph with the required permissions for device configuration management
# This will prompt for authentication if not already signed in
Connect-MgGraph -NoWelcome -Scopes "DeviceManagementConfiguration.ReadWrite.All"

#################################################
# Main Processing Loop
#################################################

# Process each mobile configuration file
foreach ($file in $files) {
    $FileContent = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/microsoft/mdatp-xplat/refs/heads/master/macos/mobileconfig/profiles/$file" -Method GET).Content
    $payload = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($FileContent))
    $FileName = $file -replace ".mobileconfig",""
    $json = '{
        "id": "00000000-0000-0000-0000-000000000000",
        "displayName": "' + $policyPrefix + $FileName + ' Configuration",
        "roleScopeTagIds": [
            "0"
        ],
        "@odata.type": "#microsoft.graph.macOSCustomConfiguration",
        "deploymentChannel": "deviceChannel",
        "payloadName": "' + $FileName + '",
        "payloadFileName": "' + $file + '",
        "payload": "' + $payload + '"
    }'
    Write-Host $FileName -ForegroundColor Green

    $uri = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations"
    $graphAction = "POST"
    Invoke-MgGraphRequest -Uri $uri -Method $graphAction -Body $json -ContentType "application/json"
    Write-Host "Uploaded $FileName configuration" -ForegroundColor Cyan
}