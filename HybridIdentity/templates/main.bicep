param subnetId string
param automationAccountName string
param createAaJob bool
param domainName string
param domainAdminName string
@secure()
param domainAdminPassword string
param dcName string 
param dcIp string
param clientName string
param localAdminName string
@secure()
param localAdminPassword string
param clientVirtualMachineAdministratorLoginRoleAssigneeId string
param location string


module automationAccount './automationAccount.bicep' = {
  name: 'Module-AutomationAccount'
  params: {
    location: location
    aaName: automationAccountName
    createAaJob: createAaJob
    domainAdminName: domainAdminName
    domainAdminPassword: domainAdminPassword
    domainName: domainName
  }
}
module domainController './domainController.bicep' = {
  name: 'Module-DomainController'
  params: {
    location: location
    vmName: dcName
    vmIp: dcIp
    // Getting 'aaName' from the output of 'automationAccountDeployment' creates a dependency.
    // Effectivly module 'domainController' depends on module 'automationAccount'. This is needed obviously.
    aaName: automationAccount.outputs.aaName
    vmAdminUserName: domainAdminName
    vmAdminPassword: domainAdminPassword
    subnetId: subnetId
  }
}
module clientVm './windowsClient.bicep' = {
  name: 'Module-ClientVM'
  params: {
    location: location
    vmName: clientName
    vmAdminPassword: localAdminPassword
    vmAdminUserName: localAdminName
    subnetId: subnetId
    roleAsigneeId: clientVirtualMachineAdministratorLoginRoleAssigneeId
  }
}
module storageAccount './storageAccount.bicep' = {
  name: 'Module-StorageAccount'
  params: {
    location: location
  }
}
