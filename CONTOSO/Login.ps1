# --- Service Principal --------------------------------------------------------------

# Save Client Secret locally (put PASSWORDS to .gitignore)
#   $clientSecret = Read-Host -Prompt 'Client Secret' -AsSecureString | ConvertFrom-SecureString
#   @{'clientSecret' = $clientSecret} | ConvertTo-Json | Out-File "./PASSWORDS"

$tenantId = '4fc7dd0c-5c8d-405e-a415-189fe82fb2bb'
$clientId = '776cca4e-a126-4efb-ad31-ed873a131b3c'
$clientSecretSecure = Get-Content "./PASSWORDS" | ConvertFrom-Json | % { $_.clientSecret } | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PSCredential($clientId, $clientSecretSecure)


# --- Login to Azure -----------------------------------------------------------------
Logout-AzAccount
Login-AzAccount -TenantId $tenantId -Credential $credential -ServicePrincipal
Get-AzContext | fl Account, Subscription, Tenant, Environment


# --- Login to Microsoft Graph -------------------------------------------------------
Disconnect-MgGraph
Connect-MgGraph -TenantId $tenantId -ClientSecretCredential $credential -NoWelcome
Get-MgContext | % Scopes | Sort-Object