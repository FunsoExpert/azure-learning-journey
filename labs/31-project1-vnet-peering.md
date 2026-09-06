# Lab 31 — Course-End Project 1: Implement Azure IaaS (VNet Peering)

**Date:** 2026-09-06
**AZ-104 Domain:** 4 — Networking
**Environment:** Fortray/Simplilearn sandbox, `project1-rg`
**Format:** CLI
**Source:** Simplilearn LMS assigned course-end project (not a Microsoft official lab —
first graded/submitted project of this course)

## Objective
Complete an assigned business-scenario project: connect a headquarters data-tier VNet
(East US) to a branch application-tier VNet (Southeast Asia) via VNet Peering, deploy
test VMs in each, and validate private connectivity with a live ping test.

## Scenario correction, identified before building anything
The project brief's prose mentions preparing the branch network for connectivity via a
"virtual network gateway," but the stated activity list calls for VNet Peering
specifically. These are different mechanisms — a VPN Gateway connects Azure to
something outside Azure; VNet Peering connects two Azure VNets to each other directly.
Since both networks are Azure-native, Peering is correct; the brief's wording was
imprecise. Proceeded with Peering, matching the actual activity list rather than the
prose.

## What I did
1. Created two VNets with deliberately non-overlapping address spaces (a hard peering
   requirement): `VNet-HQ-DataTier` (10.1.0.0/16, East US) and `VNet-Branch-AppTier`
   (10.2.0.0/16, Southeast Asia) — first use of Southeast Asia as a region this course;
   succeeded cleanly with no regional quirk, unlike an earlier East US zone-selector
   issue in a different lab.
2. Deployed one `Standard_DS1_v2` VM into each VNet's subnet (size specified directly
   by the project, already on this sandbox's policy allow-list — no substitution
   needed). Both deployed successfully first attempt, with `--storage-sku Standard_LRS`
   included proactively from prior experience rather than discovered via failure.
3. Created VNet Peering in both directions — `HQtoBranch` and `BranchtoHQ` — per the
   hard requirement that peering must be explicitly configured on each VNet; creating
   one side does not create the other automatically. Verified each peering
   independently via `az network vnet peering list` on both VNets, confirming
   `PeeringState: Connected` and `PeeringSyncLevel: FullyInSync` on both sides rather
   than assuming success from one command's output.
4. Validated connectivity by SSHing into `VM-HQ-DataTier` and pinging
   `VM-Branch-AppTier`'s private IP directly (`10.2.1.4`) — result: 4/4 packets
   received, 0% packet loss, ~222ms average round-trip time.
5. Correctly predicted beforehand that no manual NSG rule would be needed — recalled
   from earlier theory that the default `AllowVnetInBound` rule's `VirtualNetwork`
   service tag automatically expands to include a peered VNet's address space once
   peering is active.

## Key concept — Global vs Local VNet Peering
Since the two VNets span different Azure regions, this is specifically "Global VNet
Peering" (as opposed to "Local," same-region peering). Configured identically either
way — the distinction is purely based on whether peered regions match, but it's a
specific, real vocabulary term worth using precisely.

## Key concept — measured latency as a real architecture trade-off
The ~222ms average round-trip time between East US and Southeast Asia is a real,
felt cost that would be weighed in an actual architecture decision — a concrete number
behind the abstract "keep data tier centralized for security" requirement in the
business scenario, not just a completed technical exercise.

## Real-world relevance
This project mirrors an entirely realistic architecture request: a security-driven
requirement to keep data centralized, balanced against a latency-driven requirement to
keep application logic close to its regional users — exactly the kind of trade-off
conversation a real cloud architecture role involves, now backed by a working, measured
example rather than pure theory.

## Submission artifacts
- `project1-writeup.md` — full written report, submitted to Simplilearn LMS
- `project1-source.sh` — all CLI commands as a single reusable script
- Screenshots: VM creation (both regions), bidirectional peering verification, and the
  successful ping result — submitted per LMS requirements
