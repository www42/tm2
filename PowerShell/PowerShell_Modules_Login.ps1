# --- Azure (5.1 and 7) ---------------------------------
Logout-AzAccount
Login-AzAccount
$tenantId = 'd9365f9d-75c4-4fa4-8b80-566635202213'
$subscriptionId = '2e35dc59-591a-4306-bbdb-a017d6963783'
$subscriptionId = 'ece756e9-1860-4c65-a982-cfb8ac39e0d2'
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
