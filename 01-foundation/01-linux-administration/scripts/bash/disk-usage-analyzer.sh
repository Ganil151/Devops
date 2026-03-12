#!/bin/bash

#############################################################################
# Script: disk-usage-analyzer.sh
# Description: Visual disk usage analyzer and cleanup helper
# Author: Senior DevOps Engineer
# Version: 1.0 (Golden Standard)
#############################################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

TARGET_DIR="${1:-/}"
TOP_N=10
LOG_DIR="/var/log/disk-cleanup"
mkdir -p "$LOG_DIR"

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}   DISK USAGE ANALYZER${NC}"
echo -e "${CYAN}========================================${NC}"
echo "Target Directory: $TARGET_DIR"
echo "Date: $(date)"

# Check Root
if [[ $EUID -ne 0 ]]; then
   echo -e "${YELLOW}Warning: Not running as root. Some directories may be unreadable.${NC}"
fi

# 1. Filesystem Overview
echo -e "\n${CYAN}[1/5] Filesystem Usage${NC}"
df -h | grep -E '^/dev/' | awk '{ printf "  %-20s %-10s %-10s %-10s %-5s %s\n", $1, $2, $3, $4, $5, $6 }'

# 2. Large Directory Analysis
echo -e "\n${CYAN}[2/5] Top $TOP_N Largest Directories (in $TARGET_DIR)${NC}"
echo "Analyzing... this may take a moment."
du -ah "$TARGET_DIR" 2>/dev/null | sort -rh | head -n "$TOP_N" | awk '{print "  " $0}'

# 3. Large File Analysis
echo -e "\n${CYAN}[3/5] Top $TOP_N Largest Files${NC}"
find "$TARGET_DIR" -type f -exec du -h {} + 2>/dev/null | sort -rh | head -n "$TOP_N" | awk '{print "  " $0}'

# 4. Old Log Analysis
echo -e "\n${CYAN}[4/5] Old Log Files (>30 days)${NC}"
OLD_LOGS=$(find /var/log -name "*.log" -type f -mtime +30 2>/dev/null)

if [ -z "$OLD_LOGS" ]; then
    echo "  No logs older than 30 days found."
else
    echo "$OLD_LOGS" | while read -r file; do
        ls -lh "$file" | awk '{print "  " $5, $9}'
    done
fi

# 5. Cleanup Recommendations
echo -e "\n${CYAN}[5/5] Cleanup Recommendations${NC}"

# Check Docker
if command -v docker &> /dev/null; then
    DOCKER_SIZE=$(du -sh /var/lib/docker 2>/dev/null | cut -f1)
    echo -e "  ${YELLOW}Docker:${NC} using $DOCKER_SIZE. Run 'docker system prune' to reclaim space."
fi

# Check Apt Cache (Debian/Ubuntu)
if command -v apt-get &> /dev/null; then
    APT_SIZE=$(du -sh /var/cache/apt 2>/dev/null | cut -f1)
    echo -e "  ${YELLOW}APT Cache:${NC} using $APT_SIZE. Run 'apt-get clean' to clear."
fi

# Check Yum/Dnf Cache (RHEL/CentOS)
if command -v dnf &> /dev/null; then
    DNF_SIZE=$(du -sh /var/cache/dnf 2>/dev/null | cut -f1)
    echo -e "  ${YELLOW}DNF Cache:${NC} using $DNF_SIZE. Run 'dnf clean all' to clear."
fi

# Check Journals
JOURNAL_SIZE=$(du -sh /var/log/journal 2>/dev/null | cut -f1)
echo -e "  ${YELLOW}Systemd Journal:${NC} using $JOURNAL_SIZE. Run 'journalctl --vacuum-time=7d' to clear."

echo -e "\n${GREEN}Analysis Complete.${NC}"
