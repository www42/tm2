# ------------------------------------------------------------------------------------
# Scenario Hybrid Identity
# ------------------------------------------------------------------------------------
# This script creates an Azure AD user 'AzureAdSyncAdmin' 
# with role 'Global Administrator' for Azure AD Connect
# ------------------------------------------------------------------------------------
# Requires Windows Powershell 5.1 (wegen AzureAD)

# Create the Azure AD user 'AzureAdSyncAdmin' (GlobalAdministrator)
# ------------------------------------------------------------------------------------
$Domains = (Get-AzureAdTenantDetail).VerifiedDomains
$Domains | Format-Table Name,Initial,_Default

$Domain = $Domains | Where-Object _Default -EQ $true | Select-Object -ExpandProperty Name
# $Domain = $Domains | Where-Object Initial -EQ $true | Select-Object -ExpandProperty Name
# $Domain = 'trainymotion.com'
$Domain

$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = ''
$PasswordProfile.ForceChangePasswordNextLogin = $false

$Params = @{
    DisplayName       = 'AzureAdSyncAdmin'
    UserPrincipalName = "AzureAdSyncAdmin@$Domain"
    MailNickName      = 'AzureAdSyncAdmin'
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


# Remove the Azure AD user 'AzureAdSyncAdmin' (GlobalAdministrator) 
# User only needed Azure AD Connect installation/configuration changes
# User not needed for regular syncronization
# ------------------------------------------------------------------------------------

$syncUser = Get-AzureADUser -Filter "startswith(UserPrincipalName,'AzureAdSyncAdmin')"
Remove-AzureADUser -ObjectId $syncUser.ObjectId

# List all Global Administrators
$GlobalAdministrator = Get-AzureADDirectoryRole | Where-Object DisplayName -eq 'Global Administrator'
Get-AzureADDirectoryRoleMember -ObjectId $GlobalAdministrator.ObjectId

