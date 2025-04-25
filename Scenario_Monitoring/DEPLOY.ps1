# --- Scenario Monitoring ------------------------------------------------------------
#
# This scenario deploys 
#   - a Log Analytics Workspace, 
#   - a Data Collection Rule (DCR) for Windows Performance Counters
#   - and associates it to a VM.
# ------------------------------------------------------------------------------------


# --- Login --------------------------------------------------------------------------
Login-AzAccount
Login-AzAccount -Subscription 'fa366244-df54-48f8-83c2-e1739ef3c4f1'
Get-AzContext | Format-List Name,Account,Tenant,Subscription
Get-AzContext -ListAvailable | Format-List Name,Account,Tenant,Subscription
Set-AzContext -Subscription '2e35dc59-591a-4306-bbdb-a017d6963783'

# --- Passwords ----------------------------------------------------------------------
$localAdminPassword = Read-Host -Prompt 'LocalAdmin password' -AsSecureString | ConvertFrom-SecureString
@{'localAdminPassword' = $localAdminPassword} | ConvertTo-Json | Out-File "./Scenario_Monitoring/PASSWORDS"


# --- Parameters ---------------------------------------------------------------------
$rgName                        = 'rg-monitoring'
$location                      = 'westeurope'
$vnetName                      = 'vnet-monitoring'
$addressPrefix                 = '10.3.0.0/16'
$subnet0Config                 = New-AzVirtualNetworkSubnetConfig -Name 'Subnet0' -AddressPrefix '10.3.0.0/24'
$subnetId                      = $subnet0.Id  # wird weiter unten gesetzt
$vmName                        = 'vm-monitoring-svr1'
$vmName2                       = 'vm-monitoring-svr2'
$vmComputerName                = 'SVR1'
$vmComputerName2               = 'SVR2'
$systemAssignedManagedIdentity = $true
$vmAdminUserName               = 'LocalAdmin'
$vmAdminPassword               = Get-Content "./Scenario_Monitoring/PASSWORDS" | ConvertFrom-Json | % { $_.localAdminPassword } | ConvertTo-SecureString
$logAnalyticsWorkspaceName     = 'log-monitoring'
$dcrName                       = 'dcr-windowsperf'
$deployLoadbalancer            = $false
$loadbalancerName              = 'lbe-monitoring'
$templateFile = 'Scenario_Monitoring/main.bicep'

$templateParams = @{
    location = $location
    subnetId = $subnetId
    vmName = $vmName
    vmName2 = $vmName2
    vmComputerName = $vmComputerName
    vmComputerName2 = $vmComputerName2
    systemAssignedManagedIdentity = $systemAssignedManagedIdentity
    vmAdminUserName = $vmAdminUserName
    vmAdminPassword = $vmAdminPassword
    logAnalyticsWorkspaceName = $logAnalyticsWorkspaceName
    dcrName = $dcrName
    deployLoadbalancer = $deployLoadbalancer
    loadbalancerName = $loadbalancerName
}
$templateParams['deployLoadbalancer'] = $true


# --- Resource group -----------------------------------------------------------------
New-AzResourceGroup -Name $rgName -Location $location

Get-AzResourceGroup | Sort-Object ResourceGroupName | ft ResourceGroupName,Location,ProvisioningState
Get-AzResource -ResourceGroupName $rgName | Sort-Object ResourceType | Format-Table Name,ResourceType,Location

# New-AzResourceGroupDeployment -Name 'TabulaRasa' -ResourceGroupName $rgName -Mode Complete -Force -TemplateUri 'https://raw.githubusercontent.com/www42/arm/master/templates/empty.json' -AsJob
# Remove-AzResourceGroup -Name $rgName -Force -AsJob


# --- Prerequisite: Virtual Newtwork -------------------------------------------------
New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $location -AddressPrefix $addressPrefix -Subnet $subnet0Config -Force
$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
$subnet0 = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name 'Subnet0'


# --- Template Deployment: VMs, Loadbalancer, DCR, DCR association -------------------
$templateParams['subnetId'] = $subnet0.Id
$templateParams 
dir $templateFile

New-AzResourceGroupDeployment -Name 'Scenario-Monitoring' -TemplateFile $templateFile -ResourceGroupName $rgName -Location $location @templateParams 

Get-AzResourceGroupDeployment -ResourceGroupName $rgName | Sort-Object Timestamp -Descending | ft DeploymentName,ProvisioningState,Timestamp



# --- Loadbalancer -------------------------------------------------------------------
$rgName
$loadbalancerName
Get-AzLoadBalancer -Name $loadbalancerName -ResourceGroupName $rgName | fl Name,ResourceGroupName,Location,ProvisioningState,FrontendIpConfigurations,BackendAddressPools,LoadBalancingRules
$ip = Get-AzPublicIpAddress -Name 'pip-lbe-monitoring' | % IpAddress

for ($i = 1; $i -le 10; $i++) {
    Invoke-WebRequest -DisableKeepAlive -Uri $ip | % Content
}