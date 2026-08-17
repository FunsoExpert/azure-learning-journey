# DAY 7: WEEK 1 PROJECT - RESILIENT E-COMMERCE ARCHITECTURE

## Architecture Overview

### 1. Ingress (Entry Point)
- Application Gateway (WAF_v2) with SSL termination
- Path-based routing: /api/* → API backend, /* → Web frontend
- WAF in Prevention mode (OWASP 3.2)

### 2. Compute (Application Layer)
- **Frontend:** App Service (Linux, Node.js) - scales automatically
- **API:** App Service (Linux, Node.js) - scales separately
- **Why App Service?** No VM management, built-in scale, free tier for learning

### 3. Data Tier
- **Relational:** Azure SQL Database (serverless)
- **Storage:** Azure Storage Account (Blob Storage for images)
- **Secrets:** Azure Key Vault (connection strings, certs, API keys)

### 4. Network Security
- **Hub-Spoke Architecture:** Firewall in Hub VNet, workloads in Spoke VNets
- **NSGs:** Per-subnet (allow only App Gateway IP to App Service)
- **DDoS Protection:** Standard (production only)

### 5. Monitoring
- Application Insights (performance monitoring)
- Log Analytics Workspace (centralized logs)
- Alerts: CPU > 80%, 5xx errors, Health probe failures

### 6. Resilience
- **Availability Zones:** Deploy across 3 zones
- **Health Probes:** App Gateway probes on /health
- **Backup:** Daily database backups, geo-redundant storage
- **Autoscale:** CPU-based (min 2, max 10 instances)

### 7. Governance
- **Tags:** CostCenter, Environment, Application
- **Policies:** Allowed regions, Required tags (from Day 3)
- **RBAC:** Least privilege (Reader, Contributor, Owner scoped)

## Data Flow

1. Client → Application Gateway (SSL)
2. App Gateway → Backend App Service (HTTP)
3. App Service → Azure SQL Database
4. App Service → Storage Account (images)
5. App Service → Key Vault (secrets)
6. Logs → Log Analytics Workspace

## Failure Scenarios & Mitigations

| Failure Scenario | Mitigation |
|------------------|------------|
| VM/App Service crashes | Health probe removes unhealthy instances |
| Database failure | Geo-redundant backup, failover |
| DDoS attack | DDoS Standard, WAF rules |
| SSL certificate expiry | Key Vault auto-renewal |
| Region outage | Multi-region deployment (future) |