// https://learn.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults

param keyVaultName string
param location string
param tenantId string = '819ebf55-0973-4703-b006-581a48f25961'

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    accessPolicies: [
      {
        objectId: '05dccaf9-f4d8-4740-b517-d4daeccf5582'  // Paul Drude
        permissions: {
          certificates: [
            'all'
          ]
          keys: [
            'all'
          ]
          secrets: [
            'all'
          ]
          storage: [
            'all'
          ]
        }
        tenantId: tenantId
      }
    ]
  }
}

output vaultUri string = keyVault.properties.vaultUri
