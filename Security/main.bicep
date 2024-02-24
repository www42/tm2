param location string
param storageAccountNamePrefix string

module storage '../templates/storageAccountMi.bicep' = {
  name: 'Module-StorageAccount'
  params: {
    location: location
    storageAccountNamePrefix: storageAccountNamePrefix
  }
}
