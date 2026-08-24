# Lab 13 — Implement and Manage Azure Managed Disks and Partitioning in a VM (Fortray Training Lab)

**Date completed (Fortray lab):** per Fortray schedule
**Documented:** 2026-08-19
**AZ-104 Domain:** 3 — Compute (with Storage domain overlap — managed disks)
**Environment:** Fortray training lab sandbox (`ODL-AZ-XXXX`) — not my own subscription
**Format:** Azure Portal (GUI) + in-VM Disk Management (Windows)

## Objective
- Create a VM, then attach an additional Azure Managed Disk to it
- Initialize and partition the new disk inside Windows
- Format and mount it for use

## Lab scenario
As a Cloud Administrator, provisioning additional storage for an application running on
a VM — attaching a managed data disk, then configuring it inside the OS so it's usable,
mirroring a real scenario where an app needs a separate volume from the OS disk (for
performance isolation, easier backup/snapshot management, or simply running out of space
on the OS disk).

## What I did
1. Provisioned a VM (Windows Server 2019 Datacenter, `Standard_DS1_V2`, Standard HDD OS disk).
2. Confirmed the existing OS disk (Disk 0, ~127 GB, `C:\`) via Windows Disk Management.
3. In the Azure Portal, added a new managed data disk to the VM: Standard HDD, 32 GB,
   named `DataDisk`.
4. Back inside the VM, found the new disk listed as **Disk 2, Unknown/Offline** in
   Disk Management — initialized it (defaulted to GPT partition style on this modern OS).
5. Created a New Simple Volume on the unallocated space, assigned drive letter `F:`,
   formatted it, and confirmed it appeared correctly in File Explorer.

## Key concept — Managed Disks
Azure Managed Disks abstract away the underlying storage account — Azure handles
durability, availability, and placement automatically. Available performance tiers:
- **Standard HDD** — cheapest, lowest performance, used in this lab
- **Standard SSD** — better latency/consistency than HDD, still cost-conscious
- **Premium SSD** — highest performance, used for production/IO-intensive workloads

A managed disk attached to a VM is not automatically usable — it must be initialized and
partitioned inside the guest OS first. This is a distinct step from the Azure-side
provisioning, and it's easy to forget that a disk existing in the Portal ≠ a disk being
usable by the application.

## Key concept — Partition styles
- **MBR (Master Boot Record)** — older standard, supports disks up to 2 TB
- **GPT (GUID Partition Table)** — modern standard, supports disks larger than 2 TB,
  generally preferred for new disks
This lab's 32 GB disk defaulted to GPT, which is expected and correct for a modern
Windows Server guest OS.

## Real-world relevance
Separating OS and data disks is standard practice — it isolates application data from
the OS volume (simplifies backup/snapshot strategy, avoids OS disk space exhaustion from
app growth, and allows different performance tiers per workload — e.g. Premium SSD for a
database's data disk while the OS disk stays on cheaper storage). This is a task I would
expect to repeat in a real support/admin role whenever an application team requests
additional storage capacity.

## Gap / honest note
Same as Lab 12 — this was Portal + in-guest-OS driven, not CLI/Bicep. A good follow-up
exercise for Week 3 (Compute) would be replicating this via `az vm disk attach` and
scripting the in-guest partitioning (e.g. via PowerShell remoting or a custom script
extension) rather than manual RDP clicks — that's the pattern a real automated
provisioning pipeline would use instead of a human doing this by hand each time.
