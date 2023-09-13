param location string
var storageAccountName = 'hybridkrb${uniqueString(resourceGroup().id)}'
var fileShareName = '${storageAccountName}/default/docs'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}
resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-09-01' = {
  name: fileShareName
  dependsOn: [
    storageAccount
  ]
}
output storageAccountName string = storageAccountName
output fileShareName string = fileShareName
