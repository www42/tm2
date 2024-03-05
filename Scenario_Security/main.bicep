param location string
param keyVaultName string
param storageAccountNamePrefix string

module keyVault '../templates/keyVaultForCMK.bicep' = {
  name: 'Module-KeyVault'
  params: {
    keyVaultName: keyVaultName
    location: location
  }
}

module storage '../templates/storageAccountSystemManagedIdentity.bicep' = {
  name: 'Module-StorageAccount'
  params: {
    location: location
    storageAccountNamePrefix: storageAccountNamePrefix
  }
}
