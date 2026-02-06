#!/bin/bash
# Cron Job Manager
# Description: Safely add/remove cron jobs
# Author: Senior DevOps Engineer

ACTION=$1
JOB_CMD=$2
BACKUP_DIR="$HOME/.cron_backups"

mkdir -p "$BACKUP_DIR"

if [ -z "$ACTION" ]; then
    echo "Usage: $0 [add|remove] 'job_command'"
    echo "Example: $0 add '*/5 * * * * /path/to/script.sh'"
    exit 1
fi

# Backup
crontab -l > "$BACKUP_DIR/cron_$(date +%Y%m%d_%H%M%S).bak" 2>/dev/null || true

if [ "$ACTION" == "add" ]; then
    (crontab -l 2>/dev/null; echo "$JOB_CMD") | crontab -
    echo "Job added."
elif [ "$ACTION" == "remove" ]; then
    crontab -l | grep -Fv "$JOB_CMD" | crontab -
    echo "Job removed (if matched)."
else
    echo "Unknown action: $ACTION"
    exit 1
fi

crontab -l
