# Lab 28 — Azure Container Instances (ACI): Comparison Against Container Apps

**Date:** 2026-09-02
**AZ-104 Domain:** 3 — Compute
**Environment:** Fortray/Simplilearn sandbox, `odl-az-2372009`
**Format:** CLI

## Objective
Deploy a single Container Instance and directly measure/compare its provisioning
speed and feature set against Azure Container Apps (Lab 22), to ground the "ACI is
simpler/faster but less managed" theory in real evidence rather than description.

## What I did
1. First attempt failed with `RequestDisallowedByPolicy` — `az13038-PolicyDefinition`'s
   Container Instance clause requires `properties.sku` to explicitly equal `"Standard"`;
   an unset/default value evaluated as not matching, same "unset property fails an
   equality check" pattern seen repeatedly with other resource types this course.
2. Second attempt (with `--sku Standard --cpu 1 --memory 1` added, matching the policy's
   other allowed values seen in the original policy dump) failed differently:
   `InvalidOsType` — `az container create` requires an explicit `--os-type` flag; it
   does not infer OS from the image.
3. Third attempt, adding `--os-type Linux`, succeeded: `provisioningState: Succeeded`,
   container `state: Running`, live public FQDN
   (`az104-aci-demo.eastus.azurecontainer.io`) serving the expected "Welcome to Azure
   Container Instances!" page — confirmed visually in browser.
4. Measured wall-clock time directly with the `time` command: **~37 seconds** total for
   the successful deployment, with the container itself (per its own event log
   timestamps) pulled and started within about 14 seconds of the request being accepted.
   Directly contrasts with Container Apps' environment creation in Lab 22, which took
   several minutes before any container could even be deployed — ACI skips the entire
   managed-environment provisioning step (no Log Analytics workspace, no ingress
   controller) that Container Apps requires up front.
5. Noticed `"zones": null` in the response — ACI does not support Availability Zone
   placement the way VMs/VMSS do; the speed and simplicity trade away that redundancy
   option entirely.
6. Noticed the browser flagged the live URL "Not secure" (plain HTTP) — unlike Container
   Apps, which provisioned free automatic HTTPS with a Microsoft-managed certificate by
   default. ACI has no built-in TLS; fronting it with Application Gateway, Front Door,
   or a custom reverse proxy would be required for HTTPS in a real deployment.

## Key concept — ACI vs Container Apps, now with measured evidence
| Aspect | Container Instances (ACI) | Container Apps |
|---|---|---|
| Provisioning time | ~37s, no environment step | Multi-minute environment setup required first |
| Scaling | None — fixed instance, no orchestration | Built-in, including scale-to-zero |
| HTTPS | Not provided — plain HTTP by default | Automatic, Microsoft-managed certificate |
| Availability Zones | Not supported (`zones: null`) | Not directly tested, platform-managed |
| Best fit | Short-lived, one-off, batch/CI jobs | Persistent, user-facing web workloads |

## Real-world relevance
ACI's genuine use case is short-lived or batch-style work — a CI/CD build agent, a
data-processing job that runs briefly and exits — not a persistent user-facing service.
The measured ~37-second deployment with no environment overhead is exactly why it suits
that use case; the complete absence of TLS and scaling is exactly why it doesn't suit
Container Apps' use case. Choosing between the two in a real architecture decision is a
genuine trade-off between startup speed/simplicity and production-readiness features,
not a strictly-better-or-worse comparison.

## Gotcha
`az container create` requires `--os-type` explicitly; unlike some other Azure create
commands, it does not infer this from the image reference.
