# Lab 15 — Blob Storage: Containers, Access Tiers, Lifecycle Management (Portal)

**Date:** 2026-08-24/25
**AZ-104 Domain:** 2 — Storage
**Environment:** Fortray/Simplilearn training sandbox (`ODL-az-XXXXXXX`, rotates per session)
**Format:** Azure Portal — following Microsoft's official LAB_07 (Manage Azure Storage)
**Reference:** [MicrosoftLearning/AZ-104-MicrosoftAzureAdministrator, LAB_07](https://github.com/MicrosoftLearning/AZ-104-MicrosoftAzureAdministrator)

## Objective
Create a storage account and blob container via the Portal, understand and prove the
difference between inferred and explicit access tiers, and build a working lifecycle
management rule to automate tier transitions and deletion.

## What I did
1. Created a storage account (`Standard_LRS`) in the sandbox. Chose LRS deliberately:
   the resource has a guaranteed short lifespan (6-hour sandbox session), so paying for
   ZRS/GRS/GZRS protection against slow-developing failures (disk/datacenter loss) has
   no real benefit here — redundancy risk scales with how long data needs to survive.
2. Noticed the account defaulted to `Minimum TLS version: 1.2` and
   `Public network access: Enabled from all networks` on creation — unlike my own
   subscription's storage account, which defaulted to TLS1.0. Hardened networking via
   Portal (Networking → Public network access → Enabled from selected networks → added
   my client IP), reasoning that network exposure risk is continuous/binary regardless
   of resource lifespan, unlike redundancy risk which scales with time.
3. Created a private blob container (`lab-blobs`), uploaded a test blob.
4. Confirmed the uploaded blob showed `Access tier: Hot (Inferred)` — meaning it wasn't
   explicitly tiered, just following the storage account's default tier.
5. Manually changed the blob's tier to Cool via "Change tier" — confirmed the
   "(Inferred)" label disappeared and `Access tier last modified` populated with a real
   timestamp, proving the tier was now explicitly set on the blob itself, independent of
   the account default.
6. Built a lifecycle management rule (`demo-tier-transition`) with two ordered
   conditions: blobs not modified in 30+ days → move to Cool; blobs not modified in
   365+ days → delete.

## Key concept — Inferred vs. Explicit tier
A blob's access tier is either inherited from the storage account default (inferred,
changes if the account default changes) or explicitly set on that specific blob (fixed,
independent of the account default afterward). This matters for real troubleshooting:
an unexpected cost or behavior change across many blobs at once often traces back to
someone changing the account-level default tier, which only affects inferred blobs.

## Key concept — Why 30/365 days, not arbitrary numbers
The 30-day threshold isn't a hard technical requirement — Azure would accept any
threshold. It's chosen to align with Cool tier's minimum retention period, so that a
blob tiered down at day 30 won't trigger the early-deletion/rewrite penalty if it needs
to be moved back to Hot or deleted shortly after. Aligning lifecycle rule thresholds with
each tier's minimum retention period is the actual reasoning, not just "pick round numbers."

## Real-world relevance
Manual tier management doesn't scale past a handful of blobs — lifecycle rules are how
real Azure environments handle cost optimization on storage automatically. This is
exactly the kind of policy an Azure Advisor cost review would recommend implementing on
an account that's been serving Hot-tier costs on data nobody has touched in months.

## Gotcha
The Portal enforces rule ordering — lifecycle actions must progress
hot → cool → archive → delete; you can't configure a rule that deletes before archiving
or archives before cooling. Worth remembering as a real constraint, not just a UI quirk.

## Note on session/sandbox constraints
This session's resource group (`ODL-az-2360410`) will not persist — the sandbox resets
after each 6-hour session or on relaunch. Rebuilt the whole exercise fresh mid-session
after an earlier session expired; conceptual understanding carried over even though the
resources didn't. Worth treating each Fortray sandbox session as fully self-contained.

## Still to do (Storage domain, Phase 2)
- SAS tokens (generation, scope, expiry) — not yet covered hands-on
- AzCopy / Storage Explorer — not yet covered
- File shares — not yet covered
