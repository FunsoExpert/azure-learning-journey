## Day 2 - Completed Tasks

### Availability Set
- Name: web-availability-set
- Fault domains: 2 (different racks)
- Update domains: 5 (different maintenance windows)
- Use case: 99.95% SLA for production VMs

### NSG Rules
| Rule | Priority | Action | Port | Source |
|------|----------|--------|------|--------|
| Allow-HTTP | 100 | Allow | 80 | Any |
| Allow-HTTPS | 110 | Allow | 443 | Any |
| Allow-RDP | 120 | Allow | 3389 | [Your IP] |
| Deny-Bad-IP | 200 | Deny | Any | 203.0.113.0/24 |