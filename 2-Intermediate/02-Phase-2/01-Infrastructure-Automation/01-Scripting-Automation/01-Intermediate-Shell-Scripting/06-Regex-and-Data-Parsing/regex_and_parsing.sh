#!/usr/bin/env bash
# Topic: Regex and Data Parsing
# Description: Demonstrates the "Triple Threat" (Grep, Sed, Awk) for processing logs.

set -euo pipefail

# Create a sample log file for processing
CAT_LOG="app.log"
cat <<EOF > "$CAT_LOG"
2024-01-01 10:00:01 INFO user=alice action=login ip=192.168.1.5 status=success
2024-01-01 10:05:22 WARN user=bob action=upload ip=10.0.0.22 status=denied
2024-01-01 10:10:45 INFO user=charlie action=logout ip=172.16.0.4 status=success
2024-01-01 10:15:10 ERROR user=dave action=delete ip=192.168.1.10 status=failed
EOF

echo "📝 Processing $CAT_LOG..."

# 1. GREP: Filter by Level (Extended Regex)
echo "--- Errors and Warnings ---"
grep -E "ERROR|WARN" "$CAT_LOG"

# 2. SED: Mask IP addresses for privacy
echo -e "\n--- Masked IPs (SED) ---"
sed -E 's/ip=[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/ip=***.***.***.***/' "$CAT_LOG"

# 3. AWK: Extract specific columns (User and Status)
# Here we use '=' as a separator or process fields
echo -e "\n--- User Status Report (AWK) ---"
awk '{ 
    # Extract user and status using split or field positioning
    # Simple whitespace split for this log format
    user=$3; 
    status=$6; 
    print "👤 " user " | 🏷️ " status 
}' "$CAT_LOG" | sed 's/user=//; s/status=//'

# Cleanup
rm -f "$CAT_LOG"
