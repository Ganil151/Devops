#!/bin/bash

# --- UNIVERSAL DATABASE BACKUP BOILERPLATE ---
# A robust template for managing automated DB backups.

DB_TYPE="postgres" # Options: postgres, mysql
DB_NAME="production_app"
DB_USER="backup_agent"
BACKUP_DIR="/var/backups/databases"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FINAL_BACKUP="$BACKUP_DIR/${DB_NAME}_$TIMESTAMP.sql.gz"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "🚀 Starting backup for $DB_NAME..."

if [ "$DB_TYPE" == "postgres" ]; then
    # Postgres Dump (Uses password from ~/.pgpass)
    pg_dump -U "$DB_USER" "$DB_NAME" | gzip > "$FINAL_BACKUP"

elif [ "$DB_TYPE" == "mysql" ]; then
    # MySQL Dump (Uses password from ~/.my.cnf)
    mysqldump -u "$DB_USER" "$DB_NAME" | gzip > "$FINAL_BACKUP"
fi

# Retention Policy: Only keep last 7 days of backups
echo "🧹 Cleaning up old backups..."
find "$BACKUP_DIR" -type f -name "*.sql.gz" -mtime +7 -delete

echo "✅ Backup complete: $FINAL_BACKUP"

---

# Pro-Tip: The Secret Managers
Never hardcode passwords in scripts. Use these local config files instead:
1. **Postgres**: Create `~/.pgpass` (chmod 600)
2. **MySQL**: Create `~/.my.cnf` (chmod 600)
