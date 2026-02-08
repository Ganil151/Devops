#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ENV=${1:-dev}

echo -e "${RED}🗑️  Infrastructure Cleanup Script${NC}"
echo -e "${RED}Environment: ${ENV}${NC}"
echo ""

# Validate environment
if [[ ! "$ENV" =~ ^(dev|staging|prod)$ ]]; then
  echo -e "${RED}❌ Invalid environment. Use: dev, staging, or prod${NC}"
  exit 1
fi

# Extra confirmation for production
if [ "$ENV" == "prod" ]; then
  echo -e "${RED}⚠️  WARNING: You are about to DESTROY PRODUCTION infrastructure!${NC}"
  echo -e "${RED}⚠️  This action is IRREVERSIBLE!${NC}"
  read -p "Type 'destroy-prod-infrastructure' to confirm: " CONFIRM
  if [ "$CONFIRM" != "destroy-prod-infrastructure" ]; then
    echo -e "${GREEN}✅ Cleanup cancelled. No changes made.${NC}"
    exit 0
  fi
fi

# Navigate to project root
cd "$(dirname "$0")/.." || exit 1

# Step 1: Delete Kubernetes resources first
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🧹 Step 1: Deleting Kubernetes Resources${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if kubectl get namespace petclinic >/dev/null 2>&1; then
  echo -e "${YELLOW}Deleting petclinic namespace...${NC}"
  kubectl delete namespace petclinic --timeout=300s || true
  
  echo -e "${YELLOW}Waiting for LoadBalancers to be deleted...${NC}"
  for i in {1..60}; do
    if ! kubectl get svc -A | grep -q "LoadBalancer.*pending"; then
      break
    fi
    echo -n "."
    sleep 5
  done
  echo ""
  echo -e "${GREEN}✅ Kubernetes resources deleted${NC}"
else
  echo -e "${YELLOW}⚠️  Namespace 'petclinic' not found, skipping...${NC}"
fi

echo ""

# Step 2: Destroy Terraform infrastructure
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔥 Step 2: Destroying Terraform Infrastructure${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

cd terraform || exit 1
./scripts/destroy.sh "$ENV"

echo ""

# Step 3: Verify cleanup
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔍 Step 3: Verifying Cleanup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

cd "environments/${ENV}" || exit 1

# Get VPC ID if it still exists
VPC_ID=$(terraform output -raw vpc_id 2>/dev/null || echo "")

if [ -n "$VPC_ID" ]; then
  echo -e "${YELLOW}⚠️  VPC still exists, checking for orphaned resources...${NC}"
  
  # Check for orphaned Load Balancers
  echo -e "${YELLOW}Checking for orphaned Load Balancers...${NC}"
  aws elbv2 describe-load-balancers \
    --query "LoadBalancers[?VpcId=='${VPC_ID}'].[LoadBalancerName,LoadBalancerArn]" \
    --output table || true
  
  # Check for orphaned Network Interfaces
  echo -e "${YELLOW}Checking for orphaned Network Interfaces...${NC}"
  aws ec2 describe-network-interfaces \
    --filters "Name=vpc-id,Values=${VPC_ID}" \
    --query "NetworkInterfaces[*].[NetworkInterfaceId,Description]" \
    --output table || true
else
  echo -e "${GREEN}✅ VPC has been deleted${NC}"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Cleanup Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📝 If you see orphaned resources above:${NC}"
echo -e "1. Wait 5-10 minutes for AWS to complete deletion"
echo -e "2. Run this script again to verify"
echo -e "3. Manually delete straggling resources if needed"
