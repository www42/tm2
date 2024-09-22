# --- Scenario Hybrid Identity -------------------------------------------------------
#
# This deploys infrastructure for hybrid identity scenario. It creates
#   - a resource group (by PowerShell)
#   - a virtual network (by PowerShell)
#   - an automation account used as DSC pull server (by ARM template)
#   - a domain controller VM (by ARM template)
#   - a Windows 11 client VM (by ARM template)
# 
# ---- Attention ---------------------------------------------------------------------
# DSC compile job (compilation .ps1 --> .mof) is not idempotent.
# So for the first time create a compile job by 'createAaJob = $true'. In subsequent deployments say 'createAaJob = $false'


# --- Login --------------------------------------------------------------------------
Login-AzAccount
Get-AzContext | Format-List Name,Account,Tenant,Subscription


# --- Set passwords ------------------------------------------------------------------
$localAdminPassword = Read-Host -Prompt 'LocalAdmin password' -AsSecureString | ConvertFrom-SecureString
$domainAdminPassword = Read-Host -Prompt 'DomainAdmin password' -AsSecureString | ConvertFrom-SecureString
@{'localAdminPassword' = $localAdminPassword; 'domainAdminPassword' = $domainAdminPassword} | ConvertTo-Json | Out-File "./Scenario_HybridIdentity/PASSWORDS"


# --- Parameters ---------------------------------------------------------------------
$rgName              = 'rg-hybrididentity'
$location            = 'westeurope'
$localAdminPassword  = Get-Content "./Scenario_HybridIdentity/PASSWORDS" | ConvertFrom-Json | % { $_.localAdminPassword } | ConvertTo-SecureString
$domainAdminPassword = Get-Content "./Scenario_HybridIdentity/PASSWORDS" | ConvertFrom-Json | % { $_.domainAdminPassword } | ConvertTo-SecureString
$vnetName            = 'vnet-hybrididentity'
$addressPrefix       = '10.1.0.0/16'
$subnet0config       = New-AzVirtualNetworkSubnetConfig -Name 'Subnet0' -AddressPrefix '10.1.0.0/24'
$subnet1config       = New-AzVirtualNetworkSubnetConfig -Name 'Subnet1' -AddressPrefix '10.1.1.0/24'
$dcSubnetId          = $subnet0.Id
$clientSubnetId      = $subnet1.Id
$dcIp                = '10.1.0.200'
$dcName              = 'vm-hybrididentity-dc1'
$dcComputerName      = 'DC1'
$aaName              = 'aa-hybrididentity'
$createAaJob         = $true
$domainName          = 'az.training'
$domainAdminName     = 'DomainAdmin'
$localAdminName      = 'localadmin'	
$clientName          = 'vm-hybrididentity-client001'
$clientComputerName  = 'Client001'
$clientLoginUser     = 'Ludwig@az.training'
$clientVirtualMachineAdministratorLoginRoleAssigneeId = (Get-AzADUser -UserPrincipalName $clientLoginUser).Id
$templateFile        = 'Scenario_HybridIdentity/main.bicep'

$templateParams = @{
    location              = $location
    automationAccountName = $aaName
    createAaJob           = $createAaJob
    dcSubnetId            = $dcSubnetId
    clientSubnetId        = $clientSubnetId
    domainName            = $domainName
    dcName                = $dcName
    dcComputerName        = $dcComputerName
    dcIp                  = $dcIp
    domainAdminName       = $domainAdminName
    domainAdminPassword   = $domainAdminPassword
    clientName            = $clientName
    clientComputerName    = $clientComputerName
    localAdminName        = $localAdminName
    localAdminPassword    = $localAdminPassword
    clientVirtualMachineAdministratorLoginRoleAssigneeId = $clientVirtualMachineAdministratorLoginRoleAssigneeId
}
$templateParams['createAaJob'] = $false


# --- Resource group -----------------------------------------------------------------
New-AzResourceGroup -Name $rgName -Location $location

Get-AzResourceGroup | Sort-Object ResourceGroupName | ft ResourceGroupName,Location,ProvisioningState
Get-AzResource -ResourceGroupName $rgName | Sort-Object ResourceType | Format-Table Name,ResourceType,Location

# New-AzResourceGroupDeployment -Name 'TabulaRasa' -ResourceGroupName $rgName -Mode Complete -Force -TemplateUri 'https://raw.githubusercontent.com/www42/arm/master/templates/empty.json' -AsJob
# Remove-AzResourceGroup -Name $rgName -Force -AsJob



# --- Virtual network ----------------------------------------------------------------
New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $location -AddressPrefix $addressPrefix -Subnet $subnet0config, $subnet1config -Force
$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
$subnet0 = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name 'Subnet0'
$subnet1 = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name 'Subnet1'

# Set Vnet's DNS server to DC - dangerous, because it overwrites the default Azure DNS server
# $vnet.DhcpOptions.DnsServers = $dcIp
# $vnet | Set-AzVirtualNetwork

Get-AzVirtualNetwork | ft Name,Subnets,ResourceGroupName

# --- Check if Windows 11 Client already exists as AzureAD device --------------------
$Scopes = @(
    "Device.ReadWrite.All"
    "Directory.AccessAsUser.All"
)
Connect-MgGraph -Scopes $Scopes
Get-MgDevice -Filter "displayName eq '$clientComputerName'" -OutVariable device  | fl DisplayName,DeviceId,DeviceName,OperatingSystem,OperatingSystemVersion,RegisteredOwners,RegisteredUsers,TrustType
Remove-MgDevice -DeviceId $device.Id -Confirm:$false 
Disconnect-MgGraph -Verbose


# --- Template Deployment: Automation Account, Domain Controller, Windows 11 Client --
$templateParams['dcSubnetId']     = $subnet0.Id
$templateParams['clientSubnetId'] = $subnet1.Id
$templateParams
dir $templateFile
New-AzResourceGroupDeployment -Name 'Scenario-HybridIdentity' -TemplateFile $templateFile -ResourceGroupName $rgName -Location $location @templateParams 

Get-AzResourceGroupDeployment -ResourceGroupName $rgName | Sort-Object Timestamp -Descending | ft DeploymentName,ProvisioningState,Timestamp



# --- Automation account -------------------------------------------------------------
Get-AzAutomationAccount -ResourceGroupName $rgName -Name $aaName | fl AutomationAccountName,Plan,State
Get-AzAutomationRegistrationInfo -ResourceGroupName $rgName -AutomationAccountName $aaName | fl AutomationAccountName,PrimaryKey,SecondaryKey,Endpoint
Get-AzAutomationDscConfiguration -ResourceGroupName $rgName -AutomationAccountName $aaName | fl AutomationAccountName,Name,State
Get-AzAutomationDscCompilationJob -ResourceGroupName $rgName -AutomationAccountName $aaName | Tee-Object -Variable aaJob | fl AutomationAccountName,ConfigurationName,Status
Get-AzAutomationDscCompilationJobOutput -ResourceGroupName $rgName -AutomationAccountName $aaName -Id $aaJob.Id | Format-Table Time,Type,Summary
Get-AzAutomationDscNodeConfiguration -ResourceGroupName $rgName -AutomationAccountName $aaName | fl AutomationAccountName,ConfigurationName,Name,RollupStatus
Get-AzAutomationDscNode -ResourceGroupName $rgName -AutomationAccountName $aaName | fl AutomationAccountName,Name,NodeConfigurationName,LastSeen,Status

# alle System Managed Identities
Get-AzADServicePrincipal | ? ServicePrincipalType -eq 'ManagedIdentity' | Sort-Object DisplayName | ft DisplayName,ServicePrincipalType,Id

# die System Managed Identity vom Automation Account
$aa = Get-AzAutomationAccount -ResourceGroupName $rgName -Name $aaName
$aa.Identity | fl *
$objectId = $aa.Identity.PrincipalId
Get-AzADServicePrincipal -ObjectId $objectId | fl DisplayName,ServicePrincipalName,AppId,ServicePrincipalType,Id

# Role assignment für die Managed Identity
$roleDefinitionName = "Contributor"
$resourceGroup = Get-AzResourceGroup -Name 'rg-hub'
New-AzRoleAssignment -ObjectId $objectId -RoleDefinitionName $roleDefinitionName -Scope $resourceGroup.ResourceId
Get-AzRoleAssignment -ObjectId $objectId | ft DisplayName,RoleDefinitionName,Scope
Remove-AzRoleAssignment -ObjectId $objectId -RoleDefinitionName $roleDefinitionName -Scope $resourceGroup.ResourceId