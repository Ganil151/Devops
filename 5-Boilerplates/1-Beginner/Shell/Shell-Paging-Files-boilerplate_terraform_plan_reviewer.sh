#!/bin/bash

# ==============================================================================
# Script: boilerplate_terraform_plan_reviewer.sh
# Description: Pages through terraform plan with destructive change highlighting
# DevOps Context: Safe IaC review workflow
# Requires: terraform
# ==============================================================================

set -euo pipefail

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1: $2"
}

# Generate and review plan
review_plan() {
    log "INFO" "Generating Terraform plan..."
    
    terraform plan -out=tfplan.binary
    terraform show tfplan.binary | less -R
    
    log "INFO" "Review complete"
}

main() {
    if ! command -v terraform &> /dev/null; then
        log "ERROR" "Terraform not found"
        exit 1
    fi
    
    review_plan
}

main "$@"
