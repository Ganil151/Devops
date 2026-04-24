#!/bin/bash
# ==============================================================================
# Script Name: Fedora-SecurityAudit.sh
# Target: Fedora 43 (Optimized for DNF5)
# Role: Comprehensive System Auditor & Vulnerability Scanner
# ==============================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root to perform a full audit. Aborting."
    exit 1
fi

LOG_DIR="/var/log/sys_audit"
mkdir -p "$LOG_DIR"
REPORT="$LOG_DIR/audit_report_$(date +%F).txt"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# --- Header ---
echo "==========================================================" | tee -a "$REPORT"
echo "  FEDORA 43 SYSTEM AUDIT - $TIMESTAMP" | tee -a "$REPORT"
echo "==========================================================" | tee -a "$REPORT"

# --- 1. Package Vulnerability Scan (DNF5) ---
echo -e "\n[+] COMPONENT: PACKAGE MANAGEMENT (DNF5)" | tee -a "$REPORT"
echo "Checking for security advisories and CVEs..." | tee -a "$REPORT"
# dnf5 has built-in security filtering
dnf5 advisory list --security | tee -a "$REPORT"
dnf5 updateinfo list security installed | tee -a "$REPORT"

# --- 2. System Auditing (auditd) ---
echo -e "\n[+] COMPONENT: KERNEL & AUDIT DAEMON" | tee -a "$REPORT"
if systemctl is-active --quiet auditd; then
    echo "Auditd Status: ACTIVE" | tee -a "$REPORT"
    # Summarize login failures from the last 24 hours
    FAILED_LOGINS=$(ausearch -m USER_LOGIN -ts yesterday -i --raw | grep -c "res=failed" || true)
    echo "Failed Logins (24h): $FAILED_LOGINS" | tee -a "$REPORT"
else
    echo "Auditd Status: INACTIVE (Recommendation: Enable for real-time monitoring)" | tee -a "$REPORT"
fi

# --- 3. External Vulnerability Scan (Lynis) ---
# Lynis is the gold standard for host-based auditing on Linux.
echo -e "\n[+] COMPONENT: DEEP SYSTEM SCAN (LYNIS)" | tee -a "$REPORT"
if ! command -v lynis &> /dev/null; then
    echo "Lynis not found. Installing for deep system audit..." | tee -a "$REPORT"
    dnf5 install -y lynis
fi

echo "Running Lynis Audit (logging findings to report)..." | tee -a "$REPORT"
# We run it with --quick to bypass user input and log findings to its own report file.
lynis audit system --quick --report-file "$LOG_DIR/lynis-report.dat" > /dev/null

# Extract Warnings and Suggestions for the report
grep "^warning\[\]" /var/log/lynis-report.dat | tee -a "$REPORT"
grep "^suggestion\[\]" /var/log/lynis-report.dat | tee -a "$REPORT"

# --- 4. User & Access Audit ---
echo -e "\n[+] COMPONENT: USER ACCOUNTS" | tee -a "$REPORT"
echo "Accounts with empty passwords:" | tee -a "$REPORT"
awk -F: '($2 == "") {print $1}' /etc/shadow | tee -a "$REPORT"
echo "Sudoers with NOPASSWD access (excluding comments):" | tee -a "$REPORT"
grep -r --include='*' "NOPASSWD" /etc/sudoers.d/ /etc/sudoers | grep -v '^#' | tee -a "$REPORT" || echo "  None found." | tee -a "$REPORT"

# --- Final Summary ---
echo -e "\n==========================================================" | tee -a "$REPORT"
echo "Audit Complete. Full reports available in: $LOG_DIR"
echo "=========================================================="
