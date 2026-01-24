# Perm löschen
# -------------------------------------

# Welche Permissions hat ein User an einer Enterprise App consented?

# Enterprise App = Service Principal
$spDisplayName = 'Microsoft Graph PowerShell'
$spId = (Get-MgServicePrincipal -Filter "displayName eq '$spDisplayName'").Id

$userDisplayName = 'Paul Drude'
$userDisplayName = 'Anton Zeilinger'
$userId = (Get-MgUser -Filter "displayName eq '$userDisplayName'").Id

$spOAuth2PermissionsGrants = Get-MgOauth2PermissionGrant | Where-Object {$_.ClientId -EQ $spId -and $_.PrincipalId -EQ $userId}

$spOAuth2PermissionsGrants | fl *
($spOAuth2PermissionsGrants | % Scope).split(' ') | Sort-Object

# Consented Permissions löschen
$spOAuth2PermissionsGrants | ForEach-Object {Remove-MgOauth2PermissionGrant -OAuth2PermissionGrantId $_.Id}



# What Perm?
# -------------------------------------

Find-MgGraphCommand -Command Get-MgUser | Select-Object -Skip 1 | % Permissions