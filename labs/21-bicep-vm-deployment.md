# Lab 21 — Infrastructure as Code with Bicep: VM Deployment, Dependency Graphs, Idempotency

**Date:** 2026-08-27
**AZ-104 Domain:** 3 — Compute (with Domain 1 governance and Domain 4 networking overlap)
**Environment:** Fortray/Simplilearn sandbox
**Format:** Bicep + Azure CLI

## Objective
Write a Bicep template from scratch to deploy a VM with networking (VNet, subnet,
public IP, NIC, NSG) as a single declarative unit, and directly observe Bicep's
dependency resolution and idempotency rather than just reading about them.

## What I did
1. Built `vm-deploy.bicep` incrementally: parameters block (including a `@secure()`
   decorator on the admin password), VNet + subnet, public IP, NIC, then the VM resource
   itself — deliberately pre-complying with the sandbox's `az13038-PolicyDefinition`
   policy from the start (Ubuntu 24.04 image via offer `ubuntu-24_04-lts`,
   `Standard_LRS` OS disk, `Standard_B1s` size) rather than discovering violations after
   deployment as in Labs 19-20.
2. First deployment attempt: all four resources (VNet, IP, NIC, VM) created
   successfully in ~56 seconds — but the deployment reported `DeploymentOutputEvaluationFailed`
   on the `vmPublicIP` output. Diagnosed properly rather than assuming the whole
   deployment failed: verified via `az vm show` that the VM itself had
   `provisioningState: Succeeded`. Root cause: `publicIPAllocationMethod: 'Dynamic'`
   means the IP isn't assigned until the VM is running/NIC attached — the output tried
   to read `ipAddress` before it existed. Fixed by switching to `'Static'` allocation.
3. Redeployed after the fix — output now returned a real IP value
   (`vmPublicIP: "20.163.209.98"`) in the JSON response.
4. Correctly predicted, before testing, that SSH would NOT work — unlike Portal-wizard
   VM creation (which auto-generates a permissive default NSG), a raw Bicep template
   defines nothing by default; nothing happens unless explicitly declared.
5. Added an NSG resource with an explicit `AllowSSH` inbound rule (port 22, priority
   300), and attached it to the existing NIC resource by adding a
   `networkSecurityGroup: { id: nsg.id }` reference inside the NIC's properties.
6. Hit a genuine Bicep compiler error (`BCP018`/`BCP009`) on redeploy — caused by two
   stray `XX` characters accidentally left in the file (likely from an earlier fragile
   `sed` edit I'd tried and should have avoided). Diagnosed by viewing the exact flagged
   line number directly rather than guessing, fixed with a targeted `sed` removal, then
   verified the fix before redeploying.
7. Final redeploy succeeded in ~5 seconds (vs. ~56 seconds for the original full
   deployment) — direct, measured proof of idempotency: Bicep recognized the VNet,
   public IP, and VM already matched the desired state and only did real work on the new
   NSG and the NIC's updated reference.

## Key concept — Bicep dependency graph
Resource-to-resource references in Bicep (e.g. `id: nic.id`, `id: vnet.properties.subnets[0].id`)
are enough for Azure Resource Manager to compute correct deployment order automatically
— visible directly in the deployment JSON's `dependencies` array, which listed exactly
which resources depended on which, without me ever specifying an explicit sequence.
Contrast with the manual `az` CLI sequencing used all session up to this point, where I
had to run commands in the right order myself.

## Key concept — Idempotency
Re-running the same (or a modified) Bicep deployment against resources that already
exist and match doesn't recreate them — ARM reconciles only what's actually different.
Measured directly: 56 seconds for the first full deployment vs. ~5 seconds for the
second deployment that only added an NSG and updated one NIC reference.

## Key concept — IaC removes implicit Portal conveniences
The Portal VM-creation wizard auto-generates a default NSG permitting SSH/RDP inbound.
A raw Bicep template does none of this automatically — every piece of desired behavior,
including basic connectivity, must be explicitly declared. This is a genuine trade-off:
more control and full auditability, but also full responsibility for things easy to
overlook. Confirmed by correctly predicting SSH would fail before an NSG was added.

## Real-world relevance
This is the actual professional alternative to everything done manually in Labs 12-20:
instead of clicking through the Portal or running individual `az` commands per resource,
one file declares the whole desired state, is version-controllable (already committed to
this repo), and is safely re-runnable. The output-evaluation failure and the dependency
resolution are both genuinely realistic IaC debugging experiences, not contrived
teaching examples.

## Gotcha
`Dynamic` public IP allocation defers IP assignment until the VM/NIC is active — any
Bicep `output` trying to read the IP immediately after resource declaration will fail.
Use `Static` allocation when the IP needs to be available as a deployment output.

## File
`vm-deploy.bicep` — to be copied into `/scripts/` in the main repo as a reusable
template, alongside the existing pre-course Bicep files already there.
