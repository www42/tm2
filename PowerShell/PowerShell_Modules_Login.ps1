# --- Azure (5.1 and 7) ---------------------------------
Logout-AzAccount
Login-AzAccount

Get-AzContext | Format-List Name,Account,Tenant,Subscription
Get-AzSubscription
$subscription = Get-AzSubscription | Where-Object State -EQ 'enabled' | % SubscriptionId
$tenantId     = Get-AzSubscription | Where-Object State -EQ 'enabled' | % TenantId


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
