#!/bin/bash

#############################################################
# Infrastructure Deployment Script
# Purpose: Deploy all Terraform-managed infrastructure (Master, Worker, MySQL, etc.)
# from the 'terraform/app' directory.
#############################################################

set -e      # Exit immediately if a command exits with a non-zero status
set -u      # Treat unset variables as an error
set -o pipefail # Exit on pipe failure

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Error handler
error_exit() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    # Clean up plan file on failure
    rm -f tfplan 2>/dev/null || true
    exit 1
}

# Success message
success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Warning message
warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

echo "========================================="
echo "Full Infrastructure Deployment (Terraform)"
echo "========================================="
echo ""

# Step 1: Verify we're in the correct directory
TF_DIR="terraform/app"
if [ ! -d "$TF_DIR" ]; then
    error_exit "$TF_DIR directory not found. Please run from project root."
fi

cd "$TF_DIR" || error_exit "Failed to change to $TF_DIR directory"
success "Changed to $TF_DIR directory"

# Step 2: Verify Terraform is installed
if ! command -v terraform &> /dev/null; then
    error_exit "Terraform is not installed. Please install Terraform first."
fi
success "Terraform is installed: $(terraform version -json | grep -o '"terraform_version":"[^"]*' | cut -d'"' -f4)"

# Step 3: Initialize Terraform
echo ""
echo "Initializing Terraform backend and modules..."
if ! terraform init; then
    error_exit "Terraform init failed"
fi
success "Terraform initialized"

# Step 4: Format Terraform files
echo ""
echo "Formatting Terraform files..."
terraform fmt
success "Terraform files formatted"

# Step 5: Validate Terraform configuration
echo ""
echo "Validating Terraform configuration syntax..."
if ! terraform validate; then
    error_exit "Terraform validation failed. Please fix the errors above."
fi
success "Terraform configuration is valid"

# Step 6: Create execution plan
echo ""
warning "Creating Terraform plan for ALL infrastructure components..."
if ! terraform plan -out=tfplan; then
    error_exit "Terraform plan failed. Please review the errors above."
fi
success "Terraform plan created successfully as 'tfplan'"

# Step 7: Review and confirm
echo ""
warning "Review the planned changes described above. All Master, Worker, and support services will be created/modified."
echo ""
read -r -p "Do you want to apply this plan? (yes/no): " REPLY
echo ""

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Deployment cancelled by user."
    rm -f tfplan 2>/dev/null || true
    exit 0
fi

# Step 8: Apply Terraform plan
echo ""
echo "Applying Terraform plan..."
if ! terraform apply tfplan; then
    error_exit "Terraform apply failed. Please check the errors above."
fi
success "Terraform applied successfully. Infrastructure is now provisioning."

# Clean up plan file
rm -f tfplan

# Step 9: Get infrastructure outputs
echo ""
echo "========================================="
echo "Deployment Complete!"
echo "========================================="
echo ""

echo "Terraform outputs (IP addresses, connection details):"
if ! terraform output; then
    warning "Failed to retrieve Terraform outputs."
fi

echo ""
echo "Next Steps (Post-Deployment Configuration):"
echo "1. Wait for all instances to be fully provisioned and accessible."
echo "2. Use the generated SSH keys to access the Master Node."
echo "3. Run your Ansible playbooks (e.g., K8s setup, MySQL setup) from the Ansible Control Server."
echo "4. Deploy the secure in-cluster Webhook Receiver using 'kubectl apply -f webhook-deployment.yml'."
echo ""
success "Deployment script completed successfully!"