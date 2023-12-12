# ------------------------------------------------------------------------------------
# Entra ID User
# ------------------------------------------------------------------------------------
# Adam Ries - Admin account with initial domain name - break glass user
# (Don't use this user for daily work.)
#    Adam --> Global Administrator --> Tenant
#    Adam --> Owner                --> Subscription
# ------------------------------------------------------------------------------------

# Connect to Graph
# ----------------
Disconnect-MgGraph
$Scopes = @(
    "User.ReadWrite.All"
    "Group.ReadWrite.All"
    "RoleManagement.ReadWrite.Directory"
    "Directory.ReadWrite.All"
)
# If connecting as a Microsoft account you have to specify tenant id
$tenantId = ''
Connect-MgGraph -Scopes $Scopes
Connect-MgGraph -Scopes $Scopes -TenantId $tenantID

Get-MgContext | % Scopes

# Create user
# -----------
$tenantId = Get-MgContext | % TenantId
$domainName = Get-MgOrganization -OrganizationId $tenantId | % VerifiedDomains | ? IsInitial -EQ $true | % Name
$password = Read-Host -Prompt 'Password'
$passwordProfile = @{
    Password = $password
    ForceChangePasswordNextSignIn = $false
}
$params = @{
    GivenName = 'Adam'
    Surname = 'Ries'
    DisplayName = 'Adam Ries'
    UserPrincipalName = "Adam@$domainName"
    MailNickname = 'Adam'
    Country = 'Germany'
    City = 'Annaberg'
    UsageLocation = 'DE'
    AccountEnabled = $true
    PasswordProfile = $passwordProfile
}
$user = New-MgUser @params

# Assign P2 License
# -----------------
$P2Sku = Get-MgSubscribedSku -All | ? SkuPartNumber -EQ 'AAD_PREMIUM_P2'
Set-MgUserLicense -UserId $user.Id -AddLicenses @{SkuId = $P2Sku.SkuId} -RemoveLicenses @()


# Assign Global Administrator role
# --------------------------------
$globalAdministratorId = Get-MgDirectoryRole -All | ? DisplayName -eq 'Global Administrator' | % Id
$userId = $user.Id
$params = @{
    "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$userId"
}
New-MgDirectoryRoleMemberByRef -DirectoryRoleId $globalAdministratorId -BodyParameter $params


# Assign Owner role to subscription
# ---------------------------------
$SubscriptionId = (Get-AzSubscription).Id
New-AzRoleAssignment -ObjectId $user.Id -RoleDefinitionName 'Owner' -Scope "/subscriptions/$SubscriptionId"
Get-AzRoleAssignment -Scope "/subscriptions/$SubscriptionId" | Sort-Object RoleDefinitionName | Format-Table ObjectId,DisplayName,RoleDefinitionName




# Cleanup
# --------
$user = Get-MgUser | ? UserPrincipalName -EQ "Adam@$domainName"
$SubscriptionId = (Get-AzSubscription).Id
Remove-AzRoleAssignment -ObjectId $user.Id -Scope "/subscriptions/$SubscriptionId" -RoleDefinitionName 'Owner'
Remove-MgUser -UserId $user.Id
