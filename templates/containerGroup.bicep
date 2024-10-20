param location string 
param containerGroupName string
param containerName string
param acrName string
param acrUsername string
@secure()
param acrPassword string
param imageName string
param cpuCores int = 1
param memoryInGb object = {
  float : '1.5'
}
param containerPort int
param containerGroupPort int
param dnsNameLabel string

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: containerGroupName
  location: location
  properties: {
    sku: 'Standard'
    osType: 'Linux'
    restartPolicy: 'OnFailure'
    ipAddress: {
      type: 'Public'
      dnsNameLabel: dnsNameLabel
      ports: [
        {
          protocol: 'TCP'
          port: containerGroupPort
        }
      ]
    }
    imageRegistryCredentials: [
      {
        server: '${acrName}.azurecr.io'
        username: acrUsername
        password: acrPassword
      }
    ]
    containers: [
      {
        name: containerName
        properties: {
          image: '${acrName}.azurecr.io/${imageName}'
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb.float
            }
          }
          ports: [
            {
              port: containerPort
            }
          ]
        }
      }
    ]
  }
}


output containerGroupName string = containerGroup.name
output containerGroupIp string = containerGroup.properties.ipAddress.ip
