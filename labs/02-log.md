# Day 2: Virtual Machines, Availability, NSG, App Service

**Date:** June 6, 2026
**Status:** Complete (with pivot due to subscription quota)

---

## What I Learned Today

### VM Availability (AZ-104 Domain 3)

| Concept | SLA | How it works |
|---------|-----|--------------|
| Single VM | 99.9% | One VM, one datacenter |
| Availability Set | 99.95% | 2+ VMs across fault/update domains |
| Availability Zone | 99.99% | VMs across physically separate datacenters |
| VM Scale Set | Auto-scaling | Automatically adds/removes VMs based on demand |

### Subscription Constraints Discovered

My student subscription has:
- ❌ Zero quota for B-series VMs
- ❌ Zero quota for D-series, E-series, F-series
- ✅ Solution: Use Platform as a Service (PaaS) instead

---

## Resources Created

### Availability Set
```powershell
az vm availability-set create \
  --resource-group rg-vm-learning \
  --name web-availability-set \
  --platform-fault-domain-count 2 \
  --platform-update-domain-count 5

## NSG

  az network nsg create --resource-group rg-vm-learning --name web-nsg --location francecentral


  App Service (PaaS alternative to VMs)
powershell
# App Service Plan (F1 = Free)
az appservice plan create --resource-group rg-vm-learning --name free-plan --sku F1

# Web App
az webapp create --resource-group rg-vm-learning --plan free-plan --name winwebapp0606124114 --runtime "dotnet:10"

Commands Used Today
powershell
# Availability Set
az vm availability-set create --resource-group rg-vm-learning --name web-availability-set --platform-fault-domain-count 2 --platform-update-domain-count 5

# NSG
az network nsg create --resource-group rg-vm-learning --name web-nsg --location francecentral

# NSG Rules
az network nsg rule create --resource-group rg-vm-learning --nsg-name web-nsg --name Allow-HTTP --priority 100 --direction Inbound --access Allow --protocol Tcp --destination-port-ranges 80
az network nsg rule create --resource-group rg-vm-learning --nsg-name web-nsg --name Allow-HTTPS --priority 110 --direction Inbound --access Allow --protocol Tcp --destination-port-ranges 443
az network nsg rule create --resource-group rg-vm-learning --nsg-name web-nsg --name Allow-RDP --priority 120 --direction Inbound --access Allow --protocol Tcp --destination-port-ranges 3389 --source-address-prefixes $myIp
az network nsg rule create --resource-group rg-vm-learning --nsg-name web-nsg --name Deny-Bad-IP --priority 200 --direction Inbound --access Deny --protocol Tcp --source-address-prefixes "203.0.113.0/24"

# App Service
az appservice plan create --resource-group rg-vm-learning --name free-plan --sku F1
az webapp create --resource-group rg-vm-learning --plan free-plan --name winwebapp0606124114 --runtime "dotnet:10"

AZ-104 Practice Questions Answered
Question	Answer
What SLA for 2 VMs in an Availability Set?	99.95%
What protects against entire datacenter failure?	Availability Zones (99.99%)
How to allow RDP only from your office IP?	NSG rule with source IP restriction
What's the difference between Custom Script Extension and Run Command?	Extension for deployment, Run Command for ad-hoc scripts
When to use App Service instead of VMs?	For web applications where you don't need OS access


Challenges Faced & Solved
Challenge	Solution
B-series VMs not available	Used App Service (PaaS) instead
NSG rule creation	Learned priority ordering (lower number = higher priority)
Web app deployment error	Used portal App Service Editor

Cost Today
$0.00 (All resources in free tier)

App Service Plan: F1 (Free)

NSG: No cost

Availability Set: No cost
