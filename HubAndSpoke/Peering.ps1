# --- Scenario Hub and Spoke ---------------------------------------------------------
#
# This script
#  - removes old (disconnected) peerings
#  - creates new peerings

$hub        = Get-AzVirtualNetwork -Name 'vnet-hub'                  -ResourceGroupName 'rg-hub'
$hybrid     = Get-AzVirtualNetwork -Name 'vnet-hybrididentity'       -ResourceGroupName 'rg-hybrididentity'
$nested     = Get-AzVirtualNetwork -Name 'vnet-nestedvirtualization' -ResourceGroupName 'rg-nestedvirtualization'
$monitoring = Get-AzVirtualNetwork -Name 'vnet-monitoring'           -ResourceGroupName 'rg-monitoring'


# --- Delete old (disconnected) peerings ---------------------------------------------
Get-AzVirtualNetworkPeering -VirtualNetworkName $hub.Name -ResourceGroupName 'rg-hub' | ft Name,PeeringState
Get-AzVirtualNetworkPeering -VirtualNetworkName $hub.Name -ResourceGroupName 'rg-hub' | Remove-AzVirtualNetworkPeering -Force


# --- Hub <--> Hybrid (1) ------------------------------------------------------------
Add-AzVirtualNetworkPeering -Name 'peer-hub-hybrid' -VirtualNetwork $hub    -RemoteVirtualNetworkId $hybrid.Id -AllowForwardedTraffic -AllowGatewayTransit
Add-AzVirtualNetworkPeering -Name 'peer-hybrid-hub' -VirtualNetwork $hybrid -RemoteVirtualNetworkId $hub.Id    -AllowForwardedTraffic #-UseRemoteGateways

# --- Hub <--> Nested (2) ------------------------------------------------------------
Add-AzVirtualNetworkPeering -Name 'peer-hub-nested' -VirtualNetwork $hub    -RemoteVirtualNetworkId $nested.Id -AllowForwardedTraffic -AllowGatewayTransit
Add-AzVirtualNetworkPeering -Name 'peer-nested-hub' -VirtualNetwork $nested -RemoteVirtualNetworkId $hub.Id    -AllowForwardedTraffic #-UseRemoteGateways

# --- Hub <--> Monitoring (3) --------------------------------------------------------
Add-AzVirtualNetworkPeering -Name 'peer-hub-monitoring' -VirtualNetwork $hub        -RemoteVirtualNetworkId $monitoring.Id -AllowForwardedTraffic -AllowGatewayTransit
Add-AzVirtualNetworkPeering -Name 'peer-monitoring-hub' -VirtualNetwork $monitoring -RemoteVirtualNetworkId $hub.Id        -AllowForwardedTraffic #-UseRemoteGateways



# Show
Get-AzVirtualNetworkPeering -VirtualNetworkName $hub.Name        -ResourceGroupName 'rg-hub'                  | ft Name,PeeringState,AllowForwardedTraffic,AllowGatewayTransit,UseRemoteGateways
Get-AzVirtualNetworkPeering -VirtualNetworkName $hybrid.Name     -ResourceGroupName 'rg-hybrididentity'       | ft Name,PeeringState,AllowForwardedTraffic,AllowGatewayTransit,UseRemoteGateways
Get-AzVirtualNetworkPeering -VirtualNetworkName $nested.Name     -ResourceGroupName 'rg-nestedvirtualization' | ft Name,PeeringState,AllowForwardedTraffic,AllowGatewayTransit,UseRemoteGateways
Get-AzVirtualNetworkPeering -VirtualNetworkName $monitoring.Name -ResourceGroupName 'rg-monitoring'           | ft Name,PeeringState,AllowForwardedTraffic,AllowGatewayTransit,UseRemoteGateways

# Set 'UseRemoteGateways'
$hybridToHub = Get-AzVirtualNetworkPeering -VirtualNetworkName $hybrid.Name -ResourceGroupName 'rg-hybrididentity'
$hybridToHub.UseRemoteGateways = $true
Set-AzVirtualNetworkPeering -VirtualNetworkPeering $hybridToHub

$nestedToHub = Get-AzVirtualNetworkPeering -VirtualNetworkName $nested.Name -ResourceGroupName 'rg-nested'
$nestedToHub.UseRemoteGateways = $true
Set-AzVirtualNetworkPeering -VirtualNetworkPeering $nestedToHub

$monitoringToHub = Get-AzVirtualNetworkPeering -VirtualNetworkName $monitoring.Name -ResourceGroupName 'rg-monitoring'
$monitoringToHub.UseRemoteGateways = $true
Set-AzVirtualNetworkPeering -VirtualNetworkPeering $monitoringToHub


# Remove
Remove-AzVirtualNetworkPeering -Name 'peer-hub-hybrid' -VirtualNetworkName $hub.Name    -ResourceGroupName 'rg-hub'            -Force
Remove-AzVirtualNetworkPeering -Name 'peer-hybrid-hub' -VirtualNetworkName $hybrid.Name -ResourceGroupName 'rg-hybrididentity' -Force

Remove-AzVirtualNetworkPeering -Name 'peer-hub-nested' -VirtualNetworkName $hub.Name    -ResourceGroupName 'rg-hub'    -Force
Remove-AzVirtualNetworkPeering -Name 'peer-nested-hub' -VirtualNetworkName $nested.Name -ResourceGroupName 'rg-nested' -Force