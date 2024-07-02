# --- Azure (5.1 and 7) ---------------------------------
Logout-AzAccount

# Simple login
#Login-AzAccount

# More complex login
$tenantId       = '819ebf55-0973-4703-b006-581a48f25961'          # az.training
$subscriptionId = 'fa366244-df54-48f8-83c2-e1739ef3c4f1'          # Visual Studio Enterprise Subscription
#$subscriptionId = '4072ef16-4983-440e-af57-d3afa9a6ea96'          # Pay-As-You-Go Dev/Test
Login-AzAccount -Tenant $tenantId -Subscription $subscriptionId

Get-AzContext | Format-List Name,Account,Tenant,Subscription
Get-AzSubscription


# --- AzureAD (5.1 only) ---------------------------------
Disconnect-AzureAD
Connect-AzureAD

# May be you need to specify tenant id (e.g. if you are connecting with a federated Microsoft account paul@outlook.com)
$tenantId = '00a197a8-7b4d-4640-9689-01068da45596'
Connect-AzureAD -TenantId $tenantId

Get-AzureADTenantDetail | Format-List DisplayName, `
    @{n="TenantId";e={$_.ObjectId}}, `
    @{n="VerifiedDomains";e={$_.VerifiedDomains.Name}} 

# MS Online
Import-Module -Name MSOnline
Connect-MsolService



# --- Exchange Online (5.1 and 7) -------------------------
Disconnect-ExchangeOnline -Confirm:$false
Connect-ExchangeOnline -ShowBanner:$false




# --- Microsoft Graph (5.1 and 7) -------------------------

# Minimal scopes (permissions)
Connect-MgGraph

Get-MgContext
Get-MgContext | % Scopes

# Scopes (= permissions) can be added cumulatively
$Scopes = @(
    "User.Read.All"
    "Group.Read.All"
    )
    Connect-MgGraph -Scopes $Scopes
    Disconnect-MgGraph
    

# --- Entra Exporter --------------------------------------
#
# https://office365itpros.com/2023/08/24/entraexporter-tool/
Connect-EntraExporter
Export-Entra -Path '.\EntraExport\' 