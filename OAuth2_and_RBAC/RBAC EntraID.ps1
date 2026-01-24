# RBAC Entra ID
# -------------------------------------

$roleDisplayName = 'Security Administrator'
$roleDisplayName = 'User Administrator'
$roleDisplayName = 'Global Administrator'

Get-MgRoleManagementDirectoryRoleDefinition | Measure-Object                # 134
Get-MgRoleManagementDirectoryRoleDefinition | Sort-Object DisplayName

Get-MgRoleManagementDirectoryRoleDefinition -Filter "displayName eq '$roleDisplayName'" 

Get-MgRoleManagementDirectoryRoleDefinition -Filter "displayName eq '$roleDisplayName'" | 
Select-Object DisplayName, Description, IsBuiltIn, 
@{Name='Permissions'; Expression={$_.RolePermissions.AllowedResourceActions}}   | Format-List

Get-MgRoleManagementDirectoryRoleDefinition -Filter "displayName eq '$roleDisplayName'" | 
    % RolePermissions | 
    % AllowedResourceActions
