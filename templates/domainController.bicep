//
// Virtual machine with Windows Server configured as domain controller
//
param location string
param vmSize string = 'Standard_D2s_v3'
param vmAdminUserName string
@secure()
param vmAdminPassword string
param vmName string = 'DC1'
param vmIp string 
param vmNodeConfigurationName string = 'newForest.localhost'
param aaName string
param subnetId string


var vmImagePublisher = 'MicrosoftWindowsServer'
var vmImageOffer = 'WindowsServer'
var vmImageSku = '2022-datacenter-azure-edition'
var vmImageVersion = 'latest'
var vmOsDiskName = '${vmName}-Disk'
var vmComputerName = vmName
var vmNicName = '${vmName}-Nic'
var vmNsgName = '${vmName}-Nsg'

var customScriptName = 'configure-labVm.ps1'
var customScriptUri = 'https://raw.githubusercontent.com/www42/TrainyMotion/master/scripts/${customScriptName}'



resource dc 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: vmName
  location: location
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
resource dcNic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
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
          privateIPAllocationMethod: 'Static'
          privateIPAddress: vmIp
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}
resource dcNsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: vmNsgName
  location: location
}
resource aa 'Microsoft.Automation/automationAccounts@2022-08-08' existing = {
  name: aaName
}
resource dscExtension 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
  parent: dc
  name: 'Dsc'
  location: location
  // dscExtension results in a vm reboot which aborts script execution
  // dscExtension must wait until scriptExtension is ready
  dependsOn: [
    scriptExtension
  ]
  properties: {
    type: 'DSC'
    publisher: 'Microsoft.Powershell'
    typeHandlerVersion: '2.77'
    autoUpgradeMinorVersion: true
    protectedSettings: {
      Items: {
        registrationKeyPrivate: aa.listKeys().keys[0].Value
      }
    }
    settings: {
      Properties: [
        {
          Name: 'RegistrationKey'
          Value: {
            UserName: 'PLACEHOLDER_DONOTUSE'
            Password: 'PrivateSettingsRef:registrationKeyPrivate'
          }
          TypeName: 'System.Management.Automation.PSCredential'
        }
        {
          Name: 'RegistrationUrl'
          Value: aa.properties.RegistrationUrl
          TypeName: 'System.String'
        }
        {
          Name: 'NodeConfigurationName'
          Value: vmNodeConfigurationName
          TypeName: 'System.String'
        }
        {
          Name: 'ConfigurationMode'
          Value: 'ApplyandAutoCorrect'
          TypeName: 'System.String'
        }
        {
          Name: 'RebootNodeIfNeeded'
          Value: true
          TypeName: 'System.Boolean'
        }
        {
          Name: 'ActionAfterReboot'
          Value: 'ContinueConfiguration'
          TypeName: 'System.String'
        }
      ]
    }
  }
}
resource scriptExtension 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = {
  parent: dc
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

output dcId string = dc.id
