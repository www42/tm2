# Application Registration vs Enterprise App
# ------------------------------------------

# Get-MgApplication -------> App-Registrierungen (Apps, die in Ihrem Tenant registriert sind)
# Get-MgServicePrincipal --> Enterprise Applications (Service Principals, die Apps in Ihrem Tenant repräsentieren, inkl. externe Apps)
#
# Jede App-Registrierung hat normalerweise einen zugehörigen Service Principal, 
# aber nicht jeder Service Principal hat eine App-Registrierung in Ihrem Tenant.

# Microsoft Graph
# ---------------
Connect-MgGraph -Scopes "Application.Read.All"
Get-MgContext | Select-Object Scopes, Account, TenantId, AppName | fl
Get-MgContext | % Scopes  # Warum sind das so viele scopes? Ich habe doch nur "Application.Read.All" angegeben?

# Enterprise Apps (Service Principals)
# ------------------------------------
# Alle Service Principals abrufen
Get-MgServicePrincipal -All | Sort-Object DisplayName | Format-Table DisplayName, AppId, Id
Get-MgServicePrincipal -All | Measure-Object | % count  # 626
Get-MgServicePrincipalCount -ConsistencyLevel eventual  # 626, siehe https://learn.microsoft.com/en-us/graph/aad-advanced-queries

# Es gibt verschiedene Typen von Service Principals
Get-MgServicePrincipal -All | Group-Object -property ServicePrincipalType  # SocialIdp = Social Identity Provider
Get-MgServicePrincipal -All | Where-Object ServicePrincipalType -eq 'SocialIdp' | ft DisplayName,ServicePrincipalType  # O365 LinkedIn Connection

# App-Registrierungen (Applications)
# ----------------------------------
# Alle Apps anzeigen
Get-MgApplication -All | Sort-Object DisplayName | Select-Object DisplayName, AppId, Id | Format-Table
Get-MgApplication -All | Measure-Object | % count  # 52
Get-MgApplicationCount -ConsistencyLevel eventual  # 52

Get-MgApplication -All | Group-Object PublisherDomain
Get-MgApplication -All | Format-Table DisplayName, Owners


# Eine konkrete App
$app1Id = 'ae05eeea-c01d-4be8-bdaa-ed052ed44b59'  # "app42"
$app2Id = 'e3000564-07dc-482f-9b1c-2f7376a1d4fb'  # "BarApp"
Get-MgApplication -ApplicationId $appId1             # does not work
Get-MgApplicationByAppId -AppId $app1Id               # works

$app1 = Get-MgApplication      -Filter "AppId eq '$app1Id'"
$app2 = Get-MgApplication      -Filter "AppId eq '$app2Id'"
$sp1  = Get-MgServicePrincipal -Filter "AppId eq '$app1Id'"
$sp2  = Get-MgServicePrincipal -Filter "AppId eq '$app2Id'"


# app42   $appp1  wird nicht gelisted unter "Owned application"
# BarApp  $app2   wird gelisted unter "Owned application"
#
# Wer ist Owner?

$app1 | % Owners   # Feld ist leer - ok 
$app2 | % Owners   # Feld ist auch leer - seltsam

# Es gibt einen Unterschied zwischen "Owners" und "App Owners"
Get-MgApplicationOwner -ApplicationId $app1.Id
Get-MgApplicationOwner -ApplicationId $app2.Id

(Get-MgContext).Account
Get-MgUser -User (Get-MgContext).Account | fl DisplayName, UserPrincipalName, Id


$userId = (Get-MgContext).Account
Get-MgApplication -All | Where-Object {
    $appId = $_.Id
    $owners = Get-MgApplicationOwner -ApplicationId $appId
    $owners.Id -contains $userId
} | Select-Object DisplayName, AppId



# Für alle Apps die SPs abrufen (falls vorhanden)
$apps = Get-MgApplication -All
$results = foreach ($app in $apps) {
    $sp = Get-MgServicePrincipal -Filter "appId eq '$($app.AppId)'" -ErrorAction SilentlyContinue
    
    [PSCustomObject]@{
        AppDisplayName = $app.DisplayName
        AppId = $app.AppId
        AppObjectId = $app.Id
        HasServicePrincipal = ($null -ne $sp)
        SPDisplayName = $sp.DisplayName
        SPObjectId = $sp.Id
        SPType = $sp.ServicePrincipalType
    }
}
$results | Format-Table -AutoSize
$results | Measure-Object | % count # 52, should match number of apps
$results | sort AppDisplayName | Format-Table AppDisplayName, SPDisplayName



Get-MgServicePrincipal -Filter "DisplayName eq 'Demeter.WorkerRole'" | fl DisplayName, Description, Homepage, AppId, ServicePrincipalType, AppOwnerOrganizationId
Get-MgServicePrincipal -All | Group-Object AppOwnerOrganizationId | Sort-Object Count -Descending | Format-Table Name, Count