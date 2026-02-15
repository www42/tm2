# Connect to Microsoft Graph

Disconnect-MgGraph

# Dan Jump hat die Rolle 'Global Administrator'
# Dan Jump bereits viele Permissions (Scopes) consented, diese werden akkumuliert
# Dan Jump braucht also keine weiteren Scope
Connect-MgGraph -TenantId '4fc7dd0c-5c8d-405e-a415-189fe82fb2bb'  # contoso69118.com
Connect-MgGraph -TenantId '819ebf55-0973-4703-b006-581a48f25961'  # az.training
Get-MgContext
Get-MgContext | % Scopes | Sort-Object


# Hier ein paar 'schöne' Scopes
# Was die Scopes eigentlich bedeuten, steht hier:
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
    "AdministrativeUnit.ReadWrite.All"
    "Application.Read.All"
)

Disconnect-MgGraph