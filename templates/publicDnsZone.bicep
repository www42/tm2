param location string
param publicDnsPrefix string

var publicDnsZoneName = '${publicDnsPrefix}.az.training'

resource publicDnsZone 'Microsoft.Network/dnsZones@2023-07-01-preview' = {
  name: publicDnsZoneName
  location: 'global'
  properties: {
    zoneType: 'Public'    
  }
}

resource script 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'dnsZoneScript'
  location: location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '12.3'
    timeout: 'PT10M'
    retentionInterval: 'PT1H'
    scriptContent: '''
      param (
        [string]$Name
      )
      Write-Output "Created DNS Zone $Name"
    '''
    arguments: '-Name "${publicDnsZoneName}"'
    cleanupPreference: 'OnExpiration'
  }
}

output publicDnsZoneName string = publicDnsZoneName
output nameServers array = publicDnsZone.properties.nameServers
