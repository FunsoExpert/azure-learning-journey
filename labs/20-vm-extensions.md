# Lab 20 — VM Extensions (Custom Script Extension) + NSG Port Access

**Date:** 2026-08-26
**AZ-104 Domain:** 3 — Compute (with Domain 4 Networking overlap — NSGs)
**Environment:** Fortray/Simplilearn sandbox
**Format:** CLI (Azure CLI in PowerShell, sandbox shell)

## Objective
Use the Custom Script Extension to automate software installation on a VM without
manual RDP/SSH, and prove the result is actually reachable externally — surfacing the
NSG concept as a real blocker along the way.

## What I did
1. Hit the `az13038-PolicyDefinition` policy again (same one from Lab 19), this time on
   a different clause — the image (`sles-15-sp5-basic`) wasn't on the allowed image list
   (Ubuntu Focal/24.04, Windows Server, CentOS 7.9, Windows 10 only). Recreated with
   Ubuntu 24.04 LTS and Standard HDD disk, matching both policy clauses this time from
   the start rather than hitting them one at a time.
2. Checked `Agent status` on the VM before attempting an extension — was `Not Ready`
   immediately after creation, became `Ready` within a couple of minutes. Correctly
   predicted the extension would fail if attempted while not ready, since extensions run
   through the VM Agent, which must be healthy first.
3. Ran `az vm extension set` with the Custom Script Extension, targeting
   `Microsoft.Azure.Extensions` / `customScript`, with a `commandToExecute` payload to
   update packages and install Nginx.
4. Hit a JSON quoting error on first attempt — backslash-escaped quotes
   (`\"..\"`) are a cmd.exe convention, not PowerShell's. Fixed by wrapping the whole
   JSON payload in single quotes with plain double quotes inside
   (`'{"commandToExecute":"..."}'`)  — PowerShell passes single-quoted strings through
   literally.
5. Verified success two ways: `az vm extension show --query provisioningState` returned
   `Succeeded`, then tried browsing to the VM's public IP directly — got
   `ERR_CONNECTION_TIMED_OUT`, correctly predicted as an NSG block rather than an
   application failure, since Nginx itself had installed successfully.
6. Ran `az vm open-port` to explicitly allow inbound port 80 with a defined priority
   (900, chosen to avoid colliding with the default SSH rule). Re-tested — got the real
   Nginx welcome page.

## Key concept — VM Extensions
An extension is a small agent-deployed package that runs configuration/management tasks
inside the guest OS, without manual interactive login. The **Custom Script Extension**
runs an arbitrary script at deployment or on-demand — this is the direct automation
equivalent of what I did manually in Lab 12 (RDP in, click through Server Manager to
install IIS). Same outcome, but scriptable, repeatable, and auditable instead of a
one-off manual action — this is the real argument for extensions/IaC over manual config
in a production environment, now demonstrated from direct before/after experience.

## Key concept — NSGs are a separate mechanism from storage network rules
Storage account network access (`networkAcls`, from Lessons 2.1/2.2) and VM network
access (Network Security Groups) are conceptually similar — both are allow/deny rules
controlling what can reach a resource — but are completely separate mechanisms tied to
different resource types. A default VM deployment's auto-generated NSG typically allows
only SSH (or RDP) inbound by default; any other port, including HTTP/80, needs an
explicit rule. `az vm open-port` is a convenience wrapper that creates this rule with a
specified priority.

## Key concept — PowerShell JSON quoting
When passing raw JSON as a CLI argument from a PowerShell shell, wrap the entire JSON
string in single quotes and leave internal double quotes as plain double quotes — no
backslash escaping needed or wanted. Backslash-escaped quotes are for cmd.exe/bash
contexts and will corrupt the JSON if used in PowerShell. This will recur with any
ARM/Bicep parameter overrides or other JSON-payload CLI commands going forward.

## Real-world relevance
The full sequence — deploy resource, apply automated configuration, discover it's
externally unreachable, diagnose as a network-layer (not application-layer) issue, open
the correct rule — mirrors a completely realistic "why can't users reach the app I just
deployed" ticket. `ERR_CONNECTION_TIMED_OUT` (no response at all) vs. a "connection
refused" error are genuinely different symptoms worth distinguishing in real
troubleshooting: timeout suggests a silent network-level block (NSG, firewall);
refused suggests the port reached the host but nothing was listening.

## Gotcha
`az vm extension set` takes noticeably longer to return than most `az` commands, since
CLI waits for the extension to actually finish provisioning inside the guest OS before
returning — not a hang, expected behavior.
