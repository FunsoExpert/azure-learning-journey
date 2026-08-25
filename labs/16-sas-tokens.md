# Lab 16 — Shared Access Signatures (SAS)

**Date:** 2026-08-25
**AZ-104 Domain:** 2 — Storage
**Environment:** Fortray/Simplilearn training sandbox
**Format:** Azure Portal

## Objective
Generate a scoped, time-limited SAS token for a blob, understand the three SAS types
and their security trade-offs, and understand real revocation options when a token leaks.

## What I did
1. Generated a Service SAS on a single blob via the Portal's "Generate SAS" blade:
   Read-only permission, HTTPS-only, 1-hour expiry window (corrected after an initial
   AM/PM mistake gave a 13-hour window instead of 1 hour — caught by checking the actual
   `st=`/`se=` values in the generated URL rather than trusting the picker).
2. Decoded the generated SAS URL's query parameters to understand the structure:
   `sp` (permissions), `st`/`se` (start/expiry), `spr` (protocol restriction), `sv`
   (service version), `sr` (signed resource type — blob vs container), `sig` (the
   cryptographic signature — functions as the actual secret/credential in the URL).
3. Worked through what Read permission actually grants on a blob — corrected my own
   assumption that "read" and "download" were separate; for blob storage they're the
   same action, there's no view-without-download concept.

## Key concept — Three SAS types
- **Account SAS** — broadest scope, can span multiple services (Blob, File, Queue,
  Table) and multiple operation types across the whole account.
- **Service SAS** — scoped to one service, can target a specific container or blob.
  What I generated in this lab.
- **User delegation SAS** — secured with Microsoft Entra ID credentials instead of the
  storage account key. More secure because it isn't tied to the account key at all — it
  inherits the permission model and auditability of Entra ID, and isn't affected by
  storage account key rotation.

## Key concept — SAS tokens cannot be individually revoked
This was my main misconception going into this lab, worth recording precisely: a SAS
token is a signed string validated at request time — there is no central registry
Azure checks, so generating a new SAS does NOT invalidate a previously issued one; both
remain valid independently until they each expire on their own.

Real remediation if a Service/Account SAS leaks:
1. **Rotate the storage account key it was signed with** — invalidates every SAS tied
   to that key immediately, but also breaks every other legitimate SAS/application still
   using that same key. Blunt, high blast-radius option.
2. **Stored Access Policy** — if the SAS was issued against a named policy defined on
   the container (rather than carrying permissions/expiry directly in the signed URL),
   revoking or modifying that policy immediately cuts off every SAS tied to it, without
   affecting the account key or unrelated tokens. The surgical option — but only
   available if the SAS was deliberately built this way in the first place.

## Real-world relevance
SAS tokens are how you'd grant a third-party integration, contractor, or temporary
process narrow, time-boxed access to storage without ever handing over the account key.
Getting the expiry window right matters for real security, not just lab hygiene — I
caught my own AM/PM mistake that would have left a "1-hour" token valid for 13 hours in
a real scenario. Designing SAS usage around stored access policies from the start (rather
than raw SAS URLs) is the kind of decision that determines whether a future leak is a
5-minute fix or a "rotate the key and break other things too" incident.

## Credential hygiene note
Practiced (imperfectly, corrected mid-lab) not sharing full SAS URLs including the `sig`
value — the signature functions as the actual secret. Redacting everything after `sig=`
when discussing or documenting a SAS URL going forward.

## Gotcha
"Read" permission on a blob = can retrieve/download the content; there's no separate
read-only-no-download mode. Don't conflate blob-level "read" with more granular
view-vs-download models that exist in other systems.
