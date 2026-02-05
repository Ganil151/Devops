#!/usr/bin/env bash
# Topic: Advanced I/O and Logging
# Description: Demonstrates professional data plumbing, stderr redirection, and FD management.

set -euo pipefail

LOG_FILE="audit.log"
ERR_FILE="error.log"

# Clean up previous runs
rm -f "$LOG_FILE" "$ERR_FILE"

# 1. Redirection Pattern: Stdout to log, Stderr to error file
echo "🚀 Starting Deployment..." > "$LOG_FILE"

# 2. Redirecting specific commands
# &> redirects both stdout and stderr (Bash specific)
ls /root &> "$ERR_FILE" || echo "⚠️ Non-critical error caught: Unauthorized access to /root (Check $ERR_FILE)"

# 3. Using 'tee' to log and display at the same time
echo "Step 1: Installing dependencies..." | tee -a "$LOG_FILE"

# 4. Advanced: File Descriptors (3-9)
# Opening FD 3 for custom logging
exec 3>>"$LOG_FILE"

echo "Step 2: Configuring Database..." >&3
echo "Step 3: Starting Service..." >&3

# Closing FD 3
exec 3>&-

echo "-----------------------------------"
echo "✅ Operational Audit complete."
echo "View logs with: cat $LOG_FILE"
echo "View errors with: cat $ERR_FILE"
