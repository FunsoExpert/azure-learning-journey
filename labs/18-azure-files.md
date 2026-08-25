# Lab 18 — Azure Files (File Shares)

**Date:** 2026-08-25
**AZ-104 Domain:** 2 — Storage
**Environment:** Own subscription (`sazlearnfoa164`)
**Format:** CLI

## Objective
Create an SMB file share and correctly reason about whether the action was
control-plane or data-plane, applying the distinction learned in Lab 17.

## What I did
1. Created a 5 GB SMB file share (`lab-fileshare`) via `az storage share-rm create`.
2. Verified it via `az storage share-rm list` — confirmed `TransactionOptimized`
   access tier (the default), `SMB` protocol, correct quota.
3. Correctly predicted, before running, that this was a control-plane action (managing
   the share as a resource via ARM, not touching content inside it) — and that Owner
   alone would be sufficient, unlike AzCopy's data-plane write in Lab 17. Confirmed by
   the command succeeding with no `AuthorizationPermissionMismatch`.

## Key concept — Azure Files vs Blob Storage
Blob storage is unstructured data accessed via REST API/SDK — apps interact with it
programmatically. Azure Files is a fully managed SMB/NFS file share that can be mounted
as an actual network drive, on a VM, a local PC, or on-premises, and used exactly like a
traditional file server share. The real-world distinguishing use case: lift-and-shift
migrations where an on-prem application expects a mapped drive and can't be rewritten to
call blob APIs — Azure Files replaces the file server without touching the application.

## Key concept — Control plane vs data plane, generalized
Creating/deleting the share itself = control plane (ARM, covered by Owner/Contributor).
Actually reading/writing files inside the share = data plane, and would require the
appropriate data-plane role (or the equivalent SMB-level identity permission) separately
— the same distinction from Lab 17, now confirmed to apply to file shares too, not just
blob containers. This generalization is the actual value of this lab: proving the
concept holds beyond the one scenario where I first hit it.

## Real-world relevance
File shares come up specifically in migration scenarios and shared-config/shared-log
use cases across multiple VMs — a different shape of problem than blob storage, worth
knowing when to reach for which. The quota concept (fixed size at creation, unlike blob
containers which are effectively unbounded) is also a real capacity-planning
consideration worth remembering.

## Note
Did not upload actual file content into the share this session (a data-plane action) —
worth doing as a quick follow-up to directly test the control/data-plane prediction
about writes, the same way AzCopy surfaced it for blobs.
