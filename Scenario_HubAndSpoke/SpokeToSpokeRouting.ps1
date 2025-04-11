#--------------------------------------------------------------------------
# This script
#  - creates UDRs for spoke-to-spoke routing
# --------------------------------------------------------------------------
$hubPrefix        = '10.0.0.0/16'
$hybridPrefix     = '10.1.0.0/16'
$nestedPrefix     = '10.2.0.0/16'
$monitoringPrefix = '10.3.0.0/16'

$hub        = Get-AzVirtualNetwork -Name 'vnet-hub'                  -ResourceGroupName 'rg-hub'
$hybrid     = Get-AzVirtualNetwork -Name 'vnet-hybrididentity'       -ResourceGroupName 'rg-hybrididentity'
$nested     = Get-AzVirtualNetwork -Name 'vnet-nestedvirtualization' -ResourceGroupName 'rg-nestedvirtualization'
$monitoring = Get-AzVirtualNetwork -Name 'vnet-monitoring'           -ResourceGroupName 'rg-monitoring'


# Check peerings
# --------------------------------------------------------------------------
#       * Hub peerings to spokes should have 'AllowGatewayTransit' set to 'True'
#       * Spoke peerings to hub  should have 'UseRemoteGateways' set to 'True'
#
#    --> Peering.ps1


# UDR Hybrid --> Nested, Monitoring
# --------------------------------------------------------------------------
#   new route table
$routeConfig = @(
    New-AzRouteConfig -Name 'udr-nested' -AddressPrefix $nestedPrefix -NextHopType 'VirtualNetworkGateway'
    New-AzRouteConfig -Name 'udr-monitoring' -AddressPrefix $monitoringPrefix -NextHopType 'VirtualNetworkGateway'
)
New-AzRouteTable -Name 'rt-hybrid' -Route $routeConfig -ResourceGroupName 'rg-hybrididentity' -Location 'westeurope' 

#   associate route table with subnet
$routeTable = Get-AzRouteTable -Name 'rt-hybrid' -ResourceGroupName 'rg-hybrididentity'
$subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $hybrid -Name 'Subnet0'
$subnet.RouteTable = $routeTable
Set-AzVirtualNetwork -VirtualNetwork $hybrid


# UDR Nested --> Hybrid, Monitoring
# --------------------------------------------------------------------------
#   new route table
$routeConfig = @(
    New-AzRouteConfig -Name 'udr-hybrid' -AddressPrefix $hybridPrefix -NextHopType 'VirtualNetworkGateway'
    New-AzRouteConfig -Name 'udr-monitoring' -AddressPrefix $monitoringPrefix -NextHopType 'VirtualNetworkGateway'
)
New-AzRouteTable -Name 'rt-nested' -Route $routeConfig -ResourceGroupName 'rg-nestedvirtualization' -Location 'westeurope'

#  associate route table with subnet
$routeTable = Get-AzRouteTable -Name 'rt-nested' -ResourceGroupName 'rg-nestedvirtualization'
$subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $nested -Name 'Azure-VMs'
$subnet.RouteTable = $routeTable
Set-AzVirtualNetwork -VirtualNetwork $nested


# UDR Monitoring --> Hybrid, Nested
# --------------------------------------------------------------------------
#   new route table
$routeConfig = @(
    New-AzRouteConfig -Name 'udr-hybrid' -AddressPrefix $hybridPrefix -NextHopType 'VirtualNetworkGateway'
    New-AzRouteConfig -Name 'udr-nested' -AddressPrefix $nestedPrefix -NextHopType 'VirtualNetworkGateway'
)
New-AzRouteTable -Name 'rt-monitoring' -Route $routeConfig -ResourceGroupName 'rg-monitoring' -Location 'westeurope'

#   associate route table with subnet
$routeTable = Get-AzRouteTable -Name 'rt-monitoring' -ResourceGroupName 'rg-monitoring'
$subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $monitoring -Name 'Subnet0'
$subnet.RouteTable = $routeTable
Set-AzVirtualNetwork -VirtualNetwork $monitoring
