# Lab 17 — AzCopy, Control Plane vs Data Plane RBAC, Multi-Identity Troubleshooting

**Date:** 2026-08-25
**AZ-104 Domain:** 2 — Storage (with Domain 1 RBAC overlap)
**Environment:** Own subscription (`sazlearnfoa164`)
**Format:** CLI (AzCopy + Azure CLI)

## Objective
Install and use AzCopy to transfer a file into Blob Storage, and — unplanned but far
more valuable — properly diagnose a real `AuthorizationPermissionMismatch` error rather
than guessing at a fix.

## What I did
1. Installed AzCopy via `winget install --id Microsoft.Azure.AZCopy.10` (plain
   `Microsoft.AzCopy` didn't match; needed the exact package ID).
2. Hit a stale-IP firewall block on `sazlearnfoa164` before even reaching AzCopy —
   my public IP had changed since the rule was set (ISP-assigned dynamic IP). Diagnosed
   by comparing `networkRuleSet.ipRules` against my actual current IP
   (`ifconfig.me`), rather than assuming the block was something else. Added the new IP
   as an allowed rule and confirmed access restored.
3. Ran `azcopy login` — rejected outright when it defaulted to the multi-tenant login
   endpoint and picked up a personal Microsoft account; personal accounts aren't
   accepted there. Fixed by specifying `--tenant-id` explicitly for my Azure for
   Students tenant.
4. Attempted `azcopy copy` — failed with `AuthorizationPermissionMismatch` (403), despite
   being Owner on the subscription. Diagnosed this as the real, separate concept of
   **control plane vs data plane RBAC** (see Key Concept below), not a permissions
   error I could just "add more Owner" to fix.
5. Granted `Storage Blob Data Contributor` explicitly, scoped to just the storage
   account. Retried — still failed with the same error.
6. Diagnosed further rather than assuming propagation delay: compared the UPN `az`
   was authenticated as (`funso.aringbangba_outlook.com#EXT#@...`, confirmed via
   `az ad signed-in-user show`) against the identity AzCopy's device-code login had
   silently defaulted to (`funso.aringbangba@gmail.com`) — two separate guest
   identities in the same tenant, only one of which held the new role assignment.
7. Re-ran `azcopy login`, this time deliberately selecting the correct (outlook)
   identity instead of the gmail one the picker defaulted to. Retry succeeded:
   `100.0%`, `1 Done, 0 Failed`, `Final Job Status: Completed`.

## Key concept — Control plane vs. data plane RBAC
Azure Storage RBAC is split into two layers that are easy to conflate:
- **Control plane** — managing the storage account resource itself (create/delete
  account, configure networking, tiers, and — critically — creating/deleting
  *containers*, since that's an ARM resource-provider action). Covered by standard
  roles like Owner/Contributor at the subscription or resource level.
- **Data plane** — actually reading/writing *content* inside blobs. Requires a
  separate category of RBAC permission (`DataActions`), granted by roles like
  **Storage Blob Data Contributor**, **Storage Blob Data Reader**, etc.
**Owner and Contributor do NOT automatically grant blob data-plane access when
authenticating via Microsoft Entra ID** — this is exactly why `az storage container
create --auth-mode login` worked (control plane) while `azcopy copy` (data plane)
failed, using the exact same account, until the explicit data-plane role was granted.

## Key concept — Multiple guest identities in one tenant
An external/guest account can be represented by more than one identity object in a
tenant if it's been added via different invite flows or sign-in methods (here: an
outlook.com-based UPN vs. a gmail.com-based one, both tied to what I think of as "my"
account). RBAC assignments are tied to the specific identity object, not to "me" as a
person — granting a role to one doesn't grant it to the other. Diagnosed by explicitly
comparing `az ad signed-in-user show`'s UPN against which account a separate tool's
login flow actually selected, rather than assuming they were the same.

## Real-world relevance
This entire chain is exactly the shape of a real production access-denied ticket:
symptom (403) → wrong initial assumption (permissions/propagation) → systematic
comparison of actual identity/role data → root cause → fix → verify. The
control-plane/data-plane distinction specifically is a genuinely common real confusion —
"but I'm Owner, why can't I read the blob" is a real support question, not just exam
trivia.

## Gotcha
`winget install Microsoft.AzCopy` doesn't resolve — needs the exact package ID
`Microsoft.Azure.AZCopy.10`. Also: winget requires a fresh shell after install for PATH
changes to take effect — the same terminal window won't recognize the new command.

## Note
This lab happened while genuinely troubleshooting a real, unplanned failure rather than
following a script — worth remembering as the more valuable kind of lab experience.
