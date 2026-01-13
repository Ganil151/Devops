#!/bin/bash

# ==============================================================================
# Server Inventory Validator
# Intermediate Shell Scripting Example
# Demonstrates: Functions, Arrays, Loops, Redirection, and Logic
# ==============================================================================

# 1. Strict Mode
set -uo pipefail

# 2. Configuration
SERVERS=("google.com" "github.com" "localhost" "invalid.server.local")
LOG_FILE="inventory.log"

# 3. Utility Functions
log_msg() {
    local level="$1"
    local message="$2"
    echo "[$(date +'%Y-%m-%dT%H:%M:%S')] [$level] $message" | tee -a "$LOG_FILE"
}

check_server() {
    local target="$1"
    
    log_msg "INFO" "Checking server: $target"
    
    # Check DNS/Ping
    if ping -c 1 -W 2 "$target" &> /dev/null; then
        return 0 # Success
    else
        return 1 # Failure
    fi
}

# 4. Main Controller
main() {
    local online_count=0
    local offline_count=0
    
    echo "=========================================="
    echo "  DevOps Inventory Health Check"
    echo "=========================================="
    
    for server in "${SERVERS[@]}"; do
        if check_server "$server"; then
            echo "✅ READY: $server"
            ((online_count++))
        else
            echo "❌ DOWN : $server" >&2
            ((offline_count++))
        fi
    done
    
    echo "------------------------------------------"
    echo "Summary:"
    echo "  Total:   ${#SERVERS[@]}"
    echo "  Online:  $online_count"
    echo "  Offline: $offline_count"
    echo "------------------------------------------"
    
    # Logic for final exit code
    if [[ $offline_count -gt 0 ]]; then
        log_msg "WARN" "One or more servers are offline."
        exit 1
    fi
    
    log_msg "INFO" "All servers are healthy."
    exit 0
}

# 5. Invoke Main
main
