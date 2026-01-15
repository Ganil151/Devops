#!/bin/bash

# ==============================================================================
# Script: boilerplate_error_aggregator.sh
# Description: Analyzes application logs and categorizes errors by severity
# DevOps Context: Incident response and log analysis automation
# ==============================================================================

set -euo pipefail

readonly LOG_FILE="${1:-/var/log/app/application.log}"
readonly OUTPUT_FILE="error_report_$(date +%Y%m%d_%H%M%S).txt"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1: $2"
}

# Check log file exists
check_log_file() {
    if [ ! -f "$LOG_FILE" ]; then
        log "ERROR" "Log file not found: $LOG_FILE"
        exit 1
    fi
}

# Count errors by severity
analyze_errors() {
    log "INFO" "Analyzing log file: $LOG_FILE"
    
    local error_count=$(grep -c "ERROR" "$LOG_FILE" 2>/dev/null || echo 0)
    local warn_count=$(grep -c "WARN" "$LOG_FILE" 2>/dev/null || echo 0)
    local fatal_count=$(grep -c "FATAL" "$LOG_FILE" 2>/dev/null || echo 0)
    
    {
        echo "╔════════════════════════════════════════╗"
        echo "║     Log Analysis Report                ║"
        echo "╠═══════════════════════════════════════╣"
        echo "║ File: $LOG_FILE"
        echo "║ Generated: $(date)"
        echo "╠════════════════════════════════════════╣"
        echo "║ FATAL Errors: $fatal_count"
        echo "║ ERROR Messages: $error_count"
        echo "║ WARN Messages: $warn_count"
        echo "╚════════════════════════════════════════╝"
        echo ""
        
        if [ "$fatal_count" -gt 0 ]; then
            echo "=== FATAL ERRORS ==="
            grep "FATAL" "$LOG_FILE" | tail -10
            echo ""
        fi
        
        if [ "$error_count" -gt 0 ]; then
            echo "=== LAST 20 ERRORS ==="
            grep "ERROR" "$LOG_FILE" | tail -20
            echo ""
        fi
        
        if [ "$warn_count" -gt 0 ]; then
            echo "=== WARNING SUMMARY ==="
            grep "WARN" "$LOG_FILE" | cut -d' ' -f4- | sort | uniq -c | sort -rn | head -10
        fi
    } | tee "$OUTPUT_FILE"
    
    log "INFO" "✓ Report saved: $OUTPUT_FILE"
}

main() {
    log "INFO" "Starting error aggregation"
    check_log_file
    analyze_errors
    log "INFO" "✓ Analysis complete"
}

main "$@"
