# Azure Learning Journey - Day 1
**Date:** 04/06/2026
**Start Time:** 9:00 AM GMT
**Student Balance Start:** $79

## What I Built Today

| Resource | SKU/Type | Purpose |
|----------|----------|---------|
| funsostorage1234 | Standard_LRS | Default / low-cost storage |
| funsozrs2468 | Standard_ZRS | Zone-redundant (survives datacenter failure) |
| funsogrrs2468 | Standard_GRS | Geo-redundant (copied to paired region) |
| funsofile2468 | Standard_LRS | Azure Files (SMB network share) |
| bicepstorage7246 | Standard_LRS | Deployed via Bicep template |

---

## AZ-104 Skills Practiced

### Domain 2: Storage (15-20% of exam)
- [x] Choose storage redundancy (LRS/ZRS/GRS/GZRS)
- [x] Configure Blob storage containers
- [x] Generate and manage SAS tokens
- [x] Implement lifecycle management (Cool tier, deletion)
- [x] Configure Azure Files (SMB shares)

### Domain 3: Compute (20-25% of exam)
- [x] Deploy resources using Bicep (Infrastructure as Code)
- [x] Use parameters and outputs in templates

### Domain 5: Monitoring & Cost (10-15% of exam)
- [x] Configure budget alerts
- [x] Analyze costs in portal
- [x] Automate deployment with PowerShell

---

## All Commands Used Today (Compiled)

## Part 1: Environment Setup & Login
az --help	Shows all Azure CLI commands
az group --help	Shows resource group commands
az group create --help	Shows how to create a resource group
az group list --output table	Lists all your resource groups (none yet)
az configure --list-defaults   to configure list
az configure --defaults location=northeurope  set the default location to  NortEurope
az account show    to list subscription
az group create --name rg-learning-day1 --location northeurope  to create RG
Expected output: JSON showing "provisioningState": "Succeeded"

# Verify Azure CLI installation
az --version

# Login with tenant (MFA required)
az login --tenant b148ac17-728d-482f-b8af-7c46006c2742

# Select subscription (typed 1)
# Set subscription as default
az account set --subscription "c1ed7e99-3b89-43a6-933e-cf352be91887"

# Verify subscription
az account show

# Set default location to France Central (after discovering it works)
az configure --defaults location=francecentral

# Verify defaults
az configure --list-defaults

# Learn CLI structure
az --help
az group --help
az group create --help
az group list --output table

## Part 2: First Storage Account (LRS)
# Create resource group
az group create --name rg-learning-day1 --location francecentral

# Create LRS storage account
az storage account create --name funsostorage1234 --resource-group rg-learning-day1 --sku Standard_LRS --kind StorageV2 --location francecentral

# Verify storage account
az storage account list --resource-group rg-learning-day1 --output table

# Get connection string
az storage account show-connection-string --name funsostorage1234 --resource-group rg-learning-day1 --output tsv

# Create container
az storage container create --name testcontainer --account-name funsostorage1234 --account-key "[ACCOUNT-KEY-REMOVED]"

# Upload test file
echo "My first Azure storage upload - Day 1" > testfile.txt
az storage blob upload --container-name testcontainer --file testfile.txt --name testfile.txt --account-name funsostorage1234 --account-key "[ACCOUNT-KEY-REMOVED]"

# Generate SAS token
az storage blob generate-sas --container-name testcontainer --name testfile.txt --permissions r --expiry 2026-06-05 --account-name funsostorage1234 --account-key "[ACCOUNT-KEY-REMOVED]"

# List all blobs
az storage blob list --container-name testcontainer --account-name funsostorage1234 --account-key "[ACCOUNT-KEY-REMOVED]" --output table

# Show storage account details with SKU
az storage account show --name funsostorage1234 --resource-group rg-learning-day1 --query "{Name:name, Sku:sku.name}" --output table

## Part 3: Three Additional Storage Accounts (ZRS, GRS, File)
# Create ZRS storage account
az storage account create --name funsozrs2468 --resource-group rg-learning-day1 --sku Standard_ZRS --kind StorageV2 --location francecentral

# Create GRS storage account
az storage account create --name funsogrrs2468 --resource-group rg-learning-day1 --sku Standard_GRS --kind StorageV2 --location francecentral

# Create File Share storage account
az storage account create --name funsofile2468 --resource-group rg-learning-day1 --sku Standard_LRS --kind StorageV2 --location francecentral

# Get connection string for file account
$conn = az storage account show-connection-string --name funsofile2468 --resource-group rg-learning-day1 --output tsv

# Create file share
az storage share create --name sharedocuments --connection-string $conn

# List file shares
az storage share list --connection-string $conn --output table

# Verify all four storage accounts
az storage account list --resource-group rg-learning-day1 --query "[].{Name:name, Sku:sku.name}" --output table

## Part 3: Three Additional Storage Accounts (ZRS, GRS, File)
# Create ZRS storage account
az storage account create --name funsozrs2468 --resource-group rg-learning-day1 --sku Standard_ZRS --kind StorageV2 --location francecentral

# Create GRS storage account
az storage account create --name funsogrrs2468 --resource-group rg-learning-day1 --sku Standard_GRS --kind StorageV2 --location francecentral

# Create File Share storage account
az storage account create --name funsofile2468 --resource-group rg-learning-day1 --sku Standard_LRS --kind StorageV2 --location francecentral

# Get connection string for file account
$conn = az storage account show-connection-string --name funsofile2468 --resource-group rg-learning-day1 --output tsv

# Create file share
az storage share create --name sharedocuments --connection-string $conn

# List file shares
az storage share list --connection-string $conn --output table

# Verify all four storage accounts
az storage account list --resource-group rg-learning-day1 --query "[].{Name:name, Sku:sku.name}" --output table

## Part 5: Deletion Commands (Run at End of Day)
# Delete resource group (deletes ALL storage accounts inside)
az group delete --name rg-learning-day1 --yes --no-wait

# Verify deletion
az group list --output table

# Check final balance (in portal)
# Cost Management → Cost analysis

## Storage Accounts Created

| Name | SKU | Use Case |
|------|-----|----------|
| Funsostorage1234 | Standard_LRS | Default / low-cost |
| Funsozrs2468 | Standard_ZRS | Zone-redundant |
| Funsogrrs2468 | Standard_GRS | Geo-redundant |
| Funsofile2468 | Standard_LRS | Azure Files (SMB) |

---

## Knowledge Check Answers

| Question | Answer |
|----------|--------|
| Which SKU for dev/test where cost is priority? | **Standard_LRS** - cheapest, single datacenter |
| Which SKU for production that cannot lose data even if datacenter fails? | **Standard_ZRS** - survives zone failure |
| Which SKU automatically copies to paired region? | **Standard_GRS** - geo-replicated to secondary region |

## Lifecycle Policies (Portal)
Rule 1: Move to Cool tier after 30 days

Rule 2: Delete after 365 days


## Bicep (Infrastructure as Code)
az deployment group create --resource-group rg-bicep-learning --template-file storage.bicep --parameters storageAccountName=bicepstorage7246 containerName=mycontainer

## Power Shell Automation
# deploy-lab.ps1 - Creates resource group, storage account, container
.\deploy-lab.ps1 -EnvironmentName "dev"

# destroy-all.ps1 - Deletes all resource groups with 'rg-' prefix
.\destroy-all.ps1

## Knowledge Check Answers
Question	Answer
Which SKU for dev/test where cost is priority?	Standard_LRS - cheapest, single datacenter
Which SKU for production that cannot lose data even if datacenter fails?	Standard_ZRS - survives zone failure
Which SKU automatically copies to paired region?	Standard_GRS - geo-replicated
What does param do in Bicep?	Defines input variables for template reusability
What does output do in Bicep?	Returns values after deployment (e.g., resource IDs)
Why use Bicep instead of portal?	Consistency, repeatability, version control

## Costs Incurred Today
Total: ~$0.00 - $0.50

All resources were deleted immediately after labs. Student subscription credit remains ~$78-79.

## Challenges Faced & Solved
Challenge	                       Solution
MFA required for login	          Used az login --tenant TENANT_ID
Storage account region restricted	   Found francecentral works
Bicep parent property error	Used parent: storageAccount::blobServices-->>the container subchild
Container not created in Bicep	Added explicit blobService resource
PowerShell script left resources	Removed --no-wait flag
SAS token 403 error	Copy-paste exact token, no manual typing
