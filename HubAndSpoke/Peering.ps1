# --- Peerings -----------------------------------------------------------------------

$hub    = Get-AzVirtualNetwork -Name 'vnet-hub'            -ResourceGroupName 'rg-hub'
$hybrid = Get-AzVirtualNetwork -Name 'vnet-hybrididentity' -ResourceGroupName 'rg-hybrididentity'
$nested = Get-AzVirtualNetwork -Name 'vnet-nested'         -ResourceGroupName 'rg-nested'

# if error
#   Add-AzVirtualNetworkPeering: Authentication failed for auxiliary token...
# then
#   Clear-AzContext

# Hub <--> Hybrid
Add-AzVirtualNetworkPeering -Name 'peer-hub-hybrid' -VirtualNetwork $hub    -RemoteVirtualNetworkId $hybrid.Id -AllowForwardedTraffic -AllowGatewayTransit
Add-AzVirtualNetworkPeering -Name 'peer-hybrid-hub' -VirtualNetwork $hybrid -RemoteVirtualNetworkId $hub.Id    -AllowForwardedTraffic #-UseRemoteGateways

# Hub <--> Nested
Add-AzVirtualNetworkPeering -Name 'peer-hub-nested' -VirtualNetwork $hub    -RemoteVirtualNetworkId $nested.Id -AllowForwardedTraffic -AllowGatewayTransit
Add-AzVirtualNetworkPeering -Name 'peer-nested-hub' -VirtualNetwork $nested -RemoteVirtualNetworkId $hub.Id    -AllowForwardedTraffic #-UseRemoteGateways

# Show
Get-AzVirtualNetworkPeering -VirtualNetworkName $hub.Name    -ResourceGroupName 'rg-hub'            | ft Name,PeeringState,AllowForwardedTraffic,AllowGatewayTransit,UseRemoteGateways
Get-AzVirtualNetworkPeering -VirtualNetworkName $hybrid.Name -ResourceGroupName 'rg-hybrididentity' | ft Name,PeeringState,AllowForwardedTraffic,AllowGatewayTransit,UseRemoteGateways
Get-AzVirtualNetworkPeering -VirtualNetworkName $nested.Name -ResourceGroupName 'rg-nested'         | ft Name,PeeringState,AllowForwardedTraffic,AllowGatewayTransit,UseRemoteGateways

# Set 'UseRemoteGateways'
$hybridToHub = Get-AzVirtualNetworkPeering -VirtualNetworkName $hybrid.Name -ResourceGroupName 'rg-hybrididentity'
$hybridToHub.UseRemoteGateways = $true
Set-AzVirtualNetworkPeering -VirtualNetworkPeering $hybridToHub

$nestedToHub = Get-AzVirtualNetworkPeering -VirtualNetworkName $nested.Name -ResourceGroupName 'rg-nested'
$nestedToHub.UseRemoteGateways = $true
Set-AzVirtualNetworkPeering -VirtualNetworkPeering $nestedToHub


# Remove
Remove-AzVirtualNetworkPeering -Name 'peer-hub-hybrid' -VirtualNetworkName $hub.Name    -ResourceGroupName 'rg-hub'            -Force
Remove-AzVirtualNetworkPeering -Name 'peer-hybrid-hub' -VirtualNetworkName $hybrid.Name -ResourceGroupName 'rg-hybrididentity' -Force

Remove-AzVirtualNetworkPeering -Name 'peer-hub-nested' -VirtualNetworkName $hub.Name    -ResourceGroupName 'rg-hub'    -Force
Remove-AzVirtualNetworkPeering -Name 'peer-nested-hub' -VirtualNetworkName $nested.Name -ResourceGroupName 'rg-nested' -Force