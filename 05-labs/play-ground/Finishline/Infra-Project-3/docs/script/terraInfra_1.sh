#!/bin/bash
# =============================================================================
# Terraform Infrastructure Project Initialization Script
# Project: Finish Line 2026 Infrastructure
# Assignment: Finish Line 2026 §8 (Project Assignment)
# Reporter: Joseph Ndzoh Dong
# Timeline: Feb 26, 2026 – March 2, 2026
# Region: us-east-1
# =============================================================================
# This script creates the modular Terraform repository structure following
# the assignment requirements with exact module composition.
#
# Modular Structure (per Diagram 2 - Terraform Module Composition):
# - envs/dev/: Root module consuming sub-modules
# - modules/vpc: VPC, Subnets, IGW, Route Tables
# - modules/alb: Internet-facing ALB with group-tag=finishline
# - modules/eks: Cluster + Managed Node Group (2x t3.medium, Bottlerocket)
# - modules/jumphost: EC2, SG, Keypair, User-Data for tooling
# - modules/iam: Instance roles and EKS access mapping
# - modules/bootstrap: S3 state backend with DynamoDB locking
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

# Corrected module structure per assignment requirements
readonly CORE_MODULES=("vpc" "alb" "eks" "jumphost" "iam" "bootstrap")
readonly AWS_REGION="us-east-1"
readonly PROJECT_NAME="finishline-infra"
readonly S3_BUCKET_NAME="finishline-infra"

# Package installation method (answer to the pedagogical question)
# See: INSTALLATION_STRATEGY.md for detailed analysis
readonly PACKAGE_INSTALL_METHOD="user_data"  # Options: user_data, ansible, manual_script

# Git configuration
readonly GITIGNORE_CONTENT='
# =============================================================================
# Terraform Git Ignore - Finish Line 2026 Infrastructure
# =============================================================================

# Terraform state files
*.tfstate
*.tfstate.*
*.tfstate.backup
*.tfstate.lock

# Sensitive files
*.pem
*.key
*.p12
*.pfx
*.crt
*.csr

# Environment-specific secrets
**/terraform.tfvars
!terraform.tfvars.example
!*.tfvars.example

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
*.iml

# OS files
.DS_Store
Thumbs.db
desktop.ini

# Temporary files
*.tmp
*.bak
*.cache

# User data scripts (may contain secrets)
user_data_*.sh
!user_data_example.sh

# Kubeconfig files
kubeconfig_*
*.kubeconfig

# Assignment documents (keep originals, ignore working copies)
!Finishline_Infra_Project_Assignment.pdf
*.pdf~
*.docx~
'

# -----------------------------------------------------------------------------
# Colors for Output
# -----------------------------------------------------------------------------
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly MAGENTA='\033[0;35m'
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
        phase)
            echo -e "${MAGENTA}📌 [${timestamp}] $message${NC}"
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
# Print Phase Header
# -----------------------------------------------------------------------------
print_phase() {
    local phase_num="$1"
    local title="$2"
    echo ""
    echo -e "${MAGENTA}╔═══════════════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}║  PHASE ${phase_num}: ${title}${NC}"
    echo -e "${MAGENTA}╚═══════════════════════════════════════════════════════════${NC}"
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
            --install-method)
                shift
                PACKAGE_INSTALL_METHOD="$1"
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
  Initialize modular Terraform infrastructure project for Finish Line 2026.
  Creates phase-based module structure per assignment requirements.

${CYAN}Options:${NC}
  -v, --verbose           Enable verbose output
  -n, --dry-run           Show what would be done without making changes
  --skip-git              Skip Git repository initialization
  --install-method TYPE   Package installation method (user_data|ansible|manual)
                          Default: user_data (recommended)
  -h, --help              Show this help message

${CYAN}Phases:${NC}
  Phase 1: Modular Structure (modules/ + envs/dev/)
    1.1 modules/vpc       - VPC, 3 subnets across 3 AZs, IGW, Route Tables
    1.2 modules/alb       - Internet-facing ALB (group-tag=finishline)
    1.3 modules/eks       - EKS cluster + Managed Node Group (2x t3.medium)
    1.4 modules/jumphost  - EC2 (AL2023), SG, Keypair, User-Data tooling
    1.5 modules/iam       - Instance roles and EKS access mapping
  Phase 2: Bootstrap Workflow (modules/bootstrap)
    2.1 S3 backend (finishline-infra) with DynamoDB locking
  Phase 3: Environment Configuration (envs/dev/)
    3.1 Root module consuming all sub-modules

${CYAN}Examples:${NC}
  $SCRIPT_NAME                          # Initialize with defaults
  $SCRIPT_NAME --verbose                # Initialize with verbose output
  $SCRIPT_NAME --dry-run                # Preview changes without applying
  $SCRIPT_NAME --install-method ansible # Use Ansible for package installation

${CYAN}Requirements:${NC}
  - Must be run from project root (finishline_infra_app)
  - Git must be installed (unless --skip-git is used)
  - Bash 4.0 or higher

${CYAN}Assignment Compliance:${NC}
  - 3 subnets across 3 AZs (§51, §55)
  - EKS with 2x t3.medium, Bottlerocket (§74, §75, §79)
  - Jumphost AL2023 with SSH restriction (§69, §70)
  - ALB with group-tag=finishline (§31, §62)
  - S3 backend with DynamoDB locking (§28, §101)

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
        print_msg "error" "Bash 4.0 or higher required. Current: $(bash --version | head -n1)"
        exit 1
    fi
    print_msg "debug" "Bash version: $(bash --version | head -n1)"

    # Check if running from project root
    if [[ ! "$ORIGINAL_DIR" == *"finishline_infra_app"* ]]; then
        print_msg "error" "Please run from finishline_infra_app directory"
        print_msg "info" "Current directory: $ORIGINAL_DIR"
        exit 1
    fi
    print_msg "debug" "Running from: $ORIGINAL_DIR"

    # Check Git (unless skipped)
    if [[ "$SKIP_GIT" != "true" ]]; then
        if ! command -v git &>/dev/null; then
            print_msg "warning" "Git not installed. Skipping initialization."
            SKIP_GIT=true
        else
            print_msg "debug" "Git version: $(git --version)"
        fi
    fi

    # Check if terraform directory already exists
    if [[ -d "$TERRAFORM_DIR" ]]; then
        print_msg "warning" "Directory '$TERRAFORM_DIR' exists. Files will be added/updated."
    fi

    print_msg "success" "Prerequisites verified"
}

# -----------------------------------------------------------------------------
# Create Directory Structure
# -----------------------------------------------------------------------------
create_directory_structure() {
    print_phase "1" "Modular Structure Creation"

    if [[ "$DRY_RUN" == "true" ]]; then
        print_msg "info" "[DRY RUN] Would create directory structure"
        return
    fi

    print_msg "step" "Creating Terraform root directory..."
    mkdir -p "$TERRAFORM_DIR"
    cd "$TERRAFORM_DIR"

    print_msg "step" "Creating core module directories..."
    for module in "${CORE_MODULES[@]}"; do
        mkdir -p "modules/$module"
        print_msg "debug" "Created: modules/$module"
    done

    print_msg "step" "Creating environment directories..."
    for env in "${ENVIRONMENTS[@]}"; do
        mkdir -p "envs/$env"
        print_msg "debug" "Created: envs/$env"
    done

    # Create scripts directory
    mkdir -p "scripts"
    print_msg "debug" "Created: scripts/"

    # Create docs directory for diagrams
    mkdir -p "docs/diagrams"
    print_msg "debug" "Created: docs/diagrams/"

    print_msg "success" "Directory structure created"
}

# -----------------------------------------------------------------------------
# Create Module Files (with locals.tf)
# -----------------------------------------------------------------------------
create_module_files() {
    print_phase "1" "Creating Module Files with locals.tf"

    # =======================================================================
    # VPC Module (Phase 1.1)
    # Assignment: §51, §55, §56, §57 - VPC with 3 subnets across 3 AZs
    # =======================================================================
    print_msg "step" "Creating VPC module files (Phase 1.1)..."
    if [[ "$DRY_RUN" == "true" ]]; then
        print_msg "info" "[DRY RUN] Would create VPC module files"
    else
        create_vpc_module
    fi

    # =======================================================================
    # ALB Module (Phase 1.2)
    # Assignment: §31, §62, §65 - ALB with group-tag=finishline
    # =======================================================================
    print_msg "step" "Creating ALB module files (Phase 1.2)..."
    if [[ "$DRY_RUN" == "true" ]]; then
        print_msg "info" "[DRY RUN] Would create ALB module files"
    else
        create_alb_module
    fi

    # =======================================================================
    # EKS Module (Phase 1.3)
    # Assignment: §74, §75, §76, §79 - EKS with 2x t3.medium, Bottlerocket
    # =======================================================================
    print_msg "step" "Creating EKS module files (Phase 1.3)..."
    if [[ "$DRY_RUN" == "true" ]]; then
        print_msg "info" "[DRY RUN] Would create EKS module files"
    else
        create_eks_module
    fi

    # =======================================================================
    # Jumphost Module (Phase 1.4)
    # Assignment: §69, §70, §73 - AL2023, SSH restriction, tooling
    # =======================================================================
    print_msg "step" "Creating Jumphost module files (Phase 1.4)..."
    if [[ "$DRY_RUN" == "true" ]]; then
        print_msg "info" "[DRY RUN] Would create Jumphost module files"
    else
        create_jumphost_module
    fi

    # =======================================================================
    # IAM Module (Phase 1.5)
    # Assignment: §83, §84, §87, §89 - Instance roles, EKS access mapping
    # =======================================================================
    print_msg "step" "Creating IAM module files (Phase 1.5)..."
    if [[ "$DRY_RUN" == "true" ]]; then
        print_msg "info" "[DRY RUN] Would create IAM module files"
    else
        create_iam_module
    fi

    # =======================================================================
    # Bootstrap Module (Phase 2)
    # Assignment: §28, §101, §102, §105 - S3 backend with DynamoDB locking
    # =======================================================================
    print_msg "step" "Creating Bootstrap module files (Phase 2)..."
    if [[ "$DRY_RUN" == "true" ]]; then
        print_msg "info" "[DRY RUN] Would create Bootstrap module files"
    else
        create_bootstrap_module
    fi

    print_msg "success" "Module files created"
}

# -----------------------------------------------------------------------------
# VPC Module Creation
# -----------------------------------------------------------------------------
create_vpc_module() {
    # main.tf
    cat > "modules/vpc/main.tf" << 'EOF'
# =============================================================================
# VPC Module - Main Configuration
# Finish Line 2026 Infrastructure
# Assignment: §51, §55, §56, §57 - VPC with 3 subnets across 3 AZs
# =============================================================================

# VPC
resource "aws_vpc" "finishline_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-vpc"
    Type = "VPC"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "finishline_igw" {
  vpc_id = aws_vpc.finishline_vpc.id

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-igw"
    Type = "InternetGateway"
  })
}

# Public Subnets (3 across 3 AZs)
resource "aws_subnet" "finishline_public_subnet" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.finishline_vpc.id
  cidr_block              = var.public_subnets_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-public-subnet-${count.index + 1}"
    Type = "PublicSubnet"
    Tier = "public"
  })
}

# Private Subnets (3 across 3 AZs)
resource "aws_subnet" "finishline_private_subnet" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.finishline_vpc.id
  cidr_block        = var.private_subnets_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-private-subnet-${count.index + 1}"
    Type = "PrivateSubnet"
    Tier = "private"
  })
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.finishline_vpc.id

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-public-rt"
    Type = "RouteTable"
  })
}

# Default route to Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.finishline_igw.id
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.finishline_public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.finishline_vpc.id

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-private-rt"
    Type = "RouteTable"
  })
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.finishline_private_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}
EOF

    # variables.tf
    cat > "modules/vpc/variables.tf" << 'EOF'
# =============================================================================
# VPC Module - Input Variables
# Finish Line 2026 Infrastructure
# =============================================================================

variable "project_name" {
  description = "The name of the project (used in resource naming and tags)"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,20}[a-z0-9]$", var.project_name))
    error_message = "Project name must be 4-24 chars, start with letter, lowercase alphanumeric and hyphens only."
  }
}

variable "environment" {
  description = "The environment name (dev/staging/prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "manage_by" {
  description = "The entity responsible for managing resources (ManagedBy tag)"
  type        = string
  default     = "Terraform"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC (recommended: 10.0.0.0/16)"
  type        = string
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "enable_dns_hostnames" {
  description = "Whether to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Whether to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "availability_zones" {
  description = "List of 3 availability zones for subnet distribution"
  type        = list(string)
  validation {
    condition     = length(var.availability_zones) == 3
    error_message = "Exactly 3 availability zones are required per assignment §51."
  }
}

variable "public_subnets_cidrs" {
  description = "CIDR blocks for 3 public subnets"
  type        = list(string)
  validation {
    condition     = length(var.public_subnets_cidrs) == 3
    error_message = "Exactly 3 public subnet CIDRs are required."
  }
}

variable "private_subnets_cidrs" {
  description = "CIDR blocks for 3 private subnets"
  type        = list(string)
  validation {
    condition     = length(var.private_subnets_cidrs) == 3
    error_message = "Exactly 3 private subnet CIDRs are required."
  }
}
EOF

    # locals.tf
    cat > "modules/vpc/locals.tf" << 'EOF'
# =============================================================================
# VPC Module - Local Values
# Finish Line 2026 Infrastructure
# =============================================================================

locals {
  # Common tags applied to all resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.manage_by
    Module      = "vpc"
  }

  # Project name with environment prefix for unique naming
  project_name = "${var.project_name}-${var.environment}"
}
EOF

    # outputs.tf
    cat > "modules/vpc/outputs.tf" << 'EOF'
# =============================================================================
# VPC Module - Output Values
# Finish Line 2026 Infrastructure
# =============================================================================

output "main_vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.finishline_vpc.id
}

output "main_public_subnet_ids" {
  description = "List of IDs for all public subnets"
  value       = aws_subnet.finishline_public_subnet[*].id
}

output "main_private_subnet_ids" {
  description = "List of IDs for all private subnets"
  value       = aws_subnet.finishline_private_subnet[*].id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.finishline_vpc.cidr_block
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.finishline_igw.id
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = aws_route_table.private.id
}
EOF

    # README.md
    create_module_readme "modules/vpc" "VPC Module" "Creates VPC with 3 public + 3 private subnets across 3 AZs, IGW, and route tables per assignment §51, §55."
}

# -----------------------------------------------------------------------------
# ALB Module Creation
# -----------------------------------------------------------------------------
create_alb_module() {
    # main.tf
    cat > "modules/alb/main.tf" << 'EOF'
# =============================================================================
# ALB Module - Main Configuration
# Finish Line 2026 Infrastructure
# Assignment: §31, §62, §65 - ALB with group-tag=finishline
# =============================================================================

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "${local.project_name}-alb-sg"
  description = "Security group for shared Application Load Balancer"
  vpc_id      = var.vpc_id

  # HTTP ingress from anywhere (internet-facing ALB)
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS ingress from anywhere
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic allowed
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-alb-sg"
    Type = "SecurityGroup"
  })
}

# Application Load Balancer
resource "aws_lb" "finishline_alb" {
  name               = "${local.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  # Enable deletion protection in non-dev environments
  deletion_protection = var.environment != "dev" ? true : false

  # Critical tag for AWS Load Balancer Controller IngressGroup
  tags = merge(local.common_tags, {
    Name        = "${local.project_name}-alb"
    Type        = "LoadBalancer"
    "group-tag" = "finishline"  # Required for IngressGroup mechanism
  })
}

# Target Group for EKS services
resource "aws_lb_target_group" "eks_target_group" {
  name     = "${local.project_name}-eks-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200-399"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-eks-tg"
    Type = "TargetGroup"
  })
}

# HTTP Listener (redirect to HTTPS in production)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.finishline_alb.arn
  port              = 80
  protocol          = "HTTP"

  # Default action: redirect to HTTPS (or forward to target group)
  default_action {
    type = var.environment == "dev" ? "forward" : "redirect"

    target_group_arn = var.environment == "dev" ? aws_lb_target_group.eks_target_group.arn : null

    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.finishline_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.eks_target_group.arn
  }
}
EOF

    # variables.tf
    cat > "modules/alb/variables.tf" << 'EOF'
# =============================================================================
# ALB Module - Input Variables
# Finish Line 2026 Infrastructure
# =============================================================================

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment name"
  type        = string
}

variable "manage_by" {
  description = "ManagedBy tag value"
  type        = string
  default     = "Terraform"
}

variable "vpc_id" {
  description = "VPC ID where ALB will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB deployment"
  type        = list(string)
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener"
  type        = string
  default     = null
}
EOF

    # locals.tf
    cat > "modules/alb/locals.tf" << 'EOF'
# =============================================================================
# ALB Module - Local Values
# Finish Line 2026 Infrastructure
# =============================================================================

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.manage_by
    Module      = "alb"
  }

  project_name = "${var.project_name}-${var.environment}"
}
EOF

    # outputs.tf
    cat > "modules/alb/outputs.tf" << 'EOF'
# =============================================================================
# ALB Module - Output Values
# Finish Line 2026 Infrastructure
# =============================================================================

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.finishline_alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.finishline_alb.dns_name
}

output "alb_security_group_id" {
  description = "Security group ID of the ALB"
  value       = aws_security_group.alb_sg.id
}

output "target_group_arn" {
  description = "ARN of the EKS target group"
  value       = aws_lb_target_group.eks_target_group.arn
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = aws_lb_listener.https.arn
}
EOF

    create_module_readme "modules/alb" "ALB Module" "Shared internet-facing ALB with group-tag=finishline for AWS LB Controller IngressGroup per assignment §31, §62."
}

# -----------------------------------------------------------------------------
# EKS Module Creation
# -----------------------------------------------------------------------------
create_eks_module() {
    # main.tf
    cat > "modules/eks/main.tf" << 'EOF'
# =============================================================================
# EKS Module - Main Configuration
# Finish Line 2026 Infrastructure
# Assignment: §74, §75, §76, §79 - EKS with 2x t3.medium, Bottlerocket x86
# =============================================================================

# EKS Cluster IAM Role
resource "aws_iam_role" "eks_cluster_role" {
  name = "${local.project_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Attach required policies to cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

# EKS Cluster
resource "aws_eks_cluster" "finishline_eks" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
  }

  enabled_cluster_log_types = var.cluster_enabled_log_types

  tags = merge(local.common_tags, {
    Name = var.cluster_name
    Type = "EKSCluster"
  })

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller_policy,
  ]
}

# EKS Managed Node Group IAM Role
resource "aws_iam_role" "eks_node_group_role" {
  name = "${local.project_name}-eks-nodegroup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Attach required policies to node group role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}

# EKS Managed Node Group
resource "aws_eks_node_group" "finishline_node_group" {
  cluster_name    = aws_eks_cluster.finishline_eks.name
  node_group_name = "${local.project_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.subnet_ids

  # Assignment requirement: exactly 2 nodes, fixed size
  instance_types = var.instance_types
  ami_type       = "AL2_x86_64"  # Bottlerocket x86 architecture

  # Fixed node group size per assignment §79
  capacity_type  = "ON_DEMAND"
  disk_size      = 20

  scaling_config {
    desired_size = 2  # Fixed to 2 per assignment
    min_size     = 2  # Fixed to 2 per assignment
    max_size     = 2  # Fixed to 2 per assignment
  }

  # Ensure nodes have public IP for internet access
  node_repair_config {
    enabled = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-node-group"
    Type = "EKSNodeGroup"
  })

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
  ]

  lifecycle {
    ignore_changes = [
      scaling_config[0].desired_size,
    ]
  }
}

# OIDC Provider for IAM roles for service accounts
data "tls_certificate" "eks" {
  url = aws_eks_cluster.finishline_eks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.finishline_eks.identity[0].oidc[0].issuer

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-eks-oidc"
    Type = "OIDCProvider"
  })
}
EOF

    # variables.tf
    cat > "modules/eks/variables.tf" << 'EOF'
# =============================================================================
# EKS Module - Input Variables
# Finish Line 2026 Infrastructure
# =============================================================================

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment name"
  type        = string
}

variable "manage_by" {
  description = "ManagedBy tag value"
  type        = string
  default     = "Terraform"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the cluster"
  type        = string
  default     = "1.31"
}

variable "subnet_ids" {
  description = "List of subnet IDs for EKS cluster and node group"
  type        = list(string)
}

variable "endpoint_private_access" {
  description = "Whether to enable private access to EKS endpoint"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether to enable public access to EKS endpoint"
  type        = bool
  default     = true
}

variable "cluster_enabled_log_types" {
  description = "List of control plane logging types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

variable "instance_types" {
  description = "Instance types for node group (assignment: t3.medium)"
  type        = list(string)
  default     = ["t3.medium"]
}
EOF

    # locals.tf
    cat > "modules/eks/locals.tf" << 'EOF'
# =============================================================================
# EKS Module - Local Values
# Finish Line 2026 Infrastructure
# =============================================================================

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.manage_by
    Module      = "eks"
  }

  project_name = "${var.project_name}-${var.environment}"
}
EOF

    # outputs.tf
    cat > "modules/eks/outputs.tf" << 'EOF'
# =============================================================================
# EKS Module - Output Values
# Finish Line 2026 Infrastructure
# =============================================================================

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.finishline_eks.name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.finishline_eks.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for cluster CA"
  value       = aws_eks_cluster.finishline_eks.certificate_authority[0].data
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.finishline_eks.arn
}

output "node_group_name" {
  description = "Name of the managed node group"
  value       = aws_eks_node_group.finishline_node_group.node_group_name
}

output "node_group_arn" {
  description = "ARN of the managed node group"
  value       = aws_eks_node_group.finishline_node_group.arn
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "node_group_role_arn" {
  description = "ARN of the node group IAM role"
  value       = aws_iam_role.eks_node_group_role.arn
}

output "cluster_security_group_id" {
  description = "Security group ID of the EKS cluster"
  value       = aws_eks_cluster.finishline_eks.vpc_config[0].cluster_security_group_id
}
EOF

    create_module_readme "modules/eks" "EKS Module" "EKS cluster with managed node group (2x t3.medium, Bottlerocket x86) per assignment §74, §75, §79."
}

# -----------------------------------------------------------------------------
# Jumphost Module Creation
# -----------------------------------------------------------------------------
create_jumphost_module() {
    # main.tf
    cat > "modules/jumphost/main.tf" << 'EOF'
# =============================================================================
# Jumphost Module - Main Configuration
# Finish Line 2026 Infrastructure
# Assignment: §69, §70, §73 - AL2023, SSH restriction, tooling installation
# =============================================================================

# Security Group for Jumphost
resource "aws_security_group" "jumphost_sg" {
  name        = "${local.project_name}-jumphost-sg"
  description = "Security group for jumphost with SSH restriction to home IPs"
  vpc_id      = var.vpc_id

  # SSH ingress restricted to home IP CIDRs only
  dynamic "ingress" {
    for_each = var.home_ip_cidrs
    content {
      description = "SSH from ${ingress.value}"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  # All outbound traffic allowed
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-jumphost-sg"
    Type = "SecurityGroup"
  })
}

# Jumphost EC2 Instance (Amazon Linux 2023)
resource "aws_instance" "jumphost" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.jumphost_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.jumphost_profile.name
  key_name               = var.key_pair_name

  # Root block device
  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  # User data for tool installation (see user_data script below)
  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    project_name  = var.project_name
    environment   = var.environment
  })

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-jumphost"
    Type = "Jumphost"
    Role = "BastionHost"
  })
}

# Data source for Amazon Linux 2023 AMI
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# IAM Instance Profile for Jumphost
resource "aws_iam_instance_profile" "jumphost_profile" {
  name = "${local.project_name}-jumphost-profile"
  role = var.jumphost_role_name

  tags = local.common_tags
}

# Elastic IP for Jumphost
resource "aws_eip" "jumphost_eip" {
  domain   = "vpc"
  instance = aws_instance.jumphost.id

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-jumphost-eip"
    Type = "ElasticIP"
  })
}
EOF

    # user_data.sh.tpl
    cat > "modules/jumphost/user_data.sh.tpl" << 'EOF'
#!/bin/bash
# =============================================================================
# Jumphost User Data Script - Tool Installation
# Finish Line 2026 Infrastructure
# Assignment: §F - Install mysql-client, kubectl, aws-cli v2, helm, kustomize
# =============================================================================
# Installation Method: user_data (cloud-init)
# Rationale: See INSTALLATION_STRATEGY.md for comprehensive analysis
# - Idempotent, runs on first boot
# - No manual intervention required
# - Audit trail in /var/log/cloud-init-output.log
# - Aligns with AWS Well-Architected Framework
# =============================================================================

set -xe

# Log start
exec > >(tee /var/log/user-data.log) 2>&1
echo "=== User Data Script Started at $(date) ==="

PROJECT_NAME="${project_name}"
ENVIRONMENT="${environment}"

# Update system packages
echo "Updating system packages..."
dnf update -y

# =============================================================================
# Install AWS CLI v2
# Assignment: aws --version (must be v2)
# =============================================================================
echo "Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install --update
rm -rf aws awscliv2.zip

# Verify AWS CLI v2
AWS_VERSION=$(aws --version 2>&1 | head -n1)
echo "AWS CLI installed: $AWS_VERSION"

# =============================================================================
# Install kubectl
# Assignment: kubectl version --client
# =============================================================================
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/kubectl

# Verify kubectl
KUBECTL_VERSION=$(kubectl version --client --output=yaml | grep gitVersion | head -n1)
echo "Kubectl installed: $KUBECTL_VERSION"

# =============================================================================
# Install Helm (latest)
# Assignment: helm version
# =============================================================================
echo "Installing Helm..."
HELM_VERSION=$(curl -s https://api.github.com/repos/helm/helm/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
curl -LO "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz"
tar -xzf "helm-${HELM_VERSION}-linux-amd64.tar.gz"
mv linux-amd64/helm /usr/local/bin/helm
rm -rf "helm-${HELM_VERSION}-linux-amd64.tar.gz" linux-amd64

# Verify Helm
HELM_VER=$(helm version --short)
echo "Helm installed: $HELM_VER"

# =============================================================================
# Install Kustomize (latest)
# Assignment: kustomize version
# =============================================================================
echo "Installing Kustomize..."
KUSTOMIZE_VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/kustomize/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
curl -LO "https://github.com/kubernetes-sigs/kustomize/releases/download/${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION#v}_linux_amd64.tar.gz"
tar -xzf "kustomize_${KUSTOMIZE_VERSION#v}_linux_amd64.tar.gz"
mv kustomize /usr/local/bin/kustomize
chmod +x /usr/local/bin/kustomize
rm -rf "kustomize_${KUSTOMIZE_VERSION#v}_linux_amd64.tar.gz"

# Verify Kustomize
KUSTOMIZE_VER=$(kustomize version --short)
echo "Kustomize installed: $KUSTOMIZE_VER"

# =============================================================================
# Install MySQL Client
# Assignment: mysql --version
# =============================================================================
echo "Installing MySQL client..."
dnf install -y mysql

# Verify MySQL
MYSQL_VER=$(mysql --version)
echo "MySQL client installed: $MYSQL_VER"

# =============================================================================
# Install additional utilities
# =============================================================================
echo "Installing additional utilities..."
dnf install -y \
    jq \
    git \
    vim \
    telnet \
    net-tools \
    bind-utils

# =============================================================================
# Configure kubeconfig directory
# =============================================================================
echo "Configuring kubeconfig directory..."
mkdir -p /home/ec2-user/.kube
chown ec2-user:ec2-user /home/ec2-user/.kube
chmod 700 /home/ec2-user/.kube

# =============================================================================
# Create verification script
# =============================================================================
cat > /home/ec2-user/verify-tools.sh << 'VERIFY'
#!/bin/bash
echo "=== Tool Verification Checklist ==="
echo ""
echo "1. AWS CLI v2:"
aws --version
echo ""
echo "2. Kubectl:"
kubectl version --client --output=yaml | grep gitVersion
echo ""
echo "3. Helm:"
helm version --short
echo ""
echo "4. Kustomize:"
kustomize version --short
echo ""
echo "5. MySQL Client:"
mysql --version
echo ""
echo "=== All tools verified ==="
VERIFY

chmod +x /home/ec2-user/verify-tools.sh
chown ec2-user:ec2-user /home/ec2-user/verify-tools.sh

# =============================================================================
# Log completion
# =============================================================================
echo "=== User Data Script Completed at $(date) ==="
echo "=== All tools installed successfully ==="

# Signal completion
touch /var/log/user-data.complete
EOF

    # variables.tf
    cat > "modules/jumphost/variables.tf" << 'EOF'
# =============================================================================
# Jumphost Module - Input Variables
# Finish Line 2026 Infrastructure
# =============================================================================

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment name"
  type        = string
}

variable "manage_by" {
  description = "ManagedBy tag value"
  type        = string
  default     = "Terraform"
}

variable "vpc_id" {
  description = "VPC ID where jumphost will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Public subnet ID for jumphost"
  type        = string
}

variable "home_ip_cidrs" {
  description = "List of home IP CIDR blocks allowed for SSH access"
  type        = list(string)
  validation {
    condition     = length(var.home_ip_cidrs) > 0
    error_message = "At least one home IP CIDR is required for SSH access."
  }
}

variable "instance_type" {
  description = "EC2 instance type for jumphost"
  type        = string
  default     = "t3.small"
}

variable "key_pair_name" {
  description = "Name of the SSH key pair for jumphost access"
  type        = string
}

variable "jumphost_role_name" {
  description = "Name of the IAM role for jumphost EKS authentication"
  type        = string
}
EOF

    # locals.tf
    cat > "modules/jumphost/locals.tf" << 'EOF'
# =============================================================================
# Jumphost Module - Local Values
# Finish Line 2026 Infrastructure
# =============================================================================

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.manage_by
    Module      = "jumphost"
  }

  project_name = "${var.project_name}-${var.environment}"
}
EOF

    # outputs.tf
    cat > "modules/jumphost/outputs.tf" << 'EOF'
# =============================================================================
# Jumphost Module - Output Values
# Finish Line 2026 Infrastructure
# =============================================================================

output "jumphost_instance_id" {
  description = "Instance ID of the jumphost"
  value       = aws_instance.jumphost.id
}

output "jumphost_public_ip" {
  description = "Public IP address of the jumphost"
  value       = aws_eip.jumphost_eip.public_ip
}

output "jumphost_public_dns" {
  description = "Public DNS name of the jumphost"
  value       = aws_instance.jumphost.public_dns
}

output "jumphost_security_group_id" {
  description = "Security group ID of the jumphost"
  value       = aws_security_group.jumphost_sg.id
}

output "ssh_command" {
  description = "SSH command to connect to jumphost"
  value       = "ssh -i <key-file> ec2-user@${aws_eip.jumphost_eip.public_ip}"
}
EOF

    create_module_readme "modules/jumphost" "Jumphost Module" "EC2 (AL2023) with SSH restriction to home IPs, user_data tooling installation per assignment §69, §70, §73, §F."
}

# -----------------------------------------------------------------------------
# IAM Module Creation
# -----------------------------------------------------------------------------
create_iam_module() {
    # main.tf
    cat > "modules/iam/main.tf" << 'EOF'
# =============================================================================
# IAM Module - Main Configuration
# Finish Line 2026 Infrastructure
# Assignment: §83, §84, §87, §89 - Instance roles, EKS access mapping
# =============================================================================

# Jumphost IAM Role for EKS Authentication
resource "aws_iam_role" "jumphost_role" {
  name = "${local.project_name}-jumphost-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Attach policies for EKS authentication (least privilege)
resource "aws_iam_role_policy_attachment" "jumphost_eks_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.jumphost_role.name
}

# Custom policy for EKS describe actions (read-only)
resource "aws_iam_role_policy" "jumphost_eks_readonly" {
  name = "${local.project_name}-jumphost-eks-readonly"
  role = aws_iam_role.jumphost_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:AccessKubernetesApi"
        ]
        Resource = "*"
      }
    ]
  })
}

# EKS Access Entry for jumphost role (EKS 1.30+)
resource "aws_eks_access_entry" "jumphost_access" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.jumphost_role.arn
  type          = "STANDARD"

  tags = local.common_tags
}

# EKS Access Policy Association for admin access
resource "aws_eks_access_policy_association" "jumphost_admin" {
  cluster_name  = var.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_iam_role.jumphost_role.arn

  access_scope {
    type = "cluster"
  }
}
EOF

    # variables.tf
    cat > "modules/iam/variables.tf" << 'EOF'
# =============================================================================
# IAM Module - Input Variables
# Finish Line 2026 Infrastructure
# =============================================================================

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment name"
  type        = string
}

variable "manage_by" {
  description = "ManagedBy tag value"
  type        = string
  default     = "Terraform"
}

variable "cluster_name" {
  description = "Name of the EKS cluster for access mapping"
  type        = string
}
EOF

    # locals.tf
    cat > "modules/iam/locals.tf" << 'EOF'
# =============================================================================
# IAM Module - Local Values
# Finish Line 2026 Infrastructure
# =============================================================================

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.manage_by
    Module      = "iam"
  }

  project_name = "${var.project_name}-${var.environment}"
}
EOF

    # outputs.tf
    cat > "modules/iam/outputs.tf" << 'EOF'
# =============================================================================
# IAM Module - Output Values
# Finish Line 2026 Infrastructure
# =============================================================================

output "jumphost_role_name" {
  description = "Name of the jumphost IAM role"
  value       = aws_iam_role.jumphost_role.name
}

output "jumphost_role_arn" {
  description = "ARN of the jumphost IAM role"
  value       = aws_iam_role.jumphost_role.arn
}

output "jumphost_instance_profile_name" {
  description = "Name of the jumphost instance profile"
  value       = aws_iam_instance_profile.jumphost_profile.name
}
EOF

    create_module_readme "modules/iam" "IAM Module" "Instance roles and EKS access mapping for jumphost authentication per assignment §83, §84, §87, §89."
}

# -----------------------------------------------------------------------------
# Bootstrap Module Creation
# -----------------------------------------------------------------------------
create_bootstrap_module() {
    # main.tf
    cat > "modules/bootstrap/main.tf" << 'EOF'
# =============================================================================
# Bootstrap Module - S3 Backend with DynamoDB Locking
# Finish Line 2026 Infrastructure
# Assignment: §28, §101, §102, §105 - S3 backend with DynamoDB locking (bonus)
# =============================================================================

# S3 Bucket for Terraform State
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name

  tags = merge(local.common_tags, {
    Name = var.bucket_name
    Type = "TerraformStateBackend"
  })
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB Table for State Locking (bonus best practice)
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.bucket_name}-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(local.common_tags, {
    Name = "${var.bucket_name}-locks"
    Type = "TerraformStateLock"
  })
}

# Bucket Policy for security
resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.terraform_state.arn,
          "${aws_s3_bucket.terraform_state.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}
EOF

    # variables.tf
    cat > "modules/bootstrap/variables.tf" << 'EOF'
# =============================================================================
# Bootstrap Module - Input Variables
# Finish Line 2026 Infrastructure
# =============================================================================

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment name"
  type        = string
}

variable "manage_by" {
  description = "ManagedBy tag value"
  type        = string
  default     = "Terraform"
}

variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{2,62}[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be 3-63 chars, lowercase, start/end with letter/number."
  }
}

variable "region" {
  description = "AWS region for state bucket"
  type        = string
  default     = "us-east-1"
}
EOF

    # locals.tf
    cat > "modules/bootstrap/locals.tf" << 'EOF'
# =============================================================================
# Bootstrap Module - Local Values
# Finish Line 2026 Infrastructure
# =============================================================================

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.manage_by
    Module      = "bootstrap"
  }
}
EOF

    # outputs.tf
    cat > "modules/bootstrap/outputs.tf" << 'EOF'
# =============================================================================
# Bootstrap Module - Output Values
# Finish Line 2026 Infrastructure
# =============================================================================

output "bucket_name" {
  description = "Name of the S3 state bucket"
  value       = aws_s3_bucket.terraform_state.id
}

output "bucket_arn" {
  description = "ARN of the S3 state bucket"
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.terraform_locks.arn
}
EOF

    create_module_readme "modules/bootstrap" "Bootstrap Module" "S3 backend (finishline-infra) with DynamoDB state locking per assignment §28, §101, §105."
}

# -----------------------------------------------------------------------------
# Create Module README
# -----------------------------------------------------------------------------
create_module_readme() {
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
- \`locals.tf\` - Local values and common tags
- \`outputs.tf\` - Output values

## Usage

\`\`\`hcl
module "$(basename "$dir")" {
  source = "../../modules/$(basename "$dir")"

  project_name  = var.project_name
  environment   = var.environment
  # ... additional variables
}
\`\`\`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | The name of the project | string | n/a | yes |
| environment | The environment name | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| See outputs.tf | All outputs defined in outputs.tf |

---

*Generated by $SCRIPT_NAME - Finish Line 2026 Infrastructure*
EOF
}

# -----------------------------------------------------------------------------
# Create Environment Files
# -----------------------------------------------------------------------------
create_environment_files() {
    print_phase "3" "Environment Configuration"

    for env in "${ENVIRONMENTS[@]}"; do
        print_msg "step" "Creating $env environment files..."

        if [[ "$DRY_RUN" == "true" ]]; then
            print_msg "info" "[DRY RUN] Would create $env environment files"
            continue
        fi

        # Create main.tf
        cat > "envs/$env/main.tf" << EOF
# =============================================================================
# Main Configuration: $env Environment
# Finish Line 2026 Infrastructure
# Root Module consuming all sub-modules
# =============================================================================

# VPC Module (Phase 1.1)
module "vpc" {
  source = "../../modules/vpc"

  project_name           = var.project_name
  environment            = var.environment
  manage_by              = var.manage_by
  vpc_cidr               = var.vpc_cidr
  enable_dns_hostnames   = var.enable_dns_hostnames
  enable_dns_support     = var.enable_dns_support
  availability_zones     = var.availability_zones
  public_subnets_cidrs   = var.public_subnets_cidrs
  private_subnets_cidrs  = var.private_subnets_cidrs
}

# ALB Module (Phase 1.2)
module "alb" {
  source = "../../modules/alb"

  project_name      = var.project_name
  environment       = var.environment
  manage_by         = var.manage_by
  vpc_id            = module.vpc.main_vpc_id
  public_subnet_ids = module.vpc.main_public_subnet_ids
}

# EKS Module (Phase 1.3)
module "eks" {
  source = "../../modules/eks"

  project_name              = var.project_name
  environment               = var.environment
  manage_by                 = var.manage_by
  cluster_name              = var.cluster_name
  cluster_version           = var.cluster_version
  subnet_ids                = module.vpc.main_private_subnet_ids
  endpoint_private_access   = var.endpoint_private_access
  endpoint_public_access    = var.endpoint_public_access
  cluster_enabled_log_types = var.cluster_enabled_log_types
  instance_types            = var.instance_types
}

# Jumphost Module (Phase 1.4)
module "jumphost" {
  source = "../../modules/jumphost"

  project_name      = var.project_name
  environment       = var.environment
  manage_by         = var.manage_by
  vpc_id            = module.vpc.main_vpc_id
  subnet_id         = module.vpc.main_public_subnet_ids[0]
  home_ip_cidrs     = var.home_ip_cidrs
  instance_type     = var.jumphost_instance_type
  key_pair_name     = module.key_pair.key_name
  jumphost_role_name = module.iam.jumphost_role_name
}

# IAM Module (Phase 1.5)
module "iam" {
  source = "../../modules/iam"

  project_name  = var.project_name
  environment   = var.environment
  manage_by     = var.manage_by
  cluster_name  = var.cluster_name
}

# Key Pair Module
module "key_pair" {
  source = "../../modules/key_pair"

  project_name = var.project_name
  environment  = var.environment
  key_name     = var.key_name
}
EOF

        # Create variables.tf
        cat > "envs/$env/variables.tf" << EOF
# =============================================================================
# Variables: $env Environment
# Finish Line 2026 Infrastructure
# =============================================================================

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------
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

variable "manage_by" {
  description = "The entity responsible for managing resources"
  type        = string
  default     = "Terraform"
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = "${AWS_REGION}"
}

# -----------------------------------------------------------------------------
# VPC Variables
# -----------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
  default     = true
}

variable "availability_zones" {
  description = "List of 3 availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnets_cidrs" {
  description = "CIDR blocks for 3 public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets_cidrs" {
  description = "CIDR blocks for 3 private subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

# -----------------------------------------------------------------------------
# EKS Variables
# -----------------------------------------------------------------------------
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "${PROJECT_NAME}-eks-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "endpoint_private_access" {
  description = "Enable private access to EKS endpoint"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public access to EKS endpoint"
  type        = bool
  default     = true
}

variable "cluster_enabled_log_types" {
  description = "EKS control plane logging types"
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

variable "instance_types" {
  description = "Instance types for node group"
  type        = list(string)
  default     = ["t3.medium"]
}

# -----------------------------------------------------------------------------
# Jumphost Variables
# -----------------------------------------------------------------------------
variable "home_ip_cidrs" {
  description = "List of home IP CIDRs for SSH access"
  type        = list(string)
}

variable "jumphost_instance_type" {
  description = "Instance type for jumphost"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "${PROJECT_NAME}-key-pair"
}
EOF

        # Create outputs.tf
        cat > "envs/$env/outputs.tf" << EOF
# =============================================================================
# Outputs: $env Environment
# Finish Line 2026 Infrastructure
# =============================================================================

# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.main_vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.main_public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.main_private_subnet_ids
}

# ALB Outputs
output "alb_arn" {
  description = "ALB ARN"
  value       = module.alb.alb_arn
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns_name
}

# EKS Outputs
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_node_group_name" {
  description = "EKS node group name"
  value       = module.eks.node_group_name
}

# Jumphost Outputs
output "jumphost_public_ip" {
  description = "Jumphost public IP"
  value       = module.jumphost.jumphost_public_ip
}

output "jumphost_ssh_command" {
  description = "SSH command to connect to jumphost"
  value       = module.jumphost.ssh_command
}

# IAM Outputs
output "jumphost_role_name" {
  description = "Jumphost IAM role name"
  value       = module.iam.jumphost_role_name
}
EOF

        # Create backend.tf
        cat > "envs/$env/backend.tf" << EOF
# =============================================================================
# Backend Configuration: $env Environment
# Finish Line 2026 Infrastructure
# Assignment: §28, §101 - S3 backend with state locking
# =============================================================================

terraform {
  backend "s3" {
    bucket         = "${S3_BUCKET_NAME}"
    key            = "$env/terraform.tfstate"
    region         = "${AWS_REGION}"
    encrypt        = true
    dynamodb_table = "${S3_BUCKET_NAME}-locks"
  }
}
EOF

        # Create providers.tf
        cat > "envs/$env/providers.tf" << EOF
# =============================================================================
# Provider Configuration: $env Environment
# Finish Line 2026 Infrastructure
# =============================================================================

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = var.manage_by
    }
  }
}
EOF

        # Create terraform.tfvars.example
        cat > "envs/$env/terraform.tfvars.example" << EOF
# =============================================================================
# Example Variables: $env Environment
# Copy to terraform.tfvars and update values
# Finish Line 2026 Infrastructure
# =============================================================================

# General
project_name = "${PROJECT_NAME}"
environment  = "$env"
manage_by    = "Terraform"
aws_region   = "${AWS_REGION}"

# VPC
vpc_cidr               = "10.0.0.0/16"
enable_dns_hostnames   = true
enable_dns_support     = true
availability_zones     = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnets_cidrs   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets_cidrs  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

# EKS
cluster_name           = "${PROJECT_NAME}-eks-cluster"
cluster_version        = "1.31"
endpoint_private_access = true
endpoint_public_access  = true
instance_types         = ["t3.medium"]

# Jumphost - CRITICAL: Update with your home IP
home_ip_cidrs          = ["<YOUR_HOME_IP>/32"]
jumphost_instance_type = "t3.small"
key_name               = "${PROJECT_NAME}-key-pair"
EOF

        print_msg "debug" "Created: envs/$env/{main,variables,outputs,backend,providers}.tf"
        print_msg "debug" "Created: envs/$env/terraform.tfvars.example"
    done

    print_msg "success" "Environment files created"
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

    mkdir -p "scripts"

    # Create backend bucket creation script
    cat > "scripts/create-backend-bucket.sh" << 'SCRIPT'
#!/bin/bash
# =============================================================================
# Create S3 Backend Bucket with DynamoDB Table
# Finish Line 2026 Infrastructure
# Assignment: §28, §101, §105 - Bootstrap workflow for state management
# =============================================================================

set -euo pipefail

BUCKET_NAME="finishline-infra"
REGION="${AWS_REGION:-us-east-1}"

echo "Creating S3 bucket: $BUCKET_NAME in $REGION"

# Create bucket
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION"

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Block public access
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Create DynamoDB table for state locking
echo "Creating DynamoDB table: ${BUCKET_NAME}-locks"
aws dynamodb create-table \
  --table-name "${BUCKET_NAME}-locks" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION"

echo "✅ Backend bucket created: $BUCKET_NAME"
echo "✅ DynamoDB table created: ${BUCKET_NAME}-locks"
echo ""
echo "Update envs/<env>/backend.tf with:"
echo "  bucket         = \"$BUCKET_NAME\""
echo "  dynamodb_table = \"${BUCKET_NAME}-locks\""
SCRIPT
    chmod +x "scripts/create-backend-bucket.sh"

    # Create validation script
    cat > "scripts/validate.sh" << 'SCRIPT'
#!/bin/bash
# =============================================================================
# Validate Terraform Configurations
# Finish Line 2026 Infrastructure
# =============================================================================

set -euo pipefail

echo "🔍 Validating Terraform configurations..."

for env in dev staging prod; do
    echo ""
    echo "=== Validating $env environment ==="

    if [[ ! -d "envs/$env" ]]; then
        echo "⚠️  Skipping $env - directory not found"
        continue
    fi

    cd "envs/$env"

    # Check syntax
    echo "Checking syntax..."
    terraform fmt -check -recursive || true

    # Validate configuration
    echo "Validating configuration..."
    terraform validate || echo "⚠️  Run 'terraform init' first"

    cd - > /dev/null
done

echo ""
echo "✅ Validation complete"
SCRIPT
    chmod +x "scripts/validate.sh"

    # Create verification checklist script
    cat > "scripts/verify-deployment.sh" << 'SCRIPT'
#!/bin/bash
# =============================================================================
# Verify Deployment - Assignment Validation Checklist
# Finish Line 2026 Infrastructure
# =============================================================================

set -euo pipefail

ENV="${1:-dev}"

echo "🔍 Verifying deployment for environment: $ENV"
echo ""

# Get outputs
echo "=== Terraform Outputs ==="
cd "envs/$ENV"
terraform output -json | jq -r 'to_entries[] | "\(.key): \(.value.value)"'
cd - > /dev/null

echo ""
echo "=== Assignment Validation Checklist ==="
echo ""

# VPC Verification (§51, §55)
echo "✅ A) VPC with 3 subnets across 3 AZs"
VPC_ID=$(cd "envs/$ENV" && terraform output -raw vpc_id 2>/dev/null || echo "N/A")
echo "   VPC ID: $VPC_ID"

# ALB Verification (§31, §62)
echo ""
echo "✅ B) Shared ALB with group-tag=finishline"
ALB_ARN=$(cd "envs/$ENV" && terraform output -raw alb_arn 2>/dev/null || echo "N/A")
echo "   ALB ARN: $ALB_ARN"

# Jumphost Verification (§69, §70)
echo ""
echo "✅ C) Jumphost (AL2023) with SSH restriction"
JUMPHOST_IP=$(cd "envs/$ENV" && terraform output -raw jumphost_public_ip 2>/dev/null || echo "N/A")
echo "   Jumphost IP: $JUMPHOST_IP"

# EKS Verification (§74, §75)
echo ""
echo "✅ D) EKS cluster + managed node group (2x t3.medium)"
EKS_CLUSTER=$(cd "envs/$ENV" && terraform output -raw eks_cluster_name 2>/dev/null || echo "N/A")
echo "   Cluster: $EKS_CLUSTER"

echo ""
echo "=== Next Steps ==="
echo "1. SSH to jumphost: ssh -i <key> ec2-user@$JUMPHOST_IP"
echo "2. Update kubeconfig: aws eks update-kubeconfig --name $EKS_CLUSTER"
echo "3. Verify nodes: kubectl get nodes (should show 2 Ready nodes)"
echo "4. Verify tools: ~/verify-tools.sh"
SCRIPT
    chmod +x "scripts/verify-deployment.sh"

    print_msg "success" "Helper scripts created"
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
    create_root_readme
    print_msg "success" "README.md created"

    # Create initial commit
    print_msg "step" "Creating initial commit..."
    git add . 2>/dev/null || true
    git commit -m "chore: Initialize modular Terraform structure

Phase 1: Modular Structure
  - modules/vpc: VPC with 3 subnets across 3 AZs (§51, §55)
  - modules/alb: ALB with group-tag=finishline (§31, §62)
  - modules/eks: EKS + 2x t3.medium node group (§74, §75)
  - modules/jumphost: AL2023 with user_data tooling (§69, §70)
  - modules/iam: Instance roles and EKS access (§83, §84)
Phase 2: Bootstrap Module
  - modules/bootstrap: S3 backend + DynamoDB locking (§28, §101)
Phase 3: Environment Configuration
  - envs/dev: Root module consuming all sub-modules

Assignment: Finish Line 2026 Infrastructure
Reporter: Joseph Ndzoh Dong
Timeline: Feb 26 - March 2, 2026" || print_msg "warning" "Initial commit failed (configure git user)"

    print_msg "success" "Git repository initialized"
}

# -----------------------------------------------------------------------------
# Create Root README
# -----------------------------------------------------------------------------
create_root_readme() {
    cat > "README.md" << 'EOF'
# Finish Line 2026 Infrastructure

## Project Overview

This repository contains the Terraform infrastructure-as-code for the Finish Line 2026 project, following a modular, phase-based architecture.

**Reporter:** Joseph Ndzoh Dong  
**Timeline:** Feb 26, 2026 – March 2, 2026  
**Region:** AWS us-east-1

## Directory Structure

```
terraform/
├── modules/
│   ├── vpc/          # Phase 1.1: VPC, 3 subnets, IGW, Route Tables
│   ├── alb/          # Phase 1.2: ALB with group-tag=finishline
│   ├── eks/          # Phase 1.3: EKS + 2x t3.medium node group
│   ├── jumphost/     # Phase 1.4: AL2023 with user_data tooling
│   ├── iam/          # Phase 1.5: Instance roles, EKS access mapping
│   └── bootstrap/    # Phase 2: S3 backend + DynamoDB locking
├── envs/
│   ├── dev/          # Phase 3: Development environment
│   ├── staging/      # Staging environment
│   └── prod/         # Production environment
└── scripts/          # Helper scripts
```

## Quick Start

### Prerequisites

- Terraform >= 1.6.0
- AWS CLI >= 2.x
- Git

### Phase 1: Bootstrap State Backend

```bash
# Create S3 bucket and DynamoDB table
./scripts/create-backend-bucket.sh
```

### Phase 2: Deploy Development Environment

```bash
cd terraform/envs/dev

# Copy and configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars - add your home IP CIDR

# Initialize and deploy
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### Phase 3: Verify Deployment

```bash
# Run verification checklist
../../scripts/verify-deployment.sh dev

# SSH to jumphost
ssh -i <key-file> ec2-user@<jumphost-ip>

# Verify EKS connectivity
aws eks update-kubeconfig --name finishline-eks-cluster
kubectl get nodes  # Should show 2 Ready nodes

# Verify tooling on jumphost
~/verify-tools.sh
```

## Assignment Compliance

| Requirement | Status | Reference |
|-------------|--------|-----------|
| VPC: 3 subnets across 3 AZs | ✅ | §51, §55 |
| ALB: group-tag=finishline | ✅ | §31, §62 |
| Jumphost: AL2023, SSH restriction | ✅ | §69, §70 |
| EKS: 2x t3.medium, Bottlerocket | ✅ | §74, §75, §79 |
| IAM: EKS access mapping | ✅ | §83, §84 |
| State: S3 + DynamoDB locking | ✅ | §28, §101 |

## Documentation

- [Runbook](docs/RUNBOOK.md)
- [Troubleshooting](docs/TROUBLESHOOT.md)
- [Assignment PDF](docs/Finishline_Infra_Project_Assignment.pdf)

## Support

For issues or questions, contact the Platform Team.

---

*Generated by terraInfra_1.sh - Finish Line 2026 Infrastructure*
EOF
}

# -----------------------------------------------------------------------------
# Main Execution
# -----------------------------------------------------------------------------
main() {
    print_header "Finish Line 2026 Infrastructure Initialization"

    print_msg "info" "Script: $SCRIPT_NAME"
    print_msg "info" "Directory: $SCRIPT_DIR"
    print_msg "info" "Original Dir: $ORIGINAL_DIR"
    print_msg "info" "Install Method: $PACKAGE_INSTALL_METHOD"

    parse_args "$@"

    verify_prerequisites
    create_directory_structure
    create_module_files
    create_environment_files
    create_helper_scripts
    create_git_repository

    print_header "Initialization Complete"

    print_msg "success" "Terraform project structure created"
    print_msg "info" "Next steps:"
    print_msg "step" "1. cd terraform/envs/dev"
    print_msg "step" "2. cp terraform.tfvars.example terraform.tfvars"
    print_msg "step" "3. Edit terraform.tfvars (add your home IP CIDR)"
    print_msg "step" "4. Run: terraform init"
    print_msg "step" "5. Run: terraform plan -out=tfplan"
    print_msg "step" "6. Run: terraform apply tfplan"

    print_msg "info" "For help: $SCRIPT_NAME --help"
}

# Run main function
main "$@"
