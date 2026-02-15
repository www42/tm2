
# Zeige ALLE OAuth2PermissionGrants im Tenant
Get-MgOauth2PermissionGrant -All | Measure-Object | % Count
Get-MgOauth2PermissionGrant -All | 
    ForEach-Object {
        $client = Get-MgServicePrincipal -ServicePrincipalId $_.ClientId
        $resource = Get-MgServicePrincipal -ServicePrincipalId $_.ResourceId
        
        [PSCustomObject]@{
            Client = $client.DisplayName
            Resource = $resource.DisplayName
            Scopes = $_.Scope
        }
    } | Sort-Object Client | Format-Table -AutoSize