
# --- Login to Azure using a Service Principal ---------------------------------------

# --- Service Principal ---------------------------------------
# objectId  = 'e1568331-075e-4c9f-95a6-99f972e1266e'
# $clientID = '65e5bc2a-7ab0-4644-b770-e198a66546b2'
# $tenantId = '819ebf55-0973-4703-b006-581a48f25961'
# siehe KeePass 'Powershell Service Principal"


# --- Save Client Secret locally (.gitignore) ----------------------------------------
# $clientSecret = Read-Host -Prompt 'Client Secret' -AsSecureString | ConvertFrom-SecureString
# @{'clientSecret' = $clientSecret} | ConvertTo-Json | Out-File "./PASSWORDS"


# --- Login to Azure -----------------------------------------------------------------
$clientID = '65e5bc2a-7ab0-4644-b770-e198a66546b2'
$tenantId = '819ebf55-0973-4703-b006-581a48f25961'
$clientSecretSecure = Get-Content "./PASSWORDS" | ConvertFrom-Json | % { $_.clientSecret } | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PSCredential($clientID, $clientSecretSecure)

Login-AzAccount -TenantId $tenantId -Credential $credential -ServicePrincipal
Get-AzContext | fl Account, Subscription, Tenant, Environment
