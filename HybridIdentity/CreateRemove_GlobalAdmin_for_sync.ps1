# ------------------------------------------------------------------------------------
# Scenario Hybrid Identity
# ------------------------------------------------------------------------------------
# This script creates an Entra ID user 'EntraSyncAdmin' 
# with role 'Global Administrator' for Entra Connect
# ------------------------------------------------------------------------------------
# Requires Windows Powershell 5.1 (wegen AzureAD)

# Create the Entra ID user 'EntraSyncAdmin' (Global Administrator)
# ------------------------------------------------------------------------------------
$Domains = (Get-AzureAdTenantDetail).VerifiedDomains
$Domains | Format-Table Name,Initial,_Default

$Domain = $Domains | Where-Object _Default -EQ $true | Select-Object -ExpandProperty Name
# $Domain = $Domains | Where-Object Initial -EQ $true | Select-Object -ExpandProperty Name

$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = ''
$PasswordProfile.ForceChangePasswordNextLogin = $false

$Params = @{
    DisplayName       = 'EntraSyncAdmin'
    UserPrincipalName = "EntraSyncAdmin@$Domain"
    MailNickName      = 'EntraSyncAdmin'
    UsageLocation     = 'DE'
    PasswordProfile   = $PasswordProfile
    AccountEnabled    = $true
}
$SyncUser = New-AzureADUser @Params

# Add the user to the Global Administrator role
$GlobalAdministrator = Get-AzureADDirectoryRole | Where-Object DisplayName -eq 'Global Administrator'
Add-AzureADDirectoryRoleMember -ObjectId $GlobalAdministrator.ObjectId -RefObjectId $SyncUser.ObjectId

# List all Global Administrators
Get-AzureADDirectoryRoleMember -ObjectId $GlobalAdministrator.ObjectId


# Remove 'EntraSyncAdmin' (Global Administrator) 
# The User is only needed to install or configure Entra Connect
# The User is not needed for normal syncronization
# ------------------------------------------------------------------------------------

$syncUser = Get-AzureADUser -Filter "startswith(UserPrincipalName,'EntraSyncAdmin')"
Remove-AzureADUser -ObjectId $syncUser.ObjectId

# List all Global Administrators
$GlobalAdministrator = Get-AzureADDirectoryRole | Where-Object DisplayName -eq 'Global Administrator'
Get-AzureADDirectoryRoleMember -ObjectId $GlobalAdministrator.ObjectId

