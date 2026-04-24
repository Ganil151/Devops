#!/bin/bash

# ==============================================================================
# Script Name: Secure-FedoraNetwork.sh
# Description: Hardens Fedora 43 Networking (Kernel, Firewall, DNS, Privacy)
#              Updated to allow amazon.com (via HTTPS) and DevOps ports (8080, etc.)
# Author: Senior Linux Systems & Security Architect
# Version: 1.1 (Fedora 43 / DNF5 Compatible)
# ==============================================================================

LOG_FILE="/var/log/network_hardening.log"
BACKUP_DIR="/var/backups/network_hardening_$(date +%F_%H-%M)"
CUSTOM_SSH_PORT=2222
SCAN_ONLY=false

# --- DevOps & Application Ports Configuration ---
# Array of additional TCP ports to allow for DevOps tools (Jenkins, custom APIs, etc.)
DEVOPS_PORTS=(8080 8443 9090)

# Note: Domain-based allowlisting (e.g., amazon.com) cannot be done at the firewall level
# with firewalld. Outbound HTTPS (port 443) is allowed by default, which enables access
# to amazon.com, AWS APIs, and other HTTPS services. For granular domain control, use:
# - Application-level proxies (Squid, Envoy)
# - DNS filtering (Pi-hole, Cisco Umbrella)
# - AWS Security Groups / Network ACLs at the cloud level

# --- Initialization & Safety ---
# Exit immediately if a command exits with a non-zero status.
set -e

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
    log_action "Starting Firewalld Hardening..."
    if [ "$SCAN_ONLY" = false ]; then
        log_action "Setting default zone to 'drop' to deny all incoming traffic by default."
        firewall-cmd --set-default-zone=drop --permanent
        
        # --- CRITICAL: SSH Port Configuration ---
        log_action "Configuring firewall for custom SSH port: ${CUSTOM_SSH_PORT}"
        if ! firewall-cmd --zone=drop --query-port=${CUSTOM_SSH_PORT}/tcp --permanent; then
            firewall-cmd --zone=drop --add-port=${CUSTOM_SSH_PORT}/tcp --permanent
        fi
        # Remove standard SSH port if it exists in any zone to enforce custom port usage
        firewall-cmd --remove-service=ssh --permanent >/dev/null 2>&1 || true
        
        log_action "IMPORTANT: This script opens port ${CUSTOM_SSH_PORT} for SSH."
        log_action "You MUST now edit /etc/ssh/sshd_config and change the 'Port' directive:"
        log_action "1. sudo nano /etc/ssh/sshd_config"
        log_action "2. Change '#Port 22' to 'Port ${CUSTOM_SSH_PORT}' (and uncomment it)"
        log_action "3. Restart SSHD: sudo systemctl restart sshd"
        log_action "FAILURE TO DO SO WILL LOCK YOU OUT OF SSH."

        # --- Allow HTTPS (Port 443) for amazon.com, AWS APIs, and general secure web traffic ---
        log_action "Allowing HTTPS traffic (port 443) for amazon.com, AWS services, and secure web access."
        if ! firewall-cmd --zone=drop --query-service=https --permanent; then
            firewall-cmd --zone=drop --add-service=https --permanent
        fi

        # --- Allow DevOps Application Ports (8080, 8443, 9090, etc.) ---
        log_action "Allowing DevOps application ports: ${DEVOPS_PORTS[*]}"
        for port in "${DEVOPS_PORTS[@]}"; do
            if ! firewall-cmd --zone=drop --query-port=${port}/tcp --permanent; then
                firewall-cmd --zone=drop --add-port=${port}/tcp --permanent
                log_action "  - Opened TCP port ${port} for DevOps applications"
            fi
        done
        
        # Optional: Allow HTTP (port 80) for redirect to HTTPS or internal tools
        # Uncomment below if needed for your use case
        # if ! firewall-cmd --zone=drop --query-service=http --permanent; then
        #     firewall-cmd --zone=drop --add-service=http --permanent
        #     log_action "  - Opened HTTP port 80 for redirects/internal tools"
        # fi

        # IP Set for Malicious Subnets (Example: known Bogon list placeholder)
        if ! firewall-cmd --get-ipsets --permanent | grep -q "blacklist"; then
            log_action "Creating 'blacklist' ipset for malicious subnets."
            firewall-cmd --new-ipset=blacklist --type=hash:net --permanent
            firewall-cmd --ipset=blacklist --add-entry=192.0.2.0/24 --permanent # Example Bogon range
            firewall-cmd --zone=drop --add-rich-rule='rule family="ipv4" source ipset="blacklist" drop' --permanent
        fi
        
        firewall-cmd --reload
        log_action "Firewalld reloaded with new rules."
    else
        log_action "[SCAN] Checking Firewall: Default zone is $(firewall-cmd --get-default-zone)"
        log_action "[SCAN] Custom SSH port should be ${CUSTOM_SSH_PORT}"
        log_action "[SCAN] DevOps ports to allow: ${DEVOPS_PORTS[*]}"
        log_action "[SCAN] HTTPS service should be enabled for amazon.com/AWS access"
    fi
}

# --- 3. DNS over HTTPS & Privacy ---
harden_dns_and_privacy() {
    log_action "Configuring systemd-resolved and MAC Randomization..."
    if [ "$SCAN_ONLY" = false ]; then
        # DNSSEC and DoH
        mkdir -p /etc/systemd/resolved.conf.d /etc/NetworkManager/conf.d
        cat <<EOF > /etc/systemd/resolved.conf.d/hardened-dns.conf
[Resolve]
DNS=1.1.1.1#cloudflare-dns.com 9.9.9.9#dns.quad9.net
DNSOverTLS=yes
DNSSEC=yes
FallbackDNS=1.0.0.1 149.112.112.112
EOF
        systemctl try-restart systemd-resolved

        # MAC Randomization (NetworkManager)
        cat <<EOF > /etc/NetworkManager/conf.d/00-mac-randomize.conf
[device]
wifi.scan-rand-mac-address=yes

[connection]
wifi.cloned-mac-address=random
ethernet.cloned-mac-address=random
EOF
        systemctl try-reload NetworkManager || log_action "NetworkManager not running, skipping reload."
    fi
}

# --- Execution ---
prepare_backups
harden_kernel
harden_firewall
harden_dns_and_privacy

log_action "Hardening process complete. Mode: $( [ "$SCAN_ONLY" = true ] && echo "SCAN" || echo "APPLY" )"
log_action "Summary of allowed inbound services:"
log_action "  - SSH on port ${CUSTOM_SSH_PORT}/tcp"
log_action "  - HTTPS on port 443/tcp (for amazon.com, AWS APIs, secure web)"
log_action "  - DevOps ports: ${DEVOPS_PORTS[*]}/tcp"
log_action "  - All other inbound traffic is DROP by default"
log_action ""
log_action "NOTE: Outbound traffic is unrestricted by this script."
log_action "Access to amazon.com works via outbound HTTPS (port 443)."
log_action "For domain-level filtering, implement at application/proxy layer."