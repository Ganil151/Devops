#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ENV=${1:-dev}
ECR_ACCOUNT_ID=${2:-$(aws sts get-caller-identity --query Account --output text)}
AWS_REGION=${3:-us-east-1}

echo -e "${BLUE}🐳 Building and Pushing Docker Images${NC}"
echo -e "${BLUE}Environment: ${ENV}${NC}"
echo -e "${BLUE}AWS Region: ${AWS_REGION}${NC}"
echo ""

# Validate environment
if [[ ! "$ENV" =~ ^(dev|staging|prod)$ ]]; then
  echo -e "${RED}❌ Invalid environment. Use: dev, staging, or prod${NC}"
  exit 1
fi

# Navigate to project root
cd "$(dirname "$0")/.." || exit 1

# Login to ECR
echo -e "${YELLOW}🔑 Logging into ECR...${NC}"
aws ecr get-login-password --region "$AWS_REGION" | \
  docker login --username AWS --password-stdin "${ECR_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# Get ECR repositories from Terraform
cd terraform/environments/"$ENV" || exit 1
ECR_REPOS=$(terraform output -json ecr_repositories 2>/dev/null)

if [ -z "$ECR_REPOS" ]; then
  echo -e "${RED}❌ Could not get ECR repositories. Has infrastructure been deployed?${NC}"
  exit 1
fi

cd ../../.. || exit 1

# Microservices to build
SERVICES=(
  "spring-petclinic-api-gateway"
  "spring-petclinic-customers-service"
  "spring-petclinic-vets-service"
  "spring-petclinic-visits-service"
  "spring-petclinic-config-server"
  "spring-petclinic-discovery-server"
)

# Build and push each service
for service in "${SERVICES[@]}"; do
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}📦 Building: ${service}${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  
  SERVICE_DIR="../${service}"
  
  if [ ! -d "$SERVICE_DIR" ]; then
    echo -e "${YELLOW}⚠️  Directory not found: ${SERVICE_DIR}, skipping...${NC}"
    continue
  fi
  
  # Extract short service name for ECR repo
  SHORT_NAME=$(echo "$service" | sed 's/spring-petclinic-/petclinic-/')
  
  # Get ECR repository URL
  ECR_REPO=$(echo "$ECR_REPOS" | jq -r ".\"$SHORT_NAME\"" 2>/dev/null)
  
  if [ -z "$ECR_REPO" ] || [ "$ECR_REPO" == "null" ]; then
    echo -e "${YELLOW}⚠️  ECR repository not found for ${SHORT_NAME}, skipping...${NC}"
    continue
  fi
  
  # Build Docker image
  echo -e "${YELLOW}🏗️  Building Docker image...${NC}"
  docker build -t "${service}:latest" "$SERVICE_DIR"
  
  # Tag for ECR
  docker tag "${service}:latest" "${ECR_REPO}:latest"
  docker tag "${service}:latest" "${ECR_REPO}:${ENV}-$(date +%Y%m%d-%H%M%S)"
  
  # Push to ECR
  echo -e "${YELLOW}⬆️  Pushing to ECR...${NC}"
  docker push "${ECR_REPO}:latest"
  docker push "${ECR_REPO}:${ENV}-$(date +%Y%m%d-%H%M%S)"
  
  echo -e "${GREEN}✅ ${service} pushed successfully${NC}"
done

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ All images built and pushed!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📝 Next Step: Deploy to Kubernetes${NC}"
echo -e "kubectl apply -f helm/petclinic/"
