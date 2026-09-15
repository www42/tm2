// Deployt einen Twingate Connector als Azure Container Instance mit VNet-Integration.
// Voraussetzung: Vorhandenes VNet mit einem Subnetz, das an
// Microsoft.ContainerInstance/containerGroups delegiert ist.

@description('Azure Region, muss mit der Region des vorhandenen VNets übereinstimmen')
param location string

@description('Name des vorhandenen VNets')
param vnetName string

@description('Name des vorhandenen, delegierten Subnetzes für die Container Instance')
param subnetName string

@description('Name der Container Instance')
param containerName string = 'twingate-connector-azure'

@description('Twingate Network, z.B. yellowlion9566')
param twingateNetwork string

@secure()
@description('Twingate Connector Access Token aus der Admin Console')
param twingateAccessToken string

@secure()
@description('Twingate Connector Refresh Token aus der Admin Console')
param twingateRefreshToken string

@description('Twingate Connector Image')
param connectorImage string

@description('Login Server der Azure Container Registry ACR, von der das Image gezogen wird')
param arcLoginServer string

@description('ACR Admin-Username (aus: az acr credential show)')
param acrUsername string

@secure()
@description('ACR Admin-Passwort (aus: az acr credential show)')
param acrPassword string

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: vnet
  name: subnetName
}

resource container 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: containerName
  location: location
  properties: {
    osType: 'Linux'
    restartPolicy: 'Always'
    sku: 'Standard'
    imageRegistryCredentials: [
      {
        server: arcLoginServer
        username: acrUsername
        password: acrPassword
      }
    ]
    containers: [
      {
        name: 'connector'
        properties: {
          image: connectorImage
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 1
            }
          }
          environmentVariables: [
            {
              name: 'TWINGATE_NETWORK'
              value: twingateNetwork
            }
            {
              name: 'TWINGATE_ACCESS_TOKEN'
              secureValue: twingateAccessToken
            }
            {
              name: 'TWINGATE_REFRESH_TOKEN'
              secureValue: twingateRefreshToken
            }
            {
              name: 'TWINGATE_LABEL_HOSTNAME'
              value: containerName
            }
            {
              name: 'TWINGATE_DEPLOYED_BY'
              value: 'Microsoft.ContainerInstance'
            }
          ]
        }
      }
    ]
    subnetIds: [
      {
        id: subnet.id
      }
    ]
  }
}

output containerId string = container.id
