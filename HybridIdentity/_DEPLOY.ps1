# --- Scenario Hybrid Identity -------------------------------------------------------
#
# This deploys infrastructure for hybrid identity scenario
#   1. Create a resource group by PowerShell
#   2. Create a virtual network by Powershell 
#      (Virtual network by ARM template is fine for the first time. But for subsequent deployments, ARM tries to delete the existing Vnet resulting in a failed deployment. So we use PowerShell)
#   3. Create by ARM template
#          an automation account (used as DSC pull server)
#          a domain controller VM
#          a Windows 11 client VM
# 
# ------------------------------------------------------------------------------------
# DSC compile job (compilation .ps1 --> .mof) is not idempotent.
# So for the first time create a compile job by 'createAaJob = $true'. In subsequent deployments say 'createAaJob = $false'
# ------------------------------------------------------------------------------------

# --- Login --------------------------------------------------------------------------
Login-AzAccount
Get-AzContext | Format-List Name,Account,Tenant,Subscription

# --- Passwords ----------------------------------------------------------------------
$localAdminPassword = Read-Host -Prompt 'LocalAdmin password' -AsSecureString | ConvertFrom-SecureString
$domainAdminPassword = Read-Host -Prompt 'DomainAdmin password' -AsSecureString | ConvertFrom-SecureString
@{'localAdminPassword' = $localAdminPassword; 'domainAdminPassword' = $domainAdminPassword} | ConvertTo-Json | Out-File "./HybridIdentity/PASSWORDS"


# --- Parameters ---------------------------------------------------------------------
$rgName = 'testrg-hybrididentity'
$location = 'westeurope'
$localAdminPassword = Get-Content "./HybridIdentity/PASSWORDS" | ConvertFrom-Json | % { $_.localAdminPassword } | ConvertTo-SecureString
$domainAdminPassword = Get-Content "./HybridIdentity/PASSWORDS" | ConvertFrom-Json | % { $_.domainAdminPassword } | ConvertTo-SecureString
$vnetName = 'vnet-hybrididentity'
$addressPrefix = '10.2.0.0/16'
$subnet0 = New-AzVirtualNetworkSubnetConfig -Name 'Subnet0' -AddressPrefix '10.2.0.0/24'
$subnet1 = New-AzVirtualNetworkSubnetConfig -Name 'AzureBastionSubnet' -AddressPrefix '10.2.255.0/26'
$dcName = 'DC1'
$dcIp = '10.2.0.200'
$aaName = 'aa-hybrid'
$domainName = 'az.training'	
$clientLoginUser = 'Ludwig@az.training'
$clientName = 'Client003'
$templateFile = 'HybridIdentity/templates/main.bicep'

$templateParams = @{
    location              = $location
    automationAccountName = $aaName
    createAaJob           = $true
    subnetId              = $subnet.Id
    domainName            = $domainName
    dcName                = $dcName
    dcIp                  = $dcIp
    domainAdminName       = 'DomainAdmin'
    domainAdminPassword   = $domainAdminPassword
    clientName            = $clientName
    localAdminName        = 'localadmin'
    localAdminPassword    = $localAdminPassword
    clientVirtualMachineAdministratorLoginRoleAssigneeId = (Get-AzADUser -UserPrincipalName $clientLoginUser).Id
}
$templateParams['createAaJob'] = $false


# --- Resource group -----------------------------------------------------------------
New-AzResourceGroup -Name $rgName -Location $location

Get-AzResourceGroup | Sort-Object ResourceGroupName | ft ResourceGroupName,Location,ProvisioningState
Get-AzResource -ResourceGroupName $rgName | Sort-Object ResourceType | Format-Table Name,ResourceType,Location

# New-AzResourceGroupDeployment -Name 'TabulaRasa' -ResourceGroupName $rgName -Mode Complete -Force -TemplateUri 'https://raw.githubusercontent.com/www42/arm/master/templates/empty.json' -AsJob
# Remove-AzResourceGroup -Name $rgName -Force -AsJob



# --- Virtual network ----------------------------------------------------------------
New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $location -AddressPrefix $addressPrefix -Subnet $subnet0, $subnet1 -Force
$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
$subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name 'Subnet0'

# Set Vnet's DNS server to DC - dangerous, because it overwrites the default Azure DNS server
# $vnet.DhcpOptions.DnsServers = $dcIp
# $vnet | Set-AzVirtualNetwork

Get-AzVirtualNetwork | ft Name,Subnets,ResourceGroupName


# --- Automation Account, Domain Controller, Windows 11 Client -------------------------------------------
$templateParams['subnetId'] = $subnet.Id
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
