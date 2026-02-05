#!/bin/bash

# boilerplate_logging_framework.sh - Structured logging

log_info() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [INFO] $1"
}

log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [ERROR] $1" >&2
}

log_debug() {
    [ "${DEBUG:-false}" == "true" ] && echo "[$(date +'%Y-%m-%d %H:%M:%S')] [DEBUG] $1"
}

log_warn() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [WARN] $1"
}

# Example usage
log_info "Application started"
log_debug "Debug information"
log_warn "This is a warning"
log_error "An error occurred"

echo "✓ Logging framework loaded"
