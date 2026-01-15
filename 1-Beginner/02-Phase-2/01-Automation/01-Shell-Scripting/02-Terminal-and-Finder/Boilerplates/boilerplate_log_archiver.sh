#!/bin/bash

# ==============================================================================
# Script: boilerplate_log_archiver.sh
# Description: Finds and compresses old log files for compliance
# DevOps Context: Log retention automation for regulatory compliance
# Schedule: Run weekly via cron - 0 3 * * 0 /path/to/script
# ==============================================================================

set -euo pipefail

# Constants
readonly LOG_DIR="${1:-/var/log}"
readonly ARCHIVE_DIR="${2:-/var/log/archives}"
readonly RETENTION_DAYS=30
readonly TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1: $2"
}

# Create archive directory
setup_archive_dir() {
    if [ ! -d "$ARCHIVE_DIR" ]; then
        log "INFO" "Creating archive directory: $ARCHIVE_DIR"
        mkdir -p "$ARCHIVE_DIR"
    fi
}

# Find old log files
find_old_logs() {
    log "INFO" "Searching for log files older than $RETENTION_DAYS days in $LOG_DIR"
    
    find "$LOG_DIR" -maxdepth 2 -type f \
        -name "*.log" \
        -mtime +$RETENTION_DAYS \
        2>/dev/null
}

# Archive logs
archive_logs() {
    local log_files
    log_files=$(find_old_logs)
    
    if [ -z "$log_files" ]; then
        log "INFO" "No old log files found to archive"
        return 0
    fi
    
    local archive_name="logs_archive_${TIMESTAMP}.tar.gz"
    local archive_path="${ARCHIVE_DIR}/${archive_name}"
    
    log "INFO" "Archiving logs to: $archive_path"
    
    echo "$log_files" | tar -czf "$archive_path" -T - 2>/dev/null
    
    if [ $? -eq 0 ]; then
        log "INFO" "✓ Archive created successfully"
        
        # Remove original files after successful archive
        echo "$log_files" | xargs rm -f
        log "INFO" "✓ Original log files removed"
        
        # Display archive info
        local archive_size
        archive_size=$(du -h "$archive_path" | cut -f1)
        log "INFO" "Archive size: $archive_size"
    else
        log "ERROR" "Archive creation failed"
        return 1
    fi
}

# Cleanup old archives
cleanup_old_archives() {
    log "INFO" "Removing archives older than 90 days"
    
    find "$ARCHIVE_DIR" -type f -name "logs_archive_*.tar.gz" -mtime +90 -delete
    
    log "INFO" "✓ Old archive cleanup completed"
}

# Main function
main() {
    log "INFO" "========================================"
    log "INFO" "Starting log archival process"
    log "INFO" "  Log Directory: $LOG_DIR"
    log "INFO" "  Archive Directory: $ARCHIVE_DIR"
    log "INFO" "  Retention: $RETENTION_DAYS days"
    log "INFO" "========================================"
    
    setup_archive_dir
    archive_logs
    cleanup_old_archives
    
    log "INFO" "========================================"
    log "INFO" "Log archival completed successfully"
    log "INFO" "========================================"
}

main "$@"
