#!/bin/bash

# ==============================================================================
# Script: boilerplate_ansible_key_setup.sh
# Description: Sets correct permissions for Ansible files and SSH keys
# DevOps Context: Playbook execution preparation
# ==============================================================================

set -euo pipefail

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1: $2"
}

# Fix SSH key permissions
fix_ssh_keys() {
    log "INFO" "Fixing SSH key permissions..."
    
    find . -type f \( -name "*.pem" -o -name "*_rsa" -o -name "id_rsa" \) -exec chmod 600 {} \; -print | while read file; do
        log "INFO" "  chmod 600 $file"
    done
}

# Fix script permissions
fix_scripts() {
    log "INFO" "Fixing script permissions..."
    
    find . -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod 755 {} \; -print | while read file; do
        log "INFO" "  chmod 755 $file"
    done
}

# Fix Ansible files
fix_ansible_files() {
    log "INFO" "Fixing Ansible file permissions..."
    
    [ -d "group_vars" ] && chmod -R 644 group_vars/*
    [ -d "host_vars" ] && chmod -R 644 host_vars/*
    [ -f "ansible.cfg" ] && chmod 644 ansible.cfg
    [ -f "inventory.ini" ] && chmod 644 inventory.ini
}

main() {
    log "INFO" "Starting Ansible permission setup"
    
    fix_ssh_keys
    fix_scripts
    fix_ansible_files
    
    log "INFO" "✓ Permission setup complete"
}

main "$@"
