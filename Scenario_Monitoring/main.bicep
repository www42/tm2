param location string 
param subnetId string
param systemAssignedManagedIdentity bool
param vmName string
param vmName2 string
param vmComputerName string
param vmComputerName2 string
param vmAdminUserName string
@secure()
param vmAdminPassword string
param logAnalyticsWorkspaceName string
param dcrName string
param deployLoadbalancer bool
param loadbalancerName string

module virtualMachine '../templates/virtualMachine.bicep' = {
  name: 'Module-VirtualMachine'
  params: {
    location: location
    subnetId: subnetId
    vmName: vmName
    vmComputerName: vmComputerName
    systemAssignedManagedIdentity: systemAssignedManagedIdentity
    vmAdminUserName: vmAdminUserName
    vmAdminPassword: vmAdminPassword
  }
}
module azureMonitoringAgent '../templates/azureMonitoringAgent.bicep' = {
  name: 'Module-AzureMonitoringAgent'
  dependsOn: [
    virtualMachine
  ]
  params: {
    location: location
    vmName: vmName
  }
}
module logAnalyticsWorkspace '../templates/logAnalyticsWorkspace.bicep' = {
  name: 'Module-LogAnalyticsWorkspace'
  params: {
    name: logAnalyticsWorkspaceName
    location: location
  }
}
module dataCollectionRule '../templates/dataCollectionRule.bicep' = {
  name: 'Module-DataCollectionRule'
  params: {
    name: dcrName
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.logAnalyticsWorkspaceId
  }
}
module dataCollectionRuleAssociation '../templates/dataCollectionRuleAssociation.bicep' = {
  name: 'Module-DataCollectionRuleAssociation'
  params: {
    vmName: vmName
    dcrId: dataCollectionRule.outputs.dcrId
  }
}
module virtualMachine2 '../templates/virtualMachine.bicep' = if (deployLoadbalancer) {
  name: 'Module-VirtualMachine2'
  params: {
    location: location
    subnetId: subnetId
    vmName: vmName2
    vmComputerName: vmComputerName2
    systemAssignedManagedIdentity: systemAssignedManagedIdentity
    vmAdminUserName: vmAdminUserName
    vmAdminPassword: vmAdminPassword
  }
}
module loadbalancer '../templates/loadbalancerStandard.bicep' = if (deployLoadbalancer) {
  name: 'Module-LoadBalancer'
  params: {
    location: location
    name: loadbalancerName
  }
}
