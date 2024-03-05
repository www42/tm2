# ------------------------------------------------------------------------------------
# Scenario Hybrid Identity
# ------------------------------------------------------------------------------------
# Disable AD synchronization to tenant = Disable Azure AD Connect
# Run this script 
#   * on the domain controller VM with sync enabled - MSOnline module is installed already
#   * on any Windows PowerShell 5.1 instance with module MSOnline installed
# ------------------------------------------------------------------------------------

# The only working tools is MSOnline PowerShell module. Microsoft Graph does not work!? See below.
# https://learn.microsoft.com/en-us/microsoft-365/enterprise/turn-off-directory-synchronization

# Requires Windows Powershell 5.1 (due to MSOnline)

Import-Module -Name "C:\Program Files\Microsoft Azure Active Directory Connect\AADPowerShell\MSOnline.psd1"
Connect-MsolService
Set-MsolDirSyncEnabled -EnableDirSync $false -Force
Get-MsolCompanyInformation | fl DirectorySynchronizationEnabled,LastDirSyncTime,LastPasswordSyncTime



# Microsoft Graph does not work - 5. März 2023
# --------------------------------------------

# There is a map msol --> graph:   https://learn.microsoft.com/en-us/powershell/microsoftgraph/azuread-msoline-cmdlet-map
# Set-MsolDirSyncEnabled  --> Update-MgOrganization
$Scopes = @(
    "ManagedTenants.ReadWrite.All"
    "User.Read.All"
    "Group.Read.All"
)
Connect-MgGraph -Scopes $Scopes
Get-MgContext
$tenantId = Get-MgContext | % TenantId
Get-MgOrganization -OrganizationId $tenantId | Format-List Id,DisplayName,OnPremisesSyncEnabled

# This does not work:  "Property 'onPremisesSyncEnabled' is read-only and cannot be set."
Update-MgOrganization -OrganizationId $tenantId -OnPremisesSyncEnabled:$false
