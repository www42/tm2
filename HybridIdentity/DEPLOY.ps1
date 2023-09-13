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
@{'localAdminPassword' = $localAdminPassword; 'domainAdminPassword' = $domainAdminPassword} | ConvertTo-Json | Out-File "./HybridIdentity/PASSWORDS"


# --- Parameters ---------------------------------------------------------------------
$rgName = 'rg-hybrididentity'
$location = 'westeurope'
$localAdminPassword = Get-Content "./HybridIdentity/PASSWORDS" | ConvertFrom-Json | % { $_.localAdminPassword } | ConvertTo-SecureString
$domainAdminPassword = Get-Content "./HybridIdentity/PASSWORDS" | ConvertFrom-Json | % { $_.domainAdminPassword } | ConvertTo-SecureString
$vnetName = 'vnet-hybrididentity'
$addressPrefix = '10.2.0.0/16'
$subnet0config = New-AzVirtualNetworkSubnetConfig -Name 'Subnet0' -AddressPrefix '10.2.0.0/24'
$subnet1config = New-AzVirtualNetworkSubnetConfig -Name 'Subnet1' -AddressPrefix '10.2.1.0/24'
$dcSubnetId     = $subnet0.Id
$clientSubnetId = $subnet1.Id
$dcName = 'DC1'
$dcIp = '10.2.0.200'
$aaName = 'aa-hybrididentity'
$domainName = 'az.training'	
$clientLoginUser = 'Ludwig@az.training'
$clientName = 'Client001'
$clientVirtualMachineAdministratorLoginRoleAssigneeId = (Get-AzADUser -UserPrincipalName $clientLoginUser).Id
$templateFile = 'HybridIdentity/main.bicep'

$templateParams = @{
    location              = $location
    automationAccountName = $aaName
    createAaJob           = $true
    dcSubnetId            = $subnet0.Id
    clientSubnetId        = $subnet1.Id
    domainName            = $domainName
    dcName                = $dcName
    dcIp                  = $dcIp
    domainAdminName       = 'DomainAdmin'
    domainAdminPassword   = $domainAdminPassword
    clientName            = $clientName
    localAdminName        = 'localadmin'
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


# --- Automation Account, Domain Controller, Windows 11 Client -----------------------
$templateParams['dcSubnetId']     = $subnet0.Id
$templateParams['clientSubnetId'] = $subnet1.Id
New-AzResourceGroupDeployment -Name 'Scenario-HybridIdentity' -TemplateFile $templateFile -ResourceGroupName $rgName -Location $location @templateParams 

Get-AzResourceGroupDeployment -ResourceGroupName $rgName | Sort-Object Timestamp -Descending | ft DeploymentName,ProvisioningState,Timestamp


# Automation account
Get-AzAutomationAccount -ResourceGroupName $rgName -Name $aaName | fl AutomationAccountName,Plan,State
Get-AzAutomationRegistrationInfo -ResourceGroupName $rgName -AutomationAccountName $aaName | fl AutomationAccountName,PrimaryKey,SecondaryKey,Endpoint
Get-AzAutomationDscConfiguration -ResourceGroupName $rgName -AutomationAccountName $aaName | fl AutomationAccountName,Name,State
Get-AzAutomationDscCompilationJob -ResourceGroupName $rgName -AutomationAccountName $aaName | Tee-Object -Variable aaJob | fl AutomationAccountName,ConfigurationName,Status
Get-AzAutomationDscCompilationJobOutput -ResourceGroupName $rgName -AutomationAccountName $aaName -Id $aaJob.Id | Format-Table Time,Type,Summary
Get-AzAutomationDscNodeConfiguration -ResourceGroupName $rgName -AutomationAccountName $aaName | fl AutomationAccountName,ConfigurationName,Name,RollupStatus
Get-AzAutomationDscNode -ResourceGroupName $rgName -AutomationAccountName $aaName | fl AutomationAccountName,Name,NodeConfigurationName,LastSeen,Status


# --- TODO -----------------------------------------------------------------------------------------------
# DC: VM Name != Computer Name
# Client: Prüfen, ob schon als Azure AD Device registriert