<#
.SYNOPSIS
Deploys a complete Azure storage environment for AZ-104 labs
.DESCRIPTION
Creates resource group, storage account, and blob container
.PARAMETER EnvironmentName
Name prefix for all resources (dev, test, prod)
.PARAMETER Location
Azure region (default: francecentral)
.EXAMPLE
.\deploy-lab.ps1 -EnvironmentName "dev" -Location "francecentral"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentName,
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "francecentral",
    
    [Parameter(Mandatory=$false)]
    [string]$Sku = "Standard_LRS"
)

# Generate unique names using timestamp
$timestamp = Get-Date -Format "MMddHHmm"
$resourceGroupName = "rg-$EnvironmentName-$timestamp"
$storageAccountName = "st$EnvironmentName$timestamp"
$containerName = "data"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AZ-104 Lab Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Environment: $EnvironmentName"
Write-Host "Location: $Location"
Write-Host "Resource Group: $resourceGroupName"
Write-Host "Storage Account: $storageAccountName"
Write-Host "Container: $containerName"
Write-Host "========================================" -ForegroundColor Cyan

# Create resource group
Write-Host "`n[1/4] Creating resource group..." -ForegroundColor Yellow
az group create --name $resourceGroupName --location $Location --output none

# Create storage account
Write-Host "[2/4] Creating storage account..." -ForegroundColor Yellow
az storage account create `
    --name $storageAccountName `
    --resource-group $resourceGroupName `
    --sku $Sku `
    --kind StorageV2 `
    --location $Location `
    --output none

# Get account key
Write-Host "[3/4] Retrieving account key..." -ForegroundColor Yellow
$key = az storage account keys list `
    --resource-group $resourceGroupName `
    --account-name $storageAccountName `
    --query "[0].value" `
    --output tsv

# Create container
Write-Host "[4/4] Creating container..." -ForegroundColor Yellow
az storage container create `
    --name $containerName `
    --account-name $storageAccountName `
    --account-key $key `
    --output none

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Resource Group: $resourceGroupName"
Write-Host "Storage Account: $storageAccountName"
Write-Host "Container: $containerName"
Write-Host ""
Write-Host "To delete this environment, run:" -ForegroundColor Yellow
Write-Host "az group delete --name $resourceGroupName --yes"
Write-Host "========================================" -ForegroundColor Green

# Output variables for potential reuse
$global:LastDeploymentRG = $resourceGroupName
$global:LastDeploymentSA = $storageAccountName