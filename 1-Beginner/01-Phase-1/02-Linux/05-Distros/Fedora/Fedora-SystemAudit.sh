#!/bin/bash
# ==============================================================================
# Script Name: Fedora-SecurityAudit.sh
# Target: Fedora 43 (Optimized for DNF5)
# Role: Comprehensive System Auditor & Vulnerability Scanner
# ==============================================================================

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
    ausearch -m AUTH_LOGIN -ts yesterday -i | grep "res=failed" | wc -l | xargs echo "Failed Logins (24h):" | tee -a "$REPORT"
else
    echo "Auditd Status: INACTIVE (Recommendation: Enable for real-time monitoring)" | tee -a "$REPORT"
fi

# --- 3. External Vulnerability Scan (Lynis) ---
# Lynis is the gold standard for host-based auditing on Linux.
echo -e "\n[+] COMPONENT: DEEP SYSTEM SCAN (LYNIS)" | tee -a "$REPORT"
if ! command -v lynis &> /dev/null; then
    echo "Lynis not found. Installing..."
    dnf5 install -y lynis
fi

echo "Running Lynis Audit (Summary Mode)..."
# We run it with --quick to bypass user input and log findings
lynis audit system --quick --report-file "$LOG_DIR/lynis-report.dat" > /dev/null

# Extract Warnings and Suggestions for the report
grep "^warning\[\]" /var/log/lynis-report.dat | tee -a "$REPORT"
grep "^suggestion\[\]" /var/log/lynis-report.dat | tee -a "$REPORT"

# --- 4. User & Access Audit ---
echo -e "\n[+] COMPONENT: USER ACCOUNTS" | tee -a "$REPORT"
echo "Accounts with empty passwords:" | tee -a "$REPORT"
awk -F: '($2 == "") {print $1}' /etc/shadow | tee -a "$REPORT"
echo "Sudoers with NOPASSWD access:" | tee -a "$REPORT"
grep -r "NOPASSWD" /etc/sudoers /etc/sudoers.d/ | tee -a "$REPORT"

# --- Final Summary ---
echo -e "\n==========================================================" | tee -a "$REPORT"
echo "Audit Complete. Full report available at: $REPORT"
echo "=========================================================="
