# Lab 14 — Scale a Virtual Machine Size (Fortray Training Lab)

**Date completed (Fortray lab):** per Fortray schedule
**Documented:** 2026-08-19
**AZ-104 Domain:** 3 — Compute
**Environment:** Fortray training lab sandbox (`ODL-AZ-XXXX`) — not my own subscription
**Format:** Azure Portal (GUI)

## Objective
- Create a VM with a basic size
- Monitor its performance (CPU, disk, network)
- Resize (scale up) the VM to a higher-spec size
- Validate the change took effect

## Lab scenario
As a Cloud Engineer, an application initially deployed on a modestly-sized VM starts
experiencing increased load. Task: monitor current utilization, then scale the VM up to
handle the demand — simulating a real capacity-planning response to growth.

## What I did
1. Provisioned a VM at `Standard_DS1_V2` (1 vCPU, 3.5 GiB memory).
2. Reviewed built-in Portal monitoring under Overview → Monitoring: CPU utilization,
   disk utilization, and network utilization graphs.
3. Navigated to Availability + Scale → Size, selected a higher tier (`DS2_V2`), and
   confirmed the resize.
4. Verified the change by returning to Overview and confirming the new size was reflected.

## Key concept
VM resizing changes the underlying compute allocation (vCPU count, memory, sometimes
network/disk throughput limits depending on the series) without requiring a full
redeploy — the disk and configuration persist. Two things worth knowing precisely
(flagging as something to verify against Microsoft Learn before the exam, since this is
exactly the kind of detail that gets tested):
- **Resizing within the same VM series usually doesn't require a restart in every case,
  but resizing across series, or when the target size isn't available on the current
  hardware cluster, does require a stop/deallocate first.** I observed a brief resize
  operation in this lab but didn't specifically test the cross-series/restart-required
  case — worth confirming precisely during Week 3.
- Not every size is available in every region or on every hardware cluster a VM happens
  to be running on — a resize can fail with an availability error, which is a real
  troubleshooting scenario worth knowing exists.

## Real-world relevance
Right-sizing VMs is a recurring cost/performance task, not a one-time decision — this is
literally what Azure Advisor's cost recommendations often flag (VMs consistently
under-utilized should be downsized; consistently maxed-out VMs should be scaled up before
they cause an incident). Being able to read Portal-native CPU/disk/network monitoring
before scaling — rather than guessing — is the actual skill; the resize action itself is
trivial once you know a change is justified.

## Gap / honest note
This lab used Portal-native monitoring only — I haven't yet done this via Azure Monitor /
Log Analytics with KQL, which is the more powerful, production-realistic approach and is
covered in Phase 5 (Monitoring) of my roadmap. Also haven't tested the
stop/deallocate-required resize scenario specifically — flagging both as follow-ups
rather than glossing over them.
