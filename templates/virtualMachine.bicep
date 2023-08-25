param location string
param subnetId string
param vmName string
param vmSize string = 'Standard_D2s_v3'
param systemAssignedManagedIdentity bool = false
param vmAdminUserName string
@secure()
param vmAdminPassword string


var vmImagePublisher = 'MicrosoftWindowsServer'
var vmImageOffer = 'WindowsServer'
var vmImageSku = '2022-datacenter-azure-edition'
var vmImageVersion = 'latest'
var vmComputerName = vmName
var vmOsDiskName = '${vmName}-Disk'
var vmNicName = '${vmName}-Nic'
var vmNsgName = '${vmName}-Nsg'


resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
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
    networkProfile:{
      networkInterfaces: [
        {
          id: dcNic.id
        }
      ]
    }
  }
}
resource dcNic 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: vmNicName
  location: location
  properties: {
    networkSecurityGroup: {
      id: dcNsg.id
    }
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}
resource dcNsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: vmNsgName
  location: location
}

output vmId string = vm.id
output managedIdentityObjectId string = vm.identity.principalId
