#!/bin/bash
# Description: Post-Hardening Verification for Fedora 43
# Logic: Checks current runtime state against hardening requirements.

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root to perform checks and fixes. Aborting."
    exit 1
fi

CUSTOM_SSH_PORT=2222
REPORT_FILE="/var/log/hardening_audit_$(date +%F).log"

echo "--- SECURITY READINESS REPORT ---" | tee "$REPORT_FILE"

fix_dns() {
    echo "Applying Hardened DNS Configuration..." | tee -a "$REPORT_FILE"
    mkdir -p /etc/systemd/resolved.conf.d
    # Configure DNS-over-TLS with Cloudflare and Quad9 as primary, with fallbacks.
    cat <<EOF > /etc/systemd/resolved.conf.d/hardened-dns.conf
[Resolve]
DNS=1.1.1.1#cloudflare-dns.com 9.9.9.9#dns.quad9.net
DNSOverTLS=yes
DNSSEC=yes
FallbackDNS=1.0.0.1 149.112.112.112
EOF
    systemctl try-restart systemd-resolved
    sleep 2
}

check_param() {
    local label=$1
    local command=$2
    local expected=$3
    local fix_action=$4
    local current=$(eval "$command" 2>/dev/null)

    if [[ "$current" == *"$expected"* ]]; then
        echo -e "[PASS] $label" | tee -a "$REPORT_FILE"
    else
        echo -e "[FAIL] $label (Current: $current | Expected: $expected)" | tee -a "$REPORT_FILE"
        if [[ -n "$fix_action" ]]; then
            echo -e "[FIX] Attempting auto-remediation..." | tee -a "$REPORT_FILE"
            eval "$fix_action"
            current=$(eval "$command" 2>/dev/null)
            if [[ "$current" == *"$expected"* ]]; then
                echo -e "[PASS] $label (Fixed)" | tee -a "$REPORT_FILE"
            else
                echo -e "[FAIL] $label (Fix Failed)" | tee -a "$REPORT_FILE"
            fi
        fi
    fi
}

# --- Checks ---
check_param "Firewall Default Zone" "firewall-cmd --get-default-zone" "drop"
check_param "TCP SYN Cookies" "sysctl -n net.ipv4.tcp_syncookies" "1"
check_param "ICMP Redirects" "sysctl -n net.ipv4.conf.all.accept_redirects" "0"
check_param "DNSSEC Validation" "resolvectl status | grep 'DNSSEC:'" "yes" "fix_dns"
check_param "DNS over TLS" "resolvectl status | grep 'Protocols:'" "+DNSOverTLS"
check_param "SSH Custom Port" "firewall-cmd --zone=drop --query-port=${CUSTOM_SSH_PORT}/tcp" "yes"

echo "Full report saved to $REPORT_FILE"