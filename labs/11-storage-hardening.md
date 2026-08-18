# Lab 11 — Hardening Storage Account Defaults (TLS + Network Rules)

**Date:** 2026-08-18
**AZ-104 Domain:** 2 — Storage (with Domain 1 governance overlap)

## Objective
Fix insecure defaults found in Lab 10 on `sazlearnfoa164`: `minimumTlsVersion: TLS1_0`
and `networkAcls.defaultAction: Allow`. Prove the fix actually blocks/restores access,
not just that the config changed.

## What I did
1. Set `minimumTlsVersion` to `TLS1_2` via `az storage account update`.
2. Predicted, then confirmed, that setting `--default-action Deny` on network rules
   would block my own access — ran `az storage container list --auth-mode login`
   and got a network-rule block error, exactly as expected.
3. Retrieved my public IP (`ifconfig.me`) and added it as an explicit allow exception
   via `az storage account network-rule add`.
4. Re-ran the container list command — got `[]` (empty array, no error) — confirmed as
   success: the request reached the account and was authorized, there just aren't any
   containers created yet. Empty result ≠ failure; an error response would look
   completely different (e.g. the earlier `RequestDisallowedByAzure`-style message).

## Key concept
TLS version and network rules protect against different things and operate at
different layers:
- **TLS version** governs the strength of encryption in transit. TLS1_0 has known
  vulnerabilities (e.g. BEAST, POODLE) and weak cipher suite support; TLS1_2 closes
  those. It does not control *who* can connect — only how safe the connection is
  if intercepted.
- **Network rules (`defaultAction` + IP/VNet rules)** govern *who* can even reach the
  account in the first place, independent of encryption strength.
Both need to be handled — hardening one without the other leaves a real gap.

## Real-world relevance
`az storage account create` does not deploy secure-by-default settings. Any real
storage account created via CLI/ARM without explicit hardening is likely running with
`TLS1_0` and open network access — a genuine, checkable finding I could raise in a
security review, not just a lab exercise. The pattern used here (deny by default, then
allow specific known-good sources) is the standard approach for locking down any
publicly-reachable Azure resource.

## Gotcha
Distinguishing an empty-but-successful response (`[]`) from an actual network/auth
failure matters for real troubleshooting — misreading one as the other leads to chasing
the wrong problem.
