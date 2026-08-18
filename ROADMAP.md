# Azure Engineer Roadmap — AZ-104 + Real-World Readiness

**Owner:** Funso Aringbangba
**Goal:** Pass AZ-104 AND be genuinely job-ready as an Azure Support/Admin Engineer — not just exam-ready.
**Format:** Every topic = concept → hands-on lab → real-world scenario tie-in → documented in this repo.
**Repo structure:**
```
/labs/           - one .md per lab: commands run, output, what broke, how fixed
/runbooks/       - reusable "how to do X in production" docs, written as if for a teammate
/architecture/   - diagrams (draw.io/excalidraw exports) of anything you build
/scripts/        - reusable Bicep/CLI/PowerShell scripts, not one-off throwaway commands
/incident-log/   - simulated incident write-ups (see Phase 6) — problem, diagnosis, fix, prevention
ROADMAP.md       - this file, checked off as you go
```

Commit after every lab — small, frequent commits. This is a real hiring-manager-facing habit, not busywork.

---

## Phase 0 — Setup (Day 0, before Week 1)

- [ ] Create GitHub repo (or restructure your existing `azure-learning-journey` repo) into the folders above
- [ ] Write a one-paragraph README: what this repo is, what you're working toward, link to your CV
- [ ] Confirm allowed regions for your subscription (you already know: `polandcentral`, `francecentral`, `swedencentral`, `canadacentral`, `spaincentral`) — write this down in `/labs/00-subscription-notes.md` so you never re-discover it

---

## Phase 1 — Identity & Governance *(Week 1 — exam weight 20-25%)*

**Exam content:**
- [x] Resource hierarchy (Mgmt Group → Subscription → RG → Resource)
- [x] Resource groups, region/location behavior
- [x] Azure Policy — allowed locations, policy vs RBAC
- [x] RBAC role assignments, additive inheritance rule
- [x] Entra ID: users, groups, group-based role assignment
- [x] Subscriptions, cost management basics, tags, resource locks
- [~] Management groups — lightly covered (single subscription, concept understood, not hands-on)
- [ ] Conditional Access basics (what it is, why orgs use it — read-level, not hands-on required for AZ-104)
- [ ] Privileged Identity Management (PIM) — concept only: just-in-time role elevation, why it exists

**Real-world tie-in (what an Azure Engineer actually does with this):**
- Onboarding/offboarding: adding a new starter to the right group, removing a leaver's access same-day
- Access reviews: periodically auditing who has what role and why (ties directly to your governance/audit background from CWG/ESB)
- Investigating "why can't this user do X" tickets — this is RBAC + Policy troubleshooting, exactly what you did in Lesson 1
- Tagging for cost allocation — Finance asking "which team owns this spend"

**Documentation task:**
- [ ] `/runbooks/rbac-troubleshooting.md` — write this as a real runbook: "User reports access denied → steps to diagnose (check RBAC at all scopes, check Policy, check Conditional Access) → resolution." Base it on what you actually learned in the region-restriction lab.
- [x] `/runbooks/access-provisioning-via-groups.md` — group-based access provisioning runbook (done, lab 09)
- [x] Labs 09 (Entra groups/RBAC) and 10 (tags/locks/cost) logged in `/labs/`

**Phase 1 status: COMPLETE** (2026-08-18) — hands-on for hierarchy, resource groups, Policy, RBAC inheritance, Entra ID groups, tags, and locks. Remaining open item: the RBAC troubleshooting runbook above — pick up when convenient, not blocking Phase 2.

---

## Phase 2 — Storage *(Week 2 — exam weight 15-20%)*

**Exam content:**
- [ ] Storage account types and redundancy: LRS, ZRS, GRS, GZRS — and when each is the right call (this is a cost-vs-resilience tradeoff decision, not memorization)
- [ ] Blob access tiers (Hot/Cool/Cold/Archive) and lifecycle management policies
- [ ] SAS tokens, storage account keys, Microsoft Entra-based access to storage
- [ ] Storage firewalls, private endpoints, network restrictions
- [ ] AzCopy and Storage Explorer
- [ ] Soft delete, versioning, point-in-time restore for blobs

**Real-world tie-in:**
- A dev team asks you to set up storage for an app — you need to pick redundancy/tier based on actual cost and recovery requirements, not defaults
- Someone accidentally deletes a blob container — soft delete/versioning is what saves you, and you need to know it's configured *before* the incident, not after
- A security review asks "can this storage account be reached from the public internet" — firewall/private endpoint knowledge

**Documentation task:**
- [ ] `/runbooks/storage-redundancy-decision-guide.md` — a decision tree: "if the data is X, use Y redundancy, because Z cost/recovery tradeoff"
- [ ] Lab log for every command in `/labs/02-storage.md`

---

## Phase 3 — Compute *(Week 3 — exam weight 20-25%)*

**Exam content:**
- [ ] VM creation, sizing, disks (managed disks, disk types)
- [ ] Availability Sets vs Availability Zones (fault/update domain concepts — you have real experience here from your independent project)
- [ ] VM extensions, custom script extension
- [ ] ARM templates and Bicep — parameters, variables, modules (you have a head start)
- [ ] Azure Container Apps / basic container concepts
- [ ] Update Management / patch compliance

**Real-world tie-in:**
- Right-sizing VMs after deployment (cost optimization is a daily reality, not a one-time decision)
- Patch Tuesday-style patching cycles and how update management/compliance gets tracked
- "The VM won't start" or "disk is full" — classic support tickets, need to know how to diagnose via CLI/Portal fast
- Infrastructure as Code review — reading someone else's Bicep before approving a deployment (change management, which you already know from ITIL)

**Documentation task:**
- [ ] `/scripts/vm-deploy.bicep` — a reusable, parameterized VM deployment template (not throwaway)
- [ ] `/runbooks/vm-troubleshooting-checklist.md` — boot failures, connectivity, disk issues

---

## Phase 4 — Networking *(Week 4 — exam weight 15-20%, your flagged weak area — go slow)*

**Exam content:**
- [ ] VNets, subnets, IP addressing basics
- [ ] NSGs — default rules, custom rule priority/interaction (this is where most candidates fail — spend real time here)
- [ ] VNet peering vs VPN Gateway vs ExpressRoute (concept-level for the last one)
- [ ] Azure Bastion vs public RDP/SSH exposure (security-relevant, real-world critical)
- [ ] Network Watcher — connection troubleshoot, NSG flow logs
- [ ] Load Balancer basics (public vs internal)
- [ ] Azure DNS, private DNS zones

**Real-world tie-in:**
- "I can't connect to my VM" is one of the single most common support tickets in any Azure shop — this is NSG + routing + DNS triage, hands-on, every time
- Security team asks you to lock down public access to VMs — Bastion instead of public RDP/SSH is the real-world answer
- Two teams' VNets need to talk to each other — peering setup and troubleshooting

**Documentation task:**
- [ ] `/runbooks/connectivity-troubleshooting.md` — step-by-step: NSG rules → route tables → DNS → firewall, in that order, with actual CLI commands
- [ ] Build and diagram (in `/architecture/`) a two-VNet peered setup with NSGs, deployed via Bicep

---

## Phase 5 — Monitoring & Operations *(Week 5 — exam weight 10-15%, but disproportionately important for the actual job)*

**Exam content:**
- [ ] Azure Monitor — metrics, logs, Log Analytics workspace
- [ ] KQL basics (Kusto Query Language) — you will use this constantly in a real role, don't skip it
- [ ] Alerts and Action Groups (what fires, who gets notified, what happens)
- [ ] Azure Advisor — cost, security, reliability recommendations
- [ ] Backup and Azure Site Recovery basics

**Real-world tie-in:**
- Alert fatigue is real — knowing how to write a *good* alert (right threshold, right action group) vs. a noisy useless one is a genuine skill gap between junior and senior engineers
- KQL is what you'll actually use to answer "why did this fail at 3am" — this maps directly onto your SQL root-cause-analysis experience from ESB/CWG, just a new syntax
- Cost Management + Advisor reviews are often a recurring weekly/monthly task in real Azure shops

**Documentation task:**
- [ ] `/runbooks/incident-response-template.md` — a template you'll reuse in Phase 6
- [ ] `/labs/05-monitoring-kql-cheatsheet.md` — the KQL queries you actually used, not copied from docs unexamined

---

## Phase 6 — Simulated Real-World Operations *(ongoing, starts Week 4, continues post-exam)*

This is the part most AZ-104 study plans skip entirely, and it's the part that actually makes you look like an engineer instead of someone who passed a test.

- [ ] Pick 3 realistic incidents and simulate them end-to-end: break something on purpose (e.g. misconfigure an NSG rule), then diagnose and fix it using only CLI/Portal, timing yourself, then write it up in `/incident-log/`
- [ ] Write one incident log per week in ITSM style: **Problem → Impact → Diagnosis steps → Root cause → Fix → Prevention** — this format is literally what you'll use in a real job, and it's a format you already know from ITIL
- [ ] Cost review exercise: run Azure Advisor + Cost Management on your subscription, write up 3 real recommendations as if reporting to a manager
- [ ] Security baseline review: check Defender for Cloud recommendations on your subscription, address at least 2

---

## Ongoing, throughout every phase

- [ ] **Practice questions from Week 2 onward** — 10-15 after each domain, not saved for the end
- [ ] **Lab log** for every hands-on task — command, purpose, gotcha (feeds directly into `/labs/`)
- [ ] **Case study practice** in Week 4-5 — multi-question scenarios, not just single Q&A
- [ ] **Go/no-go checkpoint before booking the exam** — book only once consistently scoring 80%+ on practice exams; if not there by end of Week 4, push the date rather than sit underprepared

---

## Exam logistics (fill in once you're ready)
- Target exam date: _____________
- Practice exam scores (log each attempt): _____________
- Booking link: Pearson VUE, $165 USD