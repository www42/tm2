param location string = 'westeurope'
param name string = 'hp1'

resource hostpool 'Microsoft.DesktopVirtualization/hostpools@2025-11-01-preview' = {
  name: name
  location: location
  identity: {
    type: 'None'
  }
  properties: {
    allowRDPShortPathWithPrivateLink: 'Disabled'
    deploymentScope: 'Geographical'
    managedPrivateUDP: 'Default'
    directUDP: 'Default'
    publicUDP: 'Default'
    relayUDP: 'Default'
    publicNetworkAccess: 'Enabled'
    description: 'Created through the Azure Virtual Desktop extension'
    hostPoolType: 'Pooled'
    customRdpProperty: 'drivestoredirect:s:;usbdevicestoredirect:s:;redirectclipboard:i:0;redirectprinters:i:0;audiomode:i:0;videoplaybackmode:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;enablecredsspsupport:i:1;redirectwebauthn:i:1;use multimon:i:0;screen mode id:i:1;desktop size id:i:4;'
    maxSessionLimit: 20
    loadBalancerType: 'DepthFirst'
    validationEnvironment: false
    ring: 1
    vmTemplate: '{"namePrefix":"${name}-sh","hibernate":false,"osDiskType":"StandardSSD_LRS","diskSizeGB":128,"securityType":"Standard","secureBoot":false,"vTPM":false,"vmInfrastructureType":"Cloud","virtualProcessorCount":null,"memoryGB":null,"maximumMemoryGB":null,"minimumMemoryGB":null,"dynamicMemoryConfig":false}'
    preferredAppGroupType: 'Desktop'
    startVMOnConnect: true
  }
}

output hostpoolId string = hostpool.id
output hostpoolLoadBalancerType string = hostpool.properties.loadBalancerType
