#!/bin/bash

# boilerplate_disaster_recovery.sh - Database backup automation

set -euo pipefail

readonly DB_NAME="production_db"
readonly BACKUP_DIR="/backup"
readonly S3_BUCKET="s3://my-backups"
readonly TIMESTAMP=$(date +%Y%m%d_%H%M%S)
readonly BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.sql.gz"

# Backup
pg_dump "$DB_NAME" | gzip > "$BACKUP_FILE"

# Upload to S3
aws s3 cp "$BACKUP_FILE" "$S3_BUCKET/"

# Verify
aws s3 ls "$S3_BUCKET/$(basename "$BACKUP_FILE")" && echo "✓ Backup verified in S3"

# Cleanup old local backups
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +7 -delete

echo "✓ Disaster recovery backup complete"
