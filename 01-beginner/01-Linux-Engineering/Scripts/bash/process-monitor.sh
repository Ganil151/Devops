#!/bin/bash

#############################################################################
# Script: process-monitor.sh
# Description: Monitor high-usage processes and system load
# Author: Senior DevOps Engineer
# Version: 1.0 (Golden Standard)
#############################################################################

set -euo pipefail

# Thresholds
CPU_THRESHOLD=80
MEM_THRESHOLD=80
LOG_FILE="/var/log/process-monitor.log"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "Starting Process Monitor at $(date)"
echo "CPU Threshold: ${CPU_THRESHOLD}% | Mem Threshold: ${MEM_THRESHOLD}%"

# 1. System Load Average
LOAD_1MIN=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | xargs)
echo -e "\n[1] System Load (1 min): ${GREEN}$LOAD_1MIN${NC}"

# 2. High CPU Processes
echo -e "\n[2] Top 5 CPU Consuming Processes"
echo "PID   USER      %CPU  COMMAND"
ps -eo pid,user,pcpu,comm --sort=-pcpu | head -n 6 | tail -n 5 | \
while read -r pid user cpu comm; do
    cpu_int=${cpu%.*}
    if [ "$cpu_int" -ge "$CPU_THRESHOLD" ]; then
        echo -e "${RED}$pid  $user     $cpu  $comm (HIGH)${NC}"
        echo "$(date) ALERT: High CPU - $comm ($pid) using ${cpu}%" >> "$LOG_FILE"
    else
        echo "$pid  $user     $cpu  $comm"
    fi
done

# 3. High Memory Processes
echo -e "\n[3] Top 5 Memory Consuming Processes"
echo "PID   USER      %MEM  COMMAND"
ps -eo pid,user,pmem,comm --sort=-pmem | head -n 6 | tail -n 5 | \
while read -r pid user mem comm; do
    mem_int=${mem%.*}
    if [ "$mem_int" -ge "$MEM_THRESHOLD" ]; then
        echo -e "${RED}$pid  $user     $mem  $comm (HIGH)${NC}"
        echo "$(date) ALERT: High Memory - $comm ($pid) using ${mem}%" >> "$LOG_FILE"
    else
        echo "$pid  $user     $mem  $comm"
    fi
done

# 4. Zombie Processes
ZOMBIE_COUNT=$(ps aux | awk '{print $8}' | grep -c 'Z')
echo -e "\n[4] Zombie Processes: $ZOMBIE_COUNT"
if [ "$ZOMBIE_COUNT" -gt 0 ]; then
    echo -e "${RED}  Found zombies!${NC}"
    ps aux | awk '$8=="Z" { print $2, $11 }'
fi

# 5. Summary
echo -e "\nMonitor complete. Alerts logged to $LOG_FILE"
