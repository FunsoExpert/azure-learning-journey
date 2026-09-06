#!/bin/bash
# Implement Azure IaaS — Course-End Project 1
# Business scenario: connect a data-tier VNet (East US, headquarters)
# to an app-tier VNet (Southeast Asia, branch office) via VNet Peering,
# then validate private connectivity with a ping test.

# ---------------------------------------------------------------
# Activity 1 — Create the two Virtual Networks (non-overlapping)
# ---------------------------------------------------------------

az group create \
  --name project1-rg \
  --location eastus

az network vnet create \
  --resource-group project1-rg \
  --name VNet-HQ-DataTier \
  --address-prefix 10.1.0.0/16 \
  --subnet-name DataSubnet \
  --subnet-prefix 10.1.1.0/24 \
  --location eastus

az network vnet create \
  --resource-group project1-rg \
  --name VNet-Branch-AppTier \
  --address-prefix 10.2.0.0/16 \
  --subnet-name AppSubnet \
  --subnet-prefix 10.2.1.0/24 \
  --location southeastasia

# ---------------------------------------------------------------
# Activity 2 — Deploy a Standard_DS1_v2 test VM into each VNet
# ---------------------------------------------------------------

az vm create \
  --resource-group project1-rg \
  --name VM-HQ-DataTier \
  --image Ubuntu2404 \
  --size Standard_DS1_v2 \
  --vnet-name VNet-HQ-DataTier \
  --subnet DataSubnet \
  --admin-username azuser \
  --generate-ssh-keys \
  --storage-sku Standard_LRS \
  --location eastus

az vm create \
  --resource-group project1-rg \
  --name VM-Branch-AppTier \
  --image Ubuntu2404 \
  --size Standard_DS1_v2 \
  --vnet-name VNet-Branch-AppTier \
  --subnet AppSubnet \
  --admin-username azuser \
  --generate-ssh-keys \
  --storage-sku Standard_LRS \
  --location southeastasia

# ---------------------------------------------------------------
# Activity 3 — Establish VNet Peering (must be created in BOTH
# directions — creating one side does not create the other)
# ---------------------------------------------------------------

az network vnet peering create \
  --resource-group project1-rg \
  --name HQtoBranch \
  --vnet-name VNet-HQ-DataTier \
  --remote-vnet VNet-Branch-AppTier \
  --allow-vnet-access

az network vnet peering create \
  --resource-group project1-rg \
  --name BranchtoHQ \
  --vnet-name VNet-Branch-AppTier \
  --remote-vnet VNet-HQ-DataTier \
  --allow-vnet-access

# Verify both peerings independently before considering this activity complete
az network vnet peering list \
  --resource-group project1-rg \
  --vnet-name VNet-HQ-DataTier \
  --output table

az network vnet peering list \
  --resource-group project1-rg \
  --vnet-name VNet-Branch-AppTier \
  --output table

# ---------------------------------------------------------------
# Activity 4 — Validate connectivity
# SSH into VM-HQ-DataTier, then from inside that session run:
#   ping -c 4 10.2.1.4
# Expected result: 0% packet loss, confirming the peered private
# connection is live and carrying real traffic.
# ---------------------------------------------------------------
