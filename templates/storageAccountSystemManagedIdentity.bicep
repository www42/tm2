param location string
param storageAccountNamePrefix string
var storageAccountName = '${storageAccountNamePrefix}${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

output storageAccountName string = storageAccountName
output systemManagedIdentityObjectId string = storageAccount.identity.principalId
