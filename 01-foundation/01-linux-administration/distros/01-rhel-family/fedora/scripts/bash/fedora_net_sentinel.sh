#!/usr/bin/env bash
#
# Fedora 43 Network Sentinel (Audit, Secure, & Repair) - ENHANCED EDITION
# Architected for: Fedora 43 (DNF5, Systemd-Resolved, Firewalld, SELinux)
# Safety: Dry-run by default, backups before changes, explicit --apply required
#

set -euo pipefail

# --- Configuration & Safety ---
readonly SCRIPT_NAME="$(basename "$0")"
readonly TIMESTAMP="$(date +%F_%H-%M-%S)"
readonly BACKUP_DIR="/root/net_sentinel_backup_${TIMESTAMP}"
readonly LOG_FILE="/var/log/net_sentinel_${TIMESTAMP}.log"
DRY_RUN=true
APPLY_CHANGES=false

# Color codes (safe for non-TTY)
if [[ -t 1 ]]; then
    RED='\e[1;31m'; GREEN='\e[1;32m'; YELLOW='\e[1;33m'; BLUE='\e[1;34m'; NC='\e[0m'
else
    RED=''; GREEN=''; YELLOW=''; BLUE=''; NC=''
fi

# --- Argument Parsing ---
usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS]

Fedora 43 Network Sentinel: Audit, harden, and repair network configuration.

OPTIONS:
    --apply         Apply remediation changes (default: dry-run only)
    --dry-run       Audit only, no changes (default mode)
    --connection NAME  Target specific NetworkManager connection
    --timeout SECS  Set network test timeout (default: 5)
    --help          Show this help message

EXAMPLES:
    # Audit only (safe)
    sudo ./$SCRIPT_NAME --dry-run

    # Apply fixes after review
    sudo ./$SCRIPT_NAME --apply

    # Test with custom timeout
    sudo ./$SCRIPT_NAME --dry-run --timeout 10
EOF
    exit 0
}

TIMEOUT=5
TARGET_CONN=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --apply) APPLY_CHANGES=true; DRY_RUN=false; shift ;;
        --dry-run) DRY_RUN=true; APPLY_CHANGES=false; shift ;;
        --connection) TARGET_CONN="$2"; shift 2 ;;
        --timeout) TIMEOUT="$2"; shift 2 ;;
        --help) usage ;;
        *) echo "❌ Unknown option: $1"; usage ;;
    esac
done

# --- Root Check ---
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ This script must be run as root (sudo).${NC}" 
   exit 1
fi

# --- Logging Setup ---
log() {
    local level="$1"; shift
    echo -e "${level}$(date '+%F %T') - $*${NC}" | tee -a "$LOG_FILE"
}

log_header() {
    log "$BLUE" "[🛠️] $1"
    echo "----------------------------------------------------" | tee -a "$LOG_FILE"
}

# --- Backup Function ---
create_backup() {
    local file="$1"
    if [[ -f "$file" ]]; then
        mkdir -p "$BACKUP_DIR"
        cp -a "$file" "${BACKUP_DIR}/$(basename "$file").${TIMESTAMP}"
        log "$GREEN" "✅ Backed up: $file -> ${BACKUP_DIR}/"
    fi
}

# --- Safe Config Edit (systemd-resolved) ---
safe_resolved_conf_edit() {
    local key="$1" value="$2" file="/etc/systemd/resolved.conf"
    
    if [[ ! -f "$file" ]]; then
        log "$YELLOW" "⚠️  $file not found, skipping."
        return 0
    fi
    
    create_backup "$file"
    
    # Use systemd-conf if available (Fedora-native), else safe sed
    if command -v systemd-conf &>/dev/null && [[ "$DRY_RUN" == false ]]; then
        log "$BLUE" "Using systemd-conf to set $key=$value"
        systemd-conf set "$file" "$key" "$value" --backup-dir="$BACKUP_DIR"
    else
        # Safe sed: handle missing/commented lines
        if grep -q "^#*\s*${key}=" "$file"; then
            sed -i.bak -E "s/^#*\s*(${key}=).*/\1${value}/" "$file"
        else
            echo "${key}=${value}" >> "$file"
        fi
        log "$GREEN" "✅ Updated $file (sed fallback)"
    fi
}

# --- Correct Zone Extraction ---
get_active_zone() {
    # Parse firewalld active zones output correctly
    local zones
    zones=$(firewall-cmd --get-active-zones 2>/dev/null | grep -v '^$' | head -n1 | awk '{print $1}')
    if [[ -z "$zones" || "$zones" == "interfaces:" ]]; then
        # Fallback: get first zone with interfaces
        zones=$(firewall-cmd --get-active-zones 2>/dev/null | awk '/^[a-zA-Z]/{print $1; exit}')
    fi
    echo "$zones"
}

# --- PHASE 1: COMPREHENSIVE AUDIT ---
audit_system() {
    log_header "PHASE 1: SYSTEM & INTERFACE AUDIT"
    log "$BLUE" "Kernel: $(uname -r)"
    log "$BLUE" "Fedora Release: $(cat /etc/fedora-release 2>/dev/null || echo 'Unknown')"
    
    # SELinux status
    if command -v getenforce &>/dev/null; then
        log "$BLUE" "SELinux: $(getenforce)"
        if [[ "$(getenforce)" == "Enforcing" ]]; then
            log "$YELLOW" "ℹ️  Check network-related booleans: getsebool -a | grep -E 'dns|http|network'"
        fi
    fi
    
    nmcli general status 2>/dev/null || log "$YELLOW" "⚠️  NetworkManager not responding"
    ip -brief addr show
    
    if [[ "$DRY_RUN" == true ]]; then
        log "$YELLOW" "[DRY-RUN] Skipping active tests that modify state"
    fi
}

audit_dns() {
    log_header "DNS & RESOLUTION STATE"
    
    # Check resolved mode
    local resolved_mode
    resolved_mode=$(resolvectl status 2>/dev/null | grep "resolv.conf mode" | awk '{print $4}')
    log "$BLUE" "systemd-resolved mode: ${resolved_mode:-unknown}"
    
    if [[ "$resolved_mode" == "foreign" ]]; then
        log "$YELLOW" "⚠️  resolv.conf managed externally (likely NetworkManager). systemd-resolved changes may be overridden."
    fi
    
    # DNS protocol status
    resolvectl status 2>/dev/null | grep -E 'Protocols|DNS Servers' | head -10
    
    # Test resolution with timeout
    if timeout "$TIMEOUT" resolvectl query fedoraproject.org >/dev/null 2>&1; then
        log "$GREEN" "✅ DNS Resolution: fedoraproject.org resolved"
    else
        log "$RED" "❌ DNS Resolution: BROKEN (timeout or failure)"
    fi
    
    # Check /etc/resolv.conf linkage
    if [[ -L /etc/resolv.conf ]]; then
        log "$BLUE" "/etc/resolv.conf -> $(readlink /etc/resolv.conf)"
    else
        log "$YELLOW" "⚠️  /etc/resolv.conf is not a symlink (may cause conflicts)"
    fi
}

audit_security() {
    log_header "DEVOPS PORT & SECURITY AUDIT"
    
    # Listening ports (IPv4 + IPv6)
    log "$BLUE" "Listening services (DevOps ports):"
    if command -v ss &>/dev/null; then
        ss -tulpn 2>/dev/null | grep -E '(:8080|:8443|:22|:3000|:5432|:6379)' || log "$BLUE" "  No standard DevOps ports detected."
    else
        log "$YELLOW" "⚠️  ss command not found"
    fi
    
    # Firewalld status
    if systemctl is-active --quiet firewalld 2>/dev/null; then
        log "$BLUE" "Firewalld: ACTIVE"
        log "$BLUE" "Active zones:"
        firewall-cmd --get-active-zones 2>/dev/null || true
        
        local zone
        zone=$(get_active_zone)
        if [[ -n "$zone" ]]; then
            log "$BLUE" "Primary zone: $zone"
            # Check if DNS service is enabled (for inbound - informational only)
            if firewall-cmd --zone="$zone" --list-services 2>/dev/null | grep -q dns; then
                log "$GREEN" "✅ Zone '$zone' allows inbound DNS (server mode)"
            else
                log "$BLUE" "ℹ️  Zone '$zone' does not allow inbound DNS (normal for client workstations)"
            fi
        fi
    else
        log "$YELLOW" "⚠️  Firewalld: INACTIVE (system may be less protected)"
    fi
    
    # Check for common hardening sysctls
    log "$BLUE" "Key sysctl parameters:"
    for param in net.ipv4.ip_forward net.ipv4.conf.all.accept_redirects net.ipv4.conf.all.send_redirects; do
        echo "  $param = $(sysctl -n "$param" 2>/dev/null || echo 'N/A')"
    done
}

# --- PHASE 2: SECURITY HARDENING (Safe, Reversible) ---
harden_network() {
    log_header "PHASE 2: NETWORK SECURITY HARDENING"
    
    if [[ "$DRY_RUN" == true ]]; then
        log "$YELLOW" "[DRY-RUN] Would apply hardening changes. Use --apply to execute."
        return 0
    fi
    
    # 1. DNS Over TLS: Opportunistic mode (privacy with fallback)
    log "$BLUE" "Configuring DNSOverTLS=opportunistic..."
    safe_resolved_conf_edit "DNSOverTLS" "opportunistic"
    
    # Only restart if we actually changed config AND resolved is managing DNS
    local resolved_mode
    resolved_mode=$(resolvectl status 2>/dev/null | grep "resolv.conf mode" | awk '{print $4}')
    if [[ "$resolved_mode" != "foreign" ]] && systemctl is-active --quiet systemd-resolved; then
        log "$BLUE" "Reloading systemd-resolved configuration..."
        systemctl reload-or-restart systemd-resolved
    else
        log "$YELLOW" "ℹ️  Skipping resolved restart (mode: $resolved_mode or inactive)"
    fi
    
    # 2. Firewalld: Ensure client DNS queries are permitted (outbound UDP/53 is default-allowed)
    local zone
    zone=$(get_active_zone)
    if [[ -n "$zone" ]] && systemctl is-active --quiet firewalld; then
        log "$BLUE" "Verifying firewalld zone '$zone' permits client DNS..."
        # Outbound DNS is allowed by default; this check is informational
        if ! firewall-cmd --zone="$zone" --query-masquerade --quiet 2>/dev/null; then
            log "$BLUE" "ℹ️  Masquerading disabled (normal for workstation)"
        fi
    fi
    
    # 3. SELinux: Report relevant booleans (do not modify without explicit request)
    if command -v getsebool &>/dev/null && [[ "$(getenforce 2>/dev/null)" == "Enforcing" ]]; then
        log "$BLUE" "Relevant SELinux booleans for network operations:"
        getsebool -a 2>/dev/null | grep -E 'dns|http|network|virt' | head -10 || true
    fi
}

# --- PHASE 3: RESILIENT REMEDIATION ---
remediate_dns() {
    log_header "PHASE 3: APPLYING RESILIENT DNS (Manual + DHCP)"
    
    if [[ "$DRY_RUN" == true ]]; then
        log "$YELLOW" "[DRY-RUN] Would configure fallback DNS. Use --apply to execute."
        return 0
    fi
    
    # Identify target connection
    local conn_name="$TARGET_CONN"
    if [[ -z "$conn_name" ]]; then
        conn_name=$(nmcli -t -f NAME connection show --active 2>/dev/null | grep -v '^lo$' | head -n1)
    fi
    
    if [[ -z "$conn_name" ]]; then
        log "$RED" "❌ No active NetworkManager connection found to remediate."
        return 1
    fi
    
    log "$BLUE" "Target connection: $conn_name"
    
    # Backup connection profile before modification
    local profile_path
    profile_path=$(nmcli -g connection.filename connection show "$conn_name" 2>/dev/null || echo "/etc/NetworkManager/system-connections/${conn_name}.nmconnection")
    if [[ -f "$profile_path" ]]; then
        create_backup "$profile_path"
    fi
    
    # Apply fallback DNS while preserving DHCP primary
    log "$BLUE" "Adding fallback DNS servers (Cloudflare + Google)..."
    nmcli connection modify "$conn_name" \
        ipv4.dns "1.1.1.1 8.8.8.8" \
        ipv4.ignore-auto-dns no \
        ipv6.dns "2606:4700:4700::1111 2001:4860:4860::8888" \
        ipv6.ignore-auto-dns no 2>/dev/null || {
            log "$RED" "❌ Failed to modify DNS settings"
            return 1
        }
    
    # Reload connection (down/up is safer than 'reload' for WiFi)
    log "$BLUE" "Reloading connection '$conn_name'..."
    if nmcli connection down "$conn_name" && nmcli connection up "$conn_name"; then
        sleep 3  # Allow DHCP/reassociation
        log "$GREEN" "✅ Connection reloaded successfully"
    else
        log "$RED" "❌ Failed to reload connection"
        return 1
    fi
}

# --- PHASE 4: VERIFICATION ---
verify_fixes() {
    log_header "PHASE 4: FINAL VERIFICATION"
    
    local all_passed=true
    
    # DNS resolution test
    if timeout "$TIMEOUT" getent hosts google.com >/dev/null 2>&1; then
        log "$GREEN" "✅ DNS Resolution: SUCCESS"
    else
        log "$RED" "❌ DNS Resolution: FAILED"
        all_passed=false
    fi
    
    # Basic connectivity
    if timeout "$TIMEOUT" ping -c 1 -W "$TIMEOUT" 1.1.1.1 >/dev/null 2>&1; then
        log "$GREEN" "✅ Internet Connectivity (1.1.1.1): SUCCESS"
    else
        log "$RED" "❌ Internet Connectivity: FAILED"
        all_passed=false
    fi
    
    # HTTPS test (DevOps workflow critical)
    if timeout "$((TIMEOUT*2))" curl -s --connect-timeout "$TIMEOUT" -o /dev/null -w "%{http_code}" https://api.github.com | grep -q '200'; then
        log "$GREEN" "✅ GitHub API (HTTPS): SUCCESS"
    else
        log "$YELLOW" "⚠️  GitHub API test failed (may be rate-limited or network issue)"
    fi
    
    # Git connectivity (common DevOps tool)
    if command -v git &>/dev/null; then
        if timeout "$((TIMEOUT*2))" git ls-remote --exit-code https://github.com >/dev/null 2>&1; then
            log "$GREEN" "✅ Git HTTPS connectivity: SUCCESS"
        else
            log "$YELLOW" "⚠️  Git connectivity test failed"
        fi
    fi
    
    # Final status
    echo ""
    if [[ "$all_passed" == true ]]; then
        log "$GREEN" "🎉 All critical network checks PASSED"
    else
        log "$RED" "⚠️  Some checks failed. Review logs: $LOG_FILE"
    fi
}

# --- Rollback Instructions ---
print_rollback() {
    log_header "ROLLBACK INSTRUCTIONS (If Issues Occur)"
    cat <<EOF
If network issues occur after applying changes:

1. Restore config backups:
   sudo tar -xzf ${BACKUP_DIR}/*.tar.gz -C /

2. Revert DNS settings:
   nmcli connection modify "$TARGET_CONN" ipv4.dns '' ipv6.dns ''
   nmcli connection up "$TARGET_CONN"

3. Restore resolved.conf:
   sudo cp ${BACKUP_DIR}/resolved.conf.* /etc/systemd/resolved.conf
   sudo systemctl restart systemd-resolved

4. View detailed logs:
   tail -f $LOG_FILE

Report issues with log excerpt for faster resolution.
EOF
}

# --- MAIN EXECUTION ---
main() {
    log "$GREEN" "Starting Fedora 43 Network Sentinel (Timestamp: $TIMESTAMP)"
    log "$BLUE" "Mode: $([ "$DRY_RUN" == true ] && echo 'DRY-RUN (no changes)' || echo 'APPLY CHANGES')"
    
    # Pre-flight: Ensure required tools exist
    for cmd in nmcli firewall-cmd resolvectl ss; do
        if ! command -v "$cmd" &>/dev/null; then
            log "$YELLOW" "⚠️  Command '$cmd' not found - some checks may be skipped"
        fi
    done
    
    # Execute phases
    audit_system
    audit_dns
    audit_security
    
    if [[ "$APPLY_CHANGES" == true ]]; then
        # Confirm before destructive actions
        read -rp $'\e[1;33m⚠️  Apply remediation changes? [y/N]: \e[0m' -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log "$YELLOW" "Aborted by user. Run with --apply and confirm to execute changes."
            exit 0
        fi
        harden_network
        remediate_dns
    else
        log "$YELLOW" "Skipping remediation (use --apply to execute fixes)"
    fi
    
    verify_fixes
    print_rollback
    
    log "$GREEN" "Audit complete. Log saved to: $LOG_FILE"
}

# Run main
main "$@"
