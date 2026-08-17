#!/bin/bash
# ============================================
# DAY 4: DESTROY ALL RESOURCES
# ============================================

# 1. Store the filtered list of names inside a variable
GROUPS=$(az group list --query "[?starts_with(name, 'rg-')].name" -o tsv)

# 2. Loop through each name found
for RG in $GROUPS; do
    echo "Processing resource group: $RG"
    
    # Example: Appending a tag to all matched groups
    az group update --name $RG --tags "CostCenter=IT-Dept"
done

echo "⚠️  WARNING: This will delete the resource group: $RESOURCE_GROUP"
echo "This action cannot be undone."
read -p "Type 'DELETE' to confirm: " CONFIRM

if [ "$CONFIRM" = "DELETE" ]; then
    echo "Deleting resource group..."
    az group delete --name $RG --yes --no-wait
    echo "Resource group deletion initiated. This may take a few minutes."
else
    echo "Operation cancelled."
fi