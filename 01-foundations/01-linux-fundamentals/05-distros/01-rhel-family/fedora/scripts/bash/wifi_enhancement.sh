#!/usr/bin/env bash
#
# Fedora 43 WiFi Audit & Enhancement Script
# Purpose: Audit network configuration AND optionally apply safe WiFi hardening
# Modes: 
#   --audit-only    : Read-only collection (original behavior)
#   --enhance       : Audit + apply reversible security/performance improvements
#
# Usage: sudo ./wifi_enhance.sh [--audit-only|--enhance]
#

set -euo pipefail

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Output file setup
OUTPUT_DIR="$HOME/wifi_audit_$(date +%F_%H-%M-%S)"
mkdir -p "$OUTPUT_DIR"
OUTPUT_FILE="$OUTPUT_DIR/audit_report.txt"
BACKUP_DIR="$OUTPUT_DIR/backups"
mkdir -p "$BACKUP_DIR"

# Mode selection
MODE="${1:---audit-only}"
if [[ "$MODE" != "--audit-only" && "$MODE" != "--enhance" ]]; then
    echo -e "${RED}Usage: $0 [--audit-only|--enhance]${NC}"
    exit 1
fi

# Require root for enhancement mode
if [[ "$MODE" == "--enhance" && "$EUID" -ne 0 ]]; then
    echo -e "${RED}Enhancement mode requires root privileges. Please run with sudo.${NC}"
    exit 1
fi

# Logging functions
log_info()    { echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$OUTPUT_FILE"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1" | tee -a "$OUTPUT_FILE"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$OUTPUT_FILE"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$OUTPUT_FILE"; }

log_section() {
    echo -e "\n### $1 ###" | tee -a "$OUTPUT_FILE"
    echo "-------------------------------------------" | tee -a "$OUTPUT_FILE"
}

# Backup function for config files
backup_config() {
    local file="$1"
    local name=$(basename "$file" | tr '/' '_')
    if [[ -f "$file" ]]; then
        cp "$file" "$BACKUP_DIR/${name}.bak"
        log_info "Backed up: $file → $BACKUP_DIR/${name}.bak"
    fi
}

# Redirect output
exec > >(tee -a "$OUTPUT_FILE") 2>&1

echo -e "${GREEN}Starting Fedora 43 WiFi Audit & Enhancement${NC}"
echo "Output directory: $OUTPUT_DIR"
echo "Mode: $MODE"
echo ""

#==============================================================================
# AUDIT SECTION (Always runs)
#==============================================================================

log_section "SYSTEM INFO"
cat /etc/fedora-release 2>/dev/null || echo "Release file not found"
uname -r
getenforce 2>/dev/null || echo "SELinux status unavailable"

log_section "WIFI INTERFACE DETECTION"
# Identify WiFi interfaces
WIFI_IFACES=$(nmcli device status | grep wifi | awk '{print $1}' || true)
if [[ -z "$WIFI_IFACES" ]]; then
    log_warn "No WiFi interfaces detected. Is WiFi enabled?"
    ip -brief link show | grep -i wlan || echo "No wlan interfaces found"
else
    log_info "Detected WiFi interface(s): $WIFI_IFACES"
fi

log_section "NETWORK INTERFACES & IPS"
ip -brief addr show
ip -4 route show table all

log_section "WIFI CONNECTION DETAILS"
if command -v nmcli &>/dev/null; then
    for iface in $WIFI_IFACES; do
        echo "Interface: $iface"
        nmcli device show "$iface" 2>/dev/null | grep -E '(IP4.ADDRESS|IP4.GATEWAY|wifi.cloned-mac-address|802-11-wireless.ssid|802-11-wireless-security.key-mgmt)' || echo "  No active connection"
        echo ""
    done
fi

log_section "DNS CONFIGURATION"
resolvectl status 2>/dev/null || cat /etc/resolv.conf
# Check for DNS leaks or unencrypted DNS
if grep -q "nameserver" /etc/resolv.conf; then
    DNS_SERVERS=$(grep nameserver /etc/resolv.conf | awk '{print $2}' | tr '\n' ' ')
    log_info "Current DNS servers: $DNS_SERVERS"
    if ! echo "$DNS_SERVERS" | grep -qE '(1\.1\.1\.1|8\.8\.8\.8|9\.9\.9\.9)'; then
        log_warn "Consider using privacy-focused DNS (Cloudflare/Google/Quad9)"
    fi
fi

log_section "FIREWALLD CONFIGURATION"
if systemctl is-active firewalld &>/dev/null; then
    firewall-cmd --get-active-zones
    firewall-cmd --list-all-zones
    # Check if WiFi zone allows unnecessary services
    log_info "Firewall is active - reviewing WiFi zone rules..."
else
    log_warn "Firewalld is not active. Consider enabling for WiFi security."
fi

log_section "WIFI SECURITY PROTOCOL CHECK"
# Check encryption type for active WiFi connections
for iface in $WIFI_IFACES; do
    SECURITY=$(nmcli -g 802-11-wireless-security.key-mgmt device show "$iface" 2>/dev/null || echo "UNKNOWN")
    SSID=$(nmcli -g 802-11-wireless.ssid device show "$iface" 2>/dev/null || echo "N/A")
    echo "SSID: $SSID | Security: $SECURITY"
    case "$SECURITY" in
        wpa-psk|wpa-eap) log_info "✓ Using WPA2/WPA3 encryption" ;;
        wep|none) log_error "✗ Weak/no encryption detected! Upgrade router security." ;;
        *) log_warn "? Unknown security protocol: $SECURITY" ;;
    esac
done

log_section "WIFI SIGNAL & CHANNEL ANALYSIS"
if command -v iw &>/dev/null && [[ -n "$WIFI_IFACES" ]]; then
    for iface in $WIFI_IFACES; do
        if iw dev "$iface" link &>/dev/null; then
            echo "Signal info for $iface:"
            iw dev "$iface" link | grep -E '(signal|freq|SSID)' || true
            # Suggest 5GHz if on crowded 2.4GHz
            FREQ=$(iw dev "$iface" link | grep freq | awk '{print $2}')
            if [[ "$FREQ" =~ ^24[0-9]{2}$ ]]; then
                log_warn "Connected on 2.4GHz band. Consider 5GHz for less interference if available."
            fi
        fi
    done
fi

log_section "NETWORKMANAGER POWER MANAGEMENT"
for iface in $WIFI_IFACES; do
    PM=$(nmcli -g 802-11-wireless.powersave device show "$iface" 2>/dev/null || echo "unknown")
    echo "Interface $iface power save: $PM"
    if [[ "$PM" == "2" || "$PM" == "enable" ]]; then
        log_warn "WiFi power saving is ENABLED - may cause latency/disconnects. Consider disabling for stability."
    fi
done

log_section "LISTENING PORTS (Security Review)"
ss -tulpn | grep LISTEN || echo "No listening ports found"
# Flag unexpected services on WiFi-facing interfaces
if ss -tulpn | grep -qE ':(22|23|3389).*0\.0\.0\.0'; then
    log_warn "Remote access services listening on all interfaces - ensure firewall restricts WiFi access"
fi

log_section "CONNECTIVITY & LATENCY TESTS"
GATEWAY=$(ip -4 route show default | awk '{print $3}' | head -n1)
if [[ -n "$GATEWAY" ]]; then
    echo "Testing Gateway ($GATEWAY)..."
    ping -c 2 -W 2 "$GATEWAY" || log_warn "Gateway ping failed"
fi
echo "Testing Public DNS (1.1.1.1)..."
ping -c 2 -W 2 1.1.1.1 || log_warn "Public DNS unreachable"
echo "Testing HTTPS latency to fedoraproject.org..."
curl -s --connect-timeout 5 -o /dev/null -w "HTTP Code: %{http_code}, Time: %{time_total}s\n" https://fedoraproject.org || log_warn "Curl test failed"

#==============================================================================
# ENHANCEMENT SECTION (Only if --enhance flag used)
#==============================================================================

if [[ "$MODE" == "--enhance" ]]; then
    echo -e "\n${YELLOW}=== APPLYING SAFE WIFI ENHANCEMENTS ===${NC}"
    
    # 1. Enable IPv6 Privacy Extensions (if IPv6 is used)
    log_section "ENHANCEMENT: IPv6 Privacy Addresses"
    if sysctl -a 2>/dev/null | grep -q "net.ipv6.conf.all.use_tempaddr"; then
        backup_config "/etc/sysctl.d/99-wifi-privacy.conf"
        cat > /etc/sysctl.d/99-wifi-privacy.conf << 'EOF'
# WiFi Privacy Enhancements
net.ipv6.conf.all.use_tempaddr = 2
net.ipv6.conf.default.use_tempaddr = 2
net.ipv6.conf.all.accept_ra = 2
EOF
        sysctl -p /etc/sysctl.d/99-wifi-privacy.conf 2>/dev/null || true
        log_success "IPv6 privacy extensions enabled"
    else
        log_warn "IPv6 not detected - skipping privacy extensions"
    fi

    # 2. Disable WiFi Power Management for stability
    log_section "ENHANCEMENT: WiFi Power Management"
    for iface in $WIFI_IFACES; do
        CURRENT_PM=$(nmcli -g 802-11-wireless.powersave device show "$iface" 2>/dev/null || echo "3")
        if [[ "$CURRENT_PM" != "3" ]]; then # 3 = disable
            backup_config "/etc/NetworkManager/conf.d/wifi-powersave.conf"
            mkdir -p /etc/NetworkManager/conf.d/
            cat > /etc/NetworkManager/conf.d/wifi-powersave.conf << EOF
# Auto-generated: Disable WiFi power saving for stability
[connection]
wifi.powersave = 3
EOF
            nmcli general reload
            log_success "Disabled WiFi power saving on $iface (improves stability)"
        else
            log_info "WiFi power saving already disabled on $iface"
        fi
    done

    # 3. Enforce Secure DNS via systemd-resolved (if available)
    log_section "ENHANCEMENT: DNS Hardening"
    if command -v resolvectl &>/dev/null; then
        # Backup current resolved config
        backup_config "/etc/systemd/resolved.conf"
        
        # Check if already using secure DNS
        CURRENT_DNS=$(resolvectl status | grep "DNS Servers" | head -1 || true)
        if ! echo "$CURRENT_DNS" | grep -qE '(1\.1\.1\.1|8\.8\.8\.8|9\.9\.9\.9)'; then
            cat > /etc/systemd/resolved.conf << 'EOF'
[Resolve]
DNS=1.1.1.1 8.8.8.8 9.9.9.9
FallbackDNS=1.0.0.1 8.8.4.4
DNSOverTLS=opportunistic
Cache=yes
EOF
            systemctl restart systemd-resolved 2>/dev/null || true
            log_success "Configured secure DNS with DNS-over-TLS (opportunistic)"
        else
            log_info "DNS already configured with secure resolvers"
        fi
    else
        log_warn "systemd-resolved not available - skipping DNS hardening"
    fi

    # 4. Firewall: Ensure WiFi zone restricts unnecessary inbound traffic
    log_section "ENHANCEMENT: Firewall Hardening"
    if systemctl is-active firewalld &>/dev/null; then
        WIFI_ZONE=$(firewall-cmd --get-zone-of-interface=wlan0 2>/dev/null || firewall-cmd --get-default-zone)
        log_info "WiFi zone: $WIFI_ZONE"
        
        # Remove risky services if present in WiFi zone
        for risky_service in telnet ftp rsh rlogin; do
            if firewall-cmd --zone="$WIFI_ZONE" --list-services | grep -qw "$risky_service"; then
                firewall-cmd --zone="$WIFI_ZONE" --remove-service="$risky_service" --permanent
                log_warn "Removed insecure service '$risky_service' from WiFi zone"
            fi
        done
        
        # Ensure SSH is restricted (if enabled)
        if firewall-cmd --zone="$WIFI_ZONE" --list-services | grep -qw ssh; then
            log_warn "SSH is allowed on WiFi zone. Consider restricting to specific IPs:"
            log_warn "  firewall-cmd --zone=$WIFI_ZONE --remove-service=ssh --permanent"
            log_warn "  firewall-cmd --zone=$WIFI_ZONE --add-rich-rule='rule family=ipv4 source address=YOUR_TRUSTED_IP service name=ssh accept' --permanent"
        fi
        
        firewall-cmd --reload 2>/dev/null || true
        log_success "Firewall rules reviewed for WiFi zone"
    fi

    # 5. SELinux: Ensure enforcing mode for security
    log_section "ENHANCEMENT: SELinux Status"
    if command -v getenforce &>/dev/null; then
        SELINUX_STATUS=$(getenforce)
        if [[ "$SELINUX_STATUS" != "Enforcing" ]]; then
            log_warn "SELinux is not enforcing. To enable permanently:"
            log_warn "  sudo sed -i 's/SELINUX=permissive/SELINUX=enforcing/' /etc/selinux/config"
            log_warn "  sudo reboot"
        else
            log_success "SELinux is in enforcing mode ✓"
        fi
    fi

    # 6. Generate optimization report with actionable router-side suggestions
    log_section "ACTIONABLE RECOMMENDATIONS (Router Configuration)"
    cat << 'EOF' | tee -a "$OUTPUT_FILE"
The following improvements require access to your WiFi router:

[SECURITY]
• Upgrade to WPA3 if your router supports it (or WPA2-AES minimum)
• Disable WPS (Wi-Fi Protected Setup) - known security flaw
• Change default router admin credentials
• Enable router firewall and disable remote management

[PERFORMANCE]
• Use 5GHz band for devices that support it (less interference)
• Set WiFi channel to 1, 6, or 11 (2.4GHz) or use auto-channel selection
• Enable QoS to prioritize video calls/gaming if needed
• Update router firmware to latest version

[PRIVACY]
• Disable UPnP if not needed
• Enable guest network for visitors/IoT devices
• Consider DNS-over-HTTPS/TLS at router level

EOF

    # 7. Create rollback script
    log_section "ROLLBACK INSTRUCTIONS"
    cat > "$OUTPUT_DIR/rollback.sh" << 'ROLLBACK'
#!/usr/bin/env bash
# Auto-generated rollback script for WiFi enhancements
set -euo pipefail
echo "Rolling back WiFi enhancements..."

# Restore NetworkManager power save
rm -f /etc/NetworkManager/conf.d/wifi-powersave.conf

# Restore DNS config
rm -f /etc/systemd/resolved.conf
# (systemd-resolved will revert to defaults)

# Restore sysctl settings
rm -f /etc/sysctl.d/99-wifi-privacy.conf

# Reload services
nmcli general reload 2>/dev/null || true
systemctl restart systemd-resolved 2>/dev/null || true
sysctl -p /etc/sysctl.conf 2>/dev/null || true

echo "Rollback complete. You may need to reboot for all changes to revert."
ROLLBACK
    chmod +x "$OUTPUT_DIR/rollback.sh"
    log_success "Rollback script created: $OUTPUT_DIR/rollback.sh"

    echo -e "\n${GREEN}=== ENHANCEMENTS COMPLETE ===${NC}"
    echo -e "Review the report: ${BLUE}$OUTPUT_FILE${NC}"
    echo -e "To undo changes, run: ${BLUE}sudo $OUTPUT_DIR/rollback.sh${NC}"
else
    echo -e "\n${YELLOW}Audit complete. To apply enhancements, re-run with:${NC}"
    echo -e "${BLUE}sudo $0 --enhance${NC}"
fi

log_section "AUDIT COMPLETE"
echo "Review $OUTPUT_FILE for sensitive information before sharing."
echo "Report saved to: $OUTPUT_DIR/"
echo -e "${GREEN}Done.${NC}"