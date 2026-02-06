# Lab 03: Database Backup & S3 Upload

## 🎯 Objective
Simulate a database backup workflow.
1. Create a timestamped "backup file" (dummy file).
2. "Upload" it to a cloud path (simulate with a move).
3. Implement a **Lock File** to prevent two backups running at once.

## 📝 Starter Template (`db_backup.sh`)
```bash
#!/bin/bash

LOCK_FILE="/tmp/backup.lock"
BACKUP_DIR="/backups"

# TODO: Check if lock file exists. If so, exit.
# TODO: Create lock file.
# TODO: Ensure lock file is removed even if script crashes (trap).
# TODO: Perform "Backup" (touch file).
```

## ✅ Solution (`solution_db_backup.sh`)
```bash
#!/bin/bash
# ==============================================================================
# Script: Atomic DB Backup
# Usage: ./db_backup.sh
# ==============================================================================

set -euo pipefail

BACKUP_DIR="/tmp/db_backups"
REMOTE_PATH="/tmp/s3_bucket" # Simulating bucket
LOCK_FILE="/tmp/db_backup.lock"
TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
FILENAME="db_dump_${TIMESTAMP}.sql"

# 1. Concurrency Control
if [[ -f "$LOCK_FILE" ]]; then
    # Check if PID in lockfile is still running
    if kill -0 "$(cat "$LOCK_FILE")" 2>/dev/null; then
        echo "Error: Backup already in progress." >&2
        exit 1
    fi
    # If PID not running, it's a stale lock (safe to overwrite)
fi

# Create lock with current PID
echo $$ > "$LOCK_FILE"

# 2. Safety Trap (Runs on EXIT, ERROR, or SIGINT)
cleanup() {
    rm -f "$LOCK_FILE"
    echo "Lock released."
}
trap cleanup EXIT

# 3. Main Logic
mkdir -p "$BACKUP_DIR" "$REMOTE_PATH"

echo "[1/3] Creating backup $FILENAME..."
# Simulate dump
echo "INSERT INTO users..." > "${BACKUP_DIR}/${FILENAME}"
sleep 2 # Simulate time

echo "[2/3] Compressing..."
gzip "${BACKUP_DIR}/${FILENAME}"

echo "[3/3] Uploading to S3..."
# Simulate upload by moving
mv "${BACKUP_DIR}/${FILENAME}.gz" "${REMOTE_PATH}/"

echo "✅ Backup successfully stored in $REMOTE_PATH"
```
