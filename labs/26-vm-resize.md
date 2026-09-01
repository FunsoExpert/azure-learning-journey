# Lab 26 — Official LAB_08 Task 2: VM Resize (Vertical Scaling)

**Date:** 2026-09-01
**AZ-104 Domain:** 3 — Compute
**Environment:** Fortray/Simplilearn sandbox, `az104-rg8`
**Format:** CLI
**Reference:** [Official Microsoft LAB_08, Task 2](https://microsoftlearning.github.io/AZ-104-MicrosoftAzureAdministrator/Instructions/Labs/LAB_08-Manage_Virtual_Machines.html)

## Objective
Resolve an ambiguity left open since Lesson 14/Lab 14 (Fortray VM scaling): does
resizing a running VM require it to be stopped first, and does that depend on staying
within the same VM series?

## What I did
1. First resize attempt (`Standard_DS3_v2`) failed — but this was a false test, since
   that size isn't on the sandbox's policy allow-list at all; the failure was a policy
   block, not a genuine answer to the resize question.
2. Corrected the test by choosing `Standard_D2s_v3` — noted this is actually a
   **different series and generation** from the current `Standard_DS2_v2` (DSv2 vs
   Dsv3), making it a stronger test of the cross-series resize question than originally
   intended.
3. Ran the resize while the VM was still running (no stop/deallocate performed) —
   succeeded immediately: `provisioningState: Succeeded`,
   `hardwareProfile.vmSize: Standard_D2s_v3`, VM remained running throughout.

## Key concept — corrected understanding of live VM resize
The deciding factor for whether a VM can be resized live (no stop/deallocate) is NOT
primarily "same series vs. different series" — it's whether the **specific physical
hardware cluster** the VM is currently running on has capacity for the target size.
Series membership is only a loose proxy for how likely that capacity is to exist, not a
hard rule. A same-series resize can still require a stop if the current host lacks
capacity; a cross-series resize can succeed live if the host happens to support it, as
demonstrated here. `az vm list-sizes --resource-group <rg> --name <vm>` lists sizes
available on the VM's current host, which is the actual way to check in advance rather
than assuming based on series names.

## Key concept — data disk vs OS disk resize (corrected, verified against Microsoft Learn)
Initially stated (incorrectly) that any disk resize on an attached, running VM requires
deallocation. Directly tested and corrected: attaching a NEW empty data disk to a running
VM succeeded with no deallocation needed, and resizing that EXISTING data disk (32GB →
64GB) also succeeded live, with the VM never stopped. Verified against Microsoft's own
troubleshooting documentation: Azure supports live data disk resize when the VM SKU
supports it (Premium Storage capability, ephemeral OS disk support, or Hyper-V Gen2 —
`az104-vm1` is Gen2, qualifying), and as long as the resize stays within the same side of
the 4 TiB threshold. The rule that does NOT have exceptions: **OS disk resizing always
requires VM deallocation**, regardless of SKU — only data disks support live resize.
Also worth remembering: resizing the disk object in Azure and the guest OS actually
recognizing/using the new space are two separate steps — the OS still sees the old
partition size until the volume is manually extended inside the guest (e.g. `growpart` +
`resize2fs` on Linux), which was not performed in this lab.

## Correction to earlier material
Lesson 14 (Fortray VM sizing) left this genuinely unresolved and implicitly framed it as
a same-series-vs-cross-series distinction. That framing was an oversimplification —
recorded here as a deliberate correction rather than leaving the earlier imprecise
version uncontested.

## Real-world relevance
"Can I resize this VM without downtime" is a real, practical question before any resize
in production — checking `az vm list-sizes` against the VM's current host, rather than
assuming based on series names, is the actually correct approach and avoids an
unplanned outage from an assumed-safe resize that turns out to require a stop.
