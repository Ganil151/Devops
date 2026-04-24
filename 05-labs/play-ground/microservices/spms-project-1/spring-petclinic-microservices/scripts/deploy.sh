#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ENV=${1:-dev}

echo -e "${BLUE}🚀 PetClinic Deployment Script${NC}"
echo -e "${BLUE}Environment: ${ENV}${NC}"
echo ""

# Validate environment
if [[ ! "$ENV" =~ ^(dev|staging|prod)$ ]]; then
  echo -e "${RED}❌ Invalid environment. Use: dev, staging, or prod${NC}"
  exit 1
fi

# Check prerequisites
echo -e "${YELLOW}📋 Checking prerequisites...${NC}"

command -v terraform >/dev/null 2>&1 || { echo -e "${RED}❌ Terraform not found${NC}"; exit 1; }
command -v aws >/dev/null 2>&1 || { echo -e "${RED}❌ AWS CLI not found${NC}"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo -e "${RED}❌ kubectl not found${NC}"; exit 1; }

echo -e "${GREEN}✅ All prerequisites met${NC}"
echo ""

# Navigate to Terraform directory
cd "$(dirname "$0")/../terraform" || exit 1

# Step 1: Initialize Terraform
echo -e "${BLUE}📦 Step 1: Initializing Terraform for ${ENV}...${NC}"
./scripts/init.sh "$ENV"

# Step 2: Plan
echo -e "${BLUE}📋 Step 2: Creating Terraform plan...${NC}"
./scripts/plan.sh "$ENV"

# Step 3: Apply (with confirmation for prod)
if [ "$ENV" == "prod" ]; then
  echo -e "${YELLOW}⚠️  WARNING: Deploying to PRODUCTION${NC}"
  read -p "Type 'deploy-prod' to confirm: " CONFIRM
  if [ "$CONFIRM" != "deploy-prod" ]; then
    echo -e "${RED}❌ Deployment cancelled${NC}"
    exit 1
  fi
fi

echo -e "${BLUE}🚀 Step 3: Applying infrastructure...${NC}"
./scripts/apply.sh "$ENV"

# Step 4: Configure kubectl
echo -e "${BLUE}⚙️  Step 4: Configuring kubectl...${NC}"
cd "environments/$ENV" || exit 1
CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
AWS_REGION=$(terraform output -raw aws_region 2>/dev/null || echo "us-east-1")

aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"
echo -e "${GREEN}✅ kubectl configured for cluster: ${CLUSTER_NAME}${NC}"

# Step 5: Verify nodes
echo -e "${BLUE}🔍 Step 5: Verifying EKS nodes...${NC}"
kubectl get nodes

# Step 6: Display outputs
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📊 Infrastructure Outputs:${NC}"
terraform output

echo ""
echo -e "${BLUE}📝 Next Steps:${NC}"
echo -e "1. Build and push Docker images to ECR"
echo -e "2. Deploy microservices using Helm/kubectl"
echo -e "3. Configure monitoring and alerting"
echo ""
echo -e "${GREEN}For detailed instructions, see: terraform/RUNBOOK_AWS_DEPLOY.md${NC}"
