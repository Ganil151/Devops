#!/bin/bash

# ==============================================================================
# Script: boilerplate_devops_library.sh
# Description: Reusable DevOps function library
# DevOps Context: DRY automation - Source this file in other scripts
# Usage: source ./boilerplate_devops_library.sh
# ==============================================================================

# Terraform drift checker
check_terraform_drift() {
    local drift_found=0
    
    terraform plan -detailed-exitcode > /dev/null 2>&1
    case $? in
        0) echo "✓ No drift detected" ;;
        1) echo "❌ Terraform plan error" && return 1 ;;
        2) echo "⚠️  Drift detected!" && drift_found=1 ;;
    esac
    
    return $drift_found
}

# Ansible playbook deployer
deploy_ansible_playbook() {
    local playbook="$1"
    local inventory="${2:-inventory.ini}"
    
    ansible-playbook -i "$inventory" "$playbook" --check && \
    ansible-playbook -i "$inventory" "$playbook"
}

# Docker health checker
docker_health_check() {
    local container="$1"
    local max_retries=5
    local retry=0
    
    while [ $retry -lt $max_retries ]; do
        if docker exec "$container" echo "ok" &> /dev/null; then
            echo "✓ Container $container is healthy"
            return 0
        fi
        retry=$((retry + 1))
        sleep 2
    done
    
    echo "❌ Container $container is unhealthy"
    return 1
}

# Kubernetes deployment waiter
wait_for_k8s_deployment() {
    local deployment="$1"
    local namespace="${2:-default}"
    
   kubectl rollout status deployment/"$deployment" -n "$namespace" --timeout=5m
}

echo "✓ DevOps library loaded. Available functions:"
echo "  - check_terraform_drift"
echo "  - deploy_ansible_playbook <playbook> [inventory]"
echo "  - docker_health_check <container>"
echo "  - wait_for_k8s_deployment <deployment> [namespace]"
