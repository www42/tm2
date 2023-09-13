//
// Virtual network with one subnet. 
//
param location string
param vnetName string
param vnetAddressSpace string = '10.1.0.0/16'
param vnetSubnet0Name string = 'default'
param vnetSubnet0AddressPrefix string = '10.1.0.0/24'

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  location: location
  name: vnetName
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
    subnets: [
      {
        name: vnetSubnet0Name
        properties: {
          addressPrefix: vnetSubnet0AddressPrefix
        }
      }
    ]
  }
}

output vnet object = vnet
output vnetName string = vnet.name
output vnetId string = vnet.id
