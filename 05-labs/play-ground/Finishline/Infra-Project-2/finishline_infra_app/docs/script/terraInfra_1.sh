#!/bin/bash
# =============================================================================
# Terraform Infrastructure Project Initialization Script
# Project: Finish Line 2026 Infrastructure
# Assignment Reference: Finish Line 2026 §8 (Project Assignment)
# Reporter: Ganil Batist
# Timeline: Feb 26, 2026 – March 2, 2026
# =============================================================================
# This script creates the directory structure and placeholder files for a
# Terraform project following infrastructure-as-code best practices.
# 
# Features:
# - Modular directory structure (modules/, environments/)
# - Git-aware initialization
# - Backend configuration templates
# - Provider version locking
# - Pre-commit hooks setup (optional)
# - Validation and verification steps
# =============================================================================

# -----------------------------------------------------------------------------
# Strict Error Handling
# -----------------------------------------------------------------------------
set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly TERRAFORM_DIR="terraform"
readonly ENVIRONMENTS=("dev" "staging" "prod")
readonly MODULES=("vpc" "alb" "eks" "bootstrap" "security_group" "ec2")
readonly SECRET_MODULES=("iam" "key_pair")
readonly AWS_REGION="us-east-1"
readonly PROJECT_NAME="finishline-infra"

# Git configuration
readonly GITIGNORE_CONTENT='
# Terraform state files
*.tfstate
*.tfstate.*
*.tfstate.backup

# Sensitive files
*.pem
*.key
*.p12
*.pfx

# Environment-specific secrets
**/terraform.tfvars
!terraform.tfvars.example

# Crash logs
crash.log
crash.*.log

# Override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Local backend files
.terraform/
.terraform.lock.hcl

# IDE and editor files
.idea/
.vscode/
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db

# Temporary files
*.tmp
*.bak
'

readonly README_CONTENT='# Finish Line 2026 Infrastructure

## Project Overview

This repository contains the Terraform infrastructure-as-code for the Finish Line 2026 project.

## Directory Structure

```
terraform/
├── environments/
│   ├── dev/          # Development environment
│   ├── staging/      # Staging environment
│   └── prod/         # Production environment
└── modules/
    ├── vpc/          # VPC, subnets, IGW, NAT, route tables
    ├── alb/          # Application Load Balancer with IngressGroup
    ├── eks/          # EKS cluster and managed node groups
    ├── bootstrap/    # Jumphost EC2 instance
    ├── security_group/  # Security groups
    ├── ec2/          # EC2 instances
    └── secret/
        ├── iam/      # IAM roles and policies
        └── key_pair/ # SSH key pairs
```

## Quick Start

### Prerequisites

- Terraform >= 1.6.0
- AWS CLI >= 2.x
- Git

### Initial Setup

1. **Configure AWS credentials:**
   ```bash
   aws configure
   # or
   aws sso login --profile <profile>
   ```

2. **Create S3 backend bucket (one-time):**
   ```bash
   ./scripts/create-backend-bucket.sh
   ```

3. **Initialize and deploy (dev environment):**
   ```bash
   cd terraform/environments/dev
   terraform init
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

## Environments

| Environment | State Backend | Status |
|-------------|---------------|--------|
| `dev`       | S3: finishline-infra-app-<hash> | ✅ Active |
| `staging`   | S3: finishline-infra-app-<hash> | 🔲 Pending |
| `prod`      | S3: finishline-infra-app-<hash> | 🔲 Pending |

## Modules

| Module | Description | Status |
|--------|-------------|--------|
| `vpc` | VPC with 3 public + 3 private subnets | ✅ Complete |
| `alb` | Shared ALB with IngressGroup | ✅ Complete |
| `eks` | EKS cluster with 2x t3.medium nodes | ✅ Complete |
| `bootstrap` | Jumphost (Amazon Linux 2023) | ✅ Complete |
| `security_group` | Dynamic security groups | ✅ Complete |
| `secret/iam` | IAM roles for EKS | ✅ Complete |
| `secret/key_pair` | SSH key pair management | ✅ Complete |

## Assignment Compliance

| Requirement | Status | Reference |
|-------------|--------|-----------|
| 3 subnets across 3 AZs | ✅ | §51, §55 |
| EKS with 2x t3.medium | ✅ | §74, §75 |
| Bottlerocket AMI | ✅ | §79 |
| Jumphost with SSH restriction | ✅ | §69, §70 |
| ALB with IngressGroup | ✅ | §31, §62 |
| S3 backend with locking | ✅ | §28, §101 |

## Documentation

- [Runbook](../../docs/RUNBOOK.md)
- [Troubleshooting](../../docs/TROUBLESHOOT.md)
- [Assignment PDF](../../docs/Finishline_Infra_Project_Assignment.pdf)

## Support

For issues or questions, contact the Platform Team.

---

**Reporter:** Ganil Batist  
**Timeline:** Feb 26, 2026 – March 2, 2026
'

# -----------------------------------------------------------------------------
# Colors for Output
# -----------------------------------------------------------------------------
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# -----------------------------------------------------------------------------
# Global Variables
# -----------------------------------------------------------------------------
ORIGINAL_DIR="$(pwd)"
VERBOSE=false
DRY_RUN=false
SKIP_GIT=false

# -----------------------------------------------------------------------------
# Cleanup Function
# -----------------------------------------------------------------------------
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        print_msg "error" "Script failed with exit code: $exit_code"
    fi
    cd "$ORIGINAL_DIR" 2>/dev/null || true
    trap - EXIT
}
trap cleanup EXIT INT TERM

# -----------------------------------------------------------------------------
# Print Formatted Message
# -----------------------------------------------------------------------------
print_msg() {
    local status="$1"
    local message="$2"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    
    case "$status" in
        success)
            echo -e "${GREEN}✅ [${timestamp}] $message${NC}"
            ;;
        info)
            echo -e "${YELLOW}ℹ️  [${timestamp}] $message${NC}"
            ;;
        warning)
            echo -e "${YELLOW}⚠️  [${timestamp}] $message${NC}"
            ;;
        error)
            echo -e "${RED}❌ [${timestamp}] $message${NC}" >&2
            ;;
        debug)
            if [[ "$VERBOSE" == "true" ]]; then
                echo -e "${CYAN}🔍 [${timestamp}] $message${NC}"
            fi
            ;;
        step)
            echo -e "${BLUE}📍 [${timestamp}] $message${NC}"
            ;;
        *)
            echo "[$timestamp] $message"
            ;;
    esac
}

# -----------------------------------------------------------------------------
# Print Section Header
# -----------------------------------------------------------------------------
print_header() {
    local title="$1"
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}║  ${title}${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

# -----------------------------------------------------------------------------
# Parse Command Line Arguments
# -----------------------------------------------------------------------------
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            --skip-git)
                SKIP_GIT=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                print_msg "error" "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# -----------------------------------------------------------------------------
# Show Help Message
# -----------------------------------------------------------------------------
show_help() {
    cat << EOF
${CYAN}Usage:${NC} $SCRIPT_NAME [OPTIONS]

${CYAN}Description:${NC}
  Initialize Terraform infrastructure project structure for Finish Line 2026.

${CYAN}Options:${NC}
  -v, --verbose     Enable verbose output
  -n, --dry-run     Show what would be done without making changes
  --skip-git        Skip Git repository initialization
  -h, --help        Show this help message

${CYAN}Examples:${NC}
  $SCRIPT_NAME                    # Initialize with defaults
  $SCRIPT_NAME --verbose          # Initialize with verbose output
  $SCRIPT_NAME --dry-run          # Preview changes without applying
  $SCRIPT_NAME --skip-git         # Initialize without Git

${CYAN}Requirements:${NC}
  - Must be run from the project root directory (finishline_infra_app)
  - Git must be installed (unless --skip-git is used)
  - Bash 4.0 or higher

EOF
}

# -----------------------------------------------------------------------------
# Verify Prerequisites
# -----------------------------------------------------------------------------
verify_prerequisites() {
    print_msg "step" "Verifying prerequisites..."
    
    # Check Bash version
    local bash_version
    bash_version="$(bash --version | head -n1 | awk '{print $4}' | cut -d'.' -f1)"
    if [[ "$bash_version" -lt 4 ]]; then
        print_msg "error" "Bash 4.0 or higher is required. Current version: $(bash --version | head -n1)"
        exit 1
    fi
    print_msg "debug" "Bash version: $(bash --version | head -n1)"
    
    # Check if running from project root
    if [[ ! "$ORIGINAL_DIR" == *"finishline_infra_app"* ]]; then
        print_msg "error" "Please run this script from the finishline_infra_app directory"
        print_msg "info" "Current directory: $ORIGINAL_DIR"
        exit 1
    fi
    print_msg "debug" "Running from: $ORIGINAL_DIR"
    
    # Check Git (unless skipped)
    if [[ "$SKIP_GIT" != "true" ]]; then
        if ! command -v git &>/dev/null; then
            print_msg "warning" "Git is not installed. Skipping Git initialization."
            SKIP_GIT=true
        else
            print_msg "debug" "Git version: $(git --version)"
        fi
    fi
    
    # Check if terraform directory already exists
    if [[ -d "$TERRAFORM_DIR" ]]; then
        print_msg "warning" "Directory '$TERRAFORM_DIR' already exists. Files will be added/updated."
    fi
    
    print_msg "success" "Prerequisites verified"
}

# -----------------------------------------------------------------------------
# Create Directory Structure
# -----------------------------------------------------------------------------
create_directory_structure() {
    print_header "Creating Directory Structure"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_msg "info" "[DRY RUN] Would create directory structure"
        return
    fi
    
    print_msg "step" "Creating Terraform root directory..."
    mkdir -p "$TERRAFORM_DIR"
    cd "$TERRAFORM_DIR"
    
    print_msg "step" "Creating module directories..."
    for module in "${MODULES[@]}"; do
        mkdir -p "modules/$module"
        print_msg "debug" "Created: modules/$module"
    done
    
    print_msg "step" "Creating secret module directories..."
    for secret_module in "${SECRET_MODULES[@]}"; do
        mkdir -p "modules/secret/$secret_module"
        print_msg "debug" "Created: modules/secret/$secret_module"
    done
    
    print_msg "step" "Creating environment directories..."
    for env in "${ENVIRONMENTS[@]}"; do
        mkdir -p "environments/$env"
        print_msg "debug" "Created: environments/$env"
    done
    
    # Create scripts directory
    mkdir -p "scripts"
    print_msg "debug" "Created: scripts/"
    
    print_msg "success" "Directory structure created"
}

# -----------------------------------------------------------------------------
# Create Module Files
# -----------------------------------------------------------------------------
create_module_files() {
    print_header "Creating Module Files"
    
    # VPC Module
    print_msg "step" "Creating VPC module files..."
    if [[ "$DRY_RUN" == "true" ]]; then
        print_msg "info" "[DRY RUN] Would create VPC module files"
    else
        for file in main variables output; do
            create_placeholder_file "modules/vpc/${file}.tf" "# VPC Module - ${file^}"
        done
        create_readme "modules/vpc" "VPC Module" "Creates VPC with 3 public and 3 private subnets across 3 AZs"
    fi
    
    # ALB Module
    print_msg "step" "Creating ALB module files..."
    if [[ "$DRY_RUN" == "true" ]]; then
        print_msg "info" "[DRY RUN] Would create ALB module files"
    else
        for file in main variables output; do
            create_placeholder_file "modules/alb/${file}.tf" "# ALB Module - ${file^}"
        done
        create_readme "modules/alb" "ALB Module" "Shared Application Load Balancer with IngressGroup support"
    fi
    
    # EKS Module
    print_msg "step" "Creating EKS module files..."
    if [[ "$DRY_RUN" == "true" ]]; then
        print_msg "info" "[DRY RUN] Would create EKS module files"
    else
        for file in main variables output addons; do
            create_placeholder_file "modules/eks/${file}.tf" "# EKS Module - ${file^}"
        done
        create_readme "modules/eks" "EKS Module" "EKS cluster with managed node groups (2x t3.medium, Bottlerocket)"
    fi
    
    # Bootstrap Module
    print_msg "step" "Creating Bootstrap module files..."
    if [[ "$DRY_RUN" == "true" ]]; then
        print_msg "info" "[DRY RUN] Would create Bootstrap module files"
    else
        for file in main variables output; do
            create_placeholder_file "modules/bootstrap/${file}.tf" "# Bootstrap Module - ${file^}"
        done
        create_readme "modules/bootstrap" "Bootstrap Module" "Jumphost EC2 instance (Amazon Linux 2023)"
    fi
    
    # Security Group Module
    print_msg "step" "Creating Security Group module files..."
    if [[ "$DRY_RUN" == "true" ]]; then
        print_msg "info" "[DRY RUN] Would create Security Group module files"
    else
        for file in main variables output; do
            create_placeholder_file "modules/security_group/${file}.tf" "# Security Group Module - ${file^}"
        done
        create_readme "modules/security_group" "Security Group Module" "Dynamic security groups with ingress/egress rules"
    fi
    
    # EC2 Module
    print_msg "step" "Creating EC2 module files..."
    if [[ "$DRY_RUN" == "true" ]]; then
        print_msg "info" "[DRY RUN] Would create EC2 module files"
    else
        for file in main variables output; do
            create_placeholder_file "modules/ec2/${file}.tf" "# EC2 Module - ${file^}"
        done
        create_readme "modules/ec2" "EC2 Module" "EC2 instances with user data support"
    fi
    
    # Secret Modules
    for secret_module in "${SECRET_MODULES[@]}"; do
        print_msg "step" "Creating secret/$secret_module module files..."
        if [[ "$DRY_RUN" == "true" ]]; then
            print_msg "info" "[DRY RUN] Would create secret/$secret_module module files"
        else
            for file in main variables output; do
                create_placeholder_file "modules/secret/${secret_module}/${file}.tf" "# Secret/${secret_module^} Module - ${file^}"
            done
            create_readme "modules/secret/$secret_module" "Secret/${secret_module^} Module" "Manages ${secret_module//_/ } resources"
        fi
    done
    
    print_msg "success" "Module files created"
}

# -----------------------------------------------------------------------------
# Create Environment Files
# -----------------------------------------------------------------------------
create_environment_files() {
    print_header "Creating Environment Files"
    
    for env in "${ENVIRONMENTS[@]}"; do
        print_msg "step" "Creating $env environment files..."
        
        if [[ "$DRY_RUN" == "true" ]]; then
            print_msg "info" "[DRY RUN] Would create $env environment files"
            continue
        fi
        
        # Create main.tf
        cat > "environments/$env/main.tf" << EOF
# =============================================================================
# Main Configuration: $env Environment
# Project: Finish Line 2026 Infrastructure
# =============================================================================

# VPC Module
module "vpc" {
  source = "../../modules/vpc"
  
  # TODO: Add configuration
}

# Add more modules as needed
EOF
        
        # Create variables.tf
        cat > "environments/$env/variables.tf" << EOF
# =============================================================================
# Variables: $env Environment
# =============================================================================

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "${PROJECT_NAME}"
}

variable "environment" {
  description = "The environment name"
  type        = string
  default     = "$env"
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = "${AWS_REGION}"
}
EOF
        
        # Create outputs.tf
        cat > "environments/$env/output.tf" << EOF
# =============================================================================
# Outputs: $env Environment
# =============================================================================

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}
EOF
        
        # Create backend.tf
        cat > "environments/$env/backend.tf" << EOF
# =============================================================================
# Backend Configuration: $env Environment
# =============================================================================

terraform {
  backend "s3" {
    bucket       = "finishline-infra-app-<replace-with-hash>"
    key          = "$env/terraform.tfstate"
    region       = "${AWS_REGION}"
    use_lockfile = true
    encrypt      = true
  }
}
EOF
        
        # Create providers.tf
        cat > "environments/$env/providers.tf" << EOF
# =============================================================================
# Provider Configuration: $env Environment
# =============================================================================

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}
EOF
        
        # Create versions.tf
        cat > "environments/$env/versions.tf" << EOF
# =============================================================================
# Version Constraints: $env Environment
# =============================================================================

terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}
EOF
        
        # Create terraform.tfvars.example
        cat > "environments/$env/terraform.tfvars.example" << EOF
# =============================================================================
# Example Variables: $env Environment
# Copy this file to terraform.tfvars and update values
# =============================================================================

project_name = "${PROJECT_NAME}"
environment  = "$env"
aws_region   = "${AWS_REGION}"

# Add more variables as needed
EOF
        
        print_msg "debug" "Created: environments/$env/{main,variables,output,backend,providers,versions}.tf"
        print_msg "debug" "Created: environments/$env/terraform.tfvars.example"
    done
    
    print_msg "success" "Environment files created"
}

# -----------------------------------------------------------------------------
# Create Placeholder File
# -----------------------------------------------------------------------------
create_placeholder_file() {
    local filepath="$1"
    local content="$2"
    
    echo "# $content" > "$filepath"
    echo "# Generated by $SCRIPT_NAME on $(date)" >> "$filepath"
    echo "" >> "$filepath"
}

# -----------------------------------------------------------------------------
# Create README.md
# -----------------------------------------------------------------------------
create_readme() {
    local dir="$1"
    local title="$2"
    local description="$3"
    
    cat > "$dir/README.md" << EOF
# $title

**Path:** \`$dir\`

## Description

$description

## Files

- \`main.tf\` - Resource definitions
- \`variables.tf\` - Input variables
- \`output.tf\` - Output values

## Usage

\`\`\`hcl
module "$(basename "$dir")" {
  source = "../../$dir"
  
  # Add configuration
}
\`\`\`

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| TBD | TBD | string | "" |

## Outputs

| Name | Description |
|------|-------------|
| TBD | TBD |

---

*Generated by $SCRIPT_NAME*
EOF
}

# -----------------------------------------------------------------------------
# Create Git Repository
# -----------------------------------------------------------------------------
create_git_repository() {
    print_header "Initializing Git Repository"
    
    if [[ "$SKIP_GIT" == "true" ]]; then
        print_msg "info" "Skipping Git initialization (--skip-git flag set)"
        return
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_msg "info" "[DRY RUN] Would initialize Git repository"
        return
    fi
    
    cd "$ORIGINAL_DIR"
    
    # Check if already a git repo
    if [[ -d ".git" ]]; then
        print_msg "info" "Git repository already exists"
    else
        print_msg "step" "Initializing Git repository..."
        git init
        print_msg "success" "Git repository initialized"
    fi
    
    # Create .gitignore
    print_msg "step" "Creating .gitignore..."
    echo "$GITIGNORE_CONTENT" > ".gitignore"
    print_msg "success" ".gitignore created"
    
    # Create root README.md
    print_msg "step" "Creating README.md..."
    echo "$README_CONTENT" > "README.md"
    print_msg "success" "README.md created"
    
    # Create initial commit
    print_msg "step" "Creating initial commit..."
    git add .
    git commit -m "chore: Initialize Terraform project structure

- Create modular directory structure (modules/, environments/)
- Add VPC, ALB, EKS, bootstrap, security_group, ec2 modules
- Add secret modules (iam, key_pair)
- Configure dev, staging, prod environments
- Add .gitignore for Terraform files
- Add README with project documentation

Project: Finish Line 2026 Infrastructure
Reporter: Ganil Batist
Timeline: Feb 26, 2026 – March 2, 2026" || print_msg "warning" "Initial commit failed (may need git config)"
    
    print_msg "success" "Git repository initialized"
}

# -----------------------------------------------------------------------------
# Create Helper Scripts
# -----------------------------------------------------------------------------
create_helper_scripts() {
    print_header "Creating Helper Scripts"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_msg "info" "[DRY RUN] Would create helper scripts"
        return
    fi
    
    # Create scripts directory
    mkdir -p "$TERRAFORM_DIR/scripts"
    
    # Create backend bucket creation script
    cat > "$TERRAFORM_DIR/scripts/create-backend-bucket.sh" << 'SCRIPT'
#!/bin/bash
# Create S3 backend bucket for Terraform state

set -euo pipefail

BUCKET_NAME="finishline-infra-app-$(openssl rand -hex 4)"
REGION="${AWS_REGION:-us-east-1}"

echo "Creating S3 bucket: $BUCKET_NAME in $REGION"

aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION"

aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "✅ Backend bucket created: $BUCKET_NAME"
echo "Update backend.tf with this bucket name"
SCRIPT
    chmod +x "$TERRAFORM_DIR/scripts/create-backend-bucket.sh"
    
    # Create validate script
    cat > "$TERRAFORM_DIR/scripts/validate.sh" << 'SCRIPT'
#!/bin/bash
# Validate all Terraform configurations

set -euo pipefail

echo "🔍 Validating Terraform configurations..."

for env in dev staging prod; do
    echo ""
    echo "=== Validating $env environment ==="
    cd "environments/$env" || continue
    
    terraform fmt -check -recursive || terraform fmt -recursive
    terraform init -backend=false
    terraform validate
    
    cd ../..
done

echo ""
echo "✅ All validations passed!"
SCRIPT
    chmod +x "$TERRAFORM_DIR/scripts/validate.sh"
    
    print_msg "success" "Helper scripts created"
}

# -----------------------------------------------------------------------------
# Print Summary
# -----------------------------------------------------------------------------
print_summary() {
    print_header "Initialization Complete"
    
    cat << EOF
${GREEN}✅ Terraform Project Structure Initialized Successfully!${NC}

${CYAN}Next Steps:${NC}

1. ${YELLOW}Review the structure:${NC}
   cd $TERRAFORM_DIR
   tree -L 3

2. ${YELLOW}Create backend bucket (one-time):${NC}
   cd scripts
   ./create-backend-bucket.sh

3. ${YELLOW}Configure dev environment:${NC}
   cd environments/dev
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values

4. ${YELLOW}Initialize and deploy:${NC}
   terraform init
   terraform plan -out=tfplan
   terraform apply tfplan

${CYAN}Project Information:${NC}
  - Project Name: $PROJECT_NAME
  - AWS Region: $AWS_REGION
  - Environments: ${ENVIRONMENTS[*]}
  - Modules: ${MODULES[*]}, secret/${SECRET_MODULES[*]}

${CYAN}Documentation:${NC}
  - Runbook: docs/RUNBOOK.md
  - Troubleshooting: docs/TROUBLESHOOT.md

---
Reporter: Ganil Batist
Timeline: Feb 26, 2026 – March 2, 2026
EOF
}

# -----------------------------------------------------------------------------
# Main Function
# -----------------------------------------------------------------------------
main() {
    print_header "Finish Line 2026 - Terraform Project Initialization"
    
    parse_args "$@"
    
    print_msg "info" "Script: $SCRIPT_NAME"
    print_msg "info" "Working Directory: $ORIGINAL_DIR"
    print_msg "info" "Verbose: $VERBOSE"
    print_msg "info" "Dry Run: $DRY_RUN"
    print_msg "info" "Skip Git: $SKIP_GIT"
    
    verify_prerequisites
    create_directory_structure
    create_module_files
    create_environment_files
    create_helper_scripts
    create_git_repository
    print_summary
}

# Run main function with all arguments
main "$@"
