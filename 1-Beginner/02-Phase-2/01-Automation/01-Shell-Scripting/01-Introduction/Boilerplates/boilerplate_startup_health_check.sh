#!/bin/bash

# ==============================================================================
# Script: boilerplate_startup_health_check.sh
# Description: System health check for pre-deployment validation
# DevOps Context: Run before deployments to ensure infrastructure readiness
# ==============================================================================

set -euo pipefail

# Constants
readonly SCRIPT_NAME=$(basename "$0")
readonly CPU_THRESHOLD=80
readonly MEMORY_THRESHOLD=85
readonly DISK_THRESHOLD=90

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$1] $2"
}

# Check CPU usage
check_cpu() {
    log "INFO" "Checking CPU usage..."
    local cpu_usage
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 | awk '{print int($1)}')
    
    if (( cpu_usage > CPU_THRESHOLD )); then
        log "WARN" "CPU usage is ${cpu_usage}% (threshold: ${CPU_THRESHOLD}%)"
        return 1
    else
        log "INFO" "CPU usage: ${cpu_usage}% - OK"
        return 0
    fi
}

# Check memory usage
check_memory() {
    log "INFO" "Checking memory usage..."
    local mem_usage
    mem_usage=$(free | grep Mem | awk '{printf("%.0f"), $3/$2 * 100}')
    
    if (( mem_usage > MEMORY_THRESHOLD )); then
        log "WARN" "Memory usage is ${mem_usage}% (threshold: ${MEMORY_THRESHOLD}%)"
        return 1
    else
        log "INFO" "Memory usage: ${mem_usage}% - OK"
        return 0
    fi
}

# Check disk usage
check_disk() {
    log "INFO" "Checking disk usage..."
    local disk_usage
    disk_usage=$(df -h / | tail -1 | awk '{print $5}' | cut -d'%' -f1)
    
    if (( disk_usage > DISK_THRESHOLD )); then
        log "ERROR" "Disk usage is ${disk_usage}% (threshold: ${DISK_THRESHOLD}%)"
        return 1
    else
        log "INFO" "Disk usage: ${disk_usage}% - OK"
        return 0
    fi
}

# Main health check
main() {
    log "INFO" "Starting system health check..."
    
    local exit_code=0
    
    check_cpu || exit_code=1
    check_memory || exit_code=1
    check_disk || exit_code=1
    
    if [ $exit_code -eq 0 ]; then
        log "INFO" "✓ All health checks passed. System is ready for deployment."
    else
        log "ERROR" "✗ Health checks failed. Please review system resources."
    fi
    
    exit $exit_code
}

main "$@"
