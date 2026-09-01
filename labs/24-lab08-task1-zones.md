# Lab 24 — Official LAB_08 Task 1: Zone-Resilient VM Deployment (Shared VNet)

**Date:** 2026-08-29
**AZ-104 Domain:** 3 — Compute
**Environment:** Fortray/Simplilearn sandbox (`ODL-az-2368114`, resource group `az104-rg8`)
**Format:** Azure Portal
**Reference:** [Official Microsoft LAB_08 — Manage Virtual Machines, Task 1](https://microsoftlearning.github.io/AZ-104-MicrosoftAzureAdministrator/Instructions/Labs/LAB_08-Manage_Virtual_Machines.html)
**Note:** First lab in this course to explicitly follow Microsoft's official lab document
end-to-end, adapted only where the sandbox's `az13038-PolicyDefinition` policy forces a
substitution. Prior labs (12-23) were self-designed exercises around the same exam
domains, not literal official lab instructions — documenting this distinction honestly
per an explicit request to always follow the real Microsoft lab going forward.

## Objective
Deploy two VMs across two Availability Zones, sharing a single Virtual Network, to
achieve Azure's 99.99% SLA tier — and directly fix the "two separate auto-created VNets"
gotcha flagged back in Lab 19 by deliberately selecting an existing VNet for the second VM.

## Adaptations from the official lab (policy-forced)
- VM size: `Standard_DS2_v2` substituted for the lab's `Standard_D2s_v5` (not on the
  sandbox's allowed size list)
- OS disk: Standard HDD (`Standard_LRS`) substituted for the lab's specified Premium SSD
  (policy requires `Standard_LRS` on all disks)
- Region: West US 2 used instead of East US — not a policy substitution, but a real
  constraint hit live: the Portal's newer "preview Create-VM experience" didn't offer
  zone selection in East US for this VM series; switched region and zones became
  available. Genuine real-world adaptation, not a scripted step.

## What I did
1. Created resource group `az104-rg8`, matching the official lab's naming.
2. Deployed `az104-vm1`: Ubuntu 24.04 LTS, `Standard_DS2_v2`, Availability Zone 1,
   Standard HDD OS disk, West US 2. Networking tab defaults created a new VNet
   (`vnet-westus2-2`, subnet `snet-westus2-1 - 172.16.0.0/24`) — noted the exact names
   before proceeding, specifically to reuse them for VM 2.
3. Deployed `az104-vm2` with the same specs, but on the **Networking** tab explicitly
   selected the **existing** `vnet-westus2-2` and existing subnet `snet-westus2-1`,
   rather than accepting a second auto-created VNet — Availability Zone 2.
4. Correctly reasoned, before testing, that both VMs sharing the same subnet would be
   able to reach each other over the private network regardless of being in different
   zones, since subnet membership (logical IP space) and Availability Zone assignment
   (physical datacenter placement) are independent concepts — zone separation is about
   fault tolerance, not network isolation.
5. Verified zone assignment directly against Azure's own data via
   `az vm list --query "[].{name:name, zone:zones[0]}"` — confirmed `az104-vm1` → Zone 1,
   `az104-vm2` → Zone 2, both correctly on the shared VNet.

## Key concept — SLA tiers (verified against Microsoft Learn)
- 99.99% — 2+ VM instances across 2+ Availability Zones in the same region
- 99.95% — 2+ VMs in the same Availability Set (no extra cost for the Set itself)
- 99.9% — single-instance VM using Premium SSD or Ultra Disk for all disks
- 99.5% — single-instance VM using Standard SSD for all disks
- 95% — single-instance VM using Standard HDD for all disks
This is precisely why Task 1 requires two VMs across two zones specifically — it's the
minimum configuration structurally capable of reaching the 99.99% tier; no single VM,
however well-specced, can reach it alone. Translating SLA percentages into real downtime
makes the gap concrete: 95% allows roughly 36 hours of monthly downtime before credits
apply, versus roughly 43 minutes at 99.9% — a ~50x difference, and the reason Standard
HDD should never be used for genuinely production-critical workloads.

## Key concept — Subnets are zone-independent
A subnet is a logical IP address grouping; an Availability Zone is a physical datacenter
placement. They are fully independent — a VNet can contain resources spread across
multiple zones while all sharing one subnet, and there's no requirement to segment
subnets by zone. Subnet segmentation is typically a security/routing decision (e.g.
separating a web tier from a database tier), not a zone-redundancy mechanism — to be
covered properly in Phase 4 (Networking).

## Honest note on this lab's own irony
Our policy-forced substitution to Standard HDD technically undermines the disk-level SLA
contribution the official lab's Premium SSD choice would have provided — zone redundancy
still delivers the 99.99% VM-availability SLA regardless of disk tier, so the core
teaching point (zone spreading = highest SLA tier) still holds, but a real production
deployment following this pattern would want Premium SSD, not the HDD we were forced
into by sandbox policy.

## Real-world relevance
The VNet-sharing fix applied here is the production-correct pattern that Lab 19's
Portal defaults accidentally skipped — two VMs meant to function as a redundant,
load-balanced pair must share network space to communicate and to sit behind a shared
load balancer (Task 2/3 territory, still ahead). Hitting a genuine regional
zone-availability quirk in the Portal's newer VM-creation UI, and adapting by switching
regions rather than being blocked, mirrors realistic troubleshooting.

## Next
Task 2 of the official lab — compute/storage scaling on these VMs — up next, followed
by Tasks 3-4 (VM Scale Set creation and autoscale configuration).
