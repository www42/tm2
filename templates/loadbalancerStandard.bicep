//
// Azure Load Balancer
//    * Standard SKU
//    * Public IP address
//    * Load balancing rule for TCP traffic on port 80
//

param location string
param name string


resource loadbalancer 'Microsoft.Network/loadBalancers@2024-05-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'FrontendConfig'
        properties: {
          publicIPAddress: {
            id: loadbalancerPip.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'BackendPool1'
      }
    ]
    probes: [
      {
        name: 'HealthProbe'
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
    loadBalancingRules: [
      {
        name: 'LoadBalancingRule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', name, 'FrontendConfig')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', name, 'BackendPool1')
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', name, 'HealthProbe')
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          idleTimeoutInMinutes: 4
          enableFloatingIP: false
        }
      }
    ]
  }
}
resource loadbalancerPip 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
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


output pipLoadbalancer string = loadbalancerPip.properties.ipAddress
