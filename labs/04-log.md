# DAY 4: LOAD BALANCERS & VIRTUAL MACHINE SCALE SETS

**Date:** June 8, 2026  
**Time Spent:** 6 hours  
**Status:** ✅ COMPLETE  
**Azure Region:** francecentral  
**Subscription:** Student (quota restricted)

---

## LEARNING OBJECTIVES (AZ-104 DOMAIN 4)

- [x] Deploy Azure Load Balancer (Standard SKU)
- [x] Configure health probes with custom intervals
- [x] Create load balancing rules with session persistence
- [x] Understand VM Scale Sets architecture
- [x] Design autoscale rules (scale out fast, scale in slow)
- [x] Document quota limitations and workarounds

---

## ARCHITECTURE DEPLOYED
Internet
↓
Public IP: pip-prod (Static, Standard SKU)
↓
Load Balancer: lb-prod (Standard SKU)
├── Frontend IP: fe-prod (port 443)
├── Backend Pool: bepool-prod
├── Health Probe: probe-http
│ ├── Protocol: HTTP
│ ├── Path: /health
│ ├── Interval: 15 seconds
│ └── Threshold: 2 failures → 30 seconds tolerance
└── Load Balancing Rule: rule-https
├── Protocol: TCP
├── Frontend Port: 443 → Backend Port: 443
├── Distribution: SourceIPProtocol (session persistence)
├── Idle Timeout: 30 minutes
└── TCP Reset: Enabled

text

**Note:** VM Scale Set could not be deployed due to subscription quota (no B/D-series SKUs available in FranceCentral).

---

## COMMANDS EXECUTED

### 1. Create Resource Group
```bash
az group create --name "rg-production-design" --location "francecentral" --tags "CostCenter=IT-Dept"
2. Create Virtual Network
bash
az network vnet create \
    --resource-group "rg-production-design" \
    --name "vnet-prod" \
    --address-prefix "10.0.0.0/16" \
    --subnet-name "snet-web" \
    --subnet-prefix "10.0.1.0/24" \
    --tags "CostCenter=IT-Dept"
3. Create Public IP
bash
az network public-ip create \
    --resource-group "rg-production-design" \
    --name "pip-prod" \
    --sku "Standard" \
    --allocation-method "Static" \
    --tags "CostCenter=IT-Dept"
Output: 20.185.79.15 (example - your IP will differ)

4. Create Load Balancer
bash
az network lb create \
    --resource-group "rg-production-design" \
    --name "lb-prod" \
    --sku "Standard" \
    --public-ip-address "pip-prod" \
    --frontend-ip-name "fe-prod" \
    --backend-pool-name "bepool-prod" \
    --tags "CostCenter=IT-Dept"
5. Create Health Probe (30-second tolerance)
bash
az network lb probe create \
    --resource-group "rg-production-design" \
    --lb-name "lb-prod" \
    --name "probe-http" \
    --protocol "Http" \
    --port 80 \
    --path "/health" \
    --interval 15 \
    --threshold 2
Why these values: 15 seconds × 2 failures = 30 seconds tolerance for slow-starting applications.

6. Create Load Balancer Rule
bash
az network lb rule create \
    --resource-group "rg-production-design" \
    --lb-name "lb-prod" \
    --name "rule-https" \
    --protocol "Tcp" \
    --frontend-port 443 \
    --backend-port 443 \
    --frontend-ip-name "fe-prod" \
    --backend-pool-name "bepool-prod" \
    --probe-name "probe-http" \
    --load-distribution "SourceIPProtocol" \
    --idle-timeout 30 \
    --enable-tcp-reset true
7. Attempt VM Scale Set Creation (EXPECTED FAILURE)
bash
az vmss create \
    --resource-group "rg-production-design" \
    --name "vmss-prod" \
    --image "Ubuntu2204" \
    --admin-username "azureuser" \
    --generate-ssh-keys \
    --instance-count 2 \
    --vnet-name "vnet-prod" \
    --subnet "snet-web" \
    --backend-pool-name "bepool-prod" \
    --load-balancer "lb-prod" \
    --vm-sku "Standard_B1s" \
    --upgrade-policy-mode "Automatic" \
    --tags "CostCenter=IT-Dept"
Error Received:

json
{
  "code": "SkuNotAvailable",
  "message": "The requested VM size for resource 'Standard_B1s' is currently not available in location 'FranceCentral'."
}
Root Cause: Student subscription has zero quota for B-series, D-series, or E-series VMs in FranceCentral. Only expensive GPU and memory-optimized SKUs are available (M-series, NC-series, NV-series).

8. Autoscale Configuration (CONCEPTUAL - requires VMSS)
bash
# Would run if VMSS existed:
az monitor autoscale create \
    --resource-group "rg-production-design" \
    --name "autoscale-prod" \
    --resource "vmss-prod" \
    --min-count 2 \
    --max-count 10 \
    --count 2

az monitor autoscale rule create \
    --condition "Percentage CPU > 75 avg 5m" --scale out 1 --cooldown 300

az monitor autoscale rule create \
    --condition "Percentage CPU < 30 avg 10m" --scale in 1 --cooldown 300
BICEP TEMPLATE
Created lb-vmss.bicep - Production-grade load balancer template.

Key features:

Parameterized for reusability

Proper dependency management

Outputs load balancer ID and public IP

Production-ready settings (TCP reset, session persistence, health probe)

Deploy with:

bash
az deployment group create \
    --resource-group "rg-production-design" \
    --template-file "lb-vmss.bicep"
PRODUCTION SCRIPTS
File	Purpose
day4-production-config.sh	Complete deployment script
destroy-day4-lab.sh	Clean up all resources
lb-vmss.bicep	Infrastructure as Code template
KEY LEARNINGS
1. Load Balancer SKUs
Feature	Basic SKU	Standard SKU
SLA	None	99.99%
Availability Zones	No	Yes
HA Ports	No	Yes
Backend pool limit	150	1000
Recommendation	❌ Deprecated	✅ Always use
2. Health Probe Formula
text
Total failure time = interval × numberOfProbes

Example: 15s × 2 = 30 seconds before VM is marked unhealthy

For slow-starting apps (30s boot time):
- Option A: interval 15s, threshold 2 (30s tolerance)
- Option B: interval 5s, threshold 6 (30s tolerance)
- Option C: Custom health endpoint that returns 200 only when truly ready
3. Load Balancing Distribution Modes
Mode	Behavior	Use Case
None (5-tuple hash)	Same client → same VM	General web apps
Source IP	Same source IP → same VM	When NAT is used
Source IP + Protocol	Same client+protocol → same VM	Most common (session persistence)
4. TCP Reset
Without TCP reset: Connection hangs until client timeout (60+ seconds)

With TCP reset: Client immediately knows connection is dead, retries

Always enable for production load balancers

5. VM Scale Set Upgrade Policies
Policy	Behavior	Risk
Automatic	Updates all VMs simultaneously	Downtime if update fails
Rolling	Updates batches (e.g., 20% at a time)	Recommended - gradual rollout
Manual	You trigger updates	Most control, operational overhead
6. Autoscale Best Practices
text
Rule 1 (Scale Out):  CPU > 75% for 5 minutes  → add 1 VM
Rule 2 (Scale In):   CPU < 30% for 10 minutes → remove 1 VM
Cooldown:            5 minutes between scaling actions

Why:
- Scale out FAST (5 min) to handle spikes
- Scale in SLOW (10 min) to avoid thrashing
- Cooldown prevents constant scaling
- Minimum 2 instances for high availability
- Maximum set based on cost budget
CHALLENGES & SOLUTIONS
Challenge 1: Policy Blocked VNet Creation
Error: RequestDisallowedByPolicy - missing required tag

Solution: Added --tags "CostCenter=IT-Dept" to all resource creation commands. This satisfied the custom policy from Day 3.

Lesson: Governance policies affect ALL resources. Always check required tags before deploying.

Challenge 2: VMSS Quota Limitation
Error: SkuNotAvailable - Standard_B1s not available in FranceCentral

Root Cause: Student subscriptions have severe VM restrictions.

Workaround:

Documented the limitation

Created complete Bicep template (would work in production)

Learned to check SKU availability first: az vm list-skus --location francecentral

Lesson: Always validate quota before designing architecture. In interviews, explain how you'd verify SKU availability.

Challenge 3: Autoscale Requires VMSS
Error: ResourceNotFound - vmss-prod doesn't exist

Resolution: Documented autoscale rules conceptually. Cannot create without VMSS.

Lesson: Autoscale is dependent on VMSS. Design both together.

INTERVIEW QUESTIONS PREPARED
Q1: How do you configure a load balancer for an app that takes 30 seconds to start?
A: Increase health probe tolerance. Either increase interval (5s → 15s) or increase threshold (2 → 6 failures). Also implement a custom /health endpoint that only returns 200 when the app is truly ready, not just when the OS boots.

Q2: What's the difference between Basic and Standard Load Balancer?
A: Standard SKU has 99.99% SLA, availability zone support, HA ports, larger backend pools (1000 vs 150), and TCP reset. Basic SKU is being deprecated. Always use Standard.

Q3: How does session persistence work?
A: Using 5-tuple hash (protocol, source IP, source port, destination IP, destination port). Same client maps to same backend VM. Configured with --load-distribution "SourceIPProtocol".

Q4: What happens if all VMs fail the health probe?
A: Load balancer returns HTTP 502 Bad Gateway. No traffic is sent until at least one VM passes the health probe.

Q5: How do you design autoscale rules to prevent thrashing?
A: Scale out fast (CPU > 75% for 5 minutes), scale in slow (CPU < 30% for 10 minutes), with 5-minute cooldown between actions. Maintain minimum 2 instances for HA.

Q6: Why can't I deploy VMSS in my subscription?
A: Student subscriptions have restricted VM SKUs. In production, I would first run az vm list-skus --location to check availability, then select an available SKU like Standard_D2s_v3.

RESOURCES CREATED TODAY
File	Lines of Code	Purpose
lb-vmss.bicep	120	Production load balancer template
day4-production-config.sh	250	Automated deployment script
destroy-day4-lab.sh	15	Cleanup script
day4-log.md	400+	This document
Total LoC: ~785 lines of infrastructure code

VERIFICATION COMMANDS
bash
# Check load balancer health
az network lb show --name "lb-prod" --resource-group "rg-production-design" --query probes

# Get public IP
az network public-ip show --name "pip-prod" --resource-group "rg-production-design" --query ipAddress

# List all resources
az resource list --resource-group "rg-production-design" --output table

# Test connectivity (requires VM behind LB)
curl -k https://<PUBLIC_IP>
