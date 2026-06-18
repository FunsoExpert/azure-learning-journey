// ============================================
// DAY 5: APPLICATION GATEWAY WITH WAF (COMPLETE)
// Author: FunsoExpert
// Date: June 18, 2026
// Description: Production-grade App Gateway with WAF v2
// Note: Conceptual only - student subscription has zero quota
// ============================================

// ============================================
// PARAMETERS
// ============================================
param location string = 'francecentral'
param environmentTag string = 'Learning'
param vnetAddressPrefix string = '10.0.0.0/16'
param subnetAddressPrefix string = '10.0.2.0/24'  // App Gateway needs dedicated subnet
param backendApiIp1 string = '10.0.1.4'
param backendApiIp2 string = '10.0.1.5'
param backendWebIp1 string = '10.0.1.6'
param backendWebIp2 string = '10.0.1.7'
param wafMode string = 'Prevention'  // Prevention or Detection
param appGatewayCapacity int = 2     // 2 instances for HA

// ============================================
// VARIABLES
// ============================================
var vnetName = 'vnet-appgw-${environmentTag}'
var subnetName = 'snet-appgw'
var publicIpName = 'pip-appgw-${environmentTag}'
var appGwName = 'agw-prod-${environmentTag}'

// ============================================
// RESOURCE 1: VIRTUAL NETWORK WITH SUBNET
// ============================================
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
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
// RESOURCE 2: PUBLIC IP (STANDARD, STATIC)
// ============================================
resource publicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: publicIpName
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
// RESOURCE 3: APPLICATION GATEWAY WITH WAF
// ============================================
resource applicationGateway 'Microsoft.Network/applicationGateways@2023-11-01' = {
  name: appGwName
  location: location
  properties: {
    // ------------------------------
    // SKU Configuration
    // ------------------------------
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: appGatewayCapacity
    }
    
    // ------------------------------
    // Gateway IP Configuration (REQUIRED)
    // ------------------------------
    gatewayIPConfigurations: [
      {
        name: 'app-gateway-ip-config'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
        }
      }
    ]
    
    // ------------------------------
    // SSL Certificates (REQUIRED for HTTPS)
    // ------------------------------
    sslCertificates: [
  {
    name: 'wildcard-cert'
    properties: {
      // CORRECT: Use keyvaultDns (not keyVaultReference)
      keyVaultSecretId: 'https://placeholder-keyvault.${environment().suffixes.keyvaultDns}/secrets/placeholder-cert'
    }
  }
]
    
    // ------------------------------
    // Frontend IP Configuration
    // ------------------------------
    frontendIPConfigurations: [
      {
        name: 'frontend-ip'
        properties: {
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
    
    // ------------------------------
    // Frontend Ports
    // ------------------------------
    frontendPorts: [
      {
        name: 'port-443'
        properties: {
          port: 443
        }
      }
    ]
    
    // ------------------------------
    // Backend Address Pools
    // ------------------------------
    backendAddressPools: [
      {
        name: 'pool-api'
        properties: {
          backendAddresses: [
            {
              ipAddress: backendApiIp1
            }
            {
              ipAddress: backendApiIp2
            }
          ]
        }
      }
      {
        name: 'pool-web'
        properties: {
          backendAddresses: [
            {
              ipAddress: backendWebIp1
            }
            {
              ipAddress: backendWebIp2
            }
          ]
        }
      }
    ]
    
    // ------------------------------
    // Backend HTTP Settings
    // ------------------------------
    backendHttpSettingsCollection: [
      {
        name: 'setting-api'
        properties: {
          port: 8080
          protocol: 'Http'
          requestTimeout: 30
          cookieBasedAffinity: 'Enabled'
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', appGwName, 'probe-api')
          }
        }
      }
      {
        name: 'setting-web'
        properties: {
          port: 80
          protocol: 'Http'
          requestTimeout: 30
          cookieBasedAffinity: 'Disabled'
        }
      }
    ]
    
    // ------------------------------
    // HTTP Listeners
    // ------------------------------
    httpListeners: [
      {
        name: 'listener-https'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGwName, 'frontend-ip')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGwName, 'port-443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', appGwName, 'wildcard-cert')
          }
          hostName: 'shop.com'
          requireServerNameIndication: true
        }
      }
    ]
    
    // ------------------------------
    // URL Path Maps (Path-based Routing)
    // ------------------------------
    urlPathMaps: [
      {
        name: 'pathmap-web'
        properties: {
          defaultBackendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGwName, 'pool-web')
          }
          defaultBackendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGwName, 'setting-web')
          }
          pathRules: [
            {
              name: 'path-rule-api'
              properties: {
                paths: [
                  '/api/*'
                ]
                backendAddressPool: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGwName, 'pool-api')
                }
                backendHttpSettings: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGwName, 'setting-api')
                }
              }
            }
          ]
        }
      }
    ]
    
    // ------------------------------
    // Request Routing Rules
    // ------------------------------
    requestRoutingRules: [
      {
        name: 'rule-api'
        properties: {
          ruleType: 'PathBasedRouting'
          priority: 100
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGwName, 'listener-https')
          }
          urlPathMap: {
            id: resourceId('Microsoft.Network/applicationGateways/urlPathMaps', appGwName, 'pathmap-web')
          }
        }
      }
    ]
    
    // ------------------------------
    // Health Probes
    // ------------------------------
    probes: [
      {
        name: 'probe-api'
        properties: {
          protocol: 'Http'
          path: '/health'
          interval: 30
          timeout: 10
          unhealthyThreshold: 3
          // pickHostNameFromBackendSettings is required for v2 SKU
          pickHostNameFromBackendSettings: true
        }
      }
    ]
    
    // ------------------------------
    // WAF Configuration (Web Application Firewall)
    // ------------------------------
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: wafMode
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.2'
      disabledRuleGroups: []  // Empty = enable all rules
      // You can disable specific rules here if needed:
      // disabledRuleGroups: [
      //   {
      //     ruleGroupName: 'SQLI'
      //     rules: [942100, 942200]
      //   }
      // ]
    }
  }
  tags: {
    CostCenter: 'IT-Dept'
    Environment: environmentTag
  }
}

// ============================================
// OUTPUTS
// ============================================
output applicationGatewayId string = applicationGateway.id
output publicIpAddress string = publicIp.properties.ipAddress
output wafStatus string = applicationGateway.properties.webApplicationFirewallConfiguration.firewallMode
output vnetId string = vnet.id
output appGatewayName string = applicationGateway.name
