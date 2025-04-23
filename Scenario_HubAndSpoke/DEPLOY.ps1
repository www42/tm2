# --- Scenario Hub and Spoke ---------------------------------------------------------
# 
# This scenario deploys
#  - a Virtual Network 'Hub',
#  - a Bastion Host, connected to 'Hub',
#  - a VPN Gateway, connected to 'Hub',
#  - Peerings to other (existing) Virtual Networks


# --- Login --------------------------------------------------------------------------
Login-AzAccount
Login-AzAccount -Subscription 'fa366244-df54-48f8-83c2-e1739ef3c4f1'
Get-AzContext | Format-List Name,Account,Tenant,Subscription
Get-AzContext -ListAvailable | Format-List Name,Account,Tenant,Subscription
Set-AzContext -Subscription 'fa366244-df54-48f8-83c2-e1739ef3c4f1'


# --- Prerequisite: Root Certificate -------------------------------------------------
Get-ChildItem -Path 'Scenario_HubAndSpoke/RootCertificate.pfx'


# --- Parameters ---------------------------------------------------------------------
$rgName          = 'rg-hub'
$location        = 'westeurope'
$vnetName        = 'vnet-hub'
$addressPrefix   = '10.0.0.0/16'
$subnet0         = New-AzVirtualNetworkSubnetConfig -Name 'Subnet0'             -AddressPrefix '10.0.0.0/24'
$subnet1         = New-AzVirtualNetworkSubnetConfig -Name 'AzureBastionSubnet'  -AddressPrefix '10.0.255.0/26'
$subnet2         = New-AzVirtualNetworkSubnetConfig -Name 'AzureFirewallSubnet' -AddressPrefix '10.0.255.64/26'
$subnet3         = New-AzVirtualNetworkSubnetConfig -Name 'GatewaySubnet'       -AddressPrefix '10.0.255.128/27'
$bastionName     = 'bas-hub'
$bastionSubnetId = $bastionSubnet.Id
$gatewaySubnetId = $gatewaySubnet.Id
$deployGateway   = $false
$gatewayName     = 'vgw-hub'
$rootCertificateName = 'AzTrainingRoot'
$rootCertificateData = 'MIIC5zCCAc+gAwIBAgIQHhmUnnz6KKtGYNRtbqea+zANBgkqhkiG9w0BAQsFADAWMRQwEgYDVQQDDAtBWiBUcmFpbmluZzAeFw0yNTA0MDkxNjM2MThaFw0yNzA0MDkxNjQ2MThaMBYxFDASBgNVBAMMC0FaIFRyYWluaW5nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvh4//Exs5E/G+fouaXZYXvl51tlTLzbyBTPBAW7ta3FzmdXzHwxA3yLKBfQg6P9cH1yWHrzHVd81BnaFT/ocJI0Hc0ifbtBM6YmWmfDw+mTF497AOOTrN2VvShbRlSC95mqCkRREi6EE5aAYdrgceJatY/ml9ZSJQ313K/XCZKqOfxj1xLdjw09piA6uZFyrPXx2P/Kx4K0Z70v5xdjPeD5e4wSKqgMT94EaUkB4m9yboO65eqN0xwNCX/Ra3x7iyFPAjVsaOGrnzKK8XHCf8PDshjX3SRQhJlrIjvVZY2Es12JmATzqrpTbdF+snEF6zFxf9h3u1q0Jy3tnKHM4yQIDAQABozEwLzAOBgNVHQ8BAf8EBAMCAgQwHQYDVR0OBBYEFGFfpI68AT3H8/VVjidS8EnUQC3RMA0GCSqGSIb3DQEBCwUAA4IBAQBsCbjRxgTTqCbNzLl/gBGrUd8fZKS3GDNft8WPXeStG6l1Ebm0WF7BVZp+r/KmbUfYvHpyF4/u3ZgeKGAPU/VTC9MySuY+8K2rIA/mAxT21m4BrVQLLL96VhWl8MRd8KcnksNkFF7aV+2HbYVVN8QwxXcne4WMkRi7avOyt3i3o9HXebF+52yI+bIRWxDIkK7HDTpuyL2crQr34vQIW3E44nVVDBhyUCYsqXHy7Fx2kryMt+FZuqpLROjmo+1f8Ne7ESchVMNexOw9ZH0TVFbLGT0SiWmIoHNjkmVUCpzD+hbNF8bBdY0RY2KdYfyIbvMYGRXIvUFG7smpJQmD9Fbg'
$templateFile    = 'Scenario_HubAndSpoke/main.bicep'

$templateParams = @{
    location               = $location
    bastionName            = $bastionName
    bastionSubnetId        = $bastionSubnetId
    deployGateway          = $deployGateway
    gatewayName            = $gatewayName
    gatewaySubnetId        = $gatewaySubnetId
    rootCertificateName    = $rootCertificateName
    rootCertificateData    = $rootCertificateData
}
$templateParams['deployGateway'] = $true


# --- Resource group -----------------------------------------------------------------
New-AzResourceGroup -Name $rgName -Location $location -Force

Get-AzResourceGroup | Sort-Object ResourceGroupName | ft ResourceGroupName,Location,ProvisioningState
Get-AzResource -ResourceGroupName $rgName | Sort-Object ResourceType | Format-Table Name,ResourceType,Location

# New-AzResourceGroupDeployment -Name 'TabulaRasa' -ResourceGroupName $rgName -Mode Complete -Force -TemplateUri 'https://raw.githubusercontent.com/www42/arm/master/templates/empty.json' -AsJob
# Remove-AzResourceGroup -Name $rgName -Force -AsJob


# --- Virtual network ----------------------------------------------------------------
New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $location -AddressPrefix $addressPrefix -Subnet $subnet0,$subnet1,$subnet2,$subnet3 -Force

$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
$bastionSubnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name 'AzureBastionSubnet'
$gatewaySubnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name 'GatewaySubnet'


# --- Template Deployment: Bastion Host, VPN Gateway ---------------------------------
$templateParams['bastionSubnetId'] = $bastionSubnet.Id
$templateParams['gatewaySubnetId'] = $gatewaySubnet.Id
$templateParams
dir $templateFile

New-AzResourceGroupDeployment -Name 'Scenario-HubAndSpoke' -TemplateFile $templateFile -ResourceGroupName $rgName -Location $location @templateParams 

Get-AzResourceGroupDeployment -ResourceGroupName $rgName | Sort-Object Timestamp -Descending | ft DeploymentName,ProvisioningState,Timestamp


# --- Next steps ---------------------------------------------------------------------
#       Peering Hub and Spokes --> Peering.ps1
#       Poit-to-Site VPN       --> PointToSiteVPN.ps1
#


# --- Delete Bastion Host to save money ----------------------------------------------

# Remove a bastion host
$bastionName     = 'bas-hub'
$rgName          = 'rg-hub'
Get-AzBastion
Get-AzBastion -Name $bastionName -ResourceGroupName $rgName | Remove-AzBastion -Force

# Remove bastion host's public IP address
Get-AzPublicIpAddress -ResourceGroupName $rgName -Name "pip-$bastionName" | Remove-AzPublicIpAddress -Force