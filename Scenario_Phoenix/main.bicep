param location string
param publicDnsPrefix string

module publicDnSZone '../templates/publicDnsZone.bicep' = {
  name: 'Module-PublicDnsZone'
  params: {
    location: location
    publicDnsPrefix: publicDnsPrefix
  }
}
