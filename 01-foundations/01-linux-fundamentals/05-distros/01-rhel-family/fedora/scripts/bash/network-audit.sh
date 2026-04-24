#!/usr/bin/env bash
#
# Fedora 43 Network Audit Script (Read-Only)
# Purpose: Collect network configuration evidence for troubleshooting.
# Constraint: Does NOT modify system state.
#

set -euo pipefail

# Output file setup
OUTPUT_FILE="$HOME/network_audit_$(date +%F_%H-%M-%S).txt"
echo "Starting Fedora 43 Network Audit..."
echo "Saving output to: $OUTPUT_FILE"

# Function to log section headers
log_section() {
    echo -e "\n### $1 ###" | tee -a "$OUTPUT_FILE"
    echo "-------------------------------------------" | tee -a "$OUTPUT_FILE"
}

# Redirect all subsequent output to file and stdout
exec > >(tee -a "$OUTPUT_FILE") 2>&1

log_section "SYSTEM INFO"
cat /etc/fedora-release 2>/dev/null || echo "Release file not found"
uname -r
getenforce 2>/dev/null || echo "SELinux not installed/permissive"

log_section "NETWORK INTERFACES & IPS"
ip -brief addr show
ip -4 route show table all

log_section "DNS CONFIGURATION (systemd-resolved)"
resolvectl status
cat /etc/resolv.conf

log_section "FIREWALLD CONFIGURATION"
# Check if firewalld is active
systemctl is-active firewalld
if systemctl is-active --quiet firewalld; then
    firewall-cmd --get-active-zones
    firewall-cmd --list-all-zones
else
    echo "Firewalld is not active."
fi

log_section "NETWORKMANAGER STATUS"
nmcli general status
nmcli connection show --active

log_section "LISTENING PORTS (DevOps Check)"
# Check for common DevOps ports (8080, 8443, etc.)
ss -tulpn | grep -E '(8080|8443|LISTEN)' || echo "No specific DevOps ports found listening."

log_section "CONNECTIVITY TESTS"
echo "Testing Gateway..."
ip -4 route show default | awk '{print $3}' | head -n1 | xargs -I {} ping -c 2 {}
echo "Testing Public DNS (1.1.1.1)..."
ping -c 2 1.1.1.1
echo "Testing Domain Resolution (fedoraproject.org)..."
curl -s --connect-timeout 5 -o /dev/null -w "HTTP Code: %{http_code}\n" https://fedoraproject.org || echo "Curl failed"

log_section "AUDIT COMPLETE"
echo "Review $OUTPUT_FILE for sensitive IPs before sharing."
echo "Please provide this output to the Network Engineer for analysis."
