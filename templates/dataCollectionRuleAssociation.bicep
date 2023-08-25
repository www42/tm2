param vmName string
param dcrId string

var dcrAssociationName = '${vmName}-dcrAssociation'

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' existing = {
  name: vmName
}

resource association 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = {
  name: dcrAssociationName
  scope: vm
  properties: {
    dataCollectionRuleId: dcrId
  }
}
