// ============================================
// DAY 8: VNET PEERING
// Author: FunsoExpert
// Date: June 25, 2026
// ============================================

param location string = 'francecentral'
param environmentTag string = 'Learning'

// --------------------------------------------
// VNET 1: EAST (app)
// --------------------------------------------
resource vnet1 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: 'vnet-east-${environmentTag}'
  location: location
  properties: {
    addressSpace: { addressPrefixes: ['10.0.0.0/16'] }
    subnets: [
      { name: 'snet-app', properties: { addressPrefix: '10.0.1.0/24' } }
    ]
  }
//tags: { CostCenter: 'IT-Dept' }
}

// --------------------------------------------
// VNET 2: WEST (db)
// --------------------------------------------
resource vnet2 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: 'vnet-west-${environmentTag}'
  location: location
  properties: {
    addressSpace: { addressPrefixes: ['10.1.0.0/16'] }
    subnets: [
      { name: 'snet-db', properties: { addressPrefix: '10.1.1.0/24' } }
    ]
  }
  //tags: { CostCenter: 'IT-Dept' }
}

// --------------------------------------------
// PEERING: VNET1 → VNET2
// --------------------------------------------
resource vnet1ToVnet2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-11-01' = {
  name: 'vnet1-to-vnet2'
  parent: vnet1
  properties: {
    remoteVirtualNetwork: { id: vnet2.id }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

// --------------------------------------------
// PEERING: VNET2 → VNET1
// --------------------------------------------
resource vnet2ToVnet1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-11-01' = {
  name: 'vnet2-to-vnet1'
  parent: vnet2
  properties: {
    remoteVirtualNetwork: { id: vnet1.id }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

// --------------------------------------------
// OUTPUTS
// --------------------------------------------
output vnet1Id string = vnet1.id
output vnet2Id string = vnet2.id
