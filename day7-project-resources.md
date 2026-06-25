# Resource List: Resilient E-Commerce

## Compute
| Resource | SKU/Tier | Purpose |
|----------|----------|---------|
| App Service Plan | P1v2 (Premium V2) | Frontend + API hosting |
| App Service (Frontend) | Linux, Node.js 18 | Static website + SSR |
| App Service (API) | Linux, Node.js 18 | REST API backend |

## Networking
| Resource | Configuration | Purpose |
|----------|---------------|---------|
| Application Gateway | WAF_v2 (2 instances) | Ingress, WAF, SSL termination |
| Azure Firewall | Standard | Network/Application rules |
| VNet (Hub) | 10.0.0.0/16 | Central security |
| VNet (Spoke) | 10.1.0.0/16 | Workloads |
| NSG (Spoke) | Allow App Gateway IP only | Network security |
| Public IP (App Gateway) | Standard, Static | Frontend entry |
| Public IP (Firewall) | Standard, Static | Outbound traffic |

## Data
| Resource | SKU/Tier | Purpose |
|----------|----------|---------|
| Azure SQL Database | Serverless (GP) | Orders, customers, products |
| Storage Account | Standard (GRS) | Product images, logs, backups |
| Key Vault | Standard | Secrets, certificates, keys |

## Monitoring
| Resource | SKU/Tier | Purpose |
|----------|----------|---------|
| Application Insights | Basic | APM, performance monitoring |
| Log Analytics Workspace | PAYG | Centralized logging |
| Azure Monitor Alerts | Standard | Proactive notifications |

## Security
| Resource | Configuration | Purpose |
|----------|---------------|---------|
| WAF Policy | OWASP 3.2 (Prevention) | Block attacks |
| DDoS Protection | Standard (on VNet) | DDoS mitigation |
| RBAC Roles | Least privilege | Access control |
| Managed Identity | System-assigned | App → Key Vault auth |

## Cost Estimate (Monthly)
| Service | Estimated Cost |
|---------|----------------|
| App Service (P1v2) | ~$150 |
| App Gateway (WAF_v2) | ~$200 |
| Azure SQL Database | ~$50 |
| Storage Account | ~$10 |
| Key Vault | ~$5 |
| Azure Firewall | ~$100 |
| DDoS Standard | ~$100 |
| **Total** | **~$615/month** |