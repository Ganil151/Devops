#!/bin/bash
#============================================================
#  Run All Dev Environment Modules
#============================================================
# This script runs all Terragrunt modules in the correct
# dependency order for the dev environment.
#
# Usage:
#   ./run-all.sh [plan|apply|destroy]
#
# Examples:
#   ./run-all.sh plan    # Plan all changes
#   ./run-all.sh apply   # Apply all changes
#   ./run-all.sh destroy # Destroy all resources
#============================================================

set -euo pipefail

#============================================================
# Configuration
#============================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(dirname "$SCRIPT_DIR")"
DEV_DIR="$TERRAFORM_DIR/environments/dev"
ACTION="${1:-apply}"
FAILED_MODULES=()
START_TIME=$(date +%s)

#============================================================
# Helper Functions
#============================================================

log_info() {
    echo -e "\033[0;32m[INFO]\033[0m $1"
}

log_warn() {
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

log_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

print_header() {
    echo ""
    echo "============================================================"
    echo "  $1"
    echo "============================================================"
    echo ""
}

cleanup() {
    local exit_code=$?
    local end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    
    if [[ $exit_code -ne 0 ]]; then
        print_header "Script Failed!"
        log_error "Script terminated after ${duration} seconds"
        if [[ ${#FAILED_MODULES[@]} -gt 0 ]]; then
            log_error "Failed modules:"
            for module in "${FAILED_MODULES[@]}"; do
                log_error "  - $module"
            done
        fi
        log_error "Exit code: $exit_code"
    else
        print_header "All Dev Environment modules completed successfully!"
        log_info "Total execution time: ${duration} seconds"
    fi
    
    # Return to original directory
    cd "$SCRIPT_DIR" 2>/dev/null || true
    
    exit $exit_code
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if terragrunt is installed
    if ! command -v terragrunt &> /dev/null; then
        log_error "Terragrunt is not installed or not in PATH"
        log_error "Install terragrunt: https://terragrunt.gruntwork.io/docs/getting-started/install/"
        exit 1
    fi
    
    # Check if terraform is installed
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed or not in PATH"
        log_error "Install terraform: https://learn.hashicorp.com/tutorials/terraform/install-cli"
        exit 1
    fi
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI is not installed or not in PATH"
        log_error "Install AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured or invalid"
        log_error "Run 'aws configure' or set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY"
        exit 1
    fi
    
    # Check if dev directory exists
    if [[ ! -d "$DEV_DIR" ]]; then
        log_error "Dev environment directory not found: $DEV_DIR"
        exit 1
    fi
    
    # Validate action
    case "$ACTION" in
        plan|apply|destroy)
            ;;
        *)
            log_error "Invalid action: $ACTION"
            log_error "Valid actions: plan, apply, destroy"
            exit 1
            ;;
    esac
    
    log_info "All prerequisites checked successfully"
    log_info "AWS Account: $(aws sts get-caller-identity --query 'Account' --output text)"
    log_info "AWS Region: $(aws configure get region)"
    log_info "Action: $ACTION"
}

# Function to run terragrunt in a directory with error handling
run_terragrunt() {
    local dir="$1"
    local module="$2"
    local step="$3"
    
    echo ""
    log_info "Step $step: Running $module..."
    echo ">>> Module path: $dir"
    
    # Check if directory exists
    if [[ ! -d "$dir" ]]; then
        log_error "Module directory not found: $dir"
        FAILED_MODULES+=("$module")
        return 1
    fi
    
    # Check if terragrunt.hcl exists
    if [[ ! -f "$dir/terragrunt.hcl" ]]; then
        log_error "terragrunt.hcl not found in: $dir"
        FAILED_MODULES+=("$module")
        return 1
    fi
    
    cd "$dir"
    
    # Run terragrunt with error capture
    if terragrunt "$ACTION" --terragrunt-non-interactive; then
        log_info "✓ $module completed successfully"
        cd "$DEV_DIR"
        return 0
    else
        local exit_code=$?
        log_error "✗ $module failed with exit code: $exit_code"
        FAILED_MODULES+=("$module")
        cd "$DEV_DIR"
        return 1
    fi
}

#============================================================
# Main Execution
#============================================================

trap cleanup EXIT

print_header "Running Terragrunt $ACTION for Dev Environment"

# Check prerequisites
check_prerequisites

# Return to dev dir
cd "$DEV_DIR"

#-----------------------------
# Deployment Order:
#-----------------------------
# 1. IAM (creates roles needed by EKS)
# 2. Key Pair (creates SSH key for jumphost)
# 3. KMS (creates encryption keys for EKS)
# 4. VPC (creates networking foundation)
# 5. Security Groups (depends on VPC)
# 6. ALB (depends on VPC and SG)
# 7. EKS (depends on IAM, VPC, SG, KMS)
# 8. Jumphost (depends on VPC, SG, Key Pair, IAM)
#-----------------------------

run_terragrunt "$DEV_DIR/security/iam" "IAM Module" "1/8" || true

run_terragrunt "$DEV_DIR/security/key_pair" "Key Pair Module" "2/8" || true

run_terragrunt "$DEV_DIR/security/kms" "KMS Module" "3/8" || true

run_terragrunt "$DEV_DIR/networking/vpc" "VPC Module" "4/8" || true

run_terragrunt "$DEV_DIR/networking/sg" "Security Groups Module" "5/8" || true

run_terragrunt "$DEV_DIR/networking/alb" "ALB Module" "6/8" || true

run_terragrunt "$DEV_DIR/compute/eks" "EKS Module" "7/8" || true

run_terragrunt "$DEV_DIR/compute/jumphost" "Jumphost Module" "8/8" || true

# Check if any modules failed
if [[ ${#FAILED_MODULES[@]} -gt 0 ]]; then
    log_warn "Some modules failed. See errors above."
    exit 1
fi

exit 0
