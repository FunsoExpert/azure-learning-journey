# Lab 23 — VM Patch/Update Management

**Date:** 2026-08-27
**AZ-104 Domain:** 3 — Compute
**Environment:** Fortray/Simplilearn sandbox (redeployed VM via Lab 21's Bicep template)
**Format:** CLI

## Objective
Check and change a VM's patch orchestration mode, and confirm the Lab 21 Bicep
template is a genuinely reusable, portable artifact by redeploying it cleanly in a
fresh sandbox session.

## What I did
1. Redeployed `vm-deploy.bicep` from Lab 21 into a completely fresh sandbox resource
   group with no prior state — succeeded in one shot, ~19.5 seconds, all five resources
   (VNet, IP, NSG, NIC, VM) created correctly with dependency graph intact. Confirms the
   template genuinely works as a standalone artifact, not something that only worked
   once due to leftover session state.
2. Checked patch settings on the freshly deployed VM — correctly predicted Azure would
   apply some default even though the Bicep template never declared patch settings
   explicitly. Confirmed: `patchMode: ImageDefault`, `assessmentMode: ImageDefault` —
   the least-managed option, relying entirely on the OS image's own update mechanism
   with no Azure-side compliance tracking.
3. Upgraded both settings to `AutomaticByPlatform` via `az vm update` — succeeded
   directly, no additional flag required (a hypothesis I raised about needing an extra
   explicit opt-in flag turned out not to apply generally to this switch — worth noting
   as a correction rather than treating every "Azure needs an extra step" pattern as
   universal).
4. Confirmed via the update command's output: `provisionVMAgent: true` was already set
   (declared implicitly by Bicep's VM resource), satisfying the VM Agent prerequisite
   from Lab 20 for any agent-dependent feature, including platform-managed patching.

## Key concept — Patch orchestration models
- **Image Default** — VM patches itself per the OS image's own built-in schedule.
  Minimal Azure involvement, no compliance visibility.
- **Automatic by Platform** — Azure actively manages patch timing, generally applying
  critical/security patches during a maintenance window, with real compliance tracking
  available via Update Manager.
- **Manual, via Maintenance Configurations** — explicit customer-defined schedules
  (e.g. specific day/time, targeting VMs by tag), the real production pattern for
  environments needing controlled, planned patch windows.
This maps conceptually onto the update domain concept from Lab 19 (Availability
Sets/Zones) — both concern *when* disruptive changes happen to a VM, just at different
layers (physical placement vs. patch timing).

## Real-world relevance
This is genuinely close to ITIL-style change management from prior banking/utilities
experience — patch scheduling is a textbook example of planned, governed change, and
uncontrolled `ImageDefault` patching (a VM rebooting on its own schedule, with no
compliance visibility) is a realistic root cause for an "unexpected reboot" incident.
Switching to `AutomaticByPlatform` is the first concrete step toward the kind of
scheduled, auditable patch process a real production environment would require.

## Gotcha / correction
Assumed an extra explicit opt-in flag (by analogy with other "Azure requires
opt-in for platform control" patterns like data-plane RBAC) would be needed for
`AutomaticByPlatform` to activate — it wasn't; the switch applied directly. Worth
remembering that not every governance/opt-in pattern generalizes across every feature;
each needs verifying on its own rather than assumed by analogy.

## Phase 3 (Compute) — status
This closes out Compute: VM creation, sizing, managed disks/partitioning, Availability
Zones, VM extensions, Bicep IaC deployment, Container Apps, and patch management all
covered hands-on across Labs 12-14 and 19-23. Remaining lighter items (VM Scale Sets +
autoscale, App Service/Web Apps) were not covered hands-on this phase — flagged as a
possible later revisit rather than a silent gap, given time constraints and the domain's
core concepts already being well demonstrated.
