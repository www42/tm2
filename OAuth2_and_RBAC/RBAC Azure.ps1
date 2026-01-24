# RBAC Azure
# -------------------------------------

# Role Definitions
# ================
$roleName = 'Contributor'

Get-AzRoleDefinition | Measure-Object    # 836
Get-AzRoleDefinition -Name $roleName
Get-AzRoleDefinition -Name $roleName | % Actions
Get-AzRoleDefinition -Name $roleName | % NotActions
Get-AzRoleDefinition -Name $roleName | % DataActions
Get-AzRoleDefinition -Name $roleName | % NotDataActions


# Role Assignments
# ================
$userDisplayName = 'Paul Drude'
$userId = Get-AzADUser -DisplayName $userDisplayName | % Id

# Alle Role Assignments für einen Benutzer (explizite Rollenzuweisungen, geerbte werden nicht angezeigt)
$roleAssignments = Get-AzRoleAssignment -ObjectId $userId
$roleAssignments | Measure-Object | % Count
$roleAssignments | Sort-Object Scope | Format-Table RoleDefinitionName,Scope

# Alle Role Assignments für eine App (App = Service Principal)
$appDisplayName = 'powershell'
$appId = Get-AzADServicePrincipal -DisplayName $appDisplayName | % Id

$roleAssignments = Get-AzRoleAssignment -ObjectId $appId
$roleAssignments | Measure-Object | % Count
$roleAssignments | Sort-Object Scope | Format-Table RoleDefinitionName,Scope



# Role Assignment für "Root" / "Root Tenant Group"
# ================================================
$tenantId = '819ebf55-0973-4703-b006-581a48f25961'

# "Root" und "Root Tenant Group" sind zwei verschiedene Scopes!
$tenantRootGroup = Get-AzManagementGroup -GroupName $tenantId   # 'Tenant Root Group' hat als Namen die ID des Tenants
$tenantRootGroup.Name
$tenantRootGroup.DisplayName
$tenantRootGroup.Id


Get-AzRoleAssignment -Scope "/"
Get-AzRoleAssignment -Scope $tenantRootGroup.Id

# Role Assignments für "Root" löschen (geht im Azure Portal nicht)
Remove-AzRoleAssignment -Scope "/" -SignInName Paul@az.training -RoleDefinitionName 'Owner'