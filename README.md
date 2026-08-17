# Azure Learning Journey

**Start Date:** June 4, 2026
**Target:** AZ-104 Certification + Cloud/Azure Engineer Role
**Background:** 10+ years application support (banking, utilities) — see [full roadmap](./ROADMAP.md)

---

## About This Repository

This repository documents my hands-on path from application support background to AZ-104 certified, job-ready Azure engineer. Every lab is real Azure CLI/Bicep work against a live subscription — not just reading notes.

- Hands-on labs with real Azure resources, mapped to AZ-104 exam domains
- Infrastructure as Code (Bicep)
- PowerShell/CLI automation
- Governance, cost management, and security practices
- Simulated incident response, written up ITSM-style
- Interview preparation, built alongside the technical work

See [`ROADMAP.md`](./ROADMAP.md) for the full plan this repo follows.

---

## Repository Structure

```
/labs/              - Dated lab logs: commands run, output, what broke, how it was fixed
/scripts/           - Reusable Bicep/CLI/PowerShell — not one-off throwaway commands
/scripts/policies/  - Azure Policy JSON definitions and parameters
/runbooks/          - "How to do X in production" docs, written for a teammate to follow
/architecture/       - Diagrams and design write-ups from hands-on design exercises
/interview-prep/    - Interview Q&A built up alongside the technical work
/archive/           - Superseded plans and early scratch/test artifacts, kept for history
```

---

## Lab Log

| Lab | Topic | AZ-104 Domain(s) |
|-----|-------|-------------------|
| [01](./labs/01-identity-governance-intro.md) | Storage Accounts, Bicep, PowerShell | 2, 3, 5 |
| [02](./labs/02-log.md) | Virtual Machines, NSGs, Availability | 3, 4 |
| [03](./labs/03-log.md) | Azure Policy, RBAC, Governance | 1 |
| [04](./labs/04-log.md) | Load Balancers, Scale Sets | 3, 4 |
| [05](./labs/05-log.md) / [App Gateway basics](./labs/05-app-gateway-basics.md) | Monitoring, Alerts, App Gateway | 4, 5 |
| [06](./labs/06-log.md) | Azure Firewall | 4 |
| [07](./labs/07-log.md) | Design exercise (see `/architecture/`) | 3, 4 |
| [08](./labs/08-log.md) | VNet Peering | 4 |

---

## AZ-104 Exam Progress

| Domain | Weight | Status |
|--------|--------|--------|
| Domain 1: Identity & Governance | 20-25% | In progress |
| Domain 2: Storage | 15-20% | Started |
| Domain 3: Compute | 20-25% | Started |
| Domain 4: Networking | 15-20% | Not started |
| Domain 5: Monitoring | 10-15% | Started |

Updated as I go — see [`ROADMAP.md`](./ROADMAP.md) for the phase-by-phase breakdown.

---

## Portfolio Projects

| Project | Technologies |
|---------|--------------|
| Governance as Code | Management Groups, Azure Policy, RBAC |
| Hands-on design exercise | See [`/architecture/hands-on-design-project/`](./architecture/hands-on-design-project/) |
| Networking (App Gateway, Firewall, VNet Peering) | Bicep, NSGs, Azure Firewall |

---

## Key Scripts

- [`scripts/storage.bicep`](./scripts/storage.bicep) — Storage account deployment
- [`scripts/deploy-lab.ps1`](./scripts/deploy-lab.ps1) — Lab environment deployment
- [`scripts/destroy-all.ps1`](./scripts/destroy-all.ps1) — Resource cleanup

---

## Connect

[LinkedIn](https://www.linkedin.com/in/funso-aringbangba-843616b9) · GitHub — you're already here

---

*"Consistency beats talent when talent doesn't show up."*