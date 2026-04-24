#!/bin/bash

#############################################################################
# Script: permission-analyzer.sh
# Description: Audits file permissions, SUID/SGID binaries, and world-writables
# Author: Senior DevOps Engineer
# Version: 1.0 (Golden Standard)
#############################################################################

set -euo pipefail

# Output format
JSON_OUTPUT=false
if [[ "${1:-}" == "--json" ]]; then
    JSON_OUTPUT=true
fi

# Colors
RED='\033[0;31m'
NC='\033[0m'

if [ "$JSON_OUTPUT" = false ]; then
    echo "========================================"
    echo "   PERMISSION SECURITY AUDIT"
    echo "========================================"
fi

# 1. World Writable Files
WORLD_WRITABLE=$(find / -xdev -type f -perm -0002 -print 2>/dev/null)
WW_COUNT=$(echo "$WORLD_WRITABLE" | grep -c "/" || echo "0")

# 2. SUID/SGID Binaries
SUID_FILES=$(find / -xdev -type f \( -perm -4000 -o -perm -2000 \) -print 2>/dev/null)
SUID_COUNT=$(echo "$SUID_FILES" | grep -c "/" || echo "0")

# 3. Unowned Files
UNOWNED=$(find / -xdev \( -nouser -o -nogroup \) -print 2>/dev/null)
UNOWNED_COUNT=$(echo "$UNOWNED" | grep -c "/" || echo "0")

# 4. Root SSH Key Permissions
SSH_PERMS="Check Manual"
if [ -d "/root/.ssh" ]; then
    SSH_PERMS=$(ls -ld /root/.ssh | awk '{print $1}')
fi

if [ "$JSON_OUTPUT" = true ]; then
    # JSON Output
    cat <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "metrics": {
    "world_writable_count": $WW_COUNT,
    "suid_sgid_count": $SUID_COUNT,
    "unowned_files_count": $UNOWNED_COUNT
  },
  "root_ssh_perms": "$SSH_PERMS",
  "details": {
    "world_writable": [
      $(echo "$WORLD_WRITABLE" | head -n 10 | awk '{printf "\"%s\",", $0}' | sed 's/,$//')
    ],
    "suid_sgid_sample": [
      $(echo "$SUID_FILES" | head -n 10 | awk '{printf "\"%s\",", $0}' | sed 's/,$//')
    ]
  }
}
EOF
else
    # Console Output
    echo -e "\n[1] World Writable Files: $WW_COUNT"
    if [ "$WW_COUNT" -gt 0 ]; then
        echo -e "${RED}Warning: Found world writable files! Top 5:${NC}"
        echo "$WORLD_WRITABLE" | head -n 5 | awk '{print "  " $0}'
    fi

    echo -e "\n[2] SUID/SGID Binaries: $SUID_COUNT"
    if [ "$SUID_COUNT" -gt 0 ]; then
        echo "  Sample (Top 5):"
        echo "$SUID_FILES" | head -n 5 | awk '{print "  " $0}'
    fi

    echo -e "\n[3] Unowned Files: $UNOWNED_COUNT"
    if [ "$UNOWNED_COUNT" -gt 0 ]; then
        echo -e "${RED}Warning: Found unowned files!${NC}"
        echo "$UNOWNED" | head -n 5 | awk '{print "  " $0}'
    fi

    echo -e "\n[4] Root SSH Directory Permissions"
    echo "  /root/.ssh: $SSH_PERMS"
    if [[ "$SSH_PERMS" != "drwx------" && "$SSH_PERMS" != "Check Manual" ]]; then
         echo -e "${RED}  WARNING: /root/.ssh should be drwx------${NC}"
    fi
fi
