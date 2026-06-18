# DAY 5: APPLICATION GATEWAY & WAF

**Date:** June 18, 2026  
**Time Spent:** 4 hours (spread across multiple sessions)  
**Status:** ✅ COMPLETE  
**Azure Region:** francecentral (conceptual only - no deployment)  
**Subscription:** Student (zero quota for Application Gateway)

---

## LEARNING OBJECTIVES (AZ-104 DOMAIN 4)

- [x] Understand Application Gateway architecture and components
- [x] Configure path-based routing (`/api/*` vs `/*`)
- [x] Configure SSL/TLS termination with certificates
- [x] Understand WAF (Web Application Firewall) and OWASP rules
- [x] Create production-grade Bicep template
- [x] Fix Bicep linter warnings and errors
- [x] Document interview-ready answers

---

## WHAT I LEARNED

### 1. Application Gateway vs Load Balancer

| Feature | Load Balancer (Day 4) | Application Gateway (Day 5) |
|---------|----------------------|----------------------------|
| **Layer** | Layer 4 (TCP/UDP) | Layer 7 (HTTP/HTTPS) |
| **URL routing** | ❌ No | ✅ Yes (`/api/*` vs `/*`) |
| **Hostname routing** | ❌ No | ✅ Yes (`shop.com` vs `admin.shop.com`) |
| **SSL termination** | Passthrough only | ✅ Decrypt at gateway |
| **Session affinity** | Source IP hash | Cookie-based |
| **WAF** | ❌ No | ✅ Yes |
| **Cost** | ~$0.02/day | ~$0.20-1.00/day |

**Interview Answer:** *"I use Load Balancer for non-HTTP traffic like databases or gaming. I use Application Gateway when I need URL routing, SSL termination, or WAF security for web applications."*

---

### 2. Application Gateway Components
Client Request: https://shop.com/api/orders
↓
[Application Gateway]
↓

Listener (port 443, hostname shop.com) → MATCH
↓

Rule (if path /api/* → backend pool "api")
↓

HTTP Setting (backend port 8080, timeout 30s, use cookies)
↓

Health Probe (check /health every 30s)
↓

Backend Pool (VMSS-API or App Service)

text

| Component | What it does | Example |
|-----------|--------------|---------|
| **Frontend IP** | Entry point | 20.185.79.15 |
| **Listener** | Listens on protocol/port/hostname | HTTPS://shop.com:443 |
| **Rule** | Connects listener to backend | IF path /api/* THEN pool-api |
| **Backend pool** | Where traffic is sent | VMSS, App Service, IPs |
| **HTTP setting** | How to talk to backend | Port 8080, timeout 30s, cookies |
| **Health probe** | Checks if backend is alive | GET /health every 30s |
| **WAF** | Security inspection | Blocks SQL injection, XSS |

---

### 3. WAF (Web Application Firewall)

**What WAF blocks (OWASP Top 10):**

| Attack Type | Example | WAF Rule ID |
|-------------|---------|-------------|
| SQL Injection | `' OR '1'='1` | 942100 |
| Cross-site Scripting (XSS) | `<script>alert(1)</script>` | 941100 |
| Path Traversal | `../../etc/passwd` | 930100 |
| Command Injection | `; rm -rf /` | 932100 |

**WAF Modes:**

| Mode | Behavior | When to use |
|------|----------|-------------|
| **Detection** | Logs attacks, does NOT block | Testing new rules, validating false positives |
| **Prevention** | Logs AND blocks attacks | Production |

**OWASP Rule Set:** Version 3.2 includes 200+ rules covering the OWASP Top 10 vulnerabilities.

---

### 4. Bicep Template - Key Learnings

**File:** `app-gateway-waf.bicep`

**What I fixed:**

| Issue | Error | Fix |
|-------|-------|-----|
| Circular reference | Used `applicationGateway.id` inside resource | Used `resourceId()` function |
| Missing gateway IP config | No subnet reference | Added `gatewayIPConfigurations` |
| Missing SSL certificate | HTTPS listener without cert | Added `sslCertificates` placeholder |
| Invalid property | `healthyThreshold` not valid for v2 | Removed, used `unhealthyThreshold` only |
| Hardcoded URL | `vault.azure.net` hardcoded | Used `environment().suffixes.keyvaultDns` |
| Probe hostname | Missing for v2 SKU | Added `pickHostNameFromBackendSettings: true` |

**Corrected Bicep snippet:**

```bicep
// SSL Certificate with cross-cloud compatibility
sslCertificates: [
  {
    name: 'wildcard-cert'
    properties: {
      keyVaultSecretId: 'https://placeholder-keyvault.${environment().suffixes.keyvaultDns}/secrets/placeholder-cert'
    }
  }
]

// Health Probe for WAF_v2
probes: [
  {
    name: 'probe-api'
    properties: {
      protocol: 'Http'
      path: '/health'
      interval: 30
      timeout: 10
      unhealthyThreshold: 3
      pickHostNameFromBackendSettings: true  // Required for v2
    }
  }
]
5. Path-Based Routing Example
bicep
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
            paths: ['/api/*']
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
What this does:

Requests to https://shop.com/api/* → API backend pool (port 8080, session affinity)

## All other requests (/*) → Web backend pool (port 80, stateless)

## CHALLENGES & SOLUTIONS

Challenge 1: Bicep Linter Warning - Hardcoded URL
Error: no-hardcoded-env-urls: vault.azure.net

Fix: Used environment().suffixes.keyvaultDns instead of hardcoded URL.

Lesson: Always use environment() for cross-cloud compatibility (Azure Government, China, etc.)

Challenge 2: Bicep Error - Invalid Property
Error: BCP037: healthyThreshold is not allowed

Fix: Removed healthyThreshold. For WAF_v2, only unhealthyThreshold is valid.

Lesson: Always check the API version schema for the resource type.

Challenge 3: Bicep Error - Missing Property
Error: BCP053: keyVaultReference does not exist

Fix: Changed to keyvaultDns (note the lowercase 'v').

Lesson: Property names are case-sensitive. Always check the error message for the correct property name.

Challenge 4: Zero Subscription Quota
Error: No Application Gateway quota in student subscription.

Workaround: Designed complete Bicep template that would deploy in production. Documented the limitation.

Lesson: In interviews, explain how you'd verify quota: az vm list-usage --location

INTERVIEW QUESTIONS PREPARED
Q1: When would you use Application Gateway instead of Load Balancer?
A: When I need Layer 7 features - URL path routing, hostname routing, SSL termination, cookie-based session affinity, or WAF security. Load Balancer is for Layer 4 (TCP/UDP) traffic.

Q2: What's the difference between WAF Detection and Prevention mode?
A: Detection only logs attacks. Prevention logs and blocks them. Always test in Detection mode first to validate rules, then switch to Prevention for production.

Q3: How does path-based routing work?
A: Application Gateway inspects the URL path. For example, /api/* routes to API backend pool, while /* routes to web backend pool. This allows multiple applications behind a single gateway.

Q4: How do you enable session persistence?
A: Set cookieBasedAffinity: 'Enabled' in backend HTTP settings. Application Gateway injects a cookie (ApplicationGatewayAffinity) that maps the client to the same backend server.

Q5: What OWASP rules does WAF support?
A: OWASP 3.2 includes rules for SQL injection (942100 series), XSS (941100 series), path traversal (930100), command injection (932100), and protocol violations.

Q6: Why can't I deploy Application Gateway in my subscription?
A: Student subscriptions have zero quota for Application Gateway. In production, I would first run az vm list-usage --location to check quota, then request an increase if needed.

FILES CREATED
File	Lines of Code	Purpose
app-gateway-waf.bicep	~250	Production-grade App Gateway with WAF
day5-log.md	~300	This document
Total LoC for Day 5: ~550 lines

## HOURS BREAKDOWN
Hours	Activity
1.0	Architecture study + component mapping
1.0	Bicep template creation
1.0	Debugging linter warnings (hardcoded URL, healthyThreshold)
0.5	Fixing property name (keyVaultReference → keyvaultDns)
0.5	Documentation + interview prep
4.0	TOTAL

# Validate Bicep syntax
az bicep build --file app-gateway-waf.bicep

# Check quota (would run in production)
az vm list-usage --location francecentral --output table | findstr "ApplicationGateway"

# Deploy in production (if quota available)
az deployment group create \
    --resource-group "rg-appgw-prod" \
    --template-file app-gateway-waf.bicep