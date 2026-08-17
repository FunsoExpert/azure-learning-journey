# Day 3: Azure Policy & Governance (AZ-104 Domain 1)

**Date:** June 6, 2026  
**Status:** ✅ Complete  
**Time Spent:** ~4 hours

---

## What I Learned Today

### Azure Policy vs RBAC

| Aspect | Azure Policy | RBAC |
|--------|--------------|------|
| **Controls** | WHAT can be deployed | WHO can deploy |
| **Example** | "Only France Central" | "John can deploy VMs" |
| **Effect** | Deny, Audit, Append, Modify | Allow, Deny |

### Management Groups Hierarchy
Management Group (Root)
├── Production MG
│ └── Prod Subscription
├── Development MG
│ └── Dev Subscription
└── Sandbox MG
└── Student Subscription (mine)

text

---

## Resources Created & Tested

### 1. Built-in Policy: "Allowed Locations"

| Setting | Value |
|---------|-------|
| Policy | Allowed locations |
| Scope | rg-policy-learning |
| Allowed regions | francecentral only |

**Test Result:** ✅ Storage account in East US was BLOCKED

### 2. Custom Policy: "Require Specified Tag"

```json
{
  "displayName": "Require a Specified Tag on Resources",
  "policyRule": {
    "if": {
      "field": "[concat('tags[', parameters('tagName'), ']')]",
      "exists": "false"
    },
    "then": {
      "effect": "deny"
    }
  }
}
Test Results:

❌ Storage account WITHOUT CostCenter tag: BLOCKED

✅ Storage account WITH CostCenter=IT-Dept: CREATED

3. Resource Locks
Lock Type	Effect	Tested
CanNotDelete	Can modify, cannot delete	✅
ReadOnly	Cannot modify or delete	⏳ (concept only)
Command:

powershell
az lock create --name cannot-delete-lock --resource-group rg-policy-learning --resource-type Microsoft.Storage/storageAccounts --lock-type CanNotDelete
4. RBAC (Role-Based Access Control)
Roles Created:

Reader role assigned to test user

Test Results (with test reader account):

Create storage account: ❌ FAILED (authorization error)

List storage accounts: ✅ SUCCESS

RBAC Hierarchy:

text
Subscription level: Owner (me)
Resource Group level: Reader (test user)
Result: Owner at higher scope overrides → Can still create
Commands Used Today
Policy Commands
powershell
# List built-in policies
az policy definition list --query "[?contains(displayName, 'location')].displayName"

# Create custom policy definition
az policy definition create --name "require-specified-tag" --display-name "Require a Specified Tag on Resources" --rules require-tag-policy.json --params policy-parameters.json --mode All
Lock Commands
powershell
# Create lock
az lock create --name cannot-delete-lock --resource-group rg-policy-learning --resource-type Microsoft.Storage/storageAccounts --resource withtagstorage1234 --lock-type CanNotDelete

# List locks
az lock list --resource-group rg-policy-learning --output table

# Delete lock
az lock delete --name cannot-delete-lock --resource-group rg-policy-learning --resource-type Microsoft.Storage/storageAccounts --resource withtagstorage1234
RBAC Commands
powershell
# Get user ID
$userId = az ad signed-in-user show --query id -o tsv

# Assign role
az role assignment create --assignee $userId --role "Reader" --scope $rgId

# List assignments
az role assignment list --resource-group rg-policy-learning --output table

# Remove assignment
az role assignment delete --ids $assignmentId

# Test reader user creation
az ad user create --display-name "Reader Test User" --user-principal-name "readertest@domain.onmicrosoft.com" --password "TestP@ssw0rd123!"
AZ-104 Practice Questions Answered
Question	Answer
How to enforce that all resources have an "Owner" tag?	Custom Azure Policy with deny effect when tag missing
How to prevent accidental deletion of a critical database?	CanNotDelete resource lock
What role for helpdesk team that only restarts VMs?	Virtual Machine Contributor
How to apply policy to 50 subscriptions at once?	Management Group
What's the difference between Policy and RBAC?	Policy = WHAT (resource compliance), RBAC = WHO (permissions)
Challenges Faced & Solved
Challenge	Solution
Custom policy JSON syntax error	Removed outer "properties" wrapper
Parameter file missing	Created separate policy-parameters.json
Lock deletion failed	Specified --resource-type and --resource
Tag name mismatch (CostCenter vs CostCentre)	Aligned tag name with policy parameter
Testing Reader role on own account	Created separate test reader user
Resources Created & Destroyed
Resource	Status
Resource Group: rg-policy-learning	✅ Deleted
Custom Policy: require-specified-tag	✅ Deleted
Policy Assignment	✅ Removed
Storage Account: withtagstorage1234	✅ Deleted
Storage Account: readerteststorage1234	✅ Deleted
Lock: cannot-delete-lock	✅ Deleted
Test Reader User	✅ Deleted
Cost Today
$0.00 (All resources in free tier, deleted after lab)

Day 3 Self-Assessment
Skill	Rating (1-10)
Azure Policy (Built-in)	8/10
Azure Policy (Custom)	7/10
Resource Locks	8/10
RBAC	7/10
Overall Day 3	7.5/10


Tomorrow's Preview (Day 4)
Topic: Load Balancers & VM Scale Sets (AZ-104 Domain 3)

Azure Load Balancer (Layer 4)

Application Gateway (Layer 7)

VM Scale Sets with auto-scaling

Health probes and load balancing rules


