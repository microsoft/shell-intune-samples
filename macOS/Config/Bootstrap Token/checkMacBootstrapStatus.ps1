#requires -module Microsoft.Graph.Authentication
#requires -module Microsoft.Graph.Beta.DeviceManagement
 
Connect-MgGraph -ContextScope Process -Scopes DeviceManagementManagedDevices.Read.All
 
#getting a list of mac devices with no associated user
$macDevices=Get-MgBetaDeviceManagementManagedDevice -Filter "operatingSystem eq 'macOS'" -All
$macDevices=$macDevices | where-object {($_.userId -eq $null) -or ($_.userId -eq "") -or ($_.userId -eq "00000000-0000-0000-0000-000000000000")}
write-host "$($macDevices.count) userless mac devices."
 
If($macDevices) {
    write-host "Checking for bootstrap escrow status..."
 
    $results=@() #variable to store the results
 
    #looping through the userless mac devices to get the bootstrap token escrow status
    foreach ($macDevice in $macDevices) {
        $mac=Get-MgBetaDeviceManagementManagedDevice -ManagedDeviceId $macDevice.Id -Select bootstrapTokenEscrowed
        $results+=$mac
    }
 
 
    $escrowedMac=$results | where-object {$_.bootstrapTokenEscrowed -eq $true}
    write-host "$($escrowedMac.count) userless mac devices escrowed"
    $notEscrowedMac=$results | where-object {$_.bootstrapTokenEscrowed -eq $false}
    write-host "$($notEscrowedMac.count) userless mac devices missing bootstrap tokens"
 
    $notEscrowedMac | export-csv notEscrowedMac.csv -NoTypeInformation
    write-host "exported to notEscrowedMac.csv"
}
