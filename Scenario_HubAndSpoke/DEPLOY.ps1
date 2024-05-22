# --- Scenario Hub and Spoke ---------------------------------------------------------
# 
# This scenario deploys
#  - a Virtual Network 'Hub',
#  - a Bastion Host, connected to 'Hub',
#  - a VPN Gateway, connected to 'Hub',
#  - Peerings to other (existing) Virtual Networks


# --- Login --------------------------------------------------------------------------
Login-AzAccount
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
$rootCertificateData = 'MIIC5zCCAc+gAwIBAgIQVMUVr0NMiI1Cf4yE9ytIQjANBgkqhkiG9w0BAQsFADAWMRQwEgYDVQQDDAtBWiBUcmFpbmluZzAeFw0yMzA5MDUxNzUwMDhaFw0yNDA5MDUxODEwMDhaMBYxFDASBgNVBAMMC0FaIFRyYWluaW5nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApaom+BpYqwo6VUHCu+ah1sbqcDTnatvm/7yd5TGv0JS6pIn13gGLn+ss7dhJ5uGHB3AXiZlPkHRTgYYoLsos7EQDfLcRyz94TS/NtIAijpq709J+FrBIy7uVT7sWlOmZxkIjjh1ZvPboAotbXEP7hc2hGlXtJZGg1yLslNRRTGeaHesXf1RI/ODJ7/sO/TeZUvpqqP3EzH03uawqeztf/8ot2q/o7/vwQBy6rRvoz9OEh+QsO5m34n4FiL1Hqo60Kpj6FUTRI6HGhbRXLFonJmpB0HtvyQ7BtlykFhJhQJZZjnRxd/hyCt5o8zr4LwNmL2uejRFTl5oye1Iy32I0fQIDAQABozEwLzAOBgNVHQ8BAf8EBAMCAgQwHQYDVR0OBBYEFF1eAVAHWoZGGlS6tWTQigiuuM0dMA0GCSqGSIb3DQEBCwUAA4IBAQCWmpX2xASeulUM2oW8r/tQ+h3PHtnxp5mdNgwvg18zrcPXqYn7+ZPFDFzKClPJUdaEdtcDQfrwLA9C7/75UPUeRPdzw4Q+csqKdQ1VwLxo5/yVaFQ+KT2QnMgdLXwNXdb3S3rYDuqeDKwwxHh3hxIka8CqRZR8oPYUpD2y+9XEoepqOg+H6TuBK1WUuDasVpdEOp7XD2I5P8BkAx3VsBWOS2sueFSz16wR4Ene34VT1XLH22pV7s1U6IP1HmYQ6YIfML+QXEtSZzFfWoLFksNLsKHww7P72r7Xs6o8W/E2Np5mHFJMfja5b5qwv18Lyl+UIo908zDPV9TyHzffc8kr'
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
# 
#   --> ClientCertificate
#   --> Peering
#   --> Optional: Spoke-to-Spoke-Routing

