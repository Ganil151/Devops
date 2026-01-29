#!/bin/bash

# ==============================================================================
# Script Name: Secure-FedoraNetwork.sh
# Description: Hardens Fedora 43 Networking (Kernel, Firewall, DNS, Privacy)
# Author: Senior Linux Systems & Security Architect
# Version: 1.0 (Fedora 43 / DNF5 Compatible)
# ==============================================================================

LOG_FILE="/var/log/network_hardening.log"
BACKUP_DIR="/var/backups/network_hardening_$(date +%F_%H-%M)"
CUSTOM_SSH_PORT=2222
SCAN_ONLY=false

# --- Initialization & Safety ---
[[ $EUID -ne 0 ]] && echo "This script must be run as root." && exit 1

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -Scan) SCAN_ONLY=true ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

prepare_backups() {
    if [ "$SCAN_ONLY" = false ]; then
        mkdir -p "$BACKUP_DIR"
        cp /etc/sysctl.conf "$BACKUP_DIR/" 2>/dev/null
        cp /etc/systemd/resolved.conf "$BACKUP_DIR/" 2>/dev/null
        log_action "Backups created in $BACKUP_DIR"
    fi
}

# --- 1. Kernel / Sysctl Tuning ---
apply_sysctl() {
    local key=$1
    local value=$2
    if [ "$SCAN_ONLY" = true ]; then
        current=$(sysctl -n "$key" 2>/dev/null)
        [ "$current" != "$value" ] && log_action "[SCAN] MISMATCH: $key is $current, should be $value"
    else
        # Idempotent entry in /etc/sysctl.d/99-hardened-network.conf
        grep -q "^$key" /etc/sysctl.d/99-hardened-network.conf 2>/dev/null \
            && sed -i "s/^$key.*/$key = $value/" /etc/sysctl.d/99-hardened-network.conf \
            || echo "$key = $value" >> /etc/sysctl.d/99-hardened-network.conf
    fi
}

harden_kernel() {
    log_action "Starting Kernel Hardening..."
    # TCP SYN Cookie & Flood Protection
    apply_sysctl "net.ipv4.tcp_syncookies" "1"
    apply_sysctl "net.ipv4.tcp_rfc1337" "1"
    
    # Disable Source Routing and Redirects
    apply_sysctl "net.ipv4.conf.all.accept_source_route" "0"
    apply_sysctl "net.ipv4.conf.all.accept_redirects" "0"
    apply_sysctl "net.ipv4.conf.all.secure_redirects" "0"
    apply_sysctl "net.ipv4.conf.all.send_redirects" "0"
    
    # IPv6 Hardening (Disable RA)
    apply_sysctl "net.ipv6.conf.all.accept_ra" "0"
    apply_sysctl "net.ipv6.conf.default.accept_ra" "0"

    # High Throughput Tuning
    apply_sysctl "net.core.rmem_max" "16777216"
    apply_sysctl "net.core.wmem_max" "16777216"
    apply_sysctl "net.ipv4.tcp_rmem" "4096 87380 16777216"
    apply_sysctl "net.ipv4.tcp_wmem" "4096 65536 16777216"

    [ "$SCAN_ONLY" = false ] && sysctl --system > /dev/null
}

# --- 2. Firewalld Orchestration ---
harden_firewall() {
    log_action "Configuring Firewalld..."
    if [ "$SCAN_ONLY" = false ]; then
        # Set default zone to DROP
        firewall-cmd --set-default-zone=drop
        
        # Enable essential services
        firewall-cmd --permanent --zone=drop --add-port=${CUSTOM_SSH_PORT}/tcp
        firewall-cmd --permanent --zone=drop --add-service=https
        
        # IP Set for Malicious Subnets (Example: known Bogon list placeholder)
        firewall-cmd --permanent --new-ipset=blacklist --type=hash:net
        firewall-cmd --permanent --ipset=blacklist --add-entry=192.0.2.0/24 
        firewall-cmd --permanent --zone=drop --add-rich-rule='rule family="ipv4" source ipset="blacklist" drop'
        
        firewall-cmd --reload
    else
        log_action "[SCAN] Checking Firewall: Default zone is $(firewall-cmd --get-default-zone)"
    fi
}

# --- 3. DNS over HTTPS & Privacy ---
harden_dns_and_privacy() {
    log_action "Configuring systemd-resolved and MAC Randomization..."
    if [ "$SCAN_ONLY" = false ]; then
        # DNSSEC and DoH
        mkdir -p /etc/systemd/resolved.conf.d
        cat <<EOF > /etc/systemd/resolved.conf.d/hardened-dns.conf
[Resolve]
DNS=1.1.1.1#cloudflare-dns.com 9.9.9.9#dns.quad9.net
DNSOverTLS=yes
DNSSEC=yes
FallbackDNS=1.0.0.1 149.112.112.112
EOF
        systemctl restart systemd-resolved

        # MAC Randomization (NetworkManager)
        mkdir -p /etc/NetworkManager/conf.d
        cat <<EOF > /etc/NetworkManager/conf.d/00-mac-randomize.conf
[device]
wifi.scan-rand-mac-address=yes

[connection]
wifi.cloned-mac-address=random
ethernet.cloned-mac-address=random
EOF
        systemctl reload NetworkManager
    fi
}

# --- Execution ---
prepare_backups
harden_kernel
harden_firewall
harden_dns_and_privacy

log_action "Hardening process complete. Mode: $( [ "$SCAN_ONLY" = true ] && echo "SCAN" || echo "APPLY" )"
