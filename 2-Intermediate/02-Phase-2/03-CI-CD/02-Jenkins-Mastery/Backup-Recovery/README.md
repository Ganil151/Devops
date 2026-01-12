# Jenkins Backup and Recovery

Comprehensive backup strategies and disaster recovery procedures for Jenkins infrastructure.

## Backup Strategy

### What to Backup
```bash
# Critical Jenkins data
/var/lib/jenkins/config.xml          # Main configuration
/var/lib/jenkins/jobs/               # Job configurations
/var/lib/jenkins/users/              # User accounts
/var/lib/jenkins/secrets/            # Encryption keys
/var/lib/jenkins/plugins/            # Installed plugins
/var/lib/jenkins/credentials.xml     # Stored credentials
/var/lib/jenkins/nodes/              # Node configurations
```

### Backup Types
```bash
# Full backup - Complete Jenkins home
# Configuration backup - Settings and job definitions only  
# Incremental backup - Changed files since last backup
# Hot backup - Backup while Jenkins is running
# Cold backup - Backup while Jenkins is stopped
```

## Automated Backup Scripts

### Full Backup Script
```bash
#!/bin/bash
# jenkins-backup.sh

JENKINS_HOME="/var/lib/jenkins"
BACKUP_DIR="/backup/jenkins"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="jenkins_backup_$DATE"
RETENTION_DAYS=30

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Stop Jenkins for consistent backup (optional)
# sudo systemctl stop jenkins

echo "Starting Jenkins backup: $BACKUP_NAME"

# Create tar archive excluding unnecessary files
tar -czf "$BACKUP_DIR/$BACKUP_NAME.tar.gz" \
    --exclude="$JENKINS_HOME/workspace/*" \
    --exclude="$JENKINS_HOME/builds/*/archive" \
    --exclude="$JENKINS_HOME/logs/*" \
    --exclude="$JENKINS_HOME/.m2/repository" \
    --exclude="$JENKINS_HOME/war" \
    -C "$(dirname "$JENKINS_HOME")" \
    "$(basename "$JENKINS_HOME")"

# Restart Jenkins if stopped
# sudo systemctl start jenkins

# Verify backup
if [[ -f "$BACKUP_DIR/$BACKUP_NAME.tar.gz" ]]; then
    BACKUP_SIZE=$(du -h "$BACKUP_DIR/$BACKUP_NAME.tar.gz" | cut -f1)
    echo "✓ Backup completed: $BACKUP_NAME.tar.gz ($BACKUP_SIZE)"
    
    # Test archive integrity
    if tar -tzf "$BACKUP_DIR/$BACKUP_NAME.tar.gz" > /dev/null; then
        echo "✓ Backup integrity verified"
    else
        echo "✗ Backup integrity check failed"
        exit 1
    fi
else
    echo "✗ Backup failed"
    exit 1
fi

# Cleanup old backups
find "$BACKUP_DIR" -name "jenkins_backup_*.tar.gz" -mtime +$RETENTION_DAYS -delete
echo "✓ Old backups cleaned up (older than $RETENTION_DAYS days)"

# Upload to cloud storage (optional)
# aws s3 cp "$BACKUP_DIR/$BACKUP_NAME.tar.gz" s3://jenkins-backups/
```

### Configuration-Only Backup
```bash
#!/bin/bash
# jenkins-config-backup.sh

JENKINS_HOME="/var/lib/jenkins"
BACKUP_DIR="/backup/jenkins-config"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

# Backup configuration files only
rsync -av --delete \
    --include="config.xml" \
    --include="jobs/" \
    --include="jobs/*/config.xml" \
    --include="users/" \
    --include="users/*/config.xml" \
    --include="secrets/" \
    --include="credentials.xml" \
    --include="nodes/" \
    --include="plugins/" \
    --include="plugins/*.jpi" \
    --exclude="*" \
    "$JENKINS_HOME/" "$BACKUP_DIR/config_$DATE/"

echo "Configuration backup completed: config_$DATE"
```

### Database Backup (if using external DB)
```bash
#!/bin/bash
# jenkins-db-backup.sh

DB_HOST="localhost"
DB_NAME="jenkins"
DB_USER="jenkins"
DB_PASSWORD="password"
BACKUP_DIR="/backup/jenkins-db"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

# PostgreSQL backup
pg_dump -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" \
    --no-password --clean --create \
    > "$BACKUP_DIR/jenkins_db_$DATE.sql"

# Compress backup
gzip "$BACKUP_DIR/jenkins_db_$DATE.sql"

echo "Database backup completed: jenkins_db_$DATE.sql.gz"
```

## Cloud Backup Integration

### AWS S3 Backup
```bash
#!/bin/bash
# jenkins-s3-backup.sh

JENKINS_HOME="/var/lib/jenkins"
S3_BUCKET="jenkins-backups"
DATE=$(date +%Y%m%d_%H%M%S)
TEMP_DIR="/tmp/jenkins-backup-$DATE"

# Create temporary backup
mkdir -p "$TEMP_DIR"
tar -czf "$TEMP_DIR/jenkins_$DATE.tar.gz" \
    --exclude="workspace/*" \
    --exclude="builds/*/archive" \
    -C "$(dirname "$JENKINS_HOME")" \
    "$(basename "$JENKINS_HOME")"

# Upload to S3
aws s3 cp "$TEMP_DIR/jenkins_$DATE.tar.gz" \
    "s3://$S3_BUCKET/jenkins_$DATE.tar.gz" \
    --storage-class STANDARD_IA

# Cleanup
rm -rf "$TEMP_DIR"

# Set lifecycle policy for old backups
aws s3api put-bucket-lifecycle-configuration \
    --bucket "$S3_BUCKET" \
    --lifecycle-configuration file://lifecycle.json
```

### Azure Blob Storage Backup
```bash
#!/bin/bash
# jenkins-azure-backup.sh

JENKINS_HOME="/var/lib/jenkins"
STORAGE_ACCOUNT="jenkinsbackups"
CONTAINER="backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup
tar -czf "/tmp/jenkins_$DATE.tar.gz" \
    --exclude="workspace/*" \
    -C "$(dirname "$JENKINS_HOME")" \
    "$(basename "$JENKINS_HOME")"

# Upload to Azure
az storage blob upload \
    --account-name "$STORAGE_ACCOUNT" \
    --container-name "$CONTAINER" \
    --name "jenkins_$DATE.tar.gz" \
    --file "/tmp/jenkins_$DATE.tar.gz"

# Cleanup local file
rm "/tmp/jenkins_$DATE.tar.gz"
```

## Disaster Recovery

### Recovery Procedures

#### Complete System Recovery
```bash
#!/bin/bash
# jenkins-restore.sh

BACKUP_FILE="$1"
JENKINS_HOME="/var/lib/jenkins"
JENKINS_USER="jenkins"

if [[ -z "$BACKUP_FILE" ]]; then
    echo "Usage: $0 <backup_file.tar.gz>"
    exit 1
fi

echo "Starting Jenkins recovery from: $BACKUP_FILE"

# Stop Jenkins
sudo systemctl stop jenkins

# Backup current installation (if exists)
if [[ -d "$JENKINS_HOME" ]]; then
    sudo mv "$JENKINS_HOME" "${JENKINS_HOME}.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Extract backup
sudo mkdir -p "$JENKINS_HOME"
sudo tar -xzf "$BACKUP_FILE" -C "$(dirname "$JENKINS_HOME")"

# Set proper ownership
sudo chown -R "$JENKINS_USER:$JENKINS_USER" "$JENKINS_HOME"

# Set proper permissions
sudo chmod 755 "$JENKINS_HOME"
sudo chmod 600 "$JENKINS_HOME/secrets/"*

# Start Jenkins
sudo systemctl start jenkins

echo "✓ Jenkins recovery completed"
echo "Please verify Jenkins is working at: http://localhost:8080"
```

#### Selective Recovery
```bash
#!/bin/bash
# jenkins-selective-restore.sh

BACKUP_FILE="$1"
COMPONENT="$2"  # jobs, users, plugins, config

case "$COMPONENT" in
    "jobs")
        tar -xzf "$BACKUP_FILE" --strip-components=3 -C /var/lib/jenkins/ jenkins/jobs/
        ;;
    "users")
        tar -xzf "$BACKUP_FILE" --strip-components=3 -C /var/lib/jenkins/ jenkins/users/
        ;;
    "plugins")
        tar -xzf "$BACKUP_FILE" --strip-components=3 -C /var/lib/jenkins/ jenkins/plugins/
        ;;
    "config")
        tar -xzf "$BACKUP_FILE" --strip-components=2 -C /var/lib/jenkins/ jenkins/config.xml
        ;;
    *)
        echo "Usage: $0 <backup_file> <jobs|users|plugins|config>"
        exit 1
        ;;
esac

sudo chown -R jenkins:jenkins /var/lib/jenkins/
sudo systemctl restart jenkins
```

### Migration Procedures

#### Jenkins Migration Script
```bash
#!/bin/bash
# jenkins-migrate.sh

SOURCE_HOST="$1"
TARGET_HOST="$2"
JENKINS_USER="jenkins"

if [[ -z "$SOURCE_HOST" || -z "$TARGET_HOST" ]]; then
    echo "Usage: $0 <source_host> <target_host>"
    exit 1
fi

echo "Migrating Jenkins from $SOURCE_HOST to $TARGET_HOST"

# Create backup on source
ssh "$SOURCE_HOST" "sudo systemctl stop jenkins"
ssh "$SOURCE_HOST" "sudo tar -czf /tmp/jenkins-migration.tar.gz -C /var/lib jenkins"

# Transfer backup
scp "$SOURCE_HOST:/tmp/jenkins-migration.tar.gz" /tmp/

# Restore on target
ssh "$TARGET_HOST" "sudo systemctl stop jenkins"
scp /tmp/jenkins-migration.tar.gz "$TARGET_HOST:/tmp/"
ssh "$TARGET_HOST" "sudo tar -xzf /tmp/jenkins-migration.tar.gz -C /var/lib/"
ssh "$TARGET_HOST" "sudo chown -R $JENKINS_USER:$JENKINS_USER /var/lib/jenkins"
ssh "$TARGET_HOST" "sudo systemctl start jenkins"

# Cleanup
rm /tmp/jenkins-migration.tar.gz
ssh "$SOURCE_HOST" "rm /tmp/jenkins-migration.tar.gz"
ssh "$TARGET_HOST" "rm /tmp/jenkins-migration.tar.gz"

echo "✓ Migration completed"
```

## Backup Monitoring

### Backup Verification Script
```bash
#!/bin/bash
# verify-jenkins-backup.sh

BACKUP_DIR="/backup/jenkins"
ALERT_EMAIL="admin@example.com"
MAX_AGE_HOURS=25  # Alert if no backup in 25 hours

# Find latest backup
LATEST_BACKUP=$(find "$BACKUP_DIR" -name "jenkins_backup_*.tar.gz" -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -d' ' -f2-)

if [[ -z "$LATEST_BACKUP" ]]; then
    echo "No backups found in $BACKUP_DIR" | mail -s "Jenkins Backup Alert" "$ALERT_EMAIL"
    exit 1
fi

# Check backup age
BACKUP_AGE=$(find "$LATEST_BACKUP" -mtime +1 -print)
if [[ -n "$BACKUP_AGE" ]]; then
    echo "Latest Jenkins backup is older than $MAX_AGE_HOURS hours: $LATEST_BACKUP" | \
    mail -s "Jenkins Backup Alert" "$ALERT_EMAIL"
    exit 1
fi

# Verify backup integrity
if ! tar -tzf "$LATEST_BACKUP" > /dev/null 2>&1; then
    echo "Jenkins backup integrity check failed: $LATEST_BACKUP" | \
    mail -s "Jenkins Backup Alert" "$ALERT_EMAIL"
    exit 1
fi

echo "✓ Latest backup verified: $LATEST_BACKUP"
```

This comprehensive Jenkins backup and recovery guide provides enterprise-grade data protection and disaster recovery capabilities.