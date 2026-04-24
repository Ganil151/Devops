#!/usr/bin/env bash

###############################################################################
# Terragrunt Project Scaffolding Script - Optimized for Finish Line 2026
# Focus: Clean files, removed shared module, enhanced bootstrap module.
###############################################################################

set -euo pipefail

# --- Configuration ---
ROOT_DIR="${1:-.}"
TERRAFORM_DIR="${ROOT_DIR}/terraform"
ORIG_DIR="$(pwd)"
COLOR_RESET="\033[0m"
COLOR_GREEN="\033[32m"
COLOR_BLUE="\033[34m"
COLOR_YELLOW="\033[33m"
COLOR_RED="\033[31m"

# --- Helper Functions ---
log_info() { echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $1"; }
log_success() { echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_RESET} $1"; }
log_warn() { echo -e "${COLOR_YELLOW}[WARN]${COLOR_RESET} $1"; }
log_error() { echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $1"; }

cleanup() { cd "${ORIG_DIR}"; }
trap cleanup EXIT

# --- Pre-flight Checks ---
if [[ -d "${TERRAFORM_DIR}" ]]; then
    log_error "Directory '${TERRAFORM_DIR}' already exists. Aborting."
    exit 1
fi

# --- Directory Creation ---
create_directories() {
    log_info "Creating directory structure..."
    
    # Live Environments
    mkdir -p "${TERRAFORM_DIR}/envs"/{dev,prod,staging}
    
    # Modules (Removed 'shared')
    mkdir -p "${TERRAFORM_DIR}/modules"/{alb,bootstrap,eks,iam,jumphost,key_pair,vpc}
    
    log_success "Directories created."
}

# --- File Creation ---
create_files() {
    log_info "Generating files..."

    # 1. Global .gitignore
    cat <<'EOF' > "${TERRAFORM_DIR}/.gitignore"
.terraform/
.terragrunt-cache/
*.tfstate
*.tfstate.*
crash.log
*.tfvars
*.tfvars.json
override.tf
EOF

    # 2. Root Terragrunt HCL (Empty Template)
    touch "${TERRAFORM_DIR}/terragrunt.hcl"

    # 3. Environment Files
    for env in dev prod staging; do
        touch "${TERRAFORM_DIR}/envs/${env}/terragrunt.hcl"
    done

    # 4. Standard Module Files
    # Note: 'shared' is intentionally omitted here
    for mod in alb bootstrap eks iam jumphost key_pair vpc; do
        local mod_path="${TERRAFORM_DIR}/modules/${mod}"
        touch "${mod_path}"/{main,variables,outputs}.tf
    done

    # 5. Bootstrap Module Enhancements
    # Using bootstrap/ for common logic as requested
    local boot_path="${TERRAFORM_DIR}/modules/bootstrap"
    log_info "Adding locals.tf, data.tf and versions.tf to bootstrap module..."
    
    touch "${boot_path}/locals.tf"
    touch "${boot_path}/data.tf"
    touch "${boot_path}/versions.tf"

    log_success "All files and folders generated."
}

# --- Git Initialization ---
init_git() {
    if command -v git &> /dev/null; then
        log_info "Initializing Git..."
        cd "${TERRAFORM_DIR}"
        git init -q
        git add .
        git commit -m "Initial commit: TERRAFORM structure scaffolding"
        log_success "Git initialized."
    fi
}

# --- Main Execution ---
main() {
    echo -e "${COLOR_GREEN}Executing TERRAFORM structure Scaffolding...${COLOR_RESET}\n"
    
    create_directories
    create_files
    init_git

    echo -e "\n${COLOR_GREEN}Setup Complete!${COLOR_RESET}"
    echo -e "Structure Summary:"
    echo -e " - modules/bootstrap/ contains: locals.tf, data.tf, main.tf, etc."
    
}

main "$@"