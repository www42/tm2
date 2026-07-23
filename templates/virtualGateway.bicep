//
//  Virtual Gateway
//      * Generation 1 VpnGw1
//      * Route-based
//      * Address prefix for tunnels 192.168.255.0/24
//

param location string
param name string
param subnetId string
param rootCertificateName string
param rootCertificateData string

/* siehe unten das Problem mit der AZ-SKU
resource gateway 'Microsoft.Network/virtualNetworkGateways@2022-09-01' = {
*/
resource gateway 'Microsoft.Network/virtualNetworkGateways@2023-11-01' = {
  name: name
  location: location
  properties: {
    gatewayType: 'Vpn'
    /* die alten SKUs ohne 'AZ' lassen sich nicht mehr deployen seit dem 01.11.2025
    vpnGatewayGeneration: 'Generation1'
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    */
    vpnGatewayGeneration: 'Generation2'
    sku: {
      name: 'VpnGw1AZ'
      tier: 'VpnGw1AZ'
    }
    activeActive: false
    vpnType: 'RouteBased'
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          publicIPAddress: {
            id: pip.id
          }
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    vpnClientConfiguration: {
      vpnClientAddressPool: {
        addressPrefixes: [
          '192.168.255.0/24'
        ]
      }
      vpnClientProtocols: [
        'IkeV2'
        'SSTP'
      ]
      vpnClientRootCertificates: [
        {
          name: rootCertificateName
          properties: {
            publicCertData: rootCertificateData
          }
        }
      ]
    }
  }
}
/*
resource pip 'Microsoft.Network/publicIPAddresses@2022-09-01' = {
  name: 'pip-${name}'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}
*/
resource pip 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: 'pip-${name}'
  location: location
  sku: {
    name: 'Standard'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

output gatewayName string = gateway.name
output gatewayType string = gateway.properties.sku.name
output gatewayPip string = pip.properties.ipAddress
