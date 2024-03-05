// Dieses Key Vault enthält einen Key, mit dem Storage Accounts verschlüsselt werden (Customer Managed Keys CMK).
// https://learn.microsoft.com/en-us/azure/storage/common/customer-managed-keys-configure-new-account

param keyVaultName string
param location string
param tenantId string = '819ebf55-0973-4703-b006-581a48f25961'

var keyName = 'app-key'  // So heisst der Key in dem Applied Skill AZ-1003

// https://learn.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults
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
    enableSoftDelete: true
    softDeleteRetentionInDays: 7    // default: 90
  }
  resource key 'keys' = {
    name: keyName
    properties: {
      kty: 'RSA'
      keySize: 2048
      attributes: {
        enabled: true
        exportable: false
      }
    }
  }
}

output vaultUri string = keyVault.properties.vaultUri
output keyName string = keyName
