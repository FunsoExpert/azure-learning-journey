# Lab 29 — App Service: Plans, Tiers, and Deployment Slots (Portal Walkthrough)

**Date:** 2026-09-02
**AZ-104 Domain:** 3 — Compute
**Environment:** Fortray/Simplilearn sandbox, `odl-az-2372009`
**Format:** CLI (attempted) + Azure Portal (fallback, due to environment constraint)

## Objective
Understand and confirm precisely which App Service tiers support deployment slots and
autoscaling, closing out the final Compute domain gap from the earlier cross-check
against Microsoft's official skills outline.

## Environment constraint (documented honestly, not skipped)
Attempted `az appservice plan create` three times — Linux B1, Linux F1, and default
(Windows) F1 — all three failed identically with a quota error:
`Current Limit (Total VMs): 0`, regardless of SKU or OS. This confirms a genuine,
total App Service quota block on this particular training subscription, not a
config or policy issue that could be worked around (ruled out policy specifically: this
was a quota message, not a `RequestDisallowedByPolicy` message — a third distinct
category of "no" in Azure, alongside Policy deny and platform/SKU capability limits,
now all three encountered directly this course). Fell back to a thorough Portal
walkthrough of the Create Web App experience instead of hands-on deployment.

## What I did
1. Opened the Create Web App blade, explored the Pricing plan selector — confirmed the
   App-Service-Plan-as-compute-sizing concept directly: Free F1, Basic B1 (1.75GB/1vCPU),
   through Premium v3/v4 tiers, up to Isolated v2 — same conceptual pattern as VM sizing,
   packaged as a managed-platform tier instead.
2. Checked "Hardware view" — confirmed Free F1 shows `N/A` SLA (no SLA guarantee
   whatsoever, not just a low one), and Basic B1 supports manual scaling up to 3
   instances (correcting an initial oversimplification that Basic has no scaling at all
   — it lacks AUTOSCALING specifically, but fixed manual scale-out is available even on
   Basic).
3. Switched to "Feature view" — confirmed precisely, from the live UI:
   - **Staging slots**: `N/A` on Free AND all Basic tiers (B1/B2/B3) — no deployment
     slots at any Basic-or-below tier. Premium tiers show **20** staging slots.
   - **Auto Scale**: `Manual` on Basic, `Rules` (metric-based, same mechanism as the
     VMSS autoscale rules built in Lab 27) or `Rules,Elastic` on Premium tiers.
   - **Zone Redundant**: unchecked on Free/Basic, checked from Premium tier upward —
     App Service's equivalent of the Availability Zone concept from Lab 24, gated by
     pricing tier rather than a deployment-time zone selection like VMs.
   - Standard tier's exact slot count was not directly confirmed (scrolled past/not
     visible in the captured view) — noted as a genuine gap rather than assumed.

## Key concept — corrected and now fully confirmed: deployment slots by tier
Original assumption going into this lab was "Standard tier and above supports
deployment slots." Directly confirmed via the Portal's own Feature view comparison
table, including a follow-up scroll to locate the previously-missing Standard tier row:
- **Free / Basic (B1/B2/B3): `N/A`** — zero deployment slots at any tier this low
- **Standard (S1/S2/S3): `5`** staging slots
- **Premium (v2/v3/v4): `20`** staging slots
- **Isolated: `N/A`** in this view — noted as likely a display artifact of the "Legacy"
  categorization in this particular UI screen rather than an actual limitation, since
  Isolated tier generally matches or exceeds Premium's capabilities in Microsoft's
  broader documentation; flagged honestly as unconfirmed rather than assumed either way.
This fully closes the gap left open earlier in the same lab, where Standard's exact
figure wasn't initially visible — corrected with real, confirmed data rather than left
as a guess.

## Key concept — a third distinct category of "no" in Azure
This course has now directly encountered three genuinely different mechanisms that can
block an action, each requiring a different diagnostic approach:
1. **Azure Policy `deny`** — an organizational rule (`RequestDisallowedByPolicy`),
   diagnosable via `az policy definition show`.
2. **Platform/SKU capability limits** — the feature structurally doesn't exist at a
   given tier (e.g. no deployment slots on Basic), diagnosable via the pricing/feature
   comparison tables, not an error message at all — it's simply absent from the UI/API.
3. **Subscription/region quota** — the tier and policy both permit the action, but this
   specific subscription has zero allocated capacity (`Current Limit (Total VMs): 0`),
   diagnosable via the quota error's own explicit message, distinguishable from a policy
   error by its wording and lack of a `policyAssignment` reference.

## Real-world relevance
Deployment slots are the practical implementation of blue-green deployment — deploying
new code to a staging slot, validating it under production-like conditions, then
swapping with zero downtime, with an equally fast rollback path if something's wrong.
This is directly relevant release-management practice, connecting to prior ITIL/change
management experience, just implemented as a specific, tier-gated Azure feature rather
than an abstract process.

## Status
This closes out the App Service gap and, with it, the full Compute domain cross-check
against Microsoft's official skills outline from earlier in this course — VM
creation/scaling/extensions, ARM/Bicep, Container Apps, Container Instances, App
Service, and patch management are all now covered, either hands-on or via documented,
honest Portal-only fallback where a genuine environment constraint blocked direct testing.
