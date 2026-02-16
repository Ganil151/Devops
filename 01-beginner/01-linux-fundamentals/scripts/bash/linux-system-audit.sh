#!/bin/bash

#############################################################################
# Script: linux-system-audit.sh
# Description: Comprehensive Linux system auditing tool
# Author: Senior DevOps Engineer
# Version: 1.0 (Golden Standard)
#############################################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Output file
OUTPUT_FILE="${1:-system-audit-$(date +%Y%m%d-%H%M%S).json}"

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}   LINUX SYSTEM AUDIT${NC}"
echo -e "${CYAN}========================================${NC}"

# Initialize JSON
cat > "$OUTPUT_FILE" << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "hostname": "$(hostname)",
EOF

# OS Information
echo -e "\n${CYAN}[1/8] OS Information${NC}"
OS_NAME=$(cat /etc/os-release | grep "^PRETTY_NAME" | cut -d'"' -f2)
KERNEL=$(uname -r)
ARCH=$(uname -m)

echo "  OS: $OS_NAME"
echo "  Kernel: $KERNEL"
echo "  Architecture: $ARCH"

cat >> "$OUTPUT_FILE" << EOF
  "os": {
    "name": "$OS_NAME",
    "kernel": "$KERNEL",
    "architecture": "$ARCH"
  },
EOF

# CPU Information
echo -e "\n${CYAN}[2/8] CPU Information${NC}"
CPU_MODEL=$(lscpu | grep "Model name" | cut -d':' -f2 | xargs)
CPU_CORES=$(nproc)
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)

echo "  Model: $CPU_MODEL"
echo "  Cores: $CPU_CORES"
echo "  Usage: ${CPU_USAGE}%"

cat >> "$OUTPUT_FILE" << EOF
  "cpu": {
    "model": "$CPU_MODEL",
    "cores": $CPU_CORES,
    "usage_percent": $CPU_USAGE
  },
EOF

# Memory Information
echo -e "\n${CYAN}[3/8] Memory Information${NC}"
MEM_TOTAL=$(free -m | awk 'NR==2{print $2}')
MEM_USED=$(free -m | awk 'NR==2{print $3}')
MEM_FREE=$(free -m | awk 'NR==2{print $4}')
MEM_PERCENT=$(awk "BEGIN {printf \"%.2f\", ($MEM_USED/$MEM_TOTAL)*100}")

echo "  Total: ${MEM_TOTAL}MB"
echo "  Used: ${MEM_USED}MB (${MEM_PERCENT}%)"
echo "  Free: ${MEM_FREE}MB"

cat >> "$OUTPUT_FILE" << EOF
  "memory": {
    "total_mb": $MEM_TOTAL,
    "used_mb": $MEM_USED,
    "free_mb": $MEM_FREE,
    "usage_percent": $MEM_PERCENT
  },
EOF

# Disk Information
echo -e "\n${CYAN}[4/8] Disk Information${NC}"
echo "  Filesystem Usage:"

DISK_JSON="["
FIRST=true
while IFS= read -r line; do
    FILESYSTEM=$(echo "$line" | awk '{print $1}')
    SIZE=$(echo "$line" | awk '{print $2}')
    USED=$(echo "$line" | awk '{print $3}')
    AVAIL=$(echo "$line" | awk '{print $4}')
    USE_PERCENT=$(echo "$line" | awk '{print $5}' | tr -d '%')
    MOUNT=$(echo "$line" | awk '{print $6}')
    
    echo "    $MOUNT: ${USE_PERCENT}% used"
    
    if [ "$FIRST" = false ]; then
        DISK_JSON+=","
    fi
    FIRST=false
    
    DISK_JSON+="{\"filesystem\":\"$FILESYSTEM\",\"size\":\"$SIZE\",\"used\":\"$USED\",\"available\":\"$AVAIL\",\"use_percent\":$USE_PERCENT,\"mount\":\"$MOUNT\"}"
done < <(df -h | grep -E '^/dev/')

DISK_JSON+="]"

cat >> "$OUTPUT_FILE" << EOF
  "disks": $DISK_JSON,
EOF

# Network Information
echo -e "\n${CYAN}[5/8] Network Information${NC}"
IP_ADDR=$(hostname -I | awk '{print $1}')
echo "  IP Address: $IP_ADDR"

cat >> "$OUTPUT_FILE" << EOF
  "network": {
    "ip_address": "$IP_ADDR",
    "hostname": "$(hostname)"
  },
EOF

# Running Services
echo -e "\n${CYAN}[6/8] Running Services${NC}"
SERVICE_COUNT=$(systemctl list-units --type=service --state=running | grep -c "\.service" || echo "0")
echo "  Running services: $SERVICE_COUNT"

SERVICES_JSON="["
FIRST=true
while IFS= read -r service; do
    if [ "$FIRST" = false ]; then
        SERVICES_JSON+=","
    fi
    FIRST=false
    SERVICES_JSON+="\"$service\""
done < <(systemctl list-units --type=service --state=running --no-pager --no-legend | awk '{print $1}' | head -20)
SERVICES_JSON+="]"

cat >> "$OUTPUT_FILE" << EOF
  "services": {
    "running_count": $SERVICE_COUNT,
    "top_services": $SERVICES_JSON
  },
EOF

# User Information
echo -e "\n${CYAN}[7/8] User Information${NC}"
USER_COUNT=$(cat /etc/passwd | grep -c "/bin/bash" || echo "0")
echo "  Users with shell: $USER_COUNT"

cat >> "$OUTPUT_FILE" << EOF
  "users": {
    "shell_users": $USER_COUNT
  },
EOF

# Security Audit
echo -e "\n${CYAN}[8/8] Security Audit${NC}"
SSH_ROOT_LOGIN=$(grep "^PermitRootLogin" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' || echo "unknown")
FIREWALL_STATUS=$(systemctl is-active firewalld 2>/dev/null || systemctl is-active ufw 2>/dev/null || echo "inactive")

echo "  SSH Root Login: $SSH_ROOT_LOGIN"
echo "  Firewall Status: $FIREWALL_STATUS"

cat >> "$OUTPUT_FILE" << EOF
  "security": {
    "ssh_root_login": "$SSH_ROOT_LOGIN",
    "firewall_status": "$FIREWALL_STATUS"
  }
}
EOF

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}   AUDIT COMPLETE${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Report saved to: ${CYAN}$OUTPUT_FILE${NC}\n"

# Display summary
echo -e "${YELLOW}SUMMARY:${NC}"
echo -e "  Hostname: $(hostname)"
echo -e "  OS: $OS_NAME"
echo -e "  CPU Usage: ${CPU_USAGE}%"
echo -e "  Memory Usage: ${MEM_PERCENT}%"
echo -e "  Running Services: $SERVICE_COUNT"
echo -e "  SSH Root Login: $SSH_ROOT_LOGIN"
echo ""
