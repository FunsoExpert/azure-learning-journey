# DAY 6: AZURE FIREWALL & DDOS PROTECTION

**Date:** June 24, 2026  
**Time Spent:** 3 hours  
**Status:** ✅ COMPLETE  
**Subscription:** Student (no Firewall quota)

---

## WHAT I LEARNED

### 1. Hub-Spoke Architecture
[Internet]
│
▼
┌─────────────┐
│ Azure Firewall│ ← Central security
│ (Hub VNet) │
└──────┬──────┘
│
┌──────┴──────────────┐
│ │
▼ ▼
┌──────────┐ ┌──────────┐
│ Spoke 1 │ │ Spoke 2 │
│ (App) │ │ (DB) │
└──────────┘ └──────────┘

text

**Why this design:**
- Centralized security policy
- Easier logging and auditing
- Consistent rules across workloads

### 2. NSG vs Azure Firewall

| Feature | NSG | Azure Firewall |
|---------|-----|----------------|
| Scope | Subnet/NIC | VNet/Multi-VNet |
| FQDN filtering | ❌ No | ✅ Yes |
| Threat intelligence | ❌ No | ✅ Yes |
| Central logging | ❌ No | ✅ Yes |
| Cost | Free | ~$0.10-1.25/hour |
| When to use | Basic perimeter | Enterprise security |

### 3. DDoS Protection

| Tier | Cost | Features |
|------|------|----------|
| Basic | Free | Always on, basic monitoring |
| Standard | Pay-as-you-go | Telemetry, alerts, SLA, mitigation reports |

### 4. Forced Tunneling

**What it is:** Routing all internet traffic through the firewall.

**Why use it:** Inspection, compliance, central logging.

**How to implement:** User-Defined Route (UDR) with `nextHopType: VirtualAppliance`

---

## BICEP TEMPLATE CREATED

**File:** `day6-azure-firewall-bicep.bicep`

**Resources defined:**
- Hub VNet (with AzureFirewallSubnet)
- Spoke VNet (with app subnet)
- VNet Peering (Hub ↔ Spoke)
- Public IP for Firewall
- Azure Firewall (Standard SKU)

**Key details:**
- AzureFirewallSubnet must be `/26` minimum
- Firewall must have a public IP
- Peering requires `allowForwardedTraffic: true`

---

## INTERVIEW QUESTIONS PREPARED

**Q1:** When would you use Azure Firewall instead of NSGs?
**A:** NSGs are for basic subnet filtering. I use Azure Firewall when I need centralized logging, FQDN filtering, threat intelligence, or multi-VNet policies.

**Q2:** What is forced tunneling?
**A:** Routing all internet traffic through a firewall for inspection and compliance. Implemented with a route table (UDR) with next hop = VirtualAppliance.

**Q3:** How does DDoS Protection work?
**A:** Basic is always on (free). Standard tier gives you telemetry, alerts, and SLAs. I turn on Standard for critical production workloads.

---

## LIMITATIONS DOCUMENTED

**Cannot deploy:** Student subscription has zero Azure Firewall quota.
**Workaround:** Complete Bicep template ready for production deployment.

---

## NEXT STEPS (DAY 7)

**Topic:** Week 1 Project - Resilient E-commerce Architecture

**Goal:** Combine all Week 1 learnings into a single architecture design.

---

**Day 6 Complete ✅**