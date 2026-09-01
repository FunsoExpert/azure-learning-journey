# Lab 27 — Official LAB_08 Tasks 3-4: VM Scale Set + Autoscale Configuration

**Date:** 2026-09-01
**AZ-104 Domain:** 3 — Compute (horizontal scaling)
**Environment:** Fortray/Simplilearn sandbox, `odl-az-2371519`
**Format:** CLI
**Reference:** [Official Microsoft LAB_08, Tasks 3-4](https://microsoftlearning.github.io/AZ-104-MicrosoftAzureAdministrator/Instructions/Labs/LAB_08-Manage_Virtual_Machines.html)

## Objective
Create a zone-balanced VM Scale Set and configure metric-based autoscale rules,
closing the horizontal-scaling gap explicitly flagged after Lab 22 (Container Apps),
and correcting an earlier prediction about policy strictness along the way.

## What I did
1. Predicted the sandbox's `az13038-PolicyDefinition` might apply MORE strictly to
   VMSS than regular VMs, given it manages multiple instances. Tested directly rather
   than assuming: `az vmss create` with a policy-compliant size (`Standard_DS2_v2`) and
   disk SKU (`Standard_LRS`) from the start succeeded cleanly, first try — the policy
   applies the same allowed-list logic to Scale Sets as to individual VMs, no additional
   restriction. Recorded as a corrected prediction rather than assumed confirmed.
2. Noted the created Scale Set used `"orchestrationMode": "Flexible"` — the modern
   default, where each instance behaves more like an independent VM resource rather
   than the older, more rigid Uniform mode.
3. Noted a Load Balancer (`az104-vmssLB`) was auto-provisioned without being explicitly
   requested — confirms the architectural link from theory: a Scale Set is fundamentally
   built to distribute traffic across its instances, so a Load Balancer is a
   near-mandatory companion, not optional.
4. Attempted to verify zone placement via `az vmss list-instances --query zones` — came
   back empty. Rather than assume the `--zones 1 2` flag had failed, cross-checked with
   `az vm list --query zones[0]` instead (reasoning: Flexible-mode instances are real VM
   resources under the hood, so standard VM queries should work). Confirmed correctly:
   `az104-vmss_0811cb29` → Zone 1, `az104-vmss_ea377b59` → Zone 2. Real evidence that
   VMSS-specific tooling and Flexible orchestration mode don't always line up cleanly —
   worth checking data through more than one command path when a result looks wrong.
5. Created an autoscale profile (`az monitor autoscale create`, min 2/max 5/default 2)
   — confirmed via the profile's own `"rules": []` and the CLI's own follow-up message
   that a profile with no rules does nothing regardless of load, matching the correct
   prediction made beforehand (though the reasoning offered — "no traffic yet" — was
   refined to the more precise point: no rule exists to react to ANY condition, traffic
   or not).
6. Created a scale-out rule (CPU > 70% avg over 10 min → +1 instance) and a scale-in
   rule (CPU < 20% avg over 10 min → -1 instance). CLI proactively warned after the
   scale-out-only state: "Profile has rules to scale out but none to scale in" —
   direct platform confirmation of the hysteresis concept discussed before running it.

## Key concept — Hysteresis / threshold gap
A deliberate buffer between scale-out and scale-in thresholds (here, 70% down to 20%,
not a narrow band like 70%/69%) prevents "flapping" — rapid, oscillating scale actions
when load hovers near a single boundary. Flapping wastes cost on provisioning churn and
can disrupt connections as instances are repeatedly killed and recreated.

## Key concept — Cooldown period (distinct from hysteresis)
Each rule's `"cooldown": "PT5M"` is a separate anti-flapping mechanism: a mandatory
minimum wait after any scale action before that rule can trigger again. This addresses a
different risk than the threshold gap — a newly added instance takes time to actually
boot and start absorbing load, so allowing another scale-out immediately (before the new
instance has had any effect on the average metric) would be premature. Hysteresis
addresses noisy metrics near a boundary; cooldown addresses the time lag before a scale
action's effect is actually reflected in the metrics.

## Key concept — Flexible vs Uniform orchestration mode
Flexible mode (the modern default) treats each Scale Set instance more like an
independent VM resource — directly evidenced by `az vm list` successfully returning
zone data that the VMSS-specific `list-instances --query zones` query missed entirely.
Worth remembering which CLI command family to reach for depending on orchestration mode
when troubleshooting a real Scale Set.

## Real-world relevance
This is the actual production pattern for "our app gets hammered during business hours
and sits idle overnight" — instead of manually resizing or manually adding/removing VMs
(what we did by hand in Labs 24-26), a Scale Set with well-tuned autoscale rules handles
this automatically, safely, without human intervention, while the hysteresis/cooldown
mechanisms protect against a naively-configured system making things worse rather than
better.

## Status
This closes the horizontal-scaling gap flagged after Lab 22 — VM Scale Sets and
autoscale are now covered hands-on, completing the Compute domain's VM-scaling content
in full, following Microsoft's official lab document as agreed going forward.
