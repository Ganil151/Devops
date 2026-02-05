#!/bin/bash
# Description: Hardens a fresh Linux node (Ubuntu/CentOS)
# Features: Updates packages, configures UFW/IPTables, sets up Fail2Ban
# Usage: sudo ./harden-linux-node.sh

set -e
set -o pipefail

LOG_FILE="/var/log/server_hardening.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$1] $2" | tee -a "$LOG_FILE"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root" 
        exit 1
    fi
}

update_system() {
    log "INFO" "Updating package repositories..."
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get upgrade -y
        apt-get install -y ufw fail2ban
    elif command -v yum &> /dev/null; then
        yum update -y
        yum install -y epel-release
        yum install -y ufw fail2ban
    else
        log "ERROR" "Unsupported package manager"
        exit 1
    fi
}

configure_firewall() {
    log "INFO" "Configuring Firewall (UFW)..."
    ufw default deny incoming
    ufw default allow outgoing
    
    # Allow SSH
    ufw allow 22/tcp
    
    # Allow Web
    ufw allow 80/tcp
    ufw allow 443/tcp

    # Enable
    ufw --force enable
    log "INFO" "Firewall enabled."
}

configure_fail2ban() {
    log "INFO" "Configuring Fail2Ban..."
    if [ ! -f /etc/fail2ban/jail.local ]; then
        cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    fi
    
    systemctl enable fail2ban
    systemctl start fail2ban
    log "INFO" "Fail2Ban active."
}

audit_users() {
    log "INFO" "Checking for users with empty passwords..."
    EMPTY_PW=$(awk -F: '($2 == "") {print $1}' /etc/shadow)
    if [[ -n "$EMPTY_PW" ]]; then
        log "WARNING" "Users with empty passwords found: $EMPTY_PW"
    else
        log "INFO" "No users with empty passwords found."
    fi
}

main() {
    check_root
    log "INFO" "Starting Hardening Process..."
    
    # update_system # Commented for safety
    configure_firewall
    configure_fail2ban
    audit_users
    
    log "INFO" "Hardening Completed."
}

main
