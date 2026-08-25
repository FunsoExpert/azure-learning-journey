# Lab 19 — Availability Sets vs Availability Zones

**Date:** 2026-08-25
**AZ-104 Domain:** 3 — Compute
**Environment:** Fortray/Simplilearn sandbox (`ODL-az-2363930`) — required, since Azure
for Students subscription has no VM sizes available at all (`NotAvailableForSubscription`
on every size tested, not a quota limit — confirmed via Portal). Compute hands-on work
is now permanently routed through the Fortray sandbox as a result.

## Objective
Deploy two VMs across two different Availability Zones in the same region, and prove —
not just state — that this protects against a full-datacenter failure the way an
Availability Set alone would not.

## What I did
1. Correctly predicted, before any hands-on, that an Availability Set does NOT protect
   against a full datacenter outage — same reasoning as LRS vs ZRS in Storage, applied
   to compute: Sets spread VMs across fault/update domains *within one datacenter*, so
   the datacenter itself remains a single point of failure.
2. Confirmed via Microsoft's official regions list that all five of my allowed regions
   (France Central, Poland Central, Sweden Central, Canada Central, Spain Central)
   support Availability Zones — not guaranteed for every Azure region, worth checking
   rather than assuming.
3. Attempted the deployment on my own Azure for Students subscription first — every VM
   size was greyed out with `NotAvailableForSubscription`, confirmed via the Portal
   directly. Different failure mode than a quota cap; Student subscriptions apparently
   don't get VM provisioning rights at all on standard series. Compute work moved to the
   Fortray sandbox as a result.
4. Created `vm-zone1` (Zone 1, East US, Standard_B1s) — first attempt failed with
   `RequestDisallowedByPolicy`.
5. Diagnosed properly rather than guessing: pulled the actual policy assignment
   (`az13038-PolicyDefinition`) and its full rule definition via
   `az policy definition show --query policyRule`. Found the specific clause: any
   `Microsoft.Compute/disks` resource must have `sku.name` in `["Standard_LRS"]` — my
   VM's OS disk had defaulted to something else (likely Premium/Standard SSD, the
   Portal's modern default), which got denied.
6. Recreated `vm-zone1` with OS disk type explicitly set to Standard HDD (LRS) on the
   Disks tab — succeeded. Confirmed `Availability zone: 1` in the resource Overview.
7. Created `vm-zone2` the same way, Zone 2 this time, disk type set correctly from the
   start — succeeded first try. Confirmed `Availability zone: 2` in the resource Overview.
8. Compared both VMs side by side — confirmed distinct zone values, and separately
   noticed the Portal had auto-created two *different* virtual networks
   (`vnet-eastus-2` vs `vnet-eastus-3`) rather than reusing one — flagged as a real
   gotcha for Week 4 (Networking), not fixed in this lab.

## Key concept
Availability Sets and Availability Zones solve different-scale problems, same underlying
principle as Storage redundancy:
- **Availability Set** — fault/update domains within a single datacenter. Protects
  against rack-level hardware failure and planned maintenance. Datacenter itself is
  still a single point of failure.
- **Availability Zone** — physically separate datacenters within the same region, each
  with independent power/cooling/networking. Protects against a full datacenter outage.
- Cannot mix both strategies on the same VM. Zones are Microsoft's current recommended
  default in regions that support them; Sets are increasingly treated as legacy.

## Real-world relevance
This exact troubleshooting sequence — deployment blocked by an org-wide governance
policy, needing to read the actual policy definition rather than guess at a fix — is a
completely realistic support/admin task. The specific policy here (`az13038`) is a
genuine example of a cost/security guardrail combining dozens of resource-type
restrictions into a single assignment, the same pattern a real organization would use.

## Gotcha
Azure for Students subscriptions have no VM size availability at all on standard series
— confirmed directly via Portal (`NotAvailableForSubscription`), not a vCPU quota issue.
All future Compute-domain hands-on work routes through the Fortray sandbox as a
permanent rule, not case-by-case.

## Follow-up flagged, not yet done
Both VMs ended up on separate VNets due to Portal defaults — worth revisiting in Week 4
(Networking) to deploy zone-redundant VMs onto a shared VNet with distinct subnets
properly, the production-correct pattern.
