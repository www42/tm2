param vmName string
param location string

resource windowsAgent 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = {
  name: '${vmName}/AzureMonitorWindowsAgent'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorWindowsAgent'
    typeHandlerVersion: '1.13'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
  }
}
