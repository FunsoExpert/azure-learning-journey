# Lab 22 — Azure Container Apps: PaaS vs IaaS Comparison

**Date:** 2026-08-27
**AZ-104 Domain:** 3 — Compute
**Environment:** Fortray/Simplilearn sandbox (fresh instance, `ODL-az-2367207`)
**Format:** CLI

## Objective
Deploy a containerized app via Azure Container Apps and directly compare the
operational experience against the raw VM work from Labs 19-21 — specifically around
networking, TLS, and scaling — to understand the real PaaS vs IaaS trade-off, not just
define it.

## What I did
1. Registered required resource providers (`Microsoft.App`, `Microsoft.OperationalInsights`)
   — correctly predicted this wouldn't be blocked by `az13038-PolicyDefinition`, since
   provider registration is a subscription-level administrative action, not creation of
   a billable resource instance the policy's rules evaluate against.
2. Created a Container Apps environment (`az containerapp env create`) — noted in the
   output that `vnetConfiguration: null` yet the environment still received a public
   `staticIp` and `publicNetworkAccess: Enabled` automatically, with no VNet or NSG
   defined by me at all.
3. Deployed a sample container (`containerapps-helloworld`) with `--ingress external`
   and a target port — got a live, publicly accessible HTTPS URL immediately, no
   separate networking step required.
4. Correctly predicted (after initial uncertainty, worked through properly rather than
   guessing blind) that no NSG rule would be needed — Container Apps' ingress is handled
   by the platform's own internally-managed layer, not a customer-configurable NSG the
   way a raw VM's networking is.
5. Verified the app's scaling configuration: `minReplicas: null` (effectively 0 by
   default for HTTP ingress), `maxReplicas: 10`, `cooldownPeriod: 300` (5 minutes idle
   before scaling down). Confirmed via Microsoft Learn docs that scale-to-zero incurs no
   usage charges, but trades this for a cold-start delay (typically 15-30 seconds) on the
   next request after idling down.

## Key concept — PaaS vs IaaS, demonstrated not just defined
Every manual step required for the raw VM (Labs 19-21) — creating an NSG, opening a
specific port, installing a monitoring agent, configuring HTTPS/TLS — was either handled
automatically or entirely unnecessary here:
| Concern | Raw VM (IaaS) | Container Apps (PaaS) |
|---|---|---|
| Network access | Manual NSG rule required | Handled by platform ingress, no NSG |
| HTTPS/TLS | Not configured (served plain HTTP) | Automatic, Microsoft-managed certificate |
| Logging/monitoring | None until an agent/extension installed | Log Analytics workspace auto-provisioned |
| Scaling | Manual (resize VM, or build a Scale Set separately) | Built-in, including scale-to-zero |
This is the actual substance behind "PaaS abstracts infrastructure management" — not a
slogan, but a measurable difference in how many manual steps were required for
equivalent outward-facing functionality (a reachable web endpoint).

## Key concept — Scale-to-zero cost/latency trade-off
No charges are incurred while at zero replicas, but the first request after an idle
period triggers a cold start that can take 15-30 seconds depending on the container's
size and startup work. Real-world guidance: keep `minReplicas` at 1+ for production
user-facing apps where latency matters; scale-to-zero is best suited to dev/staging
environments or event-driven backend workloads (e.g. queue processors) where occasional
delay is acceptable in exchange for near-zero idle cost.

## Real-world relevance
Container Apps is the realistic middle-ground choice when a team has a containerized
app and wants it running in Azure without taking on Kubernetes cluster management
(AKS) or accepting the more limited feature set of plain Container Instances (ACI).
Understanding exactly which operational burdens (networking, TLS, scaling, logging) are
absorbed by the platform — demonstrated directly here rather than assumed — is the kind
of comparison a real architecture decision would rest on.

## Gotcha
Container Apps' `minReplicas: null` in the API response doesn't mean "unset/broken" —
it reflects the platform default behavior (effectively 0 with HTTP-based scaling),
distinct from explicitly setting `minReplicas: 0`.
