# --- Scenario Hub and Spoke ---------------------------------------------------------
# 
# This scenario deploys
#  - a Virtual Network 'Hub',
#  - a Bastion Host, connected to 'Hub',
#  - a VPN Gateway, connected to 'Hub',
#  - Peerings to other (existing) Virtual Networks


# --- Prerequisite: Root Certificate -------------------------------------------------
Get-ChildItem -Path './Scenario_HubAndSpoke/Atropos__RootCertificate.pfx'


# --- Parameters ---------------------------------------------------------------------
$rgName          = 'rg-infrastructure'
$location        = 'swedencentral'
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
$rootCertificateName = 'AtroposRoot'
$rootCertificateData = 'MIIC5TCCAc2gAwIBAgIQcgwLTPt2Ia1C5VV+HCziITANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDDApBdHJvcG9zIEFHMB4XDTI2MDcyMjAzNTM0M1oXDTI4MDcyMjA0MDM0M1owFTETMBEGA1UEAwwKQXRyb3BvcyBBRzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMI1fJn94Wuj7jb9G5ZkpAJFccX7dbytpQXtTnuYaz7RPei/JAJd+vbo+YHGN8EVMY9sy/GjNO8yxqatYz3N42krnIj32WcNJ3uvMoQH4m7fG2F0doWIpC4Dndzug+M5x+GdmrthoucN8QfdHEQs5m/ruU5Nh/W1LzNHYAcdRpjBc/bipUQH12IKgABOCqBXPmH0lLmkXJQAc1YkBH6sW8aft5IPBWsiU4EX1gdfyN7hUh43BT6oplrSDBGylvDeaXLsMWyIXSYuLDJiqXVUSTvJPEATFp30CPknK8QS3PHHncQRiyMsZHhHqyiTo2T+u0fbzQpkIXxa/hvg6UYSb7ECAwEAAaMxMC8wDgYDVR0PAQH/BAQDAgIEMB0GA1UdDgQWBBQz+Yawj2nApvDQT/HtTgEDRPA2vzANBgkqhkiG9w0BAQsFAAOCAQEAYMkeTYlAT55oBfRb/D/JFhjk/f9Vpvm7PHthZkitE7j8yaRHNNQxngMpbvWMHMUiG+yjweP3ozlQxYyqm22eWl+CjKPhZLGw6nxXEXKM/k6myZ9/f0CKMvLRmxtBNXQr6kptFd2raGPw5spaFUUDrXoBSQZGc0ma29kI9E83YxAZ0uv/sH9fRzpfcNd5Cdt0wvAvh2wCDR4xGULdxIm619McYay+6FcM6L/fRwCviD5bXbbTPRX/eXIa+e1p0lhldpOntW9qmyXkMn66Omuxe97GSnoFtFvAwawovklTtf8is4RoH8QbRNqZzgtgUzbrPrBD8i1OoSobm0JuVkUOEw=='
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
# New-AzResourceGroup -Name $rgName -Location $location -Force
Get-AzResourceGroup | Sort-Object ResourceGroupName | ft ResourceGroupName,Location,ProvisioningState
Get-AzResource -ResourceGroupName $rgName | Sort-Object ResourceType | Format-Table Name,ResourceType,Location

# New-AzResourceGroupDeployment -Name 'TabulaRasa' -ResourceGroupName $rgName -Mode Complete -Force -TemplateUri 'https://raw.githubusercontent.com/www42/arm/master/templates/empty.json' -AsJob
# Remove-AzResourceGroup -Name $rgName -Force -AsJob


# --- Virtual network ----------------------------------------------------------------
# New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $location -AddressPrefix $addressPrefix -Subnet $subnet0,$subnet1,$subnet2,$subnet3 -Force

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