#!/bin/bash
# ==============================================================================
# Script Name: Fedora-SelfHealing-Audit-v5.sh
# Target: Fedora 43+ (DNF5 High-Compatibility)
# ==============================================================================

set -uo pipefail
IFS=$'\n\t'

# --- Colors ---
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

# --- Configuration ---
LOG_DIR="/var/log/sys_audit"
REPORT="$LOG_DIR/audit_report_$(date +%F).log"
ERROR_LOG="$LOG_DIR/error_healing_$(date +%F).log"
AUTO_FIX=false

# --- Root Check ---
[[ $EUID -ne 0 ]] && echo -e "${RED}Run as root!${NC}" && exit 1

# --- Logic Fix for Logging ---
mkdir -p "$LOG_DIR"
touch "$REPORT" "$ERROR_LOG"

# Argument Parsing
while getopts "a" flag; do
    case "${flag}" in
        a) AUTO_FIX=true ;;
    esac
done

# Logging helper
log_msg() {
    local color=$1; local prefix=$2; local msg=$3
    echo -e "${color}[${prefix}]${NC} ${msg}" | tee -a "$REPORT"
}

# ==============================================================================
# UPDATED: DNF5 PLUGIN RESOLVER
# ==============================================================================
ensure_dnf5_plugins() {
    echo -e "\n${BLUE}--- [PRE-FLIGHT] DNF5 PLUGINS ---${NC}"
    
    # Check if verify is actually working
    if ! dnf5 help verify &>/dev/null; then
        log_msg "$YELLOW" "WARN" "Verify command missing. Trying to force-install extras..."
        if [[ "$AUTO_FIX" == true ]]; then
            # We try the most likely package names for F41-F43
            dnf5 install -y dnf5-plugins dnf5-plugin-extras dnf5-plugins-extras --skip-unavailable 2>/dev/null
            
            # Re-check
            if dnf5 help verify &>/dev/null; then
                log_msg "$GREEN" "OK" "Plugins installed successfully."
            else
                log_msg "$RED" "FAIL" "Could not install verify plugin. Using RPM fallback instead."
            fi
        fi
    else
        log_msg "$GREEN" "OK" "DNF5 verify command is ready."
    fi
}

# ==============================================================================
# MODULES
# ==============================================================================
audit_packages() {
    echo -e "\n${BLUE}--- [MODULE 1] PACKAGES ---${NC}"
    
    # 1. Security Check
    log_msg "$BLUE" "INFO" "Checking security updates..."
    dnf5 check-update --security --quiet > /dev/null 2>&1
    [[ $? -eq 100 ]] && log_msg "$YELLOW" "WARN" "Security updates available." || log_msg "$GREEN" "OK" "System secure."

    # 2. Integrity (Healed)
    log_msg "$BLUE" "INFO" "Verifying system integrity..."
    if dnf5 help verify &>/dev/null; then
        dnf5 verify | head -n 5
    else
        # Reliable fallback
        log_msg "$CYAN" "HEAL" "Using RPM fallback for integrity check."
        rpm --verify --all | grep -v '^c' | head -n 5
    fi

    # 3. Repolist (Fixed for DNF5)
    echo -e "\n${BLUE}--- Repository Status ---${NC}"
    # In some DNF5 versions, --info is gone. We use the standard repolist.
    dnf5 repolist | head -n 10
}

audit_ssh() {
    echo -e "\n${BLUE}--- [MODULE 2] SSH ---${NC}"
    local conf="/etc/ssh/sshd_config"
    if [[ -f "$conf" ]]; then
        if grep -q "^PermitRootLogin yes" "$conf"; then
            log_msg "$RED" "CRITICAL" "Root Login Enabled!"
            if [[ "$AUTO_FIX" == true ]]; then
                sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' "$conf"
                systemctl reload sshd && log_msg "$GREEN" "FIXED" "Root login disabled."
            fi
        else
            log_msg "$GREEN" "OK" "SSH Root access is restricted."
        fi
    fi
}

# ==============================================================================
# MAIN
# ==============================================================================
echo -e "${BLUE}=========================================================="
echo -e "  FEDORA AUDIT v5 - $(date)"
echo -e "==========================================================${NC}"

ensure_dnf5_plugins
audit_packages
audit_ssh

echo -e "\n${BLUE}=========================================================="
echo -e "  AUDIT COMPLETE. Report: $REPORT"
echo -e "==========================================================${NC}"