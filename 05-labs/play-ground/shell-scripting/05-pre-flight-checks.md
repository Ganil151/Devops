# Lab 05: Pre-Flight Environment Checker

## 🎯 Objective
Before deploying an app, you must check if the server meets requirements. Create a script that checks:
1. OS Version (Must be Ubuntu or CentOS)
2. Memory (Must have > 1GB Free)
3. Disk Space (Must have > 10GB Free in `/`)
4. Required Packages (`curl`, `git`, `docker` installed)

## 📝 Starter Template (`pre_flight.sh`)
```bash
#!/bin/bash

# TODO: Check /etc/os-release
# TODO: Parse 'free -m' output
# TODO: Parse 'df -h' output
# TODO: Loop through list of packages and 'command -v' them
```

## ✅ Solution (`solution_pre_flight.sh`)
```bash
#!/bin/bash
# ==============================================================================
# Script: Pre-Flight Checker
# ==============================================================================

set -euo pipefail

# Thresholds
MIN_MEM_MB=1000
MIN_DISK_GB=10
REQ_PKGS=("curl" "git" "docker")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; exit 1; }

echo "Starting Pre-Flight Checks..."

# 1. OS Check
if grep -q -E "Ubuntu|CentOS" /etc/os-release; then
    pass "OS is supported"
else
    fail "Unsupported OS. Must be Ubuntu or CentOS."
fi

# 2. Memory Check
# awk extracts the 'available' memory column
avail_mem=$(free -m | awk '/^Mem:/{print $7}')
if [[ "$avail_mem" -gt "$MIN_MEM_MB" ]]; then
    pass "Memory: ${avail_mem}MB available (Req: $MIN_MEM_MB)"
else
    fail "Insufficient Memory: ${avail_mem}MB"
fi

# 3. Disk Check
# uses awk to strip '%' and check available space
avail_disk=$(df -BG / | awk 'NR==2 {print $4}' | tr -d 'G')
if [[ "$avail_disk" -gt "$MIN_DISK_GB" ]]; then
    pass "Disk Space: ${avail_disk}GB available"
else
    fail "Insufficient Disk: ${avail_disk}GB"
fi

# 4. Package Check
for pkg in "${REQ_PKGS[@]}"; do
    if command -v "$pkg" &> /dev/null; then
        pass "Package '$pkg' is installed"
    else
        echo -e "${RED}[FAIL]${NC} Missing package: $pkg"
        # Optional: exit 1 here if you want to stop immediately
    fi
done

echo "---------------------------------"
echo "Node is healthy for deployment."
```
