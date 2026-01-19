#!/bin/bash

# ==============================================================================
# Script: boilerplate_deployment_orchestrator.sh
# Description: Multi-tool deployment workflow
# DevOps Context: Full stack deployment automation
# Tools: Terraform → Ansible → Docker
# ==============================================================================

set -euo pipefail

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1: $2"
}

# Step 1: Terraform
run_terraform() {
    log "INFO" "Step 1/3: Terraform - Provisioning infrastructure"
    
    terraform init
    terraform plan -out=tfplan
    terraform apply tfplan
    
    log "INFO" "✓ Infrastructure provisioned"
}

# Step 2: Ansible
run_ansible() {
    log "INFO" "Step 2/3: Ansible - Configuring servers"
    
    ansible-playbook -i inventory.ini playbook.yml
    
    log "INFO" "✓ Configuration applied"
}

# Step 3: Docker
deploy_containers() {
    log "INFO" "Step 3/3: Docker - Deploying applications"
    
    docker-compose up -d
    
    log "INFO" "✓ Containers deployed"
}

# Main orchestration
main() {
    log "INFO" "Starting deployment orchestration"
    
    run_terraform
    run_ansible
    deploy_containers
    
    log "INFO" "✓ Deployment complete!"
}

main "$@"
