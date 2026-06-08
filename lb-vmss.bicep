param location string = 'francecentral'
param environmentTag string = 'Learning'
param vnetAddressPrefix string = '10.0.0.0/16'
param subnetAddressPrefix string = '10.0.1.0/24'
param lbFrontendPort int = 443
param lbBackendPort int = 443

var loadBalancerName = 'lb-prod-${environmentTag}'
var frontendConfigName = 'fe-prod'
var backendPoolName = 'bepool-prod'
var probeName = 'probe-http'

var loadBalancerId = resourceId(
  'Microsoft.Network/loadBalancers',
  loadBalancerName
)

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: 'vnet-prod-${environmentTag}'
  location: location
  tags: {
    CostCenter: 'IT-Dept'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'snet-web'
        properties: {
          addressPrefix: subnetAddressPrefix
        }
      }
    ]
  }
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: 'pip-prod-${environmentTag}'
  location: location
  sku: {
    name: 'Standard'
  }
  tags: {
    CostCenter: 'IT-Dept'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource loadBalancer 'Microsoft.Network/loadBalancers@2023-11-01' = {
  name: loadBalancerName
  location: location
  sku: {
    name: 'Standard'
  }
  tags: {
    CostCenter: 'IT-Dept'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: frontendConfigName
        properties: {
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]

    backendAddressPools: [
      {
        name: backendPoolName
        properties: {}
      }
    ]

    probes: [
      {
        name: probeName
        properties: {
          protocol: 'Http'
          port: 80
          requestPath: '/health'
          intervalInSeconds: 15
          numberOfProbes: 2
        }
      }
    ]

    loadBalancingRules: [
      {
        name: 'rule-https'
        properties: {
          frontendIPConfiguration: {
            id: '${loadBalancerId}/frontendIPConfigurations/${frontendConfigName}'
          }
          backendAddressPool: {
            id: '${loadBalancerId}/backendAddressPools/${backendPoolName}'
          }
          probe: {
            id: '${loadBalancerId}/probes/${probeName}'
          }
          protocol: 'Tcp'
          frontendPort: lbFrontendPort
          backendPort: lbBackendPort
          idleTimeoutInMinutes: 30
          enableTcpReset: true
          loadDistribution: 'SourceIPProtocol'
        }
      }
    ]
  }
}

output loadBalancerId string = loadBalancer.id
output publicIpAddress string = publicIp.properties.ipAddress
