#!/bin/bash

# ==============================================================================
# Script: terraform_backend_setup.sh
# Description: Creates and validates Terraform S3 backend configuration
# DevOps Context: IaC initialization for multi-environment deployments
# ==============================================================================

set -euo pipefail

# Configuration
readonly BACKEND_BUCKET="${1:?Error: S3 bucket name required}"
readonly ENVIRONMENT="${2:-development}"
readonly REGION="${AWS_REGION:-us-east-1}"
readonly BACKEND_FILE="backend.tf"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1: $2"
}

# Check AWS CLI
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        log "ERROR" "AWS CLI not found. Please install it first."
        exit 1
    fi
    
    if ! aws sts get-caller-identity &> /dev/null; then
        log "ERROR" "AWS credentials not configured"
        exit 1
    fi
    
    log "INFO" "✓ AWS CLI configured"
}

# Create backend configuration
create_backend_config() {
    log "INFO" "Creating Terraform backend configuration..."
    
    cat > "$BACKEND_FILE" <<EOF
terraform {
  backend "s3" {
    bucket         = "${BACKEND_BUCKET}"
    key            = "${ENVIRONMENT}/terraform.tfstate"
    region         = "${REGION}"
    encrypt        = true
    dynamodb_table = "${BACKEND_BUCKET}-locks"
  }
}
EOF
    
    log "INFO" "✓ Backend configuration created: $BACKEND_FILE"
}

# Validate required files
validate_terraform_files() {
    log "INFO" "Validating Terraform configuration..."
    
    if [ ! -f "main.tf" ]; then
        log "WARN" "main.tf not found. Creating template..."
        cat > main.tf <<EOF
terraform {
  required_version = ">= 1.0"
}

provider "aws" {
  region = "${REGION}"
}
EOF
    fi
    
    if [ ! -f "variables.tf" ]; then
        log "WARN" "variables.tf not found. Creating template..."
        cat > variables.tf <<EOF
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "${ENVIRONMENT}"
}
EOF
    fi
    
    log "INFO" "✓ Terraform files validated"
}

# Main
main() {
    log "INFO" "========================================"
    log "INFO" "Terraform Backend Setup"
    log "INFO" "  Bucket: $BACKEND_BUCKET"
    log "INFO" "  Environment: $ENVIRONMENT"
    log "INFO" "  Region: $REGION"
    log "INFO" "========================================"
    
    check_aws_cli
    create_backend_config
    validate_terraform_files
    
    log "INFO" "========================================"
    log "INFO" "✓ Setup complete! Run: terraform init"
    log "INFO" "========================================"
}

main "$@"
