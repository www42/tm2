//
// Virtual Machine 
//   - Windows Server 2022 Datacenter Azure Edition
//   - Static private IP address
//   - No public IP address (use Bastion Host to connect)
//   - Standard NSG on network interface (only default rules)
//
param location string = resourceGroup().location
param vmName string = 'vm-phoenix-server1'
param vmComputerName string = 'server1'
param vmSize string = 'Standard_D2s_v3'
param vmAdminUserName string = 'localadmin'
@secure()
param vmAdminPassword string
param systemAssignedManagedIdentity bool = false
param subnetId string = '/subscriptions/7f117653-b103-4699-82b0-a70fc3f25568/resourceGroups/rg-phoenix/providers/Microsoft.Network/virtualNetworks/vnet-phoenix/subnets/Servers'
param privateIpAddress string = '10.5.0.10'
param privateIPAddressPrefixLength int = 24
// private IP address noch

var vmImagePublisher = 'MicrosoftWindowsServer'
var vmImageOffer = 'WindowsServer'
var vmImageSku = '2022-datacenter-azure-edition'
var vmImageVersion = 'latest'
var vmOsDiskName = 'disk-${vmName}'
var vmNicName = 'nic-${vmName}'
var vmNsgName = 'nsg-${vmName}'

resource vm 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: vmName
  location: location
  identity: {
    type: systemAssignedManagedIdentity ? 'SystemAssigned' : 'None'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: vmImagePublisher
        offer: vmImageOffer
        sku: vmImageSku
        version: vmImageVersion
      }
      osDisk: {
        name: vmOsDiskName
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: vmComputerName
      adminUsername: vmAdminUserName
      adminPassword: vmAdminPassword
      windowsConfiguration: {
        timeZone: 'W. Europe Standard Time'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNic.id
        }
      ]
    }    
  }
}
resource vmNic 'Microsoft.Network/networkInterfaces@2024-01-01' = {
  name: vmNicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddressVersion: 'IPv4'
          privateIPAddress: privateIpAddress
          privateIPAddressPrefixLength: privateIPAddressPrefixLength
          subnet: {
            id: subnetId
          }
          publicIPAddress: null
        }
      }
    ]
  }
}
resource vmNsg 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: vmNsgName
  location: location
}

output vmName string = vm.name
output vmAdminUserName string = vm.properties.osProfile.adminUsername
