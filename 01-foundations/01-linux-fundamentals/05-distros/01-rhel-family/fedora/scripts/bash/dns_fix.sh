#!/usr/bin/env bash
#
# Fedora 43 DNS Resolution Troubleshooting Script
# Part 1: Diagnostic (Read-Only)
# Part 2: Remediation (Commented - Uncomment intentionally)
#

set -euo pipefail

echo "=== Fedora 43 DNS Troubleshooting ==="
echo "Part 1: Running Diagnostics (Read-Only)..."

# --- DIAGNOSTIC SECTION (SAFE - NO CHANGES) ---
echo -e "\n[1/6] Checking /etc/resolv.conf..."
ls -l /etc/resolv.conf
cat /etc/resolv.conf

echo -e "\n[2/6] systemd-resolved status..."
resolvectl status 2>/dev/null || echo "resolvectl not available"

echo -e "\n[3/6] Testing raw DNS query (port 53)..."
# Test if we can reach a public DNS server directly
if command -v dig &>/dev/null; then
    dig @1.1.1.1 github.com +time=2 +tries=1 || echo "dig to 1.1.1.1 failed"
else
    echo "dig not installed; install with: dnf install bind-utils"
fi

echo -e "\n[4/6] Testing hostname resolution via getent..."
getent hosts github.com || echo "getent: resolution failed"

echo -e "\n[5/6] Firewalld DNS rules check..."
if systemctl is-active --quiet firewalld; then
    echo "Active zones:"
    firewall-cmd --get-active-zones
    echo "Checking for DNS service in active zones..."
    for zone in $(firewall-cmd --get-active-zones | awk '{print $1}'); do
        if ! firewall-cmd --zone="$zone" --list-services | grep -q dns; then
            echo "⚠️  Zone '$zone' does not have 'dns' service enabled (may block outbound DNS)"
        fi
    done
else
    echo "Firewalld not active."
fi

echo -e "\n[6/6] NetworkManager DNS configuration..."
nmcli connection show --active | awk 'NR>1 {print $1}' | while read -r conn; do
    echo "Connection: $conn"
    nmcli connection show "$conn" | grep -E 'ipv4.dns|ipv6.dns|connection.zone' || echo "  No DNS settings found"
done

# --- REMEDIATION SECTION (COMMENTED - UNCOMMENT INTENTIONALLY) ---
echo -e "\n=== Part 2: Remediation Options (COMMENTED BY DEFAULT) ==="
echo "Review diagnostics above. Uncomment ONE block below that matches your issue."

: <<'END_REMEDIATION_BLOCKS'

# OPTION A: Reset systemd-resolved to use opportunistic DNS (fixes strict DoT failures)
# Impact: Allows fallback to plaintext DNS if DoT fails. Restores resolution for most users.
# echo "Setting DNSOverTLS=opportunistic..."
# resolvectl dns <interface> 1.1.1.1 8.8.8.8  # Replace <interface> with your actual interface (e.g., eth0, wlan0)
# resolvectl domain <interface> ~.
# resolvectl dnsovertls <interface> opportunistic
# systemctl restart systemd-resolved

# OPTION B: Manually set static DNS servers via NetworkManager (bypasses resolved issues)
# Impact: Forces specific DNS servers for the active connection. Overrides DHCP DNS.
# conn_name=$(nmcli -t -f NAME connection show --active | head -n1)
# nmcli connection modify "$conn_name" ipv4.dns "1.1.1.1 8.8.8.8"
# nmcli connection modify "$conn_name" ipv4.ignore-auto-dns yes
# nmcli connection up "$conn_name"

# OPTION C: Allow DNS service in firewalld active zone (if blocked)
# Impact: Permits outbound DNS queries (UDP/TCP 53) in the specified zone.
# zone=$(firewall-cmd --get-active-zones | awk '{print $1; exit}')
# firewall-cmd --zone="$zone" --add-service=dns --permanent
# firewall-cmd --reload

# OPTION D: Temporary emergency fix - bypass resolved with static resolv.conf
# Impact: Replaces /etc/resolv.conf with static nameservers. May break if NetworkManager overwrites it.
# echo "nameserver 1.1.1.1" > /etc/resolv.conf
# echo "nameserver 8.8.8.8" >> /etc/resolv.conf
# chattr +i /etc/resolv.conf  # Make immutable (use chattr -i to revert later)

END_REMEDIATION_BLOCKS

echo -e "\n[DIAGNOSTIC COMPLETE]"
echo "If you identified a cause, edit this script to uncomment the matching remediation block."
echo "Then run with: sudo ./dns_fix.sh"
