param location string 
param _artifactsLocation string
@secure()
param _artifactsLocationSasToken string = ''
param virtualNetworkName string 
param HostAdminUsername string
@secure()
param HostAdminPassword string


module hypervHost './hypervHost.bicep' = {
  name: 'Module-HyperVHost'
  params: {
    location: location
    _artifactsLocation: _artifactsLocation
    _artifactsLocationSasToken: _artifactsLocationSasToken
    virtualNetworkName: virtualNetworkName
    HostAdminUsername: HostAdminUsername
    HostAdminPassword: HostAdminPassword
  }
}
