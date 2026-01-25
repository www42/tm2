# OAuth2 Delegated Permission Consent
# -----------------------------------

# Client App (= Enterprise App = Service Principal)
# $spDisplayName = 'Microsoft Graph PowerShell'           # az.training
$spDisplayName = 'Microsoft Graph Command Line Tools'   # contoso69118.com

$spId = (Get-MgServicePrincipal -Filter "displayName eq '$spDisplayName'").Id

# Resource (= API = Microsoft Graph)
$resourceId = (Get-MgServicePrincipal -Filter "displayName eq 'Microsoft Graph'").Id

# User
# $userDisplayName = 'Paul Drude'    # az.training
$userDisplayName = 'Dan Jump'      # contoso69118.com
$userId = (Get-MgUser -Filter "displayName eq '$userDisplayName'").Id


# Delegated Permissions auslesen
# ------------------------------
#   Delegated permissions granted by Admin (Admin consent)
$grants = Get-MgServicePrincipalOauth2PermissionGrant -ServicePrincipalId $spId | Where-Object {$_.ConsentType -EQ 'AllPrincipals'}

#   Delegated permissions granted by users
$grants = Get-MgServicePrincipalOauth2PermissionGrant -ServicePrincipalId $spId | Where-Object {$_.ConsentType -EQ 'Principal'}

#   Delegated permissions granted by a single user
$grants = Get-MgServicePrincipalOauth2PermissionGrant -ServicePrincipalId $spId | Where-Object {$_.PrincipalId -EQ $userId}

#   All Delegated permissions (user consented and admin consented)
$grants = Get-MgServicePrincipalOauth2PermissionGrant -ServicePrincipalId $spId


$grants | fl *
($grants | % Scope).split(' ') | Sort-Object


# Delegated Permissions löschen
# ------------------------------
$grants | ForEach-Object {Remove-MgOauth2PermissionGrant -OAuth2PermissionGrantId $_.Id}



# Delegated Permissions neu hinzufügen
# ------------------------------------
$scopes = 'openid email offline_access Directory.Read.All'

#   User Consent
New-MgOauth2PermissionGrant -ClientId $spId -ResourceId $resourceId -Scope $scopes -ConsentType 'Principal' -PrincipalId $userId

#   Admin Consent
New-MgOauth2PermissionGrant -ClientId $spId -ResourceId $resourceId -Scope $scopes -ConsentType 'AllPrincipals'




# Delegated Permissions updaten
# ------------------------------
$scopesToAdd = 'user_impersonation'
$grantToUpdate = Get-MgServicePrincipalOauth2PermissionGrant -ServicePrincipalId $spId | Where-Object {$_.PrincipalId -EQ $userId}

Update-MgOauth2PermissionGrant -OAuth2PermissionGrantId $grantToUpdate.Id -Scope $scopesToAdd




# Welche Permissions braucht ein PowerShell Cmdlet?
# -------------------------------------------------
Find-MgGraphCommand -Command Get-MgUser | Select-Object -Skip 1 | % Permissions | Sort-Object

# Stimmt das wirklich?
# Für 'Get-MgUser' braucht man 'Directory.ReadWrite.All'?