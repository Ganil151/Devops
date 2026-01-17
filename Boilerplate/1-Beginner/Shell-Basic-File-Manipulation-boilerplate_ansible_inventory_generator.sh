#!/bin/bash

# ==============================================================================
# Script: ansible_inventory_generator.sh
# Description: Generates dynamic Ansible inventory from AWS EC2 tags
# DevOps Context: Dynamic inventory management for cloud infrastructure
# Requires: AWS CLI, jq
# ==============================================================================

set -euo pipefail

readonly INVENTORY_FILE="inventory.ini"
readonly ENVIRONMENT="${1:-production}"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1: $2"
}

# Check dependencies
check_dependencies() {
    local missing=0
    
    for cmd in aws jq; do
        if ! command -v $cmd &> /dev/null; then
            log "ERROR" "$cmd is not installed"
            missing=1
        fi
    done
    
    [ $missing -eq 0 ] || exit 1
}

# Fetch EC2 instances
fetch_instances() {
    log "INFO" "Fetching EC2 instances for environment: $ENVIRONMENT"
    
    aws ec2 describe-instances \
        --filters "Name=tag:Environment,Values=$ENVIRONMENT" \
                  "Name=instance-state-name,Values=running" \
        --query 'Reservations[].Instances[].[Tags[?Key==`Name`].Value | [0], PrivateIpAddress, Tags[?Key==`Role`].Value | [0]]' \
        --output json | jq -r '.[] | @tsv'
}

# Generate inventory
generate_inventory() {
    log "INFO" "Generating Ansible inventory..."
    
    {
        echo "# Generated on: $(date)"
        echo "# Environment: $ENVIRONMENT"
        echo ""
        echo "[all:vars]"
        echo "ansible_user=ubuntu"
        echo "ansible_ssh_private_key_file=~/.ssh/id_rsa"
        echo ""
    } > "$INVENTORY_FILE"
    
    # Group by role
    local webservers=()
    local databases=()
    local others=()
    
    while IFS=$'\t' read -r name ip role; do
        case "$role" in
            web|webserver)
                webservers+=("$name ansible_host=$ip")
                ;;
            db|database)
                databases+=("$name ansible_host=$ip")
                ;;
            *)
                others+=("$name ansible_host=$ip")
                ;;
        esac
    done < <(fetch_instances)
    
    # Write groups
    if [ ${#webservers[@]} -gt 0 ]; then
        echo "[webservers]" >> "$INVENTORY_FILE"
        printf '%s\n' "${webservers[@]}" >> "$INVENTORY_FILE"
        echo "" >> "$INVENTORY_FILE"
    fi
    
    if [ ${#databases[@]} -gt 0 ]; then
        echo "[databases]" >> "$INVENTORY_FILE"
        printf '%s\n' "${databases[@]}" >> "$INVENTORY_FILE"
        echo "" >> "$INVENTORY_FILE"
    fi
    
    log "INFO" "✓ Inventory generated: $INVENTORY_FILE"
}

main() {
    log "INFO" "Starting Ansible inventory generation"
    check_dependencies
    generate_inventory
    log "INFO" "✓ Complete! Test with: ansible all -i $INVENTORY_FILE -m ping"
}

main "$@"
