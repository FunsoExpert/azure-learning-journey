# Lab 25 — Rebuilding LAB_08 Task 1 via CLI: A Multi-Layered Policy Troubleshooting Chain

**Date:** 2026-09-01
**AZ-104 Domain:** 3 — Compute (with Domain 1 governance overlap)
**Environment:** Fortray/Simplilearn sandbox (fresh instance, `az104-rg8`)
**Format:** CLI

## Objective
Rebuild Task 1 of official LAB_08 (two zone-resilient VMs sharing a VNet) via CLI
instead of Portal, after a sandbox reset — and, unplanned, work through a genuinely
tricky multi-layered troubleshooting chain around policy enforcement and misleading
status reporting.

## What happened (in order)
1. First `az vm create` for `az104-vm1` failed with `RequestDisallowedByPolicy` on the
   OS disk — CLI's default disk SKU isn't `Standard_LRS` unless specified, same root
   cause as Lab 19/24, now confirmed via CLI too.
2. Retried with `--storage-sku Standard_LRS` added — got a NEW, different error:
   `PropertyChangeNotAllowed` on `osDisk.managedDisk.storageAccountType`.
3. Checked `az resource list` — saw `az104-vm1` listed with `Status: Succeeded`,
   apparently contradicting the CLI's own `"status":"Failed"` JSON response from
   attempt 1. Investigated rather than trusting either signal blindly: queried the VM's
   actual disk SKU directly (`az vm show --query storageProfile.osDisk.managedDisk.storageAccountType`)
   — returned `Premium_LRS`. Working theory at this point: attempt 1 had left a
   non-compliant disk object behind, and attempt 2 was colliding with it.
4. Tried `az vm delete` to clean up — this ALSO failed with the same
   `RequestDisallowedByPolicy`, now targeting the disk during what should have been a
   delete operation. Researched Azure Policy's `deny` vs `denyAction` effects via
   Microsoft Learn: confirmed `denyAction` is a distinct, separate effect specifically
   for blocking DELETE calls; plain `deny` (what our policy uses) is documented as
   evaluating resource writes. Hypothesized that `az vm delete` triggers an implicit
   disk-detach *write* (updating `managedBy`) before the actual delete, and that write
   was what got blocked — not the delete itself.
5. Tested this by calling `az disk delete` directly on the specific disk resource,
   bypassing the VM-delete path entirely — succeeded with no error, no output.
   Seemed to confirm the write-vs-delete theory.
6. But then re-checked the resource group: `az104-vm1` STILL showed
   `Status: Succeeded` in `az resource list`, despite its disk supposedly just being
   deleted. `az disk list` returned nothing at all. Cross-checked with
   `az vm get-instance-view` — revealed the VM's actual instance status was
   `ProvisioningState/failed/RequestDisallowedByPolicy`.
7. **Real root cause, simpler than either working theory:** the VM had never actually
   been successfully created in the first place. The very first attempt failed at disk
   creation before any real disk object existed. The `az disk delete` command "succeeded"
   only because deleting a non-existent resource is a harmless no-op — there was nothing
   there to delete. `az resource list`'s `Status: Succeeded` for the VM the whole time was
   misleading/stale, reflecting the resource shell's registration rather than its actual
   provisioning outcome.
8. Deleted the broken placeholder VM cleanly (`az vm delete`, now genuinely nothing to
   conflict with), recreated it correctly with `--storage-sku Standard_LRS` from the
   start, reusing the existing NIC via `--nics` to preserve the working VNet/NSG/IP.
   Succeeded immediately, confirmed `powerState: VM running`, `zones: 1`.
9. Created `az104-vm2` in Zone 2, explicitly joining the existing VNet via `--vnet-name`
   and `--subnet` (confirmed exact flag names from Microsoft Learn documentation
   beforehand rather than guessing). First attempt guessed the subnet name as `default`
   and failed — checked the real name via `az network vnet subnet list`
   (`az104-vm1Subnet`), retried successfully. Confirmed `privateIpAddress: 10.0.0.5`,
   sequential with VM 1's `10.0.0.4` — same subnet as intended.

## Key concept — `az resource list` status can be misleading
A resource's top-level `Status` in a general listing command reflects the resource
shell's registration, not necessarily its actual functional provisioning outcome. When a
resource's real state is in question, query the specific resource type's own detailed
status (`az vm get-instance-view`, `az vm show` on specific properties) rather than
trusting a generic list command's summary field.

## Key concept — Azure Policy `deny` vs `denyAction`
Two genuinely distinct policy effects: `deny` evaluates and blocks resource
writes/creates/updates; `denyAction` is a separate, purpose-built effect specifically
for blocking DELETE calls. A `deny`-effect policy targeting a resource property (like
disk SKU) will generally not block a pure delete of that resource — but CAN block an
*implicit write* that happens as a side effect of another operation (like a VM
triggering a disk detach/update during its own deletion). When something won't delete
cleanly under a `deny` policy, check whether the deletion path involves an implicit
update to a child resource, and consider deleting bottom-up (child resource first)
rather than top-down.

## Key concept — CLI flags for joining an existing VNet
Confirmed via Microsoft Learn: `--vnet-name` and `--subnet` together on `az vm create`
attach a new VM to an existing virtual network and subnet, rather than creating new ones.
Subnet names auto-generated by `az vm create` are NOT simply `default` — verify with
`az network vnet subnet list` rather than assuming a conventional name.

## Real-world relevance
This entire session was a realistic, non-scripted troubleshooting sequence: a plausible
first theory (leftover non-compliant disk) turned out to be wrong, a second theory
(deny-vs-write-vs-delete semantics) was directionally correct but incomplete, and the
real root cause was simpler than either — a failed-at-birth resource whose status
reporting was misleading. This is genuinely representative of real incident diagnosis:
follow the evidence, verify claims with direct queries rather than trusting summary
fields, and be willing to discard a theory that doesn't fully explain the data.

## Result
Task 1 successfully rebuilt via CLI, matching the Portal-based result from Lab 24:
`az104-vm1` (Zone 1) and `az104-vm2` (Zone 2), sharing `az104-vm1VNET` /
`az104-vm1Subnet`, both Standard_LRS disks, both confirmed running.
