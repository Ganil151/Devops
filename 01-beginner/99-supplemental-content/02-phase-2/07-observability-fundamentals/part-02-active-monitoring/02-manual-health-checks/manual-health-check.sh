#!/bin/bash
# ---------------------------------------------------------------------
# SIMPLE HEALTH CHECK BOILERPLATE
# ---------------------------------------------------------------------
# Description: Checks the availability of an HTTP endpoint and local
#              system resources.
# ---------------------------------------------------------------------

URL="http://localhost:8080/health"
CPU_THRESHOLD=80
DISK_THRESHOLD=90

echo "--- System Health Report ---"

# 1. Check HTTP Endpoint
status_code=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
if [ "$status_code" -eq 200 ]; then
    echo "[PASS] Endpoint $URL is UP (200 OK)"
else
    echo "[FAIL] Endpoint $URL is DOWN (Status: $status_code)"
fi

# 2. Check CPU Usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' | cut -d. -f1)
if [ "$cpu_usage" -lt "$CPU_THRESHOLD" ]; then
    echo "[PASS] CPU Usage: $cpu_usage% (Threshold: $CPU_THRESHOLD%)"
else
    echo "[WARN] CPU Usage: $cpu_usage% EXCEEDS Threshold ($CPU_THRESHOLD%)"
fi

# 3. Check Disk Usage
disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$disk_usage" -lt "$DISK_THRESHOLD" ]; then
    echo "[PASS] Disk Usage: $disk_usage% (Threshold: $DISK_THRESHOLD%)"
else
    echo "[WARN] Disk Usage: $disk_usage% EXCEEDS Threshold ($DISK_THRESHOLD%)"
fi

echo "--- Check Complete ---"
