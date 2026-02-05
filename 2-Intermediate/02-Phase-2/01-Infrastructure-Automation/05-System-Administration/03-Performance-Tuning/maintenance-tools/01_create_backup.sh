#!/bin/bash
# BACKUP CREATION SCRIPT
# Creates a timestamped backup of the entire Devops directory

set -euo pipefail

# Configuration
SOURCE_DIR="."
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="Devops-Backup-${TIMESTAMP}"
BACKUP_DIR="../${BACKUP_NAME}"
LOG_FILE="backup_${TIMESTAMP}.log"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              DEVOPS DIRECTORY BACKUP CREATION                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Source: $(pwd)"
echo "Backup: $BACKUP_DIR"
echo "Log: $LOG_FILE"
echo ""

# Function to log messages
log() {
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] $1" | tee -a "$LOG_FILE"
}

# Check if backup already exists
if [ -d "$BACKUP_DIR" ]; then
    log "ERROR: Backup directory already exists: $BACKUP_DIR"
    exit 1
fi

# Estimate size
log "Calculating directory size..."
SIZE=$(du -sh . 2>/dev/null | cut -f1)
log "Directory size: $SIZE"

# Confirm backup
echo ""
read -p "Proceed with backup creation? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    log "Backup cancelled by user"
    exit 0
fi

# Create backup
log "Starting backup..."
echo ""

# Use rsync for better progress tracking
if command -v rsync &> /dev/null; then
    log "Using rsync for backup..."
    rsync -av --progress \
        --exclude='.git' \
        --exclude='node_modules' \
        --exclude='__pycache__' \
        --exclude='*.pyc' \
        --exclude='.pytest_cache' \
        "$SOURCE_DIR" "$BACKUP_DIR" 2>&1 | tee -a "$LOG_FILE"
else
    log "Using cp for backup..."
    cp -r "$SOURCE_DIR" "$BACKUP_DIR" 2>&1 | tee -a "$LOG_FILE"
fi

# Verify backup
log "Verifying backup..."
BACKUP_SIZE=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1)
log "Backup size: $BACKUP_SIZE"

# Create backup manifest
log "Creating backup manifest..."
find "$BACKUP_DIR" -type f > "${BACKUP_DIR}/BACKUP_MANIFEST.txt"
FILE_COUNT=$(wc -l < "${BACKUP_DIR}/BACKUP_MANIFEST.txt")
log "Files backed up: $FILE_COUNT"

# Create backup info file
cat > "${BACKUP_DIR}/BACKUP_INFO.txt" << EOF
Backup Information
==================
Created: $(date)
Source: $(pwd)
Backup Location: $BACKUP_DIR
Total Size: $BACKUP_SIZE
Total Files: $FILE_COUNT

To restore this backup:
1. Delete the modified Devops directory
2. Copy this backup back: cp -r $BACKUP_DIR <original-location>
3. Rename: mv $BACKUP_NAME Devops

IMPORTANT: Keep this backup until reorganization is verified successful!
EOF

echo ""
log "✅ Backup completed successfully!"
echo ""
echo "Backup location: $BACKUP_DIR"
echo "Backup info: ${BACKUP_DIR}/BACKUP_INFO.txt"
echo ""
echo "⚠️  IMPORTANT: Do NOT delete this backup until you have verified"
echo "   the reorganization is successful and all links are working!"
echo ""

# Create safety flag
touch ".backup_created_${TIMESTAMP}"
log "Backup flag created: .backup_created_${TIMESTAMP}"

echo "You may now proceed with migration."
