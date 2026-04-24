#!/bin/bash
# ---------------------------------------------------------------------
# MIDNIGHT BACKUP BOILERPLATE
# ---------------------------------------------------------------------
# Description: Compresses a source directory and saves it to a backup 
#              location with a timestamp.
# ---------------------------------------------------------------------

# 1. Configuration
SOURCE="/Users/Ganil/Documents/Devops/Boilerplate" # Example path
DESTINATION="/Users/Ganil/Documents/Devops/Backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H%M%S")
FILENAME="boilerplate_backup_$TIMESTAMP.tar.gz"

# 2. Check Prerequisites
if [ ! -d "$SOURCE" ]; then
    echo "ERROR: Source directory $SOURCE does not exist."
    exit 1
fi

mkdir -p "$DESTINATION"

# 3. Execution
echo "Starting backup of $SOURCE..."
tar -czf "$DESTINATION/$FILENAME" "$SOURCE"

# 4. Result Verification
if [ $? -eq 0 ]; then
    echo "SUCCESS: Backup created at $DESTINATION/$FILENAME"
else
    echo "FAILURE: Backup failed."
    exit 1
fi

# ---------------------------------------------------------------------
# CRONTAB INSTRUCTION:
# To run this every night at midnight, add this to 'crontab -e':
# 0 0 * * * /bin/bash /absolute/path/to/midnight-backup.sh >> /var/log/backup.log 2>&1
# ---------------------------------------------------------------------
