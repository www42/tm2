//
// Virtual machine with Windows 11 
//    * System managed identity
//    * Extention 'AADLoginForWindows' for logon as a tenant user (Because of this extension vm is Azure AD joined device.)
//    * Custom script extention
//        to get Kerberos tickets from AzureAD during logon
//        to disable NLA (Network Level Authentication) for RDP connection
//    * Role assignment Ludwig Boltzmann --> Virtual Machine Administrator Login
//
param location string
param vmName string
param vmSize string = 'Standard_D2s_v3'
param vmAdminUserName string
@secure()
param vmAdminPassword string
param subnetId string
param roleAsigneeId string


var vmImagePublisher = 'MicrosoftWindowsDesktop'
var vmImageOffer = 'windows-11'
var vmImageSku = 'win11-22h2-ent'
var vmImageVersion = 'latest'
var vmOsDiskName = '${vmName}-Disk'
var vmComputerName = vmName
var vmNicName = '${vmName}-Nic'
var vmNsgName = '${vmName}-Nsg'
var vmPipName = '${vmName}-Pip'
@description('role "Virtual Machine Administrator Login"')
var roleId = '1c0163c0-47e6-4577-8991-ea5c82e286e4'


var customScriptName = 'Enable-CloudKerberosTicketRetrieval.ps1'
var customScriptUri = 'https://raw.githubusercontent.com/www42/TrainyMotion/master/scripts/${customScriptName}'



resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vmName
  location: location
  identity: {
    type: 'SystemAssigned'
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
  resource aadLoginExtion 'extensions@2023-03-01' = {
    name: 'AADLoginForWindows'
    location: location
    properties: {
      publisher: 'Microsoft.Azure.ActiveDirectory'
      type: 'AADLoginForWindows'
      typeHandlerVersion: '1.0'
      autoUpgradeMinorVersion: true
      
    }
  }
  resource dscExtension 'extensions@2023-03-01' = {
    name: 'customScript'
    location: location
    properties: {
      type: 'CustomScriptExtension'
      publisher: 'Microsoft.Compute'
      typeHandlerVersion: '1.10'
      autoUpgradeMinorVersion: true
      settings: {
        fileUris: [
          customScriptUri
        ]
        commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File ${customScriptName}'  
      }
    }
  }
}
resource vmNic 'Microsoft.Network/networkInterfaces@2022-11-01' = {
  name: vmNicName
  location: location
  properties: {
    networkSecurityGroup: {
      id: vmNsg.id
    }
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: vmPip.id
          }
        }
      }
    ]
  }
}
resource vmNsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: vmNsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-RDP-Inbound'
        properties: {
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
          access: 'Allow'
          priority: 200
        }
      }
    ]
  }
}
resource vmPip 'Microsoft.Network/publicIPAddresses@2022-11-01' = {
  name: vmPipName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
  }
}
// Role assignment is strange
//     https://4bes.nl/2022/04/24/create-role-assignments-for-different-scopes-with-bicep/
//     https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/scenarios-rbac
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: roleId
  scope: resourceGroup()
}
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(vm.id, roleId, roleAsigneeId)
  scope: vm
  properties: {
    principalId: roleAsigneeId
    principalType: 'User'
    roleDefinitionId: roleDefinition.id
  }
}

output managedIdentity string = vm.identity.principalId
output roleDefinitionId string = roleDefinition.id
