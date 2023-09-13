//
// Bastion Host 
//      * Standard SKU 
//      * existing Vnet is referenced by 'subnetId'
//

param location string
param name string
param subnetId string

resource bastion 'Microsoft.Network/bastionHosts@2022-07-01' = {
  location: location
  name: name
  sku: {
    name: 'Standard'
  }
  properties: {
    enableShareableLink: true
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          publicIPAddress: {
            id: bastionPip.id
          }
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}
resource bastionPip 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
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

output bastionName string = bastion.name
output bastionType string = bastion.sku.name
output pipBastion string = bastionPip.properties.ipAddress
