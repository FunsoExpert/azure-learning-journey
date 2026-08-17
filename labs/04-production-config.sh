#!/bin/bash
# ============================================
# DAY 4: PRODUCTION LOAD BALANCER CONFIGURATION
# Author: FunsoExpert
# Date: June 8, 2026
# Description: Complete Load Balancer + VMSS configuration
# Note: VMSS will fail due to quota - this is expected
# ============================================

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variables
RESOURCE_GROUP="rg-production-design"
LOCATION="francecentral"
VNET_NAME="vnet-prod"
VNET_PREFIX="10.0.0.0/16"
SUBNET_NAME="snet-web"
SUBNET_PREFIX="10.0.1.0/24"
PUBLIC_IP_NAME="pip-prod"
LB_NAME="lb-prod"
FRONTEND_NAME="fe-prod"
BACKEND_POOL_NAME="bepool-prod"
PROBE_NAME="probe-http"
RULE_NAME="rule-https"
VMSS_NAME="vmss-prod"
TAG="CostCenter=IT-Dept"

# Function to print section headers
print_section() {
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${GREEN}========================================${NC}\n"
}

# Function to check if command succeeded
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1 succeeded${NC}"
    else
        echo -e "${RED}❌ $1 failed${NC}"
        exit 1
    fi
}

# ============================================
# PART 1: CREATE RESOURCE GROUP
# ============================================
print_section "PART 1: CREATING RESOURCE GROUP"

az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION \
    --tags $TAG

check_status "Resource group creation"

# ============================================
# PART 2: CREATE VIRTUAL NETWORK
# ============================================
print_section "PART 2: CREATING VIRTUAL NETWORK"

az network vnet create \
    --resource-group $RESOURCE_GROUP \
    --name $VNET_NAME \
    --address-prefix $VNET_PREFIX \
    --subnet-name $SUBNET_NAME \
    --subnet-prefix $SUBNET_PREFIX \
    --tags $TAG

check_status "Virtual network creation"

# ============================================
# PART 3: CREATE PUBLIC IP (STATIC, STANDARD SKU)
# ============================================
print_section "PART 3: CREATING PUBLIC IP"

az network public-ip create \
    --resource-group $RESOURCE_GROUP \
    --name $PUBLIC_IP_NAME \
    --sku "Standard" \
    --allocation-method "Static" \
    --tags $TAG

check_status "Public IP creation"

# Get the public IP address for output
PUBLIC_IP=$(az network public-ip show \
    --resource-group $RESOURCE_GROUP \
    --name $PUBLIC_IP_NAME \
    --query ipAddress \
    --output tsv)

echo -e "${GREEN}Public IP Address: $PUBLIC_IP${NC}"

# ============================================
# PART 4: CREATE LOAD BALANCER (STANDARD SKU)
# ============================================
print_section "PART 4: CREATING LOAD BALANCER"

az network lb create \
    --resource-group $RESOURCE_GROUP \
    --name $LB_NAME \
    --sku "Standard" \
    --public-ip-address $PUBLIC_IP_NAME \
    --frontend-ip-name $FRONTEND_NAME \
    --backend-pool-name $BACKEND_POOL_NAME \
    --tags $TAG

check_status "Load balancer creation"

# ============================================
# PART 5: CREATE HEALTH PROBE
# ============================================
print_section "PART 5: CREATING HEALTH PROBE (30-second tolerance)"

az network lb probe create \
    --resource-group $RESOURCE_GROUP \
    --lb-name $LB_NAME \
    --name $PROBE_NAME \
    --protocol "Http" \
    --port 80 \
    --path "/health" \
    --interval 15 \
    --threshold 2

check_status "Health probe creation"

echo -e "${YELLOW}Health probe config: 15s interval × 2 failures = 30s tolerance${NC}"

# ============================================
# PART 6: CREATE LOAD BALANCER RULE
# ============================================
print_section "PART 6: CREATING LOAD BALANCER RULE"

az network lb rule create \
    --resource-group $RESOURCE_GROUP \
    --lb-name $LB_NAME \
    --name $RULE_NAME \
    --protocol "Tcp" \
    --frontend-port 443 \
    --backend-port 443 \
    --frontend-ip-name $FRONTEND_NAME \
    --backend-pool-name $BACKEND_POOL_NAME \
    --probe-name $PROBE_NAME \
    --load-distribution "SourceIPProtocol" \
    --idle-timeout 30 \
    --enable-tcp-reset true

check_status "Load balancer rule creation"

echo -e "${YELLOW}Rule config: HTTPS with session persistence, TCP reset enabled${NC}"

# ============================================
# PART 7: ATTEMPT VMSS CREATION (EXPECTED TO FAIL)
# ============================================
print_section "PART 7: ATTEMPTING VMSS CREATION (EXPECTED FAILURE)"

echo -e "${YELLOW}Note: Student subscription has no VM quota in FranceCentral${NC}"
echo -e "${YELLOW}This failure is expected and documented in day4-log.md${NC}\n"

az vmss create \
    --resource-group $RESOURCE_GROUP \
    --name $VMSS_NAME \
    --image "Ubuntu2204" \
    --admin-username "azureuser" \
    --generate-ssh-keys \
    --instance-count 2 \
    --vnet-name $VNET_NAME \
    --subnet $SUBNET_NAME \
    --backend-pool-name $BACKEND_POOL_NAME \
    --load-balancer $LB_NAME \
    --vm-sku "Standard_B1s" \
    --upgrade-policy-mode "Automatic" \
    --tags $TAG

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ VMSS creation succeeded (unexpected!)${NC}"
    VMSS_CREATED=true
else
    echo -e "${RED}❌ VMSS creation failed as expected (quota limitation)${NC}"
    VMSS_CREATED=false
fi

# ============================================
# PART 8: CREATE AUTOSCALE SETTINGS (IF VMSS EXISTS)
# ============================================
if [ "$VMSS_CREATED" = true ]; then
    print_section "PART 8: CREATING AUTOSCALE RULES"
    
    # Create autoscale settings
    az monitor autoscale create \
        --resource-group $RESOURCE_GROUP \
        --name "autoscale-prod" \
        --resource $VMSS_NAME \
        --resource-type "Microsoft.Compute/virtualMachineScaleSets" \
        --min-count 2 \
        --max-count 10 \
        --count 2 \
        --tags $TAG
    
    check_status "Autoscale settings creation"
    
    # Scale out rule: CPU > 75% for 5 minutes
    az monitor autoscale rule create \
        --resource-group $RESOURCE_GROUP \
        --autoscale-name "autoscale-prod" \
        --condition "Percentage CPU > 75 avg 5m" \
        --scale out 1 \
        --cooldown 300
    
    check_status "Scale out rule creation"
    
    # Scale in rule: CPU < 30% for 10 minutes
    az monitor autoscale rule create \
        --resource-group $RESOURCE_GROUP \
        --autoscale-name "autoscale-prod" \
        --condition "Percentage CPU < 30 avg 10m" \
        --scale in 1 \
        --cooldown 300
    
    check_status "Scale in rule creation"
    
    echo -e "${GREEN}Autoscale rules configured:${NC}"
    echo -e "  - Scale OUT: CPU > 75% for 5 minutes → add 1 VM"
    echo -e "  - Scale IN: CPU < 30% for 10 minutes → remove 1 VM"
    echo -e "  - Cooldown: 5 minutes between scaling actions"
else
    print_section "SKIPPING AUTOSCALE (VMSS NOT CREATED)"
    echo -e "${YELLOW}Autoscale requires VMSS. Documented conceptually in day4-log.md${NC}"
fi

# ============================================
# SUMMARY
# ============================================
print_section "DEPLOYMENT SUMMARY"

echo -e "${GREEN}Successfully deployed:${NC}"
echo -e "  ✅ Resource Group: $RESOURCE_GROUP"
echo -e "  ✅ Virtual Network: $VNET_NAME ($VNET_PREFIX)"
echo -e "  ✅ Subnet: $SUBNET_NAME ($SUBNET_PREFIX)"
echo -e "  ✅ Public IP: $PUBLIC_IP_NAME ($PUBLIC_IP)"
echo -e "  ✅ Load Balancer: $LB_NAME (Standard SKU)"
echo -e "  ✅ Health Probe: $PROBE_NAME (30s tolerance)"
echo -e "  ✅ Load Balancer Rule: $RULE_NAME (HTTPS + session persistence)"

if [ "$VMSS_CREATED" = true ]; then
    echo -e "  ✅ VM Scale Set: $VMSS_NAME (2-10 instances)"
    echo -e "  ✅ Autoscale rules configured"
else
    echo -e "  ${RED}❌ VM Scale Set: NOT CREATED (quota limitation)${NC}"
    echo -e "  ${YELLOW}⚠️  Autoscale: NOT CONFIGURED (requires VMSS)${NC}"
fi

echo -e "\n${GREEN}Load balancer frontend IP: $PUBLIC_IP${NC}"
echo -e "${YELLOW}Note: No VMs are behind this load balancer due to subscription quota${NC}"

# ============================================
# DESTRUCTION COMMAND (commented out for safety)
# ============================================
print_section "CLEANUP COMMAND (run when done)"

echo -e "${YELLOW}To delete all resources created today:${NC}"
echo "az group delete --name $RESOURCE_GROUP --yes --no-wait"
echo -e "\n${YELLOW}Or run the destroy script: ./destroy-day4-lab.sh${NC}"

# ============================================
# VERIFICATION COMMANDS
# ============================================
print_section "VERIFICATION COMMANDS"

echo -e "${YELLOW}Run these to verify your deployment:${NC}"
echo ""
echo "# Check load balancer health"
echo "az network lb show --name $LB_NAME --resource-group $RESOURCE_GROUP --query probes"
echo ""
echo "# List backend pool members (will be empty)"
echo "az network lb address-pool show --lb-name $LB_NAME --name $BACKEND_POOL_NAME --resource-group $RESOURCE_GROUP"
echo ""
echo "# Test public IP connectivity (requires VM behind LB)"
echo "curl -k https://$PUBLIC_IP"
echo ""
echo "# View all resources in resource group"
echo "az resource list --resource-group $RESOURCE_GROUP --output table"

print_section "DAY 4 COMPLETE ✅"