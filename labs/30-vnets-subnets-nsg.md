# Lab 30 — Official LAB_04 Tasks 1-3: VNets, Subnets, NSGs (Portal + CLI)

**Date:** 2026-09-02/03
**AZ-104 Domain:** 4 — Networking
**Environment:** Fortray/Simplilearn sandbox (multiple resets), `az104-rg4`
**Format:** Portal (Task 1) + CLI (Tasks 1 rebuild, 2, 3)
**Reference:** [Official Microsoft LAB_04 — Implement Virtual Networking](https://microsoftlearning.github.io/AZ-104-MicrosoftAzureAdministrator/Instructions/Labs/LAB_04-Implement_Virtual_Networking.html)

## Objective
Build the full Task 1-3 architecture from the official lab — two non-overlapping VNets
each with two subnets, then an NSG with custom rules — via both Portal and CLI, with
proper theoretical grounding (CIDR math, VNet isolation rules, NSG evaluation order)
before any hands-on step, sourced from Microsoft Learn directly rather than paraphrased
from memory, given this is the flagged "hardest" domain of the course.

## Theory covered before hands-on
- CIDR math worked through properly: `/16` = 65,536 addresses, `/24` = 256, `/26` = 64
  (self-verified: correctly calculated 64 total / 59 usable). Every Azure subnet
  reserves 5 addresses automatically (network, gateway, 2x DNS, broadcast) — a `/24`
  yields 251 usable, not 256.
- VNet structural rules: region-scoped (can span zones, not regions); isolated by
  default between VNets (no communication without explicit peering/VPN); outbound
  internet access allowed by default for all resources.
- Subnet mechanics: NICs in the same VNet communicate freely regardless of subnet, with
  zero extra config — the exact mechanism proven back in Lab 24's two-zone, shared-VNet
  VM pair.
- Non-overlapping address space required specifically because overlapping ranges create
  ambiguous routing once VNets connect via peering or VPN.
- NSG evaluation: five-tuple matching, strict priority order (lowest number first), and
  first match wins with evaluation stopping immediately. Custom rules run 100-4096;
  default rules sit at 65000-65500.
- NSGs are stateful: an allowed outbound flow's return traffic is automatically
  permitted, no matching inbound rule needed.
- Dual NSG scenario (subnet + NIC level): both must independently allow traffic, most
  restrictive combination wins.
- ASGs: logical NIC groupings referenced by name in NSG rules instead of hardcoded IPs;
  all member NICs must share the same VNet as the group's first member; a rule
  referencing an ASG has no effect on NICs that aren't members of it.

## What I did
1. Built `CoreServicesVnet` (10.20.0.0/16, subnets 10.20.10.0/24 and 10.20.20.0/24) via
   Portal, per the official lab's Task 1 steps.
2. Rebuilt the same structure via CLI for direct comparison, plus created
   `ManufacturingVnet` (10.30.0.0/16, two /24 subnets) entirely via CLI rather than the
   official lab's ARM-template-export method for Task 2.
3. Hit a genuine field-naming inconsistency across CLI subcommands: `az network vnet
   subnet list` returns `addressPrefixes` (plural array), while `az network vnet
   create`'s inline subnet response returns `addressPrefix` (singular) — same
   underlying data, different shape depending on command. Diagnosed by dropping the
   `--query` filter entirely and inspecting raw JSON rather than assuming the flag
   was wrong.
4. After a sandbox reset, rebuilt the environment via a batch of CLI commands run
   without individually checking each one — the resource group summary
   (`NumSubnets: 1` on `CoreServicesVnet`) silently masked a failed `DatabaseSubnet`
   creation. Caught by refusing to trust the summary count and checking the actual
   subnet list directly.
5. Attempted to create Application Security Groups (`AsgWeb`, `AsgDb`) per Task 3 —
   failed with `AuthorizationFailed`, a genuinely new category of block (not policy,
   not quota, not SKU capability). Predicted correctly, before checking, that this
   sandbox's identity likely holds a deliberately restricted custom RBAC role rather
   than standard Owner/Contributor. Confirmed directly: `az role assignment list`
   showed a named `Spektra Custom RBAC Role 1 I33066 S1` (Simplilearn's underlying lab
   platform). Inspected the role definition (`az role definition list --query
   "[].permissions"`) — confirmed `Microsoft.Network/applicationSecurityGroups/*` is
   genuinely absent from the allowed actions list, while `networkSecurityGroups/*` is
   present. Also proactively noted `Microsoft.Network/localnetworkgateways/*` in the
   explicit `notActions` deny list — flagging a predicted future gap for LAB_05's VPN
   Gateway task before hitting it blind.
6. Created `CoreServicesNSG` via CLI — confirmed Azure's actual six default rules
   directly in the response JSON (three inbound: AllowVnetInBound/65000,
   AllowAzureLoadBalancerInBound/65001, DenyAllInBound/65500; three outbound, mirrored).
7. Added a custom `DenyAllInbound` rule at priority 4096, then a custom `AllowSSH` rule
   at priority 300. Correctly predicted, before testing, that SSH traffic would match
   the 300 rule first and never reach the 4096 deny. Confirmed directly via
   `az network nsg rule list` showing both rules with their priorities.

## Real-world relevance
The dual-NSG scenario and the ASG-membership gotcha are both genuinely common real
troubleshooting traps. Hitting a real custom RBAC role with a hard permission gap (ASGs,
VPN local gateways) mirrors exactly how enterprise environments scope down
training/sandbox accounts — reading the actual role definition rather than guessing at
what's blocked is a transferable diagnostic skill.

## Gotcha / correction
`az network vnet` subcommands are inconsistent in whether they return `addressPrefix`
or `addressPrefixes` for subnet data — always check raw JSON output rather than
assuming a `--query` path based on one command's shape.

## Environment constraint (documented, not skipped)
Application Security Group creation is blocked in this sandbox by a custom RBAC role
that explicitly omits `Microsoft.Network/applicationSecurityGroups/*`. ASG concepts are
fully covered via Microsoft Learn theory above; hands-on creation was not possible in
this specific training environment. Flagged as a predicted, likely recurring
constraint for LAB_05's VPN Gateway task too (`localnetworkgateways` explicitly denied).

## Next
Task 4 (public/private DNS zones) to close out LAB_04, then LAB_05 (VPN/peering
connectivity) and LAB_06 (load balancing/Application Gateway).
