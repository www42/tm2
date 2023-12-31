param automationAccountName string
param createAaJob bool
param domainName string
param domainAdminName string
@secure()
param domainAdminPassword string
param dcName string 
param dcComputerName string 
param dcSubnetId string
param dcIp string
param clientName string
param clientComputerName string
param clientSubnetId string
param localAdminName string
@secure()
param localAdminPassword string
param clientVirtualMachineAdministratorLoginRoleAssigneeId string
param location string


module automationAccount '../templates/automationAccount.bicep' = {
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
module domainController '../templates/domainController.bicep' = {
  name: 'Module-DomainController'
  params: {
    location: location
    vmName: dcName
    vmComputerName: dcComputerName
    vmIp: dcIp
    // Getting 'aaName' from the output of 'automationAccountDeployment' creates a dependency.
    // Effectivly module 'domainController' depends on module 'automationAccount'. This is needed obviously.
    aaName: automationAccount.outputs.aaName
    vmAdminUserName: domainAdminName
    vmAdminPassword: domainAdminPassword
    subnetId: dcSubnetId
  }
}
module clientVm '../templates/windowsClient.bicep' = {
  name: 'Module-ClientVM'
  params: {
    location: location
    vmName: clientName
    vmComputerName: clientComputerName
    vmAdminPassword: localAdminPassword
    vmAdminUserName: localAdminName
    subnetId: clientSubnetId
    roleAsigneeId: clientVirtualMachineAdministratorLoginRoleAssigneeId
  }
}
module storageAccount '../templates/storageAccount.bicep' = {
  name: 'Module-StorageAccount'
  params: {
    location: location
  }
}
