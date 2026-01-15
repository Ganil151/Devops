#!/bin/bash

# boilerplate_crontab_manager.sh - Schedule automated backups

readonly BACKUP_SCRIPT="/usr/local/bin/backup.sh"
readonly CRON_SCHEDULE="0 2 * * *"  # Daily at 2 AM

# Add to crontab
(crontab -l 2>/dev/null; echo "$CRON_SCHEDULE $BACKUP_SCRIPT") | crontab -

echo "✓ Backup job scheduled: $CRON_SCHEDULE"
crontab -l | grep backup
