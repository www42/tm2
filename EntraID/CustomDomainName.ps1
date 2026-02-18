# --- Domain Names (DNS) ------------------------------------------------
Get-MgDomain -All | Measure-Object | % Count
Get-MgDomain -All | Format-Table Id, IsDefault, IsInitial, IsVerified

# --- Get all objects referencing to a domain name ----------------------
$domainId = 'contoso69118.com'
$references = Get-MgDomainNameReference -DomainId $domainId

foreach ($reference in $references) {
    switch ($reference.AdditionalProperties.'@odata.type') {
        '#microsoft.graph.user' {
            $user = Get-MgUser -UserId $reference.Id
            Write-Host "User: $($user.UserPrincipalName)"
        }
        '#microsoft.graph.group' {
            $group = Get-MgGroup -GroupId $reference.Id
            Write-Host "Group: $($group.DisplayName)"
        }
        '#microsoft.graph.device' {
            $device = Get-MgDevice -DeviceId $reference.Id
            Write-Host "Device: $($device.DisplayName)"
        }
        default {
            Write-Host "Others: $($reference.Id) - Type: $($reference.AdditionalProperties.'@odata.type')"
        }
    }
}