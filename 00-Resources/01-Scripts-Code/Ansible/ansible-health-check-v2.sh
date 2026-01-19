#!/bin/bash
# ---------------------------------------------------------------------
# ANSIBLE HEALTH CHECK V2 (Observability & Monitoring Enhanced)
# ---------------------------------------------------------------------
# Description: Enhanced diagnostic script that verifies configuration
#              and probes for "The 4 Golden Signals".
# ---------------------------------------------------------------------

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}=========================================="
    echo -e "$1"
    echo -e "==========================================${NC}"
}

# 1. Connectivity Check
print_header "1. Connectivity & Inventory"
INVENTORY="${1:-inventory.ini}"
if [ -f "$INVENTORY" ]; then
    ansible all -i "$INVENTORY" -m ping
else
    echo -e "${RED}[ERROR] Inventory file $INVENTORY not found.${NC}"
fi

# 2. The 4 Golden Signals (Diagnostic Probes)
print_header "2. Internal Signal Inspection"

# A. Latency (Ping RTT)
echo -ne "${YELLOW}Checking Network Latency... ${NC}"
ansible all -i "$INVENTORY" -m shell -a "ping -c 3 8.8.8.8 | tail -1 | awk '{print \$4}' | cut -d/ -f2" | grep -v "SUCCESS" | xargs -I {} echo "Avg RTT: {}ms"

# B. Traffic (Network RX/TX)
echo -ne "${YELLOW}Checking Network Traffic... ${NC}"
ansible all -i "$INVENTORY" -m shell -a "grep eth0 /proc/net/dev | awk '{print \"RX: \" \$2 \" TX: \" \$10}'"

# C. Errors (System Logs)
echo -ne "${YELLOW}Checking for System Errors (Last 10 mins)... ${NC}"
ansible all -i "$INVENTORY" -m shell -a "journalctl --since '10 minutes ago' | grep -i 'error' | wc -l" | xargs -I {} echo "Found {} errors"

# D. Saturation (CPU/RAM)
echo -ne "${YELLOW}Checking Resource Saturation... ${NC}"
ansible all -i "$INVENTORY" -m shell -a "free -m | grep Mem | awk '{print \"RAM Usage: \" \$3/\$2*100 \"%\"}'"

print_header "Diagnostic Complete"
