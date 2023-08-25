@minLength(4)
@maxLength(63)
param name string = 'log-workspace1'
param location string 

resource law 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: name
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

output logAnalyticsWorkspaceId string = law.id
