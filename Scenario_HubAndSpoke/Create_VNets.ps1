# Hub and Spoke Topology
# ====================================================================================

# --- Parameters ---------------------------------------------------------------------
$location       = 'westeurope'
$rgNameHub      = 'rg-hub'
$rgNameSpoke1   = 'rg-prod'
$rgNameSpoke2   = 'rg-dev'
$vnetNameHub    = 'vnet-hub'
$vnetNameSpoke1 = 'vnet-prod'
$vnetNameSpoke2 = 'vnet-dev'


# --- List Virtual Networks ----------------------------------------------------------
Get-AzVirtualNetwork | Foreach-Object  {
    $vnet = $_
    $_.Subnets | Format-Table @{Label='VNet';Expression={$vnet.Name}},
                              @{Label='Subnet';Expression={$_.Name}},
                              AddressPrefix,
                              DefaultOutboundAccess,
                              @{Label='ResourceGroup';Expression={$vnet.ResourceGroupName}},
                              @{Label='Location';Expression={$vnet.Location}}
}


# --- Virtual Networks ---------------------------------------------------------------
# Hub virtual network
$vnetName      = $vnetNameHub
$rgName        = $rgNameHub
$addressPrefix = '10.0.0.0/16'
$subnet0 = New-AzVirtualNetworkSubnetConfig -Name 'Subnet0'                       -AddressPrefix '10.0.0.0/24'
$subnet1 = New-AzVirtualNetworkSubnetConfig -Name 'Subnet1'                       -AddressPrefix '10.0.1.0/24'
$subnet2 = New-AzVirtualNetworkSubnetConfig -Name 'AzureBastionSubnet'            -AddressPrefix '10.0.255.0/26'
$subnet3 = New-AzVirtualNetworkSubnetConfig -Name 'AzureFirewallSubnet'           -AddressPrefix '10.0.255.64/26'
$subnet4 = New-AzVirtualNetworkSubnetConfig -Name 'AzureFirewallManagementSubnet' -AddressPrefix '10.0.255.128/26'
$subnet5 = New-AzVirtualNetworkSubnetConfig -Name 'GatewaySubnet'                 -AddressPrefix '10.0.255.192/27'

New-AzVirtualNetwork -Name $vnetName `
    -ResourceGroupName $rgName `
    -Location $location `
    -AddressPrefix $addressPrefix `
    -Subnet $subnet0,$subnet1,$subnet2,$subnet3,$subnet4,$subnet5 -Force


# Spoke 1
$vnetName      = $vnetNameSpoke1
$rgName        = $rgNameSpoke1
$addressPrefix = '10.1.0.0/16'
$subnet0 = New-AzVirtualNetworkSubnetConfig -Name 'Subnet0'                       -AddressPrefix '10.1.0.0/24'
$subnet1 = New-AzVirtualNetworkSubnetConfig -Name 'Subnet1'                       -AddressPrefix '10.1.1.0/24'

New-AzVirtualNetwork -Name $vnetName `
    -ResourceGroupName $rgName `
    -Location $location `
    -AddressPrefix $addressPrefix `
    -Subnet $subnet0,$subnet1 -Force


# Spoke 2
$vnetName      = $vnetNameSpoke2
$rgName        = $rgNameSpoke2
$addressPrefix = '10.2.0.0/16'
$subnet0 = New-AzVirtualNetworkSubnetConfig -Name 'Subnet0'                       -AddressPrefix '10.2.0.0/24'
$subnet1 = New-AzVirtualNetworkSubnetConfig -Name 'Subnet1'                       -AddressPrefix '10.2.1.0/24'

New-AzVirtualNetwork -Name $vnetName `
    -ResourceGroupName $rgName `
    -Location $location `
    -AddressPrefix $addressPrefix `
    -Subnet $subnet0,$subnet1 -Force




# --- Peerings -----------------------------------------------------------------------
$vnetHub    = Get-AzVirtualNetwork -Name $vnetNameHub    -ResourceGroupName $rgNameHub
$vnetSpoke1 = Get-AzVirtualNetwork -Name $vnetNameSpoke1 -ResourceGroupName $rgNameSpoke1
$vnetSpoke2 = Get-AzVirtualNetwork -Name $vnetNameSpoke2 -ResourceGroupName $rgNameSpoke2

# Hub <--> Spoke 1
Add-AzVirtualNetworkPeering -Name 'peer-hub-prod' -VirtualNetwork $vnetHub -RemoteVirtualNetworkId $vnetSpoke1.Id -AllowForwardedTraffic -AllowGatewayTransit
Add-AzVirtualNetworkPeering -Name 'peer-prod-hub' -VirtualNetwork $vnetSpoke1 -RemoteVirtualNetworkId $vnetHub.Id -AllowForwardedTraffic 

# Hub <--> Spoke 2
Add-AzVirtualNetworkPeering -Name 'peer-hub-dev' -VirtualNetwork $vnetHub -RemoteVirtualNetworkId $vnetSpoke2.Id -AllowForwardedTraffic -AllowGatewayTransit
Add-AzVirtualNetworkPeering -Name 'peer-dev-hub' -VirtualNetwork $vnetSpoke2 -RemoteVirtualNetworkId $vnetHub.Id -AllowForwardedTraffic 

# Set 'UseRemoteGateways' for Spoke1 (Gateway in Hub must be present)
$peerSpoke1Hub = Get-AzVirtualNetworkPeering -VirtualNetworkName $vnetNameSpoke1 -ResourceGroupName $rgNameSpoke1
$peerSpoke1Hub | fl AllowVirtualNetworkAccess,AllowForwardedTraffic,AllowGatewayTransit,UseRemoteGateways
$peerSpoke1Hub.UseRemoteGateways = $true
Set-AzVirtualNetworkPeering -VirtualNetworkPeering $peerSpoke1Hub

# Set 'UseRemoteGateways' for Spoke2 (Gateway in Hub must be present)
$peerSpoke2Hub = Get-AzVirtualNetworkPeering -VirtualNetworkName $vnetNameSpoke2 -ResourceGroupName $rgNameSpoke1
$peerSpoke2Hub | fl AllowVirtualNetworkAccess,AllowForwardedTraffic,AllowGatewayTransit,UseRemoteGateways
$peerSpoke2Hub.UseRemoteGateways = $true
Set-AzVirtualNetworkPeering -VirtualNetworkPeering $peerSpoke2Hub


# List
Get-AzVirtualNetworkPeering -VirtualNetworkName $vnetNameHub    -ResourceGroupName $rgNameHub    | ft Name,PeeringState,AllowForwardedTraffic,AllowGatewayTransit,UseRemoteGateways
Get-AzVirtualNetworkPeering -VirtualNetworkName $vnetNameSpoke1 -ResourceGroupName $rgNameSpoke1 | ft Name,PeeringState,AllowForwardedTraffic,AllowGatewayTransit,UseRemoteGateways
Get-AzVirtualNetworkPeering -VirtualNetworkName $vnetNameSpoke2 -ResourceGroupName $rgNameSpoke2 | ft Name,PeeringState,AllowForwardedTraffic,AllowGatewayTransit,UseRemoteGateways



# --- UDRs ---------------------------------------------------------------------------
$vnetHub    = Get-AzVirtualNetwork -Name $vnetNameHub    -ResourceGroupName $rgNameHub
$vnetSpoke1 = Get-AzVirtualNetwork -Name $vnetNameSpoke1 -ResourceGroupName $rgNameSpoke1
$vnetSpoke2 = Get-AzVirtualNetwork -Name $vnetNameSpoke2 -ResourceGroupName $rgNameSpoke2

# Spoke1 --> Spoke2  (rt-prod)
$vnet = $vnetSpoke1
#    create RT with Spoke2 as destination
$destinationAddressPrefix = $vnetSpoke2 | % AddressSpace | % AddressPrefixes
$routeConfig = New-AzRouteConfig -Name 'prod-to-dev' -AddressPrefix $destinationAddressPrefix -NextHopType VirtualNetworkGateway
$routeTable = New-AzRouteTable -Name 'rt-prod' -Route $routeConfig -ResourceGroupName $rgNameSpoke1 -Location $location
#    associate RT with Spoke1's subnets
$vnet.Subnets | ForEach-Object {$_.RouteTable = $routeTable}
Set-AzVirtualNetwork -VirtualNetwork $vnet

# Spoke2 --> Spoke1  (rt-dev)
$vnet = $vnetSpoke2
#    create RT with Spoke1 as destination
$destinationAddressPrefix = $vnetSpoke1 | % AddressSpace | % AddressPrefixes
$routeConfig = New-AzRouteConfig -Name 'dev-to-prod' -AddressPrefix $destinationAddressPrefix -NextHopType VirtualNetworkGateway
$routeTable = New-AzRouteTable -Name 'rt-dev' -Route $routeConfig -ResourceGroupName $rgNameSpoke2 -Location $location
#    associate RT with Spoke2's subnets
$vnet.Subnets | ForEach-Object {$_.RouteTable = $routeTable}
Set-AzVirtualNetwork -VirtualNetwork $vnet



# --- DNS Zones for Private Endpoints ------------------------------------------------