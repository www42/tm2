param location string
param keyVaultName string
param storageAccountNamePrefix string

module keyVault '../templates/keyVaultAccessPolicy.bicep' = {
  name: 'Module-KeyVault'
  params: {
    keyVaultName: keyVaultName
    location: location
  }
}

module storage '../templates/storageAccountMi.bicep' = {
  name: 'Module-StorageAccount'
  params: {
    location: location
    storageAccountNamePrefix: storageAccountNamePrefix
  }
}
