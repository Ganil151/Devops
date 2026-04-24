#!/bin/bash

#############################################################################
# Script: ssh-hardening.sh
# Description: Automates SSH security configuration (CIS Benchmark aligned)
# Author: Senior DevOps Engineer
# Version: 1.0 (Golden Standard)
#############################################################################

set -euo pipefail

# Configuration
SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP_DIR="/etc/ssh/backup_$(date +%Y%m%d_%H%M%S)"
LOG_FILE="/var/log/ssh-hardening.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Error: This script must be run as root${NC}"
        exit 1
    fi
}

backup_config() {
    echo -e "${CYAN}[1/5] Backing up configuration...${NC}"
    mkdir -p "$BACKUP_DIR"
    cp "$SSHD_CONFIG" "$BACKUP_DIR/sshd_config.orig"
    log "Backup created at $BACKUP_DIR"
}

configure_ssh() {
    echo -e "${CYAN}[2/5] Configuring SSH Security Parameters...${NC}"

    # Helper function to set or replace parameter
    set_param() {
        local param=$1
        local value=$2
        if grep -q "^#*\s*${param}\s+" "$SSHD_CONFIG"; then
            sed -i "s|^#*\s*${param}\s+.*|${param} ${value}|" "$SSHD_CONFIG"
        else
            echo "${param} ${value}" >> "$SSHD_CONFIG"
        fi
        log "Set ${param} to ${value}"
    }

    # 1. Disable Root Login
    set_param "PermitRootLogin" "no"

    # 2. Disable Password Authentication (Force Key-based)
    set_param "PasswordAuthentication" "no"
    set_param "PermitEmptyPasswords" "no"
    set_param "ChallengeResponseAuthentication" "no"

    # 3. Protocol Version
    set_param "Protocol" "2"

    # 4. Max Auth Tries
    set_param "MaxAuthTries" "3"

    # 5. Disable X11 Forwarding
    set_param "X11Forwarding" "no"

    # 6. Idle Timeout (5 minutes)
    set_param "ClientAliveInterval" "300"
    set_param "ClientAliveCountMax" "0"

    # 7. Banner
    set_param "Banner" "/etc/issue.net"

    # 8. Whitelist Users (Optional - User Prompt)
    read -p "Do you want to limit SSH access to specific users? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter usernames (space separated): " ALLOW_USERS
        set_param "AllowUsers" "$ALLOW_USERS"
    fi
}

configure_crypto() {
    echo -e "${CYAN}[3/5] Configuring Strong Cryptography...${NC}"
    
    # Modern Ciphers and MACs (Mozilla Guide / CIS)
    local ciphers="chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr"
    local kex="curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256"
    local macs="hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256"

    set_param "Ciphers" "$ciphers"
    set_param "KexAlgorithms" "$kex"
    set_param "MACs" "$macs"
}

validate_config() {
    echo -e "${CYAN}[4/5] Validating Configuration...${NC}"
    if sshd -t; then
        echo -e "${GREEN}Configuration syntax is valid.${NC}"
        log "Configuration validation passed"
    else
        echo -e "${RED}Configuration syntax Check FAILED! Restoring backup...${NC}"
        cp "$BACKUP_DIR/sshd_config.orig" "$SSHD_CONFIG"
        log "Configuration validation failed. Backup restored."
        exit 1
    fi
}

reload_service() {
    echo -e "${CYAN}[5/5] Reloading SSH Service...${NC}"
    if systemctl reload sshd; then
        echo -e "${GREEN}SSH Hardening Complete!${NC}"
        log "SSHD reloaded successfully"
    else
        echo -e "${RED}Failed to reload SSHD.${NC}"
        log "Failed to reload SSHD"
        exit 1
    fi
}

# Main Execution
check_root
backup_config
configure_ssh
configure_crypto
validate_config
reload_service

echo -e "\n${YELLOW}NOTE: Verify connectivity in a NEW terminal session before closing this one!${NC}"
