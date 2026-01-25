# Connect to Microsoft Graph

Disconnect-MgGraph

# Dan Jump hat die Rolle 'Global Administrator'
# Dan Jump hat die Permission 'user_impersonation' für 'Microsoft Graph Command Line Tools' bereits consented
# Dan Jump braucht also keine weiteren Scope
Connect-MgGraph -TenantId '4fc7dd0c-5c8d-405e-a415-189fe82fb2bb'  # contoso69118.com
Get-MgContext
Get-MgContext | % Scopes


# Andere User benötigen vielleicht noch Scopes
#   https://learn.microsoft.com/en-us/graph/permissions-reference
$scopes = @(
    "User.Read"
    "User.Read.All"
    "User.ReadWrite"
    "User.ReadWrite.All"
    "Group.Read.All"
    "Group.ReadWrite.All"
    "Device.Read.All"
    "Directory.Read.All"
    "Domain.ReadWrite.All"
    "DelegatedPermissionGrant.Read.All"
    "DelegatedPermissionGrant.ReadWrite.All"
    "Mail.Read"
    "Mail.ReadWrite"
    "Policy.Read.All"
)

Connect-MgGraph -Scopes $scopes -TenantId '4fc7dd0c-5c8d-405e-a415-189fe82fb2bb'
Get-MgContext
Get-MgContext | % Scopes
    
Disconnect-MgGraph