# Lab 09 — Entra ID Groups + Group-Based RBAC

**Date:** 2026-08-17/18
**AZ-104 Domain:** 1 — Identity & Governance

## Objective
Understand and prove the real-world pattern of assigning RBAC roles to groups rather
than individual users, and confirm group-membership-based inheritance works as expected.

## What I did
1. Created a security group (`az ad group create`) — confirmed `securityEnabled: true`,
   `mailEnabled: false` (pure security group, not a Microsoft 365 group).
2. Created a test user (`az ad user create`).
3. Added the user to the group (`az ad group member add`), verified with
   `az ad group member list`.
4. Assigned the group (not the user) a Reader role at the resource group scope, using
   `--assignee-object-id` + `--assignee-principal-type Group` explicitly to avoid CLI
   ambiguity errors.
5. Verified the group shows up correctly in `az role assignment list`.
6. Cleaned up all test objects (role assignment, group, user) — none left behind.

## Key concept
Two distinct kinds of "inheritance" in Azure RBAC:
- **Scope inheritance** (top-down through Mgmt Group → Subscription → RG → Resource)
- **Group membership inheritance** (anyone in a group inherits whatever role the group holds)
Both are tested separately on the exam — don't conflate them.

## Real-world relevance
This is the standard onboarding/offboarding pattern in any real Azure environment:
add/remove a user from a group instead of managing individual role assignments.
Directly reusable for a future incident like "new starter needs access" or
"leaver still has access, remove immediately."

## Gotcha
CLI sometimes needs `--assignee-principal-type` specified explicitly (vs. plain
`--assignee`) to avoid ambiguity when resolving whether an ID is a user, group, or
service principal.