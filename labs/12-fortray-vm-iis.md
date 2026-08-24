# Lab 12 — Create and Configure an Azure VM with IIS (Fortray Training Lab)

**Date completed (Fortray lab):** per Fortray schedule
**Documented:** 2026-08-19
**AZ-104 Domain:** 3 — Compute
**Environment:** Fortray training lab sandbox (Skillable-style shared subscription, `ODL-AZ-XXXX`) — not my own Azure for Students subscription
**Format:** Azure Portal (GUI), not CLI — different from my own self-directed labs, which are CLI/Bicep-first

## Objective
- Create an Azure VM via the Portal
- Understand core VM configuration: compute, networking, storage
- Connect to the VM via RDP
- Deploy a basic workload (IIS web server) and validate it

## Lab scenario
Acting as a Cloud Engineer provisioning a Windows Server VM to host a web application —
selecting subscription/resource group, OS image, VM size, networking (RDP port), storage,
then deploying and testing IIS as the workload.

## What I did
1. Created a VM through the Portal: Windows Server 2025 Azure Edition, size
   `Standard_DS1_V2` (1 vCPU, 3.5 GiB memory), Standard HDD disk, no infrastructure
   redundancy (single-instance, matching a basic dev/test scenario rather than production).
2. Connected via RDP using the public IP assigned to the VM.
3. Installed IIS through Server Manager → Add Roles and Features → Web Server (IIS) role,
   accepting the default role services and required features.
4. Validated the install by browsing to the VM locally and confirming the default IIS
   landing page loaded — confirmed IIS was listening on port 80 with the
   "World Wide Web Services (HTTP Traffic-In)" Windows Firewall rule enabled automatically.

## Key concept
This is the GUI-driven equivalent of what I've been doing via CLI/Bicep in my own labs —
useful to have both, since real jobs mix Portal work (quick one-off tasks, demos to
non-technical stakeholders) with CLI/IaC (repeatable, auditable, automatable). Being fluent
in both is expected of an Azure Administrator, not just one or the other.

VM sizing (`Standard_DS1_V2`) determines vCPU count, memory, and (for some series)
temporary storage and network bandwidth limits — undersizing causes performance issues
under load, oversizing wastes cost. This ties directly into Lab 14 (VM scaling).

## Real-world relevance
Standing up a quick web server for testing/demo purposes is a genuinely common task —
this lab mirrors that exact workflow, RDP-in, install IIS, validate. In production, you'd
also be thinking about NSG rules limiting RDP exposure (see my own governance/networking
labs), automating this via Bicep/ARM instead of manual clicks, and choosing redundancy
appropriate to the workload rather than "no infrastructure redundancy."

## Note on lab hygiene
This Fortray lab environment uses a shared, throwaway admin password
(documented in the original lab manual) scoped to an ephemeral training subscription
(`ODL-AZ-XXXX`), not my own subscription — no real credential exposure. Still, as a
general habit: I'm keeping this write-up free of literal credentials, since publishing
plaintext passwords in a public repo is bad practice to normalize even when the
underlying account is disposable.

## Gap / honest note
This was GUI-driven, following a structured lab manual — good for understanding VM
provisioning end-to-end, but I haven't yet replicated this specific VM+IIS deployment via
CLI/Bicep myself. Worth doing as a follow-up exercise when we reach Compute (Week 3) in my
own subscription, to reinforce the same workflow the way I've been learning everything else.
