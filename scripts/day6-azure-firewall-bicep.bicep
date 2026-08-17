// ============================================
// DAY 6: AZURE FIREWALL + HUB-SPOKE NETWORK
// Author: FunsoExpert
// Date: June 24, 2026
// Description: Hub-spoke architecture with Azure Firewall
// Note: Fully corrected for clean compilation
// ============================================

// ============================================
// PARAMETERS
// ============================================
param location string = 'francecentral' 
param environmentTag string = 'Learning' 
param hubAddressPrefix string = '10.0.0.0/16'
param spokeAddressPrefix string = '10.1.0.0/16' 
param firewallSubnetAddressPrefix string = '10.0.1.0/26'  // MUST be /26 for Azure Firewall

// ============================================
// VARIABLES
// ============================================
var hubVnetName = 'vnet-hub-${environmentTag}'
var spokeVnetName = 'vnet-spoke-${environmentTag}'
var firewallSubnetName = 'AzureFirewallSubnet'  // MUST be exactly this name
var firewallPublicIpName = 'pip-firewall-${environmentTag}'
var firewallName = 'afw-hub-${environmentTag}'

// ============================================
// RESOURCE 1: HUB VNET (contains firewall)
// ============================================
resource hubVnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: hubVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        hubAddressPrefix
      ]
    }
    subnets: [
      {
        name: firewallSubnetName
        properties: {
          addressPrefix: firewallSubnetAddressPrefix
        }
      }
    ]
  }
  tags: {
    CostCenter: 'IT-Dept'
    Environment: environmentTag
  }
}

// ============================================
// RESOURCE 2: SPOKE VNET (contains workloads)
// ============================================
resource spokeVnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: spokeVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        spokeAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'snet-app'
        properties: {
          addressPrefix: '10.1.1.0/24'
        }
      }
    ]
  }
  tags: {
    CostCenter: 'IT-Dept'
    Environment: environmentTag
  }
}

// ============================================
// RESOURCE 3: VNET PEERING (Hub → Spoke)
// ============================================
resource hubToSpokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-11-01' = {
  name: 'hub-to-spoke'
  parent: hubVnet   // FIXED: Changed scope to parent
  properties: {
    remoteVirtualNetwork: {
      id: spokeVnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true   // Required for firewall routing
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

// ============================================
// RESOURCE 4: VNET PEERING (Spoke → Hub)
// ============================================
resource spokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-11-01' = {
  name: 'spoke-to-hub'
  parent: spokeVnet  // FIXED: Changed scope to parent
  properties: {
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true   // Required for firewall routing
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

// ============================================
// RESOURCE 5: PUBLIC IP FOR FIREWALL
// ============================================
resource firewallPublicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: firewallPublicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  tags: {
    CostCenter: 'IT-Dept'
    Environment: environmentTag
  }
}

// ============================================
// RESOURCE 6: AZURE FIREWALL
// ============================================
resource firewall 'Microsoft.Network/azureFirewalls@2023-11-01' = {
  name: firewallName
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          subnet: {
            id: hubVnet.properties.subnets[0].id
          }
          publicIPAddress: {
            id: firewallPublicIp.id
          }
        }
      }
    ]
  }
  tags: {
    CostCenter: 'IT-Dept'
    Environment: environmentTag
  }
}

// ============================================
// OUTPUTS
// ============================================
output hubVnetId string = hubVnet.id
output spokeVnetId string = spokeVnet.id
output firewallPublicIp string = firewallPublicIp.properties.ipAddress
output firewallId string = firewall.id
