# --- Scenario Monitoring ------------------------------------------------------------
#
# This scenario deploys 
#   - a Log Analytics Workspace, 
#   - a Data Collection Rule (DCR) for Windows Performance Counters
#   - and associates it to a VM.
# ------------------------------------------------------------------------------------


# --- Login --------------------------------------------------------------------------
Login-AzAccount
Get-AzContext | Format-List Name,Account,Tenant,Subscription


# --- Passwords ----------------------------------------------------------------------
$localAdminPassword = Read-Host -Prompt 'LocalAdmin password' -AsSecureString | ConvertFrom-SecureString
@{'localAdminPassword' = $localAdminPassword} | ConvertTo-Json | Out-File "./Monitoring/PASSWORDS"


# --- Parameters ---------------------------------------------------------------------
$rgName                        = 'rg-monitoring'
$location                      = 'westeurope'
$vnetName                      = 'vnet-monitoring'
$addressPrefix                 = '10.3.0.0/16'
$subnet0                       = New-AzVirtualNetworkSubnetConfig -Name 'Subnet0' -AddressPrefix '10.3.0.0/24'
$vmName                        = 'vm-monitoring-svr1'
$vmComputerName                = 'SVR1'
$systemAssignedManagedIdentity = $true
$vmAdminUserName               = 'LocalAdmin'
$vmAdminPassword               = Get-Content "./Monitoring/PASSWORDS" | ConvertFrom-Json | % { $_.localAdminPassword } | ConvertTo-SecureString
$logAnalyticsWorkspaceName     = 'log-monitoring'
$dcrName                       = 'dcr-windowsperf'

$templateFile = 'Monitoring/main.bicep'
$templateParams = @{
    location = $location
    subnetId = $subnet0Subnet.Id
    vmName = $vmName
    vmComputerName = $vmComputerName
    systemAssignedManagedIdentity = $systemAssignedManagedIdentity
    vmAdminUserName = $vmAdminUserName
    vmAdminPassword = $vmAdminPassword
    logAnalyticsWorkspaceName = $logAnalyticsWorkspaceName
    dcrName = $dcrName
}


# --- Resource group -----------------------------------------------------------------
New-AzResourceGroup -Name $rgName -Location $location

Get-AzResourceGroup | Sort-Object ResourceGroupName | ft ResourceGroupName,Location,ProvisioningState
Get-AzResource -ResourceGroupName $rgName | Sort-Object ResourceType | Format-Table Name,ResourceType,Location

# New-AzResourceGroupDeployment -Name 'TabulaRasa' -ResourceGroupName $rgName -Mode Complete -Force -TemplateUri 'https://raw.githubusercontent.com/www42/arm/master/templates/empty.json' -AsJob
# Remove-AzResourceGroup -Name $rgName -Force -AsJob


# --- Prerequisite: Virtual Newtwork -------------------------------------------------
New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $location -AddressPrefix $addressPrefix -Subnet $subnet0 -Force
$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
$subnet0Subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name 'Subnet0'

$templateParams['subnetId'] = $subnet0Subnet.Id
$templateParams

# --- Template Deployment: VM, DCR, DCR association ----------------------------------
New-AzResourceGroupDeployment -Name 'Scenario-Monitoring' -TemplateFile $templateFile -ResourceGroupName $rgName -Location $location @templateParams 

Get-AzResourceGroupDeployment -ResourceGroupName $rgName | Sort-Object Timestamp -Descending | ft DeploymentName,ProvisioningState,Timestamp


# TODO
#   - $subnet0 --> $subnet0Config
#   - $subnet0Subnet --> $subnet0