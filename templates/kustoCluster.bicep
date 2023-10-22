@minLength(4)
@maxLength(22)
@description('Name of the Azure Data Explorer Cluster. Use only lowercase letters and numbers.')
param name string
param location string

resource cluster 'Microsoft.Kusto/clusters@2023-08-15' = {
  name: name
  location: location
  sku: {
    name: 'Dev(No SLA)_Standard_D11_v2'
    tier: 'Basic'
  }
  identity: {
    type: 'SystemAssigned'
  }
}
