# Linux System Administration Guide for DevOps Engineers

## System Services and Process Management

### Systemd Service Management

#### Understanding Systemd Units
```bash
# Unit types
.service    # System services
.socket     # Network sockets
.target     # Groups of units
.mount      # Mount points
.timer      # Scheduled tasks
.path       # Path-based activation
.device     # Device units
```

#### Service Management Commands
```bash
# Service status and control
systemctl status service_name     # Check service status
systemctl start service_name      # Start service
systemctl stop service_name       # Stop service
systemctl restart service_name    # Restart service
systemctl reload service_name     # Reload configuration
systemctl enable service_name     # Enable at boot
systemctl disable service_name    # Disable at boot
systemctl mask service_name       # Prevent service from starting
systemctl unmask service_name     # Remove mask

# System-wide operations
systemctl daemon-reload           # Reload systemd configuration
systemctl list-units             # List all active units
systemctl list-units --failed    # List failed units
systemctl list-unit-files        # List all unit files
systemctl get-default            # Show default target
systemctl set-default multi-user.target  # Set default target
```

#### Creating Custom Services
```bash
# /etc/systemd/system/myapp.service
[Unit]
Description=My Application Service
After=network.target
Wants=network-online.target

[Service]
Type=simple
User=myapp
Group=myapp
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/bin/myapp --config /etc/myapp/config.yml
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=myapp

# Security settings
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/lib/myapp /var/log/myapp

[Install]
WantedBy=multi-user.target
```

#### Service Dependencies and Ordering
```bash
# Dependency types
Requires=       # Hard dependency (fails if dependency fails)
Wants=          # Soft dependency (continues if dependency fails)
Requisite=      # Must be running before start
BindsTo=        # Stops when dependency stops

# Ordering
Before=         # Start before specified units
After=          # Start after specified units

# Example complex service
[Unit]
Description=Web Application
After=network.target postgresql.service redis.service
Wants=network-online.target
Requires=postgresql.service
BindsTo=redis.service

[Service]
Type=notify
ExecStart=/usr/bin/webapp
ExecReload=/bin/kill -USR1 $MAINPID
```

### Process Management and Monitoring

#### Advanced Process Control
```bash
# Process priorities
nice -n 10 command               # Start with lower priority
renice -n 5 -p PID              # Change priority of running process
ionice -c 3 -p PID              # Set I/O priority (idle class)

# Process limits
ulimit -a                       # Show all limits
ulimit -n 65536                 # Set file descriptor limit
ulimit -u 4096                  # Set process limit
ulimit -f unlimited             # Set file size limit

# Persistent limits (/etc/security/limits.conf)
username soft nofile 65536
username hard nofile 65536
@group soft nproc 4096
@group hard nproc 8192
```

#### Process Monitoring Tools
```bash
# Real-time monitoring
htop                            # Interactive process viewer
atop                            # Advanced system monitor
iotop                           # I/O monitoring
pidstat 1                       # Process statistics every second
vmstat 1                        # Virtual memory statistics

# Process analysis
pstree                          # Process tree
pgrep -f pattern                # Find processes by pattern
pkill -f pattern                # Kill processes by pattern
lsof -p PID                     # Files opened by process
strace -p PID                   # System call tracing
```

## User and Group Management

### Advanced User Management

#### User Account Creation and Management
```bash
# Create user with specific settings
useradd -m -s /bin/bash -G sudo,docker -c "John Doe" -e 2024-12-31 username

# User modification
usermod -aG group username      # Add user to group
usermod -s /bin/zsh username    # Change shell
usermod -L username             # Lock account
usermod -U username             # Unlock account
usermod -e 2024-12-31 username  # Set expiry date

# Password management
passwd username                 # Set password
passwd -l username              # Lock password
passwd -u username              # Unlock password
passwd -d username              # Delete password
chage -l username               # Show password aging info
chage -M 90 username            # Set max password age
chage -E 2024-12-31 username    # Set account expiry
```

#### Group Management
```bash
# Group operations
groupadd -g 1001 developers     # Create group with specific GID
groupmod -n newname oldname     # Rename group
gpasswd -a username group       # Add user to group
gpasswd -d username group       # Remove user from group
gpasswd -A admin group          # Set group administrator

# Group information
groups username                 # Show user's groups
id username                     # Show user and group IDs
getent group groupname          # Get group information
```

### Sudo Configuration and Security

#### Sudoers File Configuration
```bash
# /etc/sudoers (edit with visudo)

# User privilege specification
root    ALL=(ALL:ALL) ALL
username ALL=(ALL:ALL) ALL

# Group privileges
%sudo   ALL=(ALL:ALL) ALL
%wheel  ALL=(ALL:ALL) ALL

# Command-specific privileges
username ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx
username ALL=(ALL) NOPASSWD: /usr/bin/docker

# Host-specific privileges
username webservers=(ALL) /usr/bin/systemctl restart apache2

# Alias definitions
User_Alias ADMINS = alice, bob, charlie
Cmnd_Alias SERVICES = /usr/bin/systemctl, /usr/sbin/service
Host_Alias WEBSERVERS = web1, web2, web3

ADMINS WEBSERVERS = (ALL) SERVICES

# Security options
Defaults env_reset
Defaults mail_badpass
Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Defaults timestamp_timeout=15
Defaults passwd_tries=3
```

#### Sudo Security Best Practices
```bash
# Audit sudo usage
sudo -l                         # List allowed commands
sudo -ll                        # Detailed list
last -f /var/log/wtmp           # Login history
grep sudo /var/log/auth.log     # Sudo usage logs

# Sudo session management
sudo -k                         # Clear sudo timestamp
sudo -K                         # Clear all sudo timestamps
sudo -v                         # Refresh sudo timestamp
```

## Storage and File System Management

### Disk and Partition Management

#### Disk Information and Partitioning
```bash
# Disk information
lsblk                           # List block devices
fdisk -l                        # List all disks and partitions
parted -l                       # List partitions (parted)
blkid                           # Show block device attributes
lshw -class disk                # Hardware information

# Partitioning with fdisk
fdisk /dev/sda                  # Interactive partitioning
# Commands within fdisk:
# n - new partition
# d - delete partition
# t - change partition type
# p - print partition table
# w - write changes
# q - quit without saving

# Partitioning with parted
parted /dev/sda mklabel gpt     # Create GPT partition table
parted /dev/sda mkpart primary ext4 0% 50%    # Create partition
parted /dev/sda rm 1            # Remove partition 1
```

#### File System Creation and Management
```bash
# Create file systems
mkfs.ext4 /dev/sda1             # Create ext4 filesystem
mkfs.xfs /dev/sda1              # Create XFS filesystem
mkfs.btrfs /dev/sda1            # Create Btrfs filesystem

# File system options
mkfs.ext4 -L "DataDisk" /dev/sda1           # Set label
mkfs.ext4 -m 1 /dev/sda1                    # Set reserved space to 1%
mkfs.xfs -f -L "LogDisk" /dev/sda1          # Force create with label

# File system checking and repair
fsck /dev/sda1                  # Check filesystem
fsck -y /dev/sda1               # Auto-repair filesystem
e2fsck -f /dev/sda1             # Force check ext2/3/4
xfs_repair /dev/sda1            # Repair XFS filesystem
```

### Mount Management

#### Manual Mounting
```bash
# Basic mounting
mount /dev/sda1 /mnt            # Mount filesystem
mount -t ext4 /dev/sda1 /mnt    # Mount with specific type
mount -o ro /dev/sda1 /mnt      # Mount read-only
umount /mnt                     # Unmount filesystem
umount -f /mnt                  # Force unmount
umount -l /mnt                  # Lazy unmount

# Mount options
mount -o rw,noatime,nodev /dev/sda1 /mnt    # Multiple options
mount -o loop disk.img /mnt                  # Mount disk image
mount -o bind /source /destination           # Bind mount
```

#### Persistent Mounting (/etc/fstab)
```bash
# /etc/fstab format:
# <device> <mountpoint> <fstype> <options> <dump> <pass>

# Examples
/dev/sda1 / ext4 defaults 0 1
/dev/sda2 /home ext4 defaults,nodev 0 2
/dev/sda3 /var/log ext4 defaults,nodev,nosuid,noexec 0 2
/dev/sda4 /tmp ext4 defaults,nodev,nosuid,noexec 0 2
/dev/sda5 swap swap defaults 0 0

# Network filesystems
192.168.1.100:/export/data /mnt/nfs nfs defaults,_netdev 0 0
//server/share /mnt/cifs cifs username=user,password=pass,_netdev 0 0

# Test fstab entries
mount -a                        # Mount all fstab entries
findmnt --verify               # Verify fstab syntax
```

### LVM (Logical Volume Management)

#### LVM Concepts and Commands
```bash
# Physical Volumes (PV)
pvcreate /dev/sda1 /dev/sdb1    # Create physical volumes
pvdisplay                       # Show PV information
pvs                             # Show PV summary

# Volume Groups (VG)
vgcreate vg_data /dev/sda1 /dev/sdb1    # Create volume group
vgextend vg_data /dev/sdc1      # Add PV to VG
vgdisplay                       # Show VG information
vgs                             # Show VG summary

# Logical Volumes (LV)
lvcreate -L 10G -n lv_web vg_data       # Create 10GB LV
lvcreate -l 100%FREE -n lv_logs vg_data # Use all free space
lvextend -L +5G /dev/vg_data/lv_web     # Extend LV by 5GB
lvresize -L 20G /dev/vg_data/lv_web     # Resize to 20GB
lvdisplay                       # Show LV information
lvs                             # Show LV summary
```

#### LVM Snapshots
```bash
# Create snapshot
lvcreate -L 1G -s -n lv_web_snap /dev/vg_data/lv_web

# Mount snapshot
mkdir /mnt/snapshot
mount /dev/vg_data/lv_web_snap /mnt/snapshot

# Remove snapshot
umount /mnt/snapshot
lvremove /dev/vg_data/lv_web_snap
```

## System Monitoring and Performance

### System Resource Monitoring

#### CPU Monitoring
```bash
# CPU information
lscpu                           # CPU architecture info
cat /proc/cpuinfo               # Detailed CPU info
nproc                           # Number of processors

# CPU usage monitoring
top                             # Real-time CPU usage
htop                            # Enhanced top
sar -u 1 10                     # CPU usage every second for 10 times
mpstat 1                        # Multi-processor statistics
iostat -c 1                     # CPU statistics
```

#### Memory Monitoring
```bash
# Memory information
free -h                         # Memory usage (human readable)
cat /proc/meminfo               # Detailed memory info
vmstat 1                        # Virtual memory statistics
sar -r 1 10                     # Memory usage statistics

# Memory analysis
pmap -x PID                     # Process memory map
smem                            # Memory usage by process
ps aux --sort=-%mem | head -10  # Top memory consumers
```

#### Disk I/O Monitoring
```bash
# Disk usage
df -h                           # Disk space usage
du -sh /path/*                  # Directory sizes
ncdu /path                      # Interactive disk usage

# I/O monitoring
iostat -x 1                     # Extended I/O statistics
iotop                           # I/O usage by process
sar -d 1 10                     # Disk activity statistics
```

### Log Management and Analysis

#### Systemd Journal Management
```bash
# Journal viewing
journalctl                      # Show all journal entries
journalctl -f                   # Follow journal
journalctl -u service_name      # Service-specific logs
journalctl -p err               # Error level logs only
journalctl --since "1 hour ago" # Recent logs
journalctl --until "2024-01-01" # Logs until date
journalctl -n 50                # Last 50 entries
journalctl -o json              # JSON output format

# Journal management
journalctl --disk-usage         # Show disk usage
journalctl --vacuum-time=7d     # Keep only 7 days of logs
journalctl --vacuum-size=100M   # Keep only 100MB of logs
journalctl --rotate             # Rotate journal files
```

#### Log Rotation Configuration
```bash
# /etc/logrotate.conf
daily                           # Rotate daily
weekly                          # Rotate weekly
monthly                         # Rotate monthly
rotate 52                       # Keep 52 old logs
compress                        # Compress old logs
delaycompress                   # Delay compression
missingok                       # Don't error if log missing
notifempty                      # Don't rotate empty logs
create 644 root root            # Create new log with permissions

# Application-specific rotation
# /etc/logrotate.d/nginx
/var/log/nginx/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 www-data adm
    sharedscripts
    prerotate
        if [ -d /etc/logrotate.d/httpd-prerotate ]; then \
            run-parts /etc/logrotate.d/httpd-prerotate; \
        fi
    endscript
    postrotate
        invoke-rc.d nginx rotate >/dev/null 2>&1
    endscript
}
```

## System Security and Hardening

### Security Auditing

#### System Security Checks
```bash
# File permissions audit
find / -type f -perm /o+w 2>/dev/null          # World-writable files
find / -type f -perm /4000 2>/dev/null         # SUID files
find / -type f -perm /2000 2>/dev/null         # SGID files
find / -nouser -o -nogroup 2>/dev/null         # Orphaned files

# Network security
ss -tuln                        # Listening ports
netstat -tulpn                  # Listening ports (legacy)
lsof -i                         # Network connections

# Process security
ps aux --forest                 # Process tree
lsof -p PID                     # Files opened by process
```

#### Security Tools
```bash
# System auditing
lynis audit system              # Security audit
rkhunter --check               # Rootkit detection
chkrootkit                     # Alternative rootkit scanner
aide --init                    # File integrity monitoring

# Network security
nmap -sS localhost             # Port scan
fail2ban-client status         # Intrusion prevention status
```

### System Hardening

#### Kernel Security Parameters
```bash
# /etc/sysctl.conf or /etc/sysctl.d/99-security.conf

# Network security
net.ipv4.ip_forward = 0                    # Disable IP forwarding
net.ipv4.conf.all.send_redirects = 0      # Disable ICMP redirects
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_redirects = 0    # Don't accept redirects
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0    # Don't accept secure redirects
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1  # Ignore ping broadcasts
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Memory protection
kernel.dmesg_restrict = 1                  # Restrict dmesg
kernel.kptr_restrict = 2                   # Hide kernel pointers
kernel.yama.ptrace_scope = 1               # Restrict ptrace

# Apply settings
sysctl -p                                  # Reload sysctl settings
```

#### Service Hardening
```bash
# Disable unnecessary services
systemctl list-unit-files --type=service --state=enabled
systemctl disable service_name

# Remove unnecessary packages
apt autoremove                  # Remove unused packages
apt autoclean                   # Clean package cache

# Update system
apt update && apt upgrade -y    # Debian/Ubuntu
yum update -y                   # Red Hat/CentOS
```

## Backup and Recovery

### Backup Strategies

#### File-based Backups
```bash
# rsync backups
rsync -av --delete /source/ /backup/        # Mirror backup
rsync -av --backup --suffix=.bak /source/ /backup/  # Keep old versions
rsync -av -e ssh /source/ user@server:/backup/      # Remote backup

# tar backups
tar -czf backup_$(date +%Y%m%d).tar.gz /path/to/backup
tar -cjf backup_$(date +%Y%m%d).tar.bz2 /path/to/backup

# Incremental backups with tar
tar -czf full_backup.tar.gz -g snapshot.snar /path/to/backup
tar -czf incremental_backup.tar.gz -g snapshot.snar /path/to/backup
```

#### Database Backups
```bash
# MySQL/MariaDB
mysqldump -u root -p --all-databases > all_databases.sql
mysqldump -u root -p database_name > database_backup.sql
mysqldump -u root -p --single-transaction --routines --triggers database_name > backup.sql

# PostgreSQL
pg_dumpall -U postgres > all_databases.sql
pg_dump -U postgres database_name > database_backup.sql
pg_basebackup -U postgres -D /backup/postgres -Ft -z -P
```

#### Automated Backup Script
```bash
#!/bin/bash
# Comprehensive backup script

BACKUP_ROOT="/opt/backups"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30
LOG_FILE="/var/log/backup.log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

backup_files() {
    local source="$1"
    local dest="$2"
    
    log_message "Starting file backup: $source -> $dest"
    
    if rsync -av --delete "$source/" "$dest/"; then
        log_message "File backup completed successfully"
    else
        log_message "ERROR: File backup failed"
        return 1
    fi
}

backup_database() {
    local db_name="$1"
    local backup_file="$BACKUP_ROOT/db_${db_name}_${DATE}.sql.gz"
    
    log_message "Starting database backup: $db_name"
    
    if mysqldump -u backup_user -p"$DB_PASSWORD" "$db_name" | gzip > "$backup_file"; then
        log_message "Database backup completed: $backup_file"
    else
        log_message "ERROR: Database backup failed"
        return 1
    fi
}

cleanup_old_backups() {
    log_message "Cleaning up backups older than $RETENTION_DAYS days"
    find "$BACKUP_ROOT" -type f -mtime +$RETENTION_DAYS -delete
}

main() {
    log_message "Starting backup process"
    
    # Create backup directory
    mkdir -p "$BACKUP_ROOT"
    
    # Backup files
    backup_files "/etc" "$BACKUP_ROOT/etc"
    backup_files "/home" "$BACKUP_ROOT/home"
    backup_files "/var/www" "$BACKUP_ROOT/www"
    
    # Backup databases
    backup_database "production_db"
    backup_database "staging_db"
    
    # Cleanup old backups
    cleanup_old_backups
    
    log_message "Backup process completed"
}

main "$@"
```

This comprehensive system administration guide covers the essential topics that DevOps engineers need to master for managing Linux systems effectively in production environments.