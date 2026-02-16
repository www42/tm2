# --- Service Principals -------------------------------------------------------------

# Save Client Secret locally (put PASSWORDS into .gitignore) 
#   $clientSecretAztraining = Read-Host -Prompt 'Client Secret AZ Training' -AsSecureString | ConvertFrom-SecureString
#   $clientSecretContoso = Read-Host -Prompt 'Client Secret Contoso' -AsSecureString | ConvertFrom-SecureString
#   @{'clientSecretAztraining' = $clientSecretAztraining; 'clientSecretContoso' = $clientSecretContoso} | ConvertTo-Json | Out-File "./PASSWORDS"


# --- AZ Training --------------------------------------------------------------------
$tenantIdAztraining = '819ebf55-0973-4703-b006-581a48f25961'
$clientIdAztraining = '65e5bc2a-7ab0-4644-b770-e198a66546b2'
$clientSecretSecureAztraining = Get-Content "./PASSWORDS" | ConvertFrom-Json | % { $_.clientSecretAztraining } | ConvertTo-SecureString
$credentialAztraining = New-Object System.Management.Automation.PSCredential($clientIdAztraining, $clientSecretSecureAztraining)

# Login to Azure
Disconnect-AzAccount
Connect-AzAccount -TenantId $tenantIdAztraining -Credential $credentialAztraining -ServicePrincipal
Get-AzContext | fl Account, Subscription, Tenant, Environment

# Login to Microsoft Graph
Disconnect-MgGraph
Connect-MgGraph -TenantId $tenantIdAztraining -ClientSecretCredential $credentialAztraining -NoWelcome
Get-MgContext
Get-MgContext | % Scopes | Sort-Object



# --- Contoso ------------------------------------------------------------------------
$tenantIdContoso = '4fc7dd0c-5c8d-405e-a415-189fe82fb2bb'
$clientIdContoso = '776cca4e-a126-4efb-ad31-ed873a131b3c'
$clientSecretSecureContoso = Get-Content "./PASSWORDS" | ConvertFrom-Json | % { $_.clientSecretContoso } | ConvertTo-SecureString
$credentialContoso = New-Object System.Management.Automation.PSCredential($clientIdContoso, $clientSecretSecureContoso)

# Login to Azure
Disconnect-AzAccount
Connect-AzAccount -TenantId $tenantIdContoso -Credential $credentialContoso -ServicePrincipal
Get-AzContext | fl Account, Subscription, Tenant, Environment

# Login to Microsoft Graph
Disconnect-MgGraph
Connect-MgGraph -TenantId $tenantIdContoso -ClientSecretCredential $credentialContoso -NoWelcome
Get-MgContext
Get-MgContext | % Scopes | Sort-Object