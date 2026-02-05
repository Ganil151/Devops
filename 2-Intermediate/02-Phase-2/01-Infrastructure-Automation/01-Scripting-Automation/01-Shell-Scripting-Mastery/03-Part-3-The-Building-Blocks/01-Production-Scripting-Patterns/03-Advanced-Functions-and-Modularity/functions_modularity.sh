#!/usr/bin/env bash
# Topic: Advanced Functions & Modularity
# Description: Demonstrates local scope, return values, and library structure.

set -euo pipefail

# --- Library Functions ---

# Professional Standard: Use 'local' for all internal variables
# Use a clear naming convention for library functions
lib_check_disk_usage() {
    local threshold=${1:-80} # Default to 80%
    local partition="/"
    
    local usage
    usage=$(df -h "$partition" | awk 'NR==2 {print $5}' | sed 's/%//')

    if [[ "$usage" -gt "$threshold" ]]; then
        echo "🚨 Warning: Disk usage on $partition is at $usage% (Threshold: $threshold%)"
        return 1
    fi
    echo "✅ Disk usage is healthy ($usage%)"
    return 0
}

lib_log() {
    local level=$1
    shift
    local message="$*"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    echo "[$timestamp] [$level] $message"
}

# --- Main Execution Logic ---

main() {
    lib_log "INFO" "Starting System Health Check..."
    
    # Capture return code in a variable if needed
    if ! lib_check_disk_usage 90; then
        lib_log "ERROR" "Disk check failed. Triggering alert..."
        # Logic to send alert would go here
    fi

    lib_log "INFO" "Health Check Complete."
}

# Only run if executed directly, allows for 'sourcing' as a library
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
