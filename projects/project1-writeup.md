# Implement Azure IaaS — Course-End Project 1

## Business Scenario

OSS Corporation is a globally distributed firm headquartered in East US, with a branch
office in Southeast Asia. For a new project, the application tier will be deployed in
the branch region, while the data tier must remain in the headquarters region for
security reasons. Communication between the application and data tiers must occur over
a private channel rather than the public internet.

## Objective

Deploy two Azure Virtual Networks — one in each region — connect them via VNet Peering
so that application and data tiers can communicate privately, and validate the
connection with a live ping test between test VMs deployed in each network.

## Architecture Decision: VNet Peering, not VPN Gateway

The original brief mentions preparing the branch network for connectivity via a
"virtual network gateway," but the stated activities call for **VNet Peering**. These
are different mechanisms: a VPN Gateway is used to connect Azure to something outside
Azure (on-premises networks, another cloud). Since both networks here are Azure VNets,
**VNet Peering** is the correct, native mechanism — it connects two Azure VNets directly
over Azure's private backbone, with no gateway hardware required, lower latency, and no
additional gateway cost. Peering was used throughout this project.

Because the two VNets span different Azure regions (East US and Southeast Asia), this
specifically is **Global VNet Peering** (as opposed to Local peering, which connects
VNets in the same region). Both are configured identically; the distinction is purely
based on whether the peered regions match.

## Activity 1 — Create the Virtual Networks

Two non-overlapping VNets were created, one per region, per Azure Peering's hard
requirement that peered networks cannot share overlapping IP address spaces:

| VNet | Region | Address Space | Subnet |
|---|---|---|---|
| `VNet-HQ-DataTier` | East US | 10.1.0.0/16 | DataSubnet (10.1.1.0/24) |
| `VNet-Branch-AppTier` | Southeast Asia | 10.2.0.0/16 | AppSubnet (10.2.1.0/24) |

Both VNets provisioned successfully on the first attempt via Azure CLI.

## Activity 2 — Deploy Test VMs

One `Standard_DS1_v2` VM was deployed into each VNet's subnet, per the project
specification:

| VM | Region | Private IP | Public IP |
|---|---|---|---|
| `VM-HQ-DataTier` | East US | 10.1.1.4 | 172.173.249.190 |
| `VM-Branch-AppTier` | Southeast Asia | 10.2.1.4 | 4.193.175.185 |

Both VMs deployed successfully and reported `powerState: VM running` immediately.

## Activity 3 — Establish VNet Peering

Per Azure's peering requirements, a peering relationship must be explicitly created in
**both directions** — creating a peering from VNet A to VNet B does not automatically
create the reverse relationship. Two peerings were created:

- `HQtoBranch` — on `VNet-HQ-DataTier`, pointing to `VNet-Branch-AppTier`
- `BranchtoHQ` — on `VNet-Branch-AppTier`, pointing to `VNet-HQ-DataTier`

Both peerings were verified independently via `az network vnet peering list` on each
VNet, confirming `PeeringState: Connected` and `PeeringSyncLevel: FullyInSync` on both
sides — a genuinely established bidirectional relationship, not assumed from a single
successful command.

## Activity 4 — Validate Connectivity

Connectivity was validated by SSH-ing into `VM-HQ-DataTier` and pinging
`VM-Branch-AppTier`'s private IP address directly:

```
ping -c 4 10.2.1.4
```

**Result: 4 packets transmitted, 4 received, 0% packet loss**, average round-trip time
of ~222ms — consistent with the real physical distance between East US and Southeast
Asia. No additional NSG configuration was required: Azure's default Network Security
Group rule `AllowVnetInBound` automatically expands its `VirtualNetwork` service tag to
include a peered VNet's address space once peering is active, so the default rules
already permitted the traffic.

## Conclusion

The deployment successfully satisfies OSS Corporation's requirement: the application
tier (Southeast Asia) and data tier (East US) can communicate over a private channel
using Azure's backbone network via VNet Peering, without exposing either tier to the
public internet, and without requiring a VPN Gateway. The ~222ms measured latency is a
real, quantifiable factor worth weighing in the broader architecture discussion, since
it reflects the actual cost of the security-driven decision to keep the data tier
geographically separate from the application tier.

## Environment Note

This project was completed in a Simplilearn/Fortray training sandbox subscription. All
resource names, addresses, and regions above are exactly as deployed and verified;
where the sandbox's identity carries a restricted custom RBAC role (encountered
elsewhere in this course), no such restriction affected this project's required
resource types.
