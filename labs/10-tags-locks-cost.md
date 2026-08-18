# Lab 10 — Tags, Resource Locks, Cost Management Basics

**Date:** 2026-08-18
**AZ-104 Domain:** 1 — Identity & Governance

## Objective
Understand and prove how tags, resource locks, and cost management fit into Azure
governance — specifically that tags carry no security meaning, and that locks are the
one mechanism that overrides even Owner-level RBAC.

## What I did
1. Applied tags (`environment=learning`, `owner=funso`) to the storage account
   `sazlearnfoa164` using `az resource tag`, verified with `az resource show --query tags`.
2. While reviewing the tagged resource's full output, spotted two insecure defaults that
   `az storage account create` leaves in place unless explicitly hardened:
   - `minimumTlsVersion: TLS1_0` (weakest supported TLS version)
   - `networkAcls.defaultAction: Allow` (public network access allowed by default)
   Flagged to fix in Week 2 (Storage) — not addressed yet, deliberately left as-is for now.
3. Created a `CanNotDelete` lock on `rg-az104-learn` with `az lock create`.
4. Attempted `az group delete` on the locked resource group while still logged in as
   Owner on the subscription — confirmed it failed with `(ScopeLocked)`, proving locks
   override RBAC entirely, including Owner.
5. Left the lock in place intentionally (resource group is still needed for Week 2 labs).

## Key concept
Two distinct lock types, easy to conflate:
- **`CanNotDelete`** — blocks deletion only; modification is still allowed.
- **`ReadOnly`** — blocks both modification and deletion.
Locks apply regardless of RBAC role — this is the one exception to "RBAC decides
everything," and it's directly testable as a scenario question (given a lock type,
predict what action will/won't succeed).

## Real-world relevance
Tags are the backbone of cost allocation and ownership accountability — an untagged
resource isn't just "messy," it becomes a resource nobody is confident is safe to modify
or delete, which is a real operational and security liability (unpatched, unmonitored,
unowned). Locks are the practical safeguard against accidental deletion of production
infrastructure — e.g. locking a production resource group so a mistyped `az group delete`
can't take down a live environment, even for someone with Owner rights.

## Gotcha / finding to carry forward
`az storage account create` does not deploy secure-by-default settings — TLS version and
public network access both need to be explicitly hardened after creation. This is a real,
live finding on my own subscription, not a hypothetical — to be fixed as the opening task
of Week 2 (Storage).
