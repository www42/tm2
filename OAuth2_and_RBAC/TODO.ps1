 
Get-MgContext | % Scopes | Sort-Object

Get-MgApplication -All | 
    Select-Object DisplayName, AppId | 
    Format-Table

# Alle Service Principals vom Typ "Application" mit dem Tag "WindowsAzureActiveDirectoryIntegratedApp"
# Das sind die Apps, die im Entra Portal mit dem Filter 'Application type == Enterprise Applications' angezeigt werden
$enterpriseApps = Get-MgServicePrincipal -All | 
    Where-Object { 
        $_.ServicePrincipalType -eq 'Application' -and 
        $_.Tags -contains 'WindowsAzureActiveDirectoryIntegratedApp'
    }

$enterpriseApps.Count
$enterpriseApps | 
    Select-Object DisplayName, AppId | Sort-Object DisplayName | Format-Table -AutoSize


Get-MgApplication -ApplicationId 'cfc4c66e-f229-489f-bc8c-57a65287ff9a'  # Error: ...does not exist or one of its queried reference-property objects are not present.
Get-MgApplication -All | 
    Where-Object AppId -EQ 'cfc4c66e-f229-489f-bc8c-57a65287ff9a' | Select-Object DisplayName, AppId | Format-Table -AutoSize # Ok



# Alle Service Principals mit "Portal" oder "Azure" im Namen
Get-MgServicePrincipal -Filter "startswith(displayName,'Azure')" | 
    Select-Object DisplayName, AppId | 
    Format-Table




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