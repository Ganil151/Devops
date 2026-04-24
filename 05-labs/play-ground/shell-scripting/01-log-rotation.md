# Lab 01: Log Rotation Automation

## 🎯 Objective
Create a script to manage application logs. The script must:
1. Compress logs (`*.log`) older than 7 days.
2. Delete compressed logs (`*.tar.gz`) older than 30 days.
3. Handle errors (e.g., missing directory) gracefully.

## 📝 Starter Template (`rotate_logs.sh`)
```bash
#!/bin/bash
set -euo pipefail

LOG_DIR="${1:-/var/log/app}"

log_msg() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# TODO: Check if directory exists

# TODO: Find and compress old logs
log_msg "Starting compression..."

# TODO: Find and delete valid archives
log_msg "Starting cleanup..."
```

## ✅ Solution (`solution_rotate_logs.sh`)
```bash
#!/bin/bash
# ==============================================================================
# Script: Log Rotation Manager
# Usage: ./rotate_logs.sh [TARGET_DIR]
# ==============================================================================

set -euo pipefail

DIR="${1:-/tmp/logs}"
RETENTION_DAYS_COMPRESS=7
RETENTION_DAYS_DELETE=30

log() {
    local msg="$1"
    echo "[$(date +'%Y-%m-%dT%H:%M:%S')] $msg"
}

# 1. Validation
if [[ ! -d "$DIR" ]]; then
    log "ERROR: Directory $DIR does not exist."
    exit 1
fi

log "Processing logs in: $DIR"

# 2. Compress Logs older than 7 days
# uses find with -exec to safely handle filenames with spaces
find "$DIR" -name "*.log" -type f -mtime +$RETENTION_DAYS_COMPRESS -print0 | \
    while IFS= read -r -d '' file; do
        if gzip "$file"; then
            log "Compressed: $file"
        else
            log "Failed to compress: $file" >&2
        fi
    done

# 3. Delete Archives older than 30 days
count=$(find "$DIR" -name "*.gz" -type f -mtime +$RETENTION_DAYS_DELETE | wc -l)
if [[ "$count" -gt 0 ]]; then
    # -delete is efficient but dangerous; verify path first!
    find "$DIR" -name "*.gz" -type f -mtime +$RETENTION_DAYS_DELETE -delete
    log "Deleted $count old archives."
else
    log "No archives to delete."
fi

log "Rotation complete."
```
