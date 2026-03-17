#!/bin/bash
# =============================================================================
# Minimal Terragrunt Structure Initialization Script
# Project: Finish Line 2026 Infrastructure
# Reporter: Ganil Batist Yan
# Timeline: Feb 26, 2026 – March 2, 2026
# =============================================================================
# Purpose: Create directory structure and empty placeholder files only.
#          NO file content population - structure scaffolding exclusively.
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
readonly SCRIPT_NAME="$(basename "$0")"
readonly TERRAFORM_ROOT="terraform"
readonly ENVIRONMENTS=("dev" "stage" "prod")
readonly NETWORKING_MODULES=("vpc" "sg" "alb")
readonly COMPUTE_MODULES=("jumphost" "eks")
readonly TF_FILES=("main.tf" "variables.tf" "outputs.tf" "data.tf" "local.tf")
readonly TG_FILE="terragrunt.hcl"
readonly AWS_REGION="us-east-1"

# -----------------------------------------------------------------------------
# Colors
# -----------------------------------------------------------------------------
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# -----------------------------------------------------------------------------
# Global State
# -----------------------------------------------------------------------------
ORIGINAL_DIR="$(pwd)"
VERBOSE=false
DRY_RUN=false
SKIP_GIT=false

# -----------------------------------------------------------------------------
# Cleanup
# -----------------------------------------------------------------------------
cleanup() {
    local exit_code=$?
    cd "$ORIGINAL_DIR" 2>/dev/null || true
    trap - EXIT
    return $exit_code
}
trap cleanup EXIT INT TERM

# -----------------------------------------------------------------------------
# Logging
# -----------------------------------------------------------------------------
log() {
    local level="$1"
    local msg="$2"
    local ts="$(date '+%Y-%m-%d %H:%M:%S')"
    
    case "$level" in
        info)    echo -e "${YELLOW}[${ts}] ℹ️  $msg${NC}" ;;
        success) echo -e "${GREEN}[${ts}] ✅ $msg${NC}" ;;
        error)   echo -e "${RED}[${ts}] ❌ $msg${NC}" >&2 ;;
        step)    echo -e "${BLUE}[${ts}] 📍 $msg${NC}" ;;
        debug)   [[ "$VERBOSE" == "true" ]] && echo -e "${BLUE}[${ts}] 🔍 $msg${NC}" ;;
    esac
}

header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

# -----------------------------------------------------------------------------
# Argument Parsing
# -----------------------------------------------------------------------------
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -v|--verbose) VERBOSE=true; shift ;;
            -n|--dry-run) DRY_RUN=true; shift ;;
            --skip-git)   SKIP_GIT=true; shift ;;
            -h|--help)    show_help; exit 0 ;;
            *) log error "Unknown option: $1"; show_help; exit 1 ;;
        esac
    done
}

show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Create minimal Terragrunt project structure for Finish Line 2026.
Only directories and empty .tf/.hcl files are created.

Options:
  -v, --verbose     Enable verbose output
  -n, --dry-run     Preview actions without making changes
  --skip-git        Skip Git repository initialization
  -h, --help        Show this help message

Structure Created:
  terraform/
  ├── terragrunt.hcl
  ├── environment/{dev,stage,prod}/terragrunt.hcl
  ├── modules/
  │   ├── networking/{vpc,sg,alb}/{main,variables,outputs}.tf
  │   └── compute/{jumphost,eks}/{main,variables,outputs}.tf
  └── bootstrap/ (optional state backend)

Example:
  $SCRIPT_NAME --dry-run --verbose
EOF
}

# -----------------------------------------------------------------------------
# Prerequisites
# -----------------------------------------------------------------------------
verify_prerequisites() {
    log step "Verifying prerequisites..."
    
    # Bash version
    if [[ "$(bash --version | head -n1 | grep -oP '\d+\.\d+' | head -1)" < "4.0" ]]; then
        log error "Bash 4.0+ required"
        exit 1
    fi
    
    # Git check
    if [[ "$SKIP_GIT" != "true" ]] && ! command -v git &>/dev/null; then
        log info "Git not found; skipping Git initialization"
        SKIP_GIT=true
    fi
    
    log success "Prerequisites verified"
}

# -----------------------------------------------------------------------------
# Directory Creation
# -----------------------------------------------------------------------------
create_directories() {
    header "Creating Directory Structure"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log info "[DRY RUN] Would create directories under $TERRAFORM_ROOT/"
        return
    fi
    
    log step "Creating root: $TERRAFORM_ROOT/"
    mkdir -p "$TERRAFORM_ROOT"
    cd "$TERRAFORM_ROOT"
    
    # Environment directories
    log step "Creating environment directories..."
    for env in "${ENVIRONMENTS[@]}"; do
        mkdir -p "environment/$env"
        log debug "Created: environment/$env"
    done
    
    # Networking modules
    log step "Creating networking modules..."
    for mod in "${NETWORKING_MODULES[@]}"; do
        mkdir -p "modules/networking/$mod"
        log debug "Created: modules/networking/$mod"
    done
    
    # Compute modules
    log step "Creating compute modules..."
    for mod in "${COMPUTE_MODULES[@]}"; do
        mkdir -p "modules/compute/$mod"
        log debug "Created: modules/compute/$mod"
    done
    
    # Bootstrap directory (for state backend)
    mkdir -p "bootstrap"
    log debug "Created: bootstrap/"
    
    # Scripts and docs
    mkdir -p "scripts" "docs"
    log debug "Created: scripts/ docs/"
    
    log success "Directory structure created"
}

# -----------------------------------------------------------------------------
# File Creation (Empty Placeholders Only)
# -----------------------------------------------------------------------------
create_empty_files() {
    header "Creating Empty Placeholder Files"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log info "[DRY RUN] Would create empty .tf and .hcl files"
        return
    fi
    
    # Root terragrunt.hcl
    log step "Creating root terragrunt.hcl..."
    touch "$TG_FILE"
    
    # Environment terragrunt.hcl files
    log step "Creating environment terragrunt.hcl files..."
    for env in "${ENVIRONMENTS[@]}"; do
        touch "environment/$env/$TG_FILE"
        log debug "Created: environment/$env/$TG_FILE"
    done
    
    # Bootstrap terragrunt.hcl
    touch "bootstrap/$TG_FILE"
    log debug "Created: bootstrap/$TG_FILE"
    
    # Networking module .tf files
    log step "Creating networking module .tf files..."
    for mod in "${NETWORKING_MODULES[@]}"; do
        for tf_file in "${TF_FILES[@]}"; do
            touch "modules/networking/$mod/$tf_file"
            log debug "Created: modules/networking/$mod/$tf_file"
        done
    done
    
    # Compute module .tf files
    log step "Creating compute module .tf files..."
    for mod in "${COMPUTE_MODULES[@]}"; do
        for tf_file in "${TF_FILES[@]}"; do
            touch "modules/compute/$mod/$tf_file"
            log debug "Created: modules/compute/$mod/$tf_file"
        done
    done
    
    log success "Empty placeholder files created"
}

# -----------------------------------------------------------------------------
# Git Initialization
# -----------------------------------------------------------------------------
init_git() {
    if [[ "$SKIP_GIT" == "true" ]]; then
        log info "Skipping Git initialization (--skip-git)"
        return
    fi
    
    header "Initializing Git Repository"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log info "[DRY RUN] Would initialize Git"
        return
    fi
    
    cd "$ORIGINAL_DIR"
    
    if [[ ! -d ".git" ]]; then
        log step "Initializing Git repository..."
        git init
        log success "Git repository initialized"
    else
        log info "Git repository already exists"
    fi
    
    # Minimal .gitignore
    log step "Creating .gitignore..."
    cat > ".gitignore" << 'EOF'
# Terraform/Terragrunt
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl
.terragrunt-cache/
*.tfplan
*.out

# Sensitive
*.pem
*.key
**/jumphost.pem
**/terraform.tfvars
!terraform.tfvars.example

# Logs
*.log
crash.log
EOF
    log success ".gitignore created"
    
    # Initial commit (if files exist)
    if git ls-files --others --exclude-standard | grep -q .; then
        log step "Creating initial commit..."
        git add . 2>/dev/null || true
        git commit -m "chore: Initialize minimal Terragrunt structure

- Directory structure: modules/, environment/, bootstrap/
- Empty placeholders: *.tf, terragrunt.hcl
- .gitignore for Terraform/Terragrunt artifacts

Project: Finish Line 2026 Infrastructure
Reporter: Ganil Batist Yan" 2>/dev/null || log info "Commit skipped (configure git user)"
        log success "Initial commit created"
    fi
}

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
print_summary() {
    header "Structure Initialization Complete"
    
    cat << EOF
${GREEN}✅ Minimal Terragrunt Structure Created${NC}

${CYAN}Directory Tree:${NC}
  $TERRAFORM_ROOT/
  ├── $TG_FILE                          # Root Terragrunt config
  ├── environment/
  │   ├── dev/$TG_FILE
  │   ├── stage/$TG_FILE
  │   └── prod/$TG_FILE
  ├── modules/
  │   ├── networking/
  │   │   ├── vpc/    {main,variables,outputs}.tf
  │   │   ├── sg/     {main,variables,outputs}.tf
  │   │   └── alb/    {main,variables,outputs}.tf
  │   └── compute/
  │       ├── jumphost/ {main,variables,outputs}.tf
  │       └── eks/      {main,variables,outputs}.tf
  ├── bootstrap/
  │   └── $TG_FILE                      # State backend config
  ├── scripts/                          # Helper scripts (empty)
  └── docs/                             # Documentation (empty)

${CYAN}Next Steps (Manual):${NC}
1. Populate root $TG_FILE with remote_state and provider generation
2. Populate environment/$ENV/$TG_FILE with module dependencies
3. Implement module logic in modules/*/{main,variables,outputs}.tf
4. Run: cd $TERRAFORM_ROOT/bootstrap && terragrunt init && terragrunt apply
5. Deploy: cd environment/dev && terragrunt run-all apply

${CYAN}File Types Created:${NC}
  - *.tf       : Terraform configuration placeholders (empty)
  - *.hcl      : Terragrunt configuration placeholders (empty)
  - .gitignore : Excludes state, secrets, cache

${CYAN}Project Metadata:${NC}
  - Region: $AWS_REGION
  - Environments: ${ENVIRONMENTS[*]}
  - Networking Modules: ${NETWORKING_MODULES[*]}
  - Compute Modules: ${COMPUTE_MODULES[*]}

---
Reporter: Ganil Batist Yan
Timeline: Feb 26, 2026 – March 2, 2026
EOF
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    header "Finish Line 2026 - Minimal Structure Initialization"
    
    parse_args "$@"
    
    log info "Script: $SCRIPT_NAME"
    log info "Working directory: $ORIGINAL_DIR"
    log info "Options: verbose=$VERBOSE, dry-run=$DRY_RUN, skip-git=$SKIP_GIT"
    
    verify_prerequisites
    create_directories
    create_empty_files
    init_git
    print_summary
}

# Execute
main "$@"