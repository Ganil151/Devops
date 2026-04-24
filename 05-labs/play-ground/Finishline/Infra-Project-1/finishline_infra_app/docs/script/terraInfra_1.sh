#!/bin/bash
# =============================================================================
# Terraform Infrastructure Project Initialization Script
# =============================================================================
# This script creates the directory structure and placeholder files for a
# Terraform project following infrastructure-as-code best practices.
# =============================================================================

# Strict error handling: exit on error, undefined variables, and pipe failures
set -euo pipefail

# Configuration
TERRAFORM_DIR="terraform"
ENVIRONMENTS=("dev" "staging" "prod")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track the original directory
ORIGINAL_DIR="$(pwd)"

# Cleanup function to return to original directory on exit
cleanup() {
    cd "$ORIGINAL_DIR"
}
trap cleanup EXIT

# Print formatted message
print_msg() {
    local status="$1"
    local message="$2"
    case "$status" in
        success)
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        info)
            echo -e "${YELLOW}ℹ️  $message${NC}"
            ;;
        error)
            echo -e "${RED}❌ $message${NC}"
            ;;
        *)
            echo "$message"
            ;;
    esac
}

# Verify script is run from project root
verify_project_root() {
    if [[ "$ORIGINAL_DIR" == *"finishline_infra_app"* ]]; then
        print_msg "info" "Running from project root: $ORIGINAL_DIR"
    else
        print_msg "error" "Please run this script from the project root directory"
        exit 1
    fi
}

# Check if directory already exists and warn
check_existing_dir() {
    if [[ -d "$TERRAFORM_DIR" ]]; then
        print_msg "info" "Directory '$TERRAFORM_DIR' already exists. Files will be added."
    fi
}

# Main execution
main() {
    print_msg "info" "Starting Terraform project initialization..."
    
    # Verification steps
    verify_project_root
    check_existing_dir
    
    # 1. Create the Directory Structure
    print_msg "info" "Creating directory structure..."
    mkdir -p "$TERRAFORM_DIR" && cd "$TERRAFORM_DIR"
    mkdir -p modules/{vpc,alb,eks,ec2,bootstrap,security_group} \
             modules/secret/{iam,key_pair} \
             environments/{dev,staging,prod}
    print_msg "success" "Directory structure created"

    # 2. Populate Networking & Compute Modules
    print_msg "info" "Creating VPC module files..."
    touch modules/vpc/{main,variables,output}.tf
    touch modules/vpc/README.md
    
    print_msg "info" "Creating ALB module files..."
    touch modules/alb/{main,variables,output}.tf
    touch modules/alb/README.md
    
    print_msg "info" "Creating bootstrap module files..."
    touch modules/bootstrap/{main,variables,output}.tf
    touch modules/bootstrap/README.md
    
    print_msg "info" "Creating security group module files..."
    touch modules/security_group/{main,variables,output}.tf
    touch modules/security_group/README.md

    # 3. Populate EKS Module (with Addons)
    print_msg "info" "Creating EKS module files..."
    touch modules/eks/{main,variables,output,addons}.tf
    touch modules/eks/README.md

    # 4. Populate Secret/Security Modules
    print_msg "info" "Creating secret/iam module files..."
    touch modules/secret/iam/{main,variables,output}.tf
    touch modules/secret/iam/README.md
    
    print_msg "info" "Creating secret/key_pair module files..."
    touch modules/secret/key_pair/{main,variables,output}.tf
    touch modules/secret/key_pair/README.md

    # 5. Populate EC2 and Additional Modules (if needed)
    print_msg "info" "Creating EC2 module files..."
    touch modules/ec2/{main,variables,output}.tf
    touch modules/ec2/README.md

    # 6. Populate Environment Folders (Root Modules)
    print_msg "info" "Creating environment configuration files..."
    for env in "${ENVIRONMENTS[@]}"; do
        touch environments/$env/{main,variables,output,backend,providers,versions}.tf
        touch environments/$env/terraform.tfvars
    done

    print_msg "success" "Terraform Project Structure Initialized Successfully."
    print_msg "info" "Directory: $TERRAFORM_DIR/"
}

# Run main function
main "$@"
