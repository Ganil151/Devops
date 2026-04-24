#!/bin/bash

#############################################################################
# Script: gcp-project-setup.sh
# Description: Automates GCP Project Initialization
# Author: Senior DevOps Engineer
# Version: 1.0 (Golden Standard)
#############################################################################

set -euo pipefail

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_ID=${1:-""}
BILLING_ACCOUNT=${2:-""}

if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}Usage: $0 <project-id> [billing-account-id]${NC}"
    exit 1
fi

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}   GCP PROJECT INITIALIZER${NC}"
echo -e "${CYAN}========================================${NC}"
echo "Project ID: $PROJECT_ID"

# 1. Create Project
echo -e "\n${CYAN}[1/5] Creating Project...${NC}"
if gcloud projects describe "$PROJECT_ID" &>/dev/null; then
    echo "Project already exists."
else
    gcloud projects create "$PROJECT_ID" --name="DevOps-$PROJECT_ID"
    echo -e "${GREEN}Project created.${NC}"
fi

gcloud config set project "$PROJECT_ID"

# 2. Link Billing
if [ -n "$BILLING_ACCOUNT" ]; then
    echo -e "\n${CYAN}[2/5] Linking Billing Account...${NC}"
    gcloud beta billing projects link "$PROJECT_ID" --billing-account "$BILLING_ACCOUNT"
    echo -e "${GREEN}Billing linked.${NC}"
else
    echo -e "\n${CYAN}[2/5] Skipping Billing (Not provided)${NC}"
fi

# 3. Enable APIs
echo -e "\n${CYAN}[3/5] Enabling Core APIs...${NC}"
APIS=(
    "compute.googleapis.com"
    "container.googleapis.com"
    "cloudbuild.googleapis.com"
    "iam.googleapis.com"
)

for api in "${APIS[@]}"; do
    echo "Enabling $api..."
    gcloud services enable "$api"
done
echo -e "${GREEN}APIs enabled.${NC}"

# 4. Create Service Account
echo -e "\n${CYAN}[4/5] Creating Terraform Service Account...${NC}"
SA_NAME="terraform-sa"
if ! gcloud iam service-accounts describe "$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" &>/dev/null; then
    gcloud iam service-accounts create $SA_NAME --display-name="Terraform Service Account"
    echo -e "${GREEN}Service Account created.${NC}"
fi

# 5. IAM Binding
echo -e "\n${CYAN}[5/5] Configuring IAM Roles...${NC}"
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/editor" > /dev/null

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}   SETUP COMPLETE${NC}"
echo -e "${GREEN}========================================${NC}"
