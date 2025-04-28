//
// Virtual machine Windows Server
//    * Windows Server 2022 Datacenter Azure Edition
//    * Custom Script Extension to install IIS
//

param location string
param vmName string
param vmComputerName string
param vmSize string = 'Standard_D2s_v3'
param vmAdminUserName string
@secure()
param vmAdminPassword string
param systemAssignedManagedIdentity bool = false
param subnetId string


var vmImagePublisher = 'MicrosoftWindowsServer'
var vmImageOffer = 'WindowsServer'
var vmImageSku = '2022-datacenter-azure-edition'
var vmImageVersion = 'latest'
var vmOsDiskName = 'disk-${vmName}'
var vmNicName = 'nic-${vmName}'
var vmNsgName = 'nsg-${vmName}'


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
resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = {
  name: 'IISInstallScript'
  location: location
  parent: vm
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      commandToExecute: 'powershell.exe Install-WindowsFeature -name Web-Server -IncludeManagementTools && powershell.exe remove-item \'C:\\inetpub\\wwwroot\\iisstart.htm\' && powershell.exe Add-Content -Path \'C:\\inetpub\\wwwroot\\iisstart.htm\' -Value $(\'Hello World from \' + $env:computername)'
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
  properties: {
    securityRules: [
      {
        name: 'Allow-HTTP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 400
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow-HTTPS'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 410
          direction: 'Inbound'
        }
      }
    ]
  }
}

output vmId string = vm.id
output managedIdentityObjectId string = vm.identity.principalId
