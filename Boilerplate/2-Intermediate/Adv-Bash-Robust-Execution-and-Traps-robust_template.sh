#!/bin/bash
# -----------------------------------------------------------------------------
# Name: robust_template.sh
# Description: A production-ready Bash template with locking, logging, and cleanup.
# -----------------------------------------------------------------------------

set -euo pipefail
IFS=$'\n\t'

# Configuration
SCRIPT_NAME="${0##*/}"
LOCKFILE="/tmp/${SCRIPT_NAME}.lock"
LOGFILE="/tmp/${SCRIPT_NAME}.log"
TEMP_DIR=""

# -----------------------------------------------------------------------------
# Logging Functions
# -----------------------------------------------------------------------------
log_info() { echo "[$(date +'%Y-%m-%dT%H:%M:%S')] [INFO] $*" | tee -a "$LOGFILE"; }
log_warn() { echo "[$(date +'%Y-%m-%dT%H:%M:%S')] [WARN] $*" | tee -a "$LOGFILE" >&2; }
log_error() { echo "[$(date +'%Y-%m-%dT%H:%M:%S')] [ERROR] $*" | tee -a "$LOGFILE" >&2; }

# -----------------------------------------------------------------------------
# Cleanup & Signal Handling
# -----------------------------------------------------------------------------
cleanup() {
    local exit_code=$?
    log_info "Cleaning up..."
    
    # Remove Temp Directory
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
        log_info "Removed temp dir: $TEMP_DIR"
    fi

    # Kill background jobs if any
    # kill $(jobs -p) 2>/dev/null || true
    
    # Release Lock (Optional, usually handled by flock automatically if using FD)
    # But for mkdir method:
    # rmdir "$LOCKFILE" 2>/dev/null
    
    log_info "Exiting with status $exit_code"
    exit $exit_code
}

trap cleanup EXIT SIGINT SIGTERM

# -----------------------------------------------------------------------------
# Locking (Flock Method)
# -----------------------------------------------------------------------------
exec 200>"$LOCKFILE"
if ! flock -n 200; then
    log_error "Another instance is already running."
    exit 1
fi

# -----------------------------------------------------------------------------
# Main Logic
# -----------------------------------------------------------------------------
main() {
    log_info "Script started. Lock acquired."
    
    # Create a guaranteed unique temp directory
    TEMP_DIR=$(mktemp -d)
    log_info "Working in $TEMP_DIR"
    
    # Simulate work
    sleep 2
    
    # Example of conditional logic
    if [[ "${1:-}" == "fail" ]]; then
        log_error "Triggering simulated failure..."
        exit 1
    fi
    
    log_info "Work complete."
}

main "$@"
