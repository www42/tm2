# --- Scenario Phoenix ---------------------------------------------------------------
#
# This deploys infrastructure for Windows Server scenario. It deployes
#   - a virtual network with two subnets (PowerShell)
#   - a public DNS zone 'phoenix.az.training' (Bicep)


# --- Login --------------------------------------------------------------------------
$Subscription1 = 'fa366244-df54-48f8-83c2-e1739ef3c4f1'  # Visual Studio Enterprise Subscription
$Subscription2 = '7f117653-b103-4699-82b0-a70fc3f25568'  # Azure Pass - Sponsorship Subscription
$tenantId      = '819ebf55-0973-4703-b006-581a48f25961'  # az.training
Login-AzAccount -Subscription $Subscription2 -Tenant $tenantId
Get-AzContext                | Format-List Name,Account,Tenant,Subscription
Get-AzContext -ListAvailable | Format-List Name,Account,Tenant,Subscription

Set-AzContext -Subscription $Subscription2


# --- Passwords ----------------------------------------------------------------------
$localAdminPassword = Read-Host -Prompt 'LocalAdmin password' -AsSecureString | ConvertFrom-SecureString
@{'localAdminPassword' = $localAdminPassword} | ConvertTo-Json | Out-File "./Scenario_Monitoring/PASSWORDS"



# --- Parameters ---------------------------------------------------------------------
$rgName          = 'rg-phoenix'
$location        = 'westeurope'
$vnetName        = 'vnet-phoenix'
$addressPrefix   = '10.5.0.0/16'
$subnet0config   = New-AzVirtualNetworkSubnetConfig -Name 'Servers'      -AddressPrefix '10.5.0.0/24'
$subnet1config   = New-AzVirtualNetworkSubnetConfig -Name 'Workstations' -AddressPrefix '10.5.1.0/24'
$serverSubnetId  = $subnet0.Id
$clientSubnetId  = $subnet1.Id
$publicDnsPrefix = 'phoenix'
$templateFile    = 'Scenario_Phoenix/main.bicep'

$templateParams = @{
    location          = $location
    publicDnsPrefix   = $publicDnsPrefix
}



# --- Resource group -----------------------------------------------------------------
New-AzResourceGroup -Name $rgName -Location $location

Get-AzResourceGroup | Sort-Object ResourceGroupName | ft ResourceGroupName,Location,ProvisioningState
Get-AzResource -ResourceGroupName $rgName | Sort-Object ResourceType | Format-Table Name,ResourceType,Location

# New-AzResourceGroupDeployment -Name 'TabulaRasa' -ResourceGroupName $rgName -Mode Complete -Force -TemplateUri 'https://raw.githubusercontent.com/www42/arm/master/templates/empty.json' -AsJob
# Remove-AzResourceGroup -Name $rgName -Force -AsJob


# --- Virtual network ----------------------------------------------------------------
# Create
New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $location -AddressPrefix $addressPrefix -Subnet $subnet0config, $subnet1config -Force
$phoenix = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName

# Peering mit vnet-hub
#   --- Hub / Subscription 1 ---
Set-AzContext -Subscription $Subscription1
Get-AzContext | Format-List Name,Account,Tenant,Subscription
$hub = Get-AzVirtualNetwork -Name 'vnet-hub' -ResourceGroupName 'rg-hub'
Get-AzVirtualNetworkPeering -VirtualNetworkName $hub.Name -ResourceGroupName 'rg-hub' | ft Name,PeeringState
Add-AzVirtualNetworkPeering -Name 'peer-hub-phoenix' -VirtualNetwork $hub -RemoteVirtualNetworkId $phoenix.Id -AllowForwardedTraffic -AllowGatewayTransit
#Remove-AzVirtualNetworkPeering -Name 'peer-hub-phoenix' -VirtualNetworkName $hub.Name -ResourceGroupName 'rg-hub' -Force

#   --- Spoke / Subscription 2 ---
Set-AzContext -Subscription $Subscription2
Get-AzContext | Format-List Name,Account,Tenant,Subscription
Get-AzVirtualNetworkPeering -VirtualNetworkName $phoenix.Name -ResourceGroupName $rgName | ft Name,PeeringState
Add-AzVirtualNetworkPeering -Name 'peer-phoenix-hub' -VirtualNetwork $phoenix -RemoteVirtualNetworkId $hub.Id -AllowForwardedTraffic #-UseRemoteGateways
#Remove-AzVirtualNetworkPeering -Name 'peer-phoenix-hub' -VirtualNetworkName $phoenix.Name -ResourceGroupName $rgName -Force



# --- Template Deployment: Public DNS Zone -------------------------------------------
$templateParams
dir $templateFile
New-AzResourceGroupDeployment -Name 'Scenario-phoenix' -TemplateFile $templateFile -ResourceGroupName $rgName -Location $location @templateParams 

Get-AzResourceGroupDeployment -ResourceGroupName $rgName | Sort-Object Timestamp -Descending | ft DeploymentName,ProvisioningState,Timestamp
$publicDnsZoneDeployment = Get-AzResourceGroupDeployment -ResourceGroupName $rgName -Name 'Module-PublicDnsZone'
$publicDnsZoneDeployment.Outputs.nameServers.Value
Resolve-DnsName -Type NS -Name "$publicDnsPrefix.az.training" | Sort-Object NameHost

# Deployment Script
#       In dem Bicep Template steht eine Resource von Typ 'deploymentScripts', das lediglich 'Write-Output' macht.
#       Wie kann ich die Ausgabe des Scripts sehen? Wohin schreibt 'Write-Output'?
#       Mit PowerShell kann ich die Ausgabe des Scripts nicht sehen, aber mit CLI geht es:
az deployment-scripts show-log --name dnsZoneScript --resource-group rg-phoenix
az deployment-scripts show-log --name dnsZoneScript --resource-group rg-phoenix --query "value[0].log"