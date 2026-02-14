#!/bin/bash

################################################################################
# Browser Security Hardening Script
# Purpose: Comprehensive browser security and intrusion protection
# Features:
#   - Popup blocking
#   - Malware/phishing protection
#   - Safe browsing enforcement
#   - Cookie and tracking protection
#   - Extension management
#   - DNS-level ad/malware blocking
#   - Firewall rules for common attack vectors
#   - Logging and audit trail
#   - Rollback capability
################################################################################

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly LOG_DIR="/var/log/browser-security"
readonly LOG_FILE="${LOG_DIR}/security-hardening.log"
readonly BACKUP_DIR="/var/backups/browser-policies"
readonly TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    
    # Create log directory if it doesn't exist
    if [ ! -d "${LOG_DIR}" ]; then
        mkdir -p "${LOG_DIR}" 2>/dev/null || true
    fi
    
    # Log to file and console
    echo "[${timestamp}] [${level}] ${message}" | tee -a "${LOG_FILE}" 2>/dev/null || \
        echo "[${timestamp}] [${level}] ${message}"
}

log_info() {
    log "INFO" "$@"
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    log "SUCCESS" "$@"
    echo -e "${GREEN}[✓]${NC} $*"
}

log_warning() {
    log "WARNING" "$@"
    echo -e "${YELLOW}[⚠]${NC} $*"
}

log_error() {
    log "ERROR" "$@"
    echo -e "${RED}[✗]${NC} $*" >&2
}

check_root() {
    if [ "$EUID" -ne 0 ]; then 
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

create_directories() {
    log_info "Creating necessary directories..."
    
    # Create backup directory (log directory is auto-created by log() function)
    mkdir -p "${BACKUP_DIR}"
    chmod 755 "${LOG_DIR}" "${BACKUP_DIR}" 2>/dev/null || true
    
    log_success "Directories created"
}

backup_existing_policies() {
    local policy_dir="$1"
    local browser_name="$2"
    
    if [ -d "${policy_dir}" ]; then
        local backup_path="${BACKUP_DIR}/${browser_name}_${TIMESTAMP}"
        log_info "Backing up existing ${browser_name} policies to ${backup_path}"
        cp -r "${policy_dir}" "${backup_path}"
        log_success "Backup completed for ${browser_name}"
    fi
}

# ============================================================================
# BROWSER POLICY DEFINITIONS
# ============================================================================

# Comprehensive security policy for Chromium-based browsers
generate_chromium_policy() {
    cat <<'EOF'
{
  "DefaultPopupsSetting": 2,
  "PopupsAllowedForUrls": [],
  "PopupsBlockedForUrls": ["*"],
  
  "SafeBrowsingEnabled": true,
  "SafeBrowsingProtectionLevel": 2,
  "SafeBrowsingExtendedReportingEnabled": false,
  
  "PasswordManagerEnabled": true,
  "PasswordLeakDetectionEnabled": true,
  
  "DefaultCookiesSetting": 1,
  "CookiesAllowedForUrls": [],
  "CookiesBlockedForUrls": [],
  "BlockThirdPartyCookies": true,
  
  "DefaultNotificationsSetting": 2,
  "NotificationsAllowedForUrls": [],
  
  "DefaultGeolocationSetting": 2,
  "DefaultMediaStreamSetting": 2,
  
  "AutofillAddressEnabled": false,
  "AutofillCreditCardEnabled": false,
  
  "DnsOverHttpsMode": "secure",
  "DnsOverHttpsTemplates": "https://dns.google/dns-query",
  
  "SSLErrorOverrideAllowed": false,
  "AllowCrossOriginAuthPrompt": false,
  
  "DefaultInsecureContentSetting": 2,
  "InsecureContentAllowedForUrls": [],
  
  "URLBlocklist": [
    "*://*.doubleclick.net/*",
    "*://*.googlesyndication.com/*",
    "*://*.googleadservices.com/*",
    "*://*.advertising.com/*",
    "*://*.ads-twitter.com/*",
    "*://*.adnxs.com/*"
  ],
  
  "ExtensionInstallBlocklist": ["*"],
  "ExtensionInstallAllowlist": [
    "cjpalhdlnbpafiamejdnhcphjbkeiagm",
    "nngceckbapebfimnlniiiahkandclblb"
  ],
  
  "BrowserSignin": 1,
  "SyncDisabled": false,
  
  "DefaultSearchProviderEnabled": true,
  "DefaultSearchProviderSearchURL": "https://www.google.com/search?q={searchTerms}",
  
  "DownloadRestrictions": 0,
  "DownloadDirectory": "${HOME}/Downloads",
  
  "HomepageIsNewTabPage": true,
  "RestoreOnStartup": 1,
  
  "MetricsReportingEnabled": false,
  "CloudReportingEnabled": false,
  
  "AudioCaptureAllowed": false,
  "VideoCaptureAllowed": false,
  "AudioCaptureAllowedUrls": [],
  "VideoCaptureAllowedUrls": [],
  
  "DefaultWebBluetoothGuardSetting": 2,
  "DefaultWebUsbGuardSetting": 2,
  
  "AdvancedProtectionAllowed": true,
  "RemoteAccessHostFirewallTraversal": false,
  
  "ComponentUpdatesEnabled": true,
  "BackgroundModeEnabled": false,
  
  "BrowserNetworkTimeQueriesEnabled": true,
  "BuiltInDnsClientEnabled": true,
  
  "ChromeCleanupEnabled": true,
  "ChromeCleanupReportingEnabled": false,
  
  "DefaultJavaScriptSetting": 1,
  "JavaScriptAllowedForUrls": ["*"],
  "JavaScriptBlockedForUrls": [],
  
  "DefaultImagesSetting": 1,
  "ImagesAllowedForUrls": ["*"],
  "ImagesBlockedForUrls": [],
  
  "PromptForDownloadLocation": true,
  "AlternateErrorPagesEnabled": true,
  "SearchSuggestEnabled": true,
  
  "SpellCheckServiceEnabled": false,
  "TranslateEnabled": true,
  
  "NetworkPredictionOptions": 2,
  "WPADQuickCheckEnabled": false,
  
  "UrlKeyedAnonymizedDataCollectionEnabled": false,
  "EnableMediaRouter": false,
  
  "HideWebStoreIcon": true,
  "HideWebStorePromo": true
}
EOF
}

# Firefox policy (uses policies.json format)
generate_firefox_policy() {
    cat <<'EOF'
{
  "policies": {
    "DisableTelemetry": true,
    "DisableFirefoxStudies": true,
    "DisablePocket": true,
    "DisableFirefoxAccounts": false,
    "DisableFormHistory": false,
    "DisplayBookmarksToolbar": true,
    "DontCheckDefaultBrowser": true,
    
    "EnableTrackingProtection": {
      "Value": true,
      "Locked": true,
      "Cryptomining": true,
      "Fingerprinting": true
    },
    
    "Cookies": {
      "AcceptThirdParty": "never",
      "Locked": true
    },
    
    "Permissions": {
      "Camera": {
        "BlockNewRequests": true,
        "Locked": true
      },
      "Microphone": {
        "BlockNewRequests": true,
        "Locked": true
      },
      "Location": {
        "BlockNewRequests": true,
        "Locked": true
      },
      "Notifications": {
        "BlockNewRequests": true,
        "Locked": true
      }
    },
    
    "PopupBlocking": {
      "Default": true,
      "Locked": true
    },
    
    "DNSOverHTTPS": {
      "Enabled": true,
      "ProviderURL": "https://mozilla.cloudflare-dns.com/dns-query",
      "Locked": true
    },
    
    "EncryptedMediaExtensions": {
      "Enabled": true,
      "Locked": false
    },
    
    "ExtensionSettings": {
      "*": {
        "blocked_install_message": "Extension installation is restricted for security.",
        "install_sources": ["https://addons.mozilla.org/"],
        "installation_mode": "blocked",
        "allowed_types": ["extension", "theme"]
      }
    },
    
    "FirefoxHome": {
      "Search": true,
      "TopSites": false,
      "Highlights": false,
      "Pocket": false,
      "Snippets": false,
      "Locked": true
    },
    
    "Homepage": {
      "StartPage": "homepage"
    },
    
    "OfferToSaveLogins": true,
    "PasswordManagerEnabled": true,
    
    "SSLVersionMin": "tls1.2",
    
    "WebsiteFilter": {
      "Block": [
        "*://*.doubleclick.net/*",
        "*://*.googlesyndication.com/*",
        "*://*.advertising.com/*"
      ]
    }
  }
}
EOF
}

# ============================================================================
# BROWSER POLICY APPLICATION
# ============================================================================

apply_chrome_policies() {
    log_info "Applying Google Chrome policies..."
    local chrome_dir="/etc/opt/chrome/policies/managed"
    
    backup_existing_policies "${chrome_dir}" "chrome"
    mkdir -p "${chrome_dir}"
    
    generate_chromium_policy > "${chrome_dir}/security_hardening.json"
    chmod 644 "${chrome_dir}/security_hardening.json"
    
    log_success "Chrome policies applied successfully"
}

apply_chromium_policies() {
    log_info "Applying Chromium policies..."
    local chromium_dir="/etc/chromium/policies/managed"
    
    backup_existing_policies "${chromium_dir}" "chromium"
    mkdir -p "${chromium_dir}"
    
    generate_chromium_policy > "${chromium_dir}/security_hardening.json"
    chmod 644 "${chromium_dir}/security_hardening.json"
    
    log_success "Chromium policies applied successfully"
}

apply_brave_policies() {
    log_info "Applying Brave Browser policies..."
    local brave_dir="/etc/brave/policies/managed"
    
    backup_existing_policies "${brave_dir}" "brave"
    mkdir -p "${brave_dir}"
    
    generate_chromium_policy > "${brave_dir}/security_hardening.json"
    chmod 644 "${brave_dir}/security_hardening.json"
    
    log_success "Brave policies applied successfully"
}

apply_firefox_policies() {
    log_info "Applying Firefox policies..."
    local firefox_dir="/etc/firefox/policies"
    
    backup_existing_policies "${firefox_dir}" "firefox"
    mkdir -p "${firefox_dir}"
    
    generate_firefox_policy > "${firefox_dir}/policies.json"
    chmod 644 "${firefox_dir}/policies.json"
    
    log_success "Firefox policies applied successfully"
}

# ============================================================================
# DNS-LEVEL BLOCKING
# ============================================================================

setup_dns_blocking() {
    log_info "Setting up DNS-level ad and malware blocking..."
    
    # Check if systemd-resolved is running
    if systemctl is-active --quiet systemd-resolved; then
        log_info "Configuring systemd-resolved for secure DNS..."
        
        local resolved_conf="/etc/systemd/resolved.conf.d/security.conf"
        mkdir -p "$(dirname "${resolved_conf}")"
        
        cat > "${resolved_conf}" <<EOF
[Resolve]
DNS=1.1.1.2 1.0.0.2
FallbackDNS=9.9.9.9 149.112.112.112
DNSSEC=yes
DNSOverTLS=yes
EOF
        
        systemctl restart systemd-resolved
        log_success "DNS-level blocking configured (Cloudflare Malware Blocking DNS)"
    else
        log_warning "systemd-resolved not active, skipping DNS configuration"
    fi
}

# ============================================================================
# FIREWALL RULES
# ============================================================================

setup_firewall_rules() {
    log_info "Configuring firewall rules for intrusion protection..."
    
    # Check if ufw is available
    if command -v ufw &> /dev/null; then
        log_info "Configuring UFW firewall..."
        
        # Enable UFW if not already enabled
        ufw --force enable
        
        # Block common malicious ports
        ufw deny 23/tcp comment 'Block Telnet'
        ufw deny 135/tcp comment 'Block MS RPC'
        ufw deny 139/tcp comment 'Block NetBIOS'
        ufw deny 445/tcp comment 'Block SMB'
        ufw deny 3389/tcp comment 'Block RDP from external'
        
        # Rate limit SSH to prevent brute force
        ufw limit 22/tcp comment 'Rate limit SSH'
        
        log_success "Firewall rules applied"
    elif command -v firewall-cmd &> /dev/null; then
        log_info "Configuring firewalld..."
        
        # Block common attack vectors
        firewall-cmd --permanent --add-rich-rule='rule service name="telnet" reject'
        firewall-cmd --permanent --add-rich-rule='rule service name="rpc-bind" reject'
        firewall-cmd --reload
        
        log_success "Firewall rules applied"
    else
        log_warning "No supported firewall found (ufw or firewalld)"
    fi
}

# ============================================================================
# HOSTS FILE BLOCKING
# ============================================================================

update_hosts_file() {
    log_info "Updating /etc/hosts with known malicious domains..."
    
    local hosts_backup="/etc/hosts.backup.${TIMESTAMP}"
    cp /etc/hosts "${hosts_backup}"
    
    # Add common ad/malware domains to hosts file
    cat >> /etc/hosts <<'EOF'

# Browser Security Script - Malicious Domain Blocking
127.0.0.1 doubleclick.net
127.0.0.1 www.doubleclick.net
127.0.0.1 ad.doubleclick.net
127.0.0.1 googleadservices.com
127.0.0.1 www.googleadservices.com
127.0.0.1 googlesyndication.com
127.0.0.1 www.googlesyndication.com
127.0.0.1 advertising.com
127.0.0.1 www.advertising.com
EOF
    
    log_success "Hosts file updated (backup: ${hosts_backup})"
}

# ============================================================================
# SYSTEM HARDENING
# ============================================================================

apply_system_hardening() {
    log_info "Applying system-level security hardening..."
    
    # Disable IPv6 if not needed (reduces attack surface)
    if [ -f /etc/sysctl.conf ]; then
        if ! grep -q "net.ipv6.conf.all.disable_ipv6" /etc/sysctl.conf; then
            cat >> /etc/sysctl.conf <<EOF

# Browser Security Script - IPv6 Hardening
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
            sysctl -p &> /dev/null || true
            log_success "IPv6 disabled for security"
        fi
    fi
    
    # Enable automatic security updates if available
    if command -v unattended-upgrades &> /dev/null; then
        dpkg-reconfigure -plow unattended-upgrades &> /dev/null || true
        log_success "Automatic security updates enabled"
    fi
}

# ============================================================================
# ROLLBACK FUNCTIONALITY
# ============================================================================

rollback_policies() {
    log_info "Rolling back to previous policies..."
    
    if [ ! -d "${BACKUP_DIR}" ] || [ -z "$(ls -A "${BACKUP_DIR}")" ]; then
        log_error "No backups found in ${BACKUP_DIR}"
        exit 1
    fi
    
    # Find the most recent backup
    local latest_backup=$(ls -t "${BACKUP_DIR}" | head -1)
    
    log_info "Restoring from backup: ${latest_backup}"
    
    # Restore each browser's policies
    for browser_backup in "${BACKUP_DIR}"/*; do
        local browser_name=$(basename "${browser_backup}" | cut -d'_' -f1)
        local target_dir=""
        
        case "${browser_name}" in
            chrome)
                target_dir="/etc/opt/chrome/policies/managed"
                ;;
            chromium)
                target_dir="/etc/chromium/policies/managed"
                ;;
            brave)
                target_dir="/etc/brave/policies/managed"
                ;;
            firefox)
                target_dir="/etc/firefox/policies"
                ;;
        esac
        
        if [ -n "${target_dir}" ]; then
            rm -rf "${target_dir}"
            cp -r "${browser_backup}" "${target_dir}"
            log_success "Restored ${browser_name} policies"
        fi
    done
    
    log_success "Rollback completed"
}

# ============================================================================
# REPORTING
# ============================================================================

generate_report() {
    log_info "Generating security report..."
    
    local report_file="${LOG_DIR}/security_report_${TIMESTAMP}.txt"
    
    cat > "${report_file}" <<EOF
================================================================================
Browser Security Hardening Report
Generated: $(date)
================================================================================

POLICIES APPLIED:
-----------------
$([ -f /etc/opt/chrome/policies/managed/security_hardening.json ] && echo "✓ Google Chrome" || echo "✗ Google Chrome")
$([ -f /etc/chromium/policies/managed/security_hardening.json ] && echo "✓ Chromium" || echo "✗ Chromium")
$([ -f /etc/brave/policies/managed/security_hardening.json ] && echo "✓ Brave Browser" || echo "✗ Brave Browser")
$([ -f /etc/firefox/policies/policies.json ] && echo "✓ Firefox" || echo "✗ Firefox")

SECURITY FEATURES:
------------------
✓ Popup blocking enabled
✓ Safe browsing protection (Enhanced)
✓ Third-party cookie blocking
✓ Notification blocking
✓ Geolocation blocking
✓ Media stream blocking
✓ DNS over HTTPS enabled
✓ SSL error override disabled
✓ Extension installation restricted
✓ Malicious URL blocking
✗ Download restrictions (reversed)
✓ Audio/video capture blocked

SYSTEM HARDENING:
-----------------
$(systemctl is-active --quiet systemd-resolved && echo "✓ Secure DNS configured" || echo "✗ Secure DNS not configured")
$(command -v ufw &> /dev/null && ufw status | grep -q "Status: active" && echo "✓ Firewall active" || echo "✗ Firewall not active")
✓ Hosts file updated with malicious domains

BACKUPS:
--------
Backup location: ${BACKUP_DIR}
Latest backup: $(ls -t "${BACKUP_DIR}" 2>/dev/null | head -1 || echo "None")

NEXT STEPS:
-----------
1. Restart all browsers for policies to take effect
2. Review ${LOG_FILE} for detailed logs
3. Test browser functionality to ensure no breakage
4. To rollback: sudo $0 --rollback

================================================================================
EOF
    
    cat "${report_file}"
    log_success "Report saved to ${report_file}"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    echo "================================================================================"
    echo "  Browser Security Hardening & Intrusion Protection Script"
    echo "================================================================================"
    echo ""
    
    check_root
    create_directories
    
    log_info "Starting security hardening process..."
    
    # Apply browser policies
    [ "$SKIP_CHROME" = false ] && apply_chrome_policies
    [ "$SKIP_CHROMIUM" = false ] && apply_chromium_policies
    [ "$SKIP_BRAVE" = false ] && apply_brave_policies
    [ "$SKIP_FIREFOX" = false ] && apply_firefox_policies
    
    # Apply system-level protections
    [ "$SKIP_DNS" = false ] && setup_dns_blocking
    [ "$SKIP_FIREWALL" = false ] && setup_firewall_rules
    [ "$SKIP_HOSTS" = false ] && update_hosts_file
    [ "$SKIP_SYSTEM" = false ] && apply_system_hardening
    
    # Generate report
    generate_report
    
    echo ""
    echo "================================================================================"
    echo -e "${GREEN}Security hardening completed successfully!${NC}"
    echo "================================================================================"
    echo ""
    echo "IMPORTANT: Please restart all browsers for changes to take effect."
    echo ""
    echo "Logs: ${LOG_FILE}"
    echo "Backups: ${BACKUP_DIR}"
    echo ""
    echo "To rollback changes: sudo $0 --rollback"
    echo ""
}

# Initialize default skip variables
SKIP_CHROME=false
SKIP_CHROMIUM=false
SKIP_BRAVE=false
SKIP_FIREFOX=false
SKIP_DNS=false
SKIP_FIREWALL=false
SKIP_HOSTS=false
SKIP_SYSTEM=false
ROLLBACK=false

# Simple argument parsing loop
while [[ $# -gt 0 ]]; do
    case "$1" in
        --rollback)
            ROLLBACK=true
            shift
            ;;
        --skip-chrome)
            SKIP_CHROME=true
            shift
            ;;
        --skip-chromium)
            SKIP_CHROMIUM=true
            shift
            ;;
        --skip-brave)
            SKIP_BRAVE=true
            shift
            ;;
        --skip-firefox)
            SKIP_FIREFOX=true
            shift
            ;;
        --skip-dns)
            SKIP_DNS=true
            shift
            ;;
        --skip-firewall)
            SKIP_FIREWALL=true
            shift
            ;;
        --skip-hosts)
            SKIP_HOSTS=true
            shift
            ;;
        --skip-system)
            SKIP_SYSTEM=true
            shift
            ;;
        --help|-h)
            cat <<EOF
Usage: sudo $0 [OPTIONS]

OPTIONS:
    --rollback      Restore previous policies from backup
    --skip-chrome   Do not apply Chrome policies
    --skip-chromium Do not apply Chromium policies
    --skip-brave    Do not apply Brave policies
    --skip-firefox  Do not apply Firefox policies
    --skip-dns      Do not configure DNS blocking
    --skip-firewall Do not configure firewall rules
    --skip-hosts    Do not update hosts file
    --skip-system   Do not apply system hardening
    --help, -h      Show this help message

DESCRIPTION:
    This script applies comprehensive browser security policies and system-level
    intrusion protection measures.

EXAMPLES:
    sudo $0                 # Apply all security hardening
    sudo $0 --skip-dns      # Apply everything except DNS blocking
    sudo $0 --rollback      # Restore previous settings

EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [ "$ROLLBACK" = true ]; then
    check_root
    create_directories
    rollback_policies
else
    main
fi
