# Runbook — Provisioning Access via Groups (RBAC)

**Purpose:** Grant or remove a user's access to an Azure resource group/subscription
using the group-based pattern, instead of individual role assignments.
**When to use:** New starter needs access · Leaver needs access removed · User moving
teams needs access changed.
**Owner:** Funso Aringbangba
**Last verified:** 2026-08-18 (Azure CLI)

---

## Before you start

- Confirm you know the **target group's object ID** and the **user's object ID (or UPN)**.
- Confirm the group already has the correct role assigned at the correct scope — if it
  doesn't, this is a bigger change than a simple add/remove and should go through normal
  change management, not this runbook.
- If unsure what role a group grants, check first (see "Checking what a group can do" below)
  rather than assuming from the group's name.

---

## Grant access (add user to group)

```powershell
az ad group member add --group <GROUP_OBJECT_ID> --member-id <USER_OBJECT_ID>
```

Verify:

```powershell
az ad group member list --group <GROUP_OBJECT_ID> --output table
```

Confirm the user now appears in the list.

**Note:** Group membership changes can take a short time (seconds to a couple of minutes)
to fully replicate. If the user reports access isn't working immediately, wait briefly
and re-check before troubleshooting further.

---

## Remove access (remove user from group)

```powershell
az ad group member remove --group <GROUP_OBJECT_ID> --member-id <USER_OBJECT_ID>
```

Verify the user no longer appears:

```powershell
az ad group member list --group <GROUP_OBJECT_ID> --output table
```

**For leavers specifically:** removing group membership only removes the *access this
group grants*. If the user has other role assignments (individual or via other groups),
those must be checked and removed separately — see "Checking a user's full access" below.

---

## Checking what a group can do

Find every role a group holds and at what scope, before assuming what "adding someone
to it" actually grants them:

```powershell
az role assignment list --assignee <GROUP_OBJECT_ID> --output table
```

---

## Checking a user's full access

Don't rely on group membership alone to confirm access is fully removed. Check direct
and inherited role assignments for the user across the whole subscription:

```powershell
az role assignment list --assignee <USER_OBJECT_ID> --all --output table
```

If anything appears here beyond expected group-based access, escalate — it likely means
an individual role assignment was made outside the standard group pattern at some point.

---

## Common mistakes to avoid

- Assigning a role directly to a user instead of a group "just this once" — breaks the
  pattern and makes future audits harder. Always add to the group instead, or raise a
  request to create/adjust a group if none fits.
- Assuming a more restrictive role assigned at a narrower scope will "override" a broader
  role held above it. **It won't — Azure RBAC is additive only.** Removing access always
  means removing the grant that's actually causing it, not adding a weaker one on top.
- Forgetting Azure Policy can independently block actions RBAC allows. If access looks
  correct but the user still can't act, check policy assignments at the relevant scope too.