```sh
 sudo oscap xccdf eval \
 --profile xccdf_org.ssgproject.content_profile_cis \
 --results /tmp/baseline_results.xml \
 --report /tmp/baseline_report.html \
 /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml
```
WARNING: Datastream component 'scap_org.open-scap_cref_security-data-oval-com.redhat.rhsa-RHEL8.xml' points out to the remote 'https://www.redhat.com/security/data/oval/com.redhat.rhsa-RHEL8.xml'. Use '--fetch-remote-resources' option to download it.
WARNING: Skipping 'https://www.redhat.com/security/data/oval/com.redhat.rhsa-RHEL8.xml' file which is referenced from datastream
WARNING: Skipping ./security-data-oval-com.redhat.rhsa-RHEL8.xml file which is referenced from XCCDF content

---
### To **verify if the audit rules above already exist and are active**, and to ensure they will not result in failure on the next scan, follow these steps:

#### 1. List All Active Audit Rule
```bash
sudo auditctl -l
```
This command displays all currently loaded audit rules.

#### 2. Search for Specific Rules
For each rule, use `grep` to check if it is present and active. For example:
```bash
# Check for MAC policy rules
sudo auditctl -l | grep MAC-policy

# Check for media export rules
sudo auditctl -l | grep media_export

# Check for network modifications
sudo auditctl -l | grep network_modifications

# Check for session events
sudo auditctl -l | grep session

# Check for sysadmin actions
sudo auditctl -l | grep actions

# Check for user/group modifications
sudo auditctl -l | grep identity

# Check for DAC modifications
sudo auditctl -l | grep perm_mod

# Check for file deletions
sudo auditctl -l | grep delete

# Check for unsuccessful file modifications
sudo auditctl -l | grep access

# Check for kernel module loading/unloading
sudo auditctl -l | grep modules
```
#### 3. Check for Rule Duplicates or Conflicts
Ensure each rule appears only once and is not overridden by another rule. If you see multiple entries for the same syscall or file, review your `/etc/audit/rules.d/*.rules` files for duplicates.
#### 4. Check for Rule Persistence
Audit rules loaded with `auditctl` are not persistent across reboots. To ensure persistence:
- Rules must be present in `/etc/audit/rules.d/*.rules` or `/etc/audit/audit.rules`.
- After editing or adding rules, reload them:
  ```bash
  sudo augenrules --load
  ```
#### 5. Test Rule Effectiveness
Trigger an event that should be logged (e.g., modify `/etc/group` or attempt a failed file access), then search the audit logs:
```bash
sudo ausearch -k identity
sudo ausearch -k delete
sudo ausearch -k access
```
If you see relevant entries, the rule is active and working.
#### 6. Confirm No Failures in OpenSCAP
After verifying rules are loaded and effective, rerun your OpenSCAP scan:
```bash
sudo oscap xccdf eval --profile <profile> --results /tmp/results.xml --report /tmp/report.html <path-to-xccdf-or-ds.xml>
```
Check the report for any remaining failures.
#### Summary Table

| Rule Key         | Check Command Example                        |
|------------------|---------------------------------------------|
| MAC-policy       | `sudo auditctl -l | grep MAC-policy`         |
| media_export     | `sudo auditctl -l | grep media_export`       |
| network_modifications | `sudo auditctl -l | grep network_modifications` |
| session          | `sudo auditctl -l | grep session`            |
| actions          | `sudo auditctl -l | grep actions`            |
| identity         | `sudo auditctl -l | grep identity`           |
| perm_mod         | `sudo auditctl -l | grep perm_mod`           |
| delete           | `sudo auditctl -l | grep delete`             |
| access           | `sudo auditctl -l | grep access`             |
| modules          | `sudo auditctl -l | grep modules`            |
**If all rules are present in the output and log events as expected, they are active and will not result in failure on the next scan.**  
If any are missing, review your `/etc/audit/rules.d/` files and reload the rules.

---
### AIDE (Advanced Intrusion Detection Environment)
Title   Install AIDE
Rule    xccdf_org.ssgproject.content_rule_package_aide_installed
Ident   CCE-80844-4
Result  fail

Title   Configure Periodic Execution of AIDE
Rule    xccdf_org.ssgproject.content_rule_aide_periodic_cron_checking
Ident   CCE-80676-0
Result  fail
#### Overview :
AIDE is a host-based intrusion detection system (HIDS) that monitors file system changes. It works by creating a database of file properties and periodically checking files against this database to detect unauthorized modifications.
#### Why It's Necessary
- Helps detect unauthorized changes to system files
- Critical for security compliance and system integrity
- Can identify potential security breaches or malware
- Essential for audit trails and forensic analysis
- Required by many security standards (CIS, STIG, etc.)
#### Current Status
The OpenSCAP scan shows two AIDE-related failures:
1. `package_aide_installed` - AIDE is not installed
2. `aide_periodic_cron_checking` - Periodic checks are not configured
#### How to Fix
 1. Install AIDE
```bash
# Install AIDE package
sudo dnf install aide

# Initialize AIDE database
sudo aide --init

# Move the initialized database to the default location
sudo mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
```
 2. Configure Periodic Checks
```bash
# Create a cron job for daily AIDE checks
sudo echo "0 5 * * * root /usr/sbin/aide --check" > /etc/cron.daily/aide
```
 3. Configure AIDE Rules
Create or edit `/etc/aide.conf`:
```bash
# Basic configuration example
database=file:/var/lib/aide/aide.db
database_out=file:/var/lib/aide/aide.db.new
database_new=file:/var/lib/aide/aide.db.new
gzip_dbout=yes

# Define what to monitor
/etc p+i+n+u+g+s+m+c+md5
/bin p+i+n+u+g+s+m+c+md5
/sbin p+i+n+u+g+s+m+c+md5
/usr p+i+n+u+g+s+m+c+md5
```
4. Verify Installation
```bash
# Run a manual check
sudo aide --check

# Review the results
sudo aide --update
```
#### Log Monitoring
```bash
# Monitor AIDE log files
sudo tail -f /var/log/aide/aide.log
```
#### Best Practices
1. Store the AIDE database on read-only media
2. Configure email notifications for changes
3. Review AIDE reports regularly
4. Update the database after legitimate changes
5. Backup the AIDE database
6. Document all authorized changes
#### Automation Script 
How to automate and implement AIDE best practices:
1. First, create an automated installation and configuration script:
````bash
#!/bin/bash
# filepath: /root/scripts/aide_setup.sh

# Install AIDE if not present
if ! rpm -q aide &>/dev/null; then
    dnf install -y aide
fi

# Backup original config if exists
if [ -f "/etc/aide.conf" ]; then
    cp /etc/aide.conf /etc/aide.conf.bak
fi

# Create enhanced AIDE configuration
cat > /etc/aide.conf <<EOF
# AIDE configuration
database=file:/var/lib/aide/aide.db
database_out=file:/var/lib/aide/aide.db.new
database_new=file:/var/lib/aide/aide.db.new
gzip_dbout=yes

# Mail configuration
report_url=mailto:root@localhost

# Monitoring rules
/etc    PERMS+FTYPE+P+U+G+I+ANF+SHA512
/bin    PERMS+FTYPE+P+U+G+I+ANF+SHA512
/sbin   PERMS+FTYPE+P+U+G+I+ANF+SHA512
/usr    PERMS+FTYPE+P+U+G+I+ANF+SHA512
/var    PERMS+FTYPE+P+U+G+I+ANF+SHA512
!/var/log/.*  # Exclude logs
!/var/spool/.* # Exclude spools

# Custom rules
@@define CONTENT SHA512+FTYPE
@@define SYSTEM PERMS+FTYPE+P+U+G
EOF

# Initialize AIDE database
aide --init
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

# Create backup copy on separate media (if available)
if [ -d "/mnt/backup" ]; then
    cp /var/lib/aide/aide.db.gz /mnt/backup/
fi
````
2. Create an automated checking and notification script:
````bash
#!/bin/bash
# filepath: /root/scripts/aide_check.sh

# Set email for notifications
ADMIN_EMAIL="admin@yourdomain.com"

# Run AIDE check
aide --check > /var/log/aide/aide_check.log 2>&1
CHECK_STATUS=$?

# Send notification if changes detected
if [ $CHECK_STATUS -ne 0 ]; then
    mail -s "AIDE: System Changes Detected" $ADMIN_EMAIL < /var/log/aide/aide_check.log
fi

# Rotate logs
if [ -f "/var/log/aide/aide_check.log" ]; then
    mv /var/log/aide/aide_check.log /var/log/aide/aide_check.log.1
    gzip /var/log/aide/aide_check.log.1
fi
````
3. Create systemd timer for automated checks:
````ini
[Unit]
Description=Daily AIDE check

[Timer]
OnCalendar=*-*-* 05:00:00
RandomizedDelaySec=1800
Persistent=true

[Install]
WantedBy=timers.target
````
4. Create corresponding service file:
````ini
[Unit]
Description=AIDE check service
After=network.target

[Service]
Type=oneshot
ExecStart=/root/scripts/aide_check.sh
Nice=19
IOSchedulingClass=idle

[Install]
WantedBy=multi-user.target
````
5. Create database update script:
````bash
#!/bin/bash
# filepath: /root/scripts/aide_update.sh

# Log the update
echo "AIDE database update initiated $(date)" >> /var/log/aide/updates.log

# Backup current database
cp /var/lib/aide/aide.db.gz /var/lib/aide/aide.db.gz.backup

# Update database
aide --update

# If successful, replace old database
if [ $? -eq 0 ]; then
    mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
    echo "Database updated successfully" >> /var/log/aide/updates.log
    
    # Backup to separate media if available
    if [ -d "/mnt/backup" ]; then
        cp /var/lib/aide/aide.db.gz /mnt/backup/aide.db.gz.$(date +%Y%m%d)
    fi
else
    echo "Update failed" >> /var/log/aide/updates.log
fi
````
6. Final setup commands:
````bash
# Make scripts executable
chmod +x /root/scripts/aide_*.sh

# Enable and start the timer
systemctl enable aide-check.timer
systemctl start aide-check.timer

# Create log directory
mkdir -p /var/log/aide
chmod 700 /var/log/aide

# Set up log rotation
cat > /etc/logrotate.d/aide <<EOF
/var/log/aide/*.log {
    weekly
    rotate 12
    compress
    delaycompress
    missingok
    notifempty
}
EOF
````

This implementation:
- Automates installation and configuration
- Sets up daily checks with randomized timing
- Implements email notifications
- Includes database backups
- Provides log rotation
- Includes more comprehensive file monitoring
- Adds systematic database updates
- Uses systemd timers for reliability

Remember to:
- Customize email addresses
- Adjust monitoring paths based on your needs
- Configure backup locations
- Test the implementation in a safe environment first
- Document any changes in your change management system

By implementing these fixes, you'll bring your system into compliance with security baselines and significantly improve your security posture through automated file integrity monitoring.

---
 ### System Cryptography Policy Configuration
 Title   Configure System Cryptography Policy
Rule    xccdf_org.ssgproject.content_rule_configure_crypto_policy
Ident   CCE-80935-0
Result  fail

Title   Configure SSH to use System Crypto Policy
Rule    xccdf_org.ssgproject.content_rule_configure_ssh_crypto_policy
Ident   CCE-80939-2
Result  pass
#### Overview
The System-wide Cryptographic Policies provide a centralized control over cryptographic subsystems in RHEL/CentOS 8. It ensures consistent security levels for cryptographic operations across the operating system.
#### Why It's Necessary
- Ensures consistent cryptographic security across all system services
- Prevents the use of weak or deprecated cryptographic algorithms
- Meets compliance requirements for security standards
- Simplifies cryptographic policy management
- Reduces the risk of cryptographic vulnerabilities
#### How to Fix
1. Check current policy:
```bash
update-crypto-policies --show
```
2. Set to FIPS mode:
```bash
# Set to FIPS 140-2 compliant policy
update-crypto-policies --set FIPS

# Alternatively, use DEFAULT policy for general security
update-crypto-policies --set DEFAULT
```
#### Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/crypto_policy_setup.sh

# Log file setup
LOG_FILE="/var/log/crypto_policy_setup.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting cryptographic policy configuration at $(date)"

# Function to check if running in FIPS mode
check_fips_mode() {
    if fips-mode-setup --check | grep -q "enabled"; then
        return 0
    else
        return 1
    fi
}

# Function to configure FIPS
configure_fips() {
    echo "Configuring FIPS mode..."
    
    # Backup current configuration
    cp /etc/crypto-policies/config /etc/crypto-policies/config.backup
    
    # Enable FIPS mode
    fips-mode-setup --enable
    
    # Verify the change
    if check_fips_mode; then
        echo "FIPS mode successfully enabled"
        return 0
    else
        echo "Failed to enable FIPS mode"
        return 1
    fi
}

# Function to verify system services
verify_services() {
    echo "Verifying system services..."
    
    # List of services to check
    SERVICES=("sshd" "httpd" "nginx" "postgresql")
    
    for service in "${SERVICES[@]}"; do
        if systemctl is-active --quiet "$service"; then
            systemctl restart "$service"
            echo "Restarted $service to apply new crypto policies"
        fi
    done
}

# Main execution
echo "Current crypto policy: $(update-crypto-policies --show)"

if ! check_fips_mode; then
    echo "FIPS mode is not enabled. Enabling..."
    if configure_fips; then
        # Update running system
        update-crypto-policies --set FIPS
        verify_services
        
        # Verify configuration
        echo "Verifying final configuration..."
        update-crypto-policies --show
        fips-mode-setup --check
    else
        echo "Failed to configure FIPS mode"
        exit 1
    fi
else
    echo "FIPS mode is already enabled"
fi

# Create documentation
cat > /root/crypto_policy_documentation.txt <<EOF
Cryptographic Policy Configuration
================================
Date: $(date)
Current Policy: $(update-crypto-policies --show)
FIPS Status: $(fips-mode-setup --check)

Configuration Changes Made:
- Enabled FIPS mode
- Updated system-wide crypto policies
- Restarted affected services

To verify configuration:
1. Run 'update-crypto-policies --show'
2. Run 'fips-mode-setup --check'

To revert changes:
1. Run 'fips-mode-setup --disable'
2. Run 'update-crypto-policies --set DEFAULT'
EOF

echo "Configuration complete. See $LOG_FILE for details"
````
3. Make the script executable and run:
```bash
chmod +x /root/scripts/crypto_policy_setup.sh
./root/scripts/crypto_policy_setup.sh
```
#### Verification
After running the script, verify the configuration:
```bash
update-crypto-policies --show
fips-mode-setup --check
```

This implementation ensures strong cryptographic policies across the system while maintaining compatibility with essential services.

---
### Filesystem Partitioning Configuration
Title   Ensure /home Located On Separate Partition
Rule    xccdf_org.ssgproject.content_rule_partition_for_home
Ident   CCE-81044-0
Result  fail

Title   Ensure /tmp Located On Separate Partition
Rule    xccdf_org.ssgproject.content_rule_partition_for_tmp
Ident   CCE-80851-9
Result  fail

Title   Ensure /var Located On Separate Partition
Rule    xccdf_org.ssgproject.content_rule_partition_for_var
Ident   CCE-80852-7
Result  fail

Title   Ensure /var/log Located On Separate Partition
Rule    xccdf_org.ssgproject.content_rule_partition_for_var_log
Ident   CCE-80853-5
Result  fail

Title   Ensure /var/log/audit Located On Separate Partition
Rule    xccdf_org.ssgproject.content_rule_partition_for_var_log_audit
Ident   CCE-80854-3
Result  fail

Title   Ensure /var/tmp Located On Separate Partition
Rule    xccdf_org.ssgproject.content_rule_partition_for_var_tmp
Ident   CCE-82730-3
Result  fail

#### Overview
Proper filesystem partitioning is crucial for system security and stability. Separate partitions help contain resource exhaustion and ensure proper system operation.
#### Why It's Necessary
- Prevents denial of service through disk space exhaustion
- Isolates system logs from other filesystems
- Protects audit logs from tampering
- Improves system security and stability
- Enables different mount options for different partitions
- Required by many security standards (CIS, STIG)
#### Current Status
The OpenSCAP scan shows failures for:
1. /home partition
2. /tmp partition
3. /var partition
4. /var/log partition
5. /var/log/audit partition
6. /var/tmp partition

#### How to Fix
 1. Check Current Partition Layout
```bash
# View current partition layout
df -h
lsblk
```
 2. Backup Important Data
```bash
# Backup important data before repartitioning
tar -czf /backup/home_backup.tar.gz /home
tar -czf /backup/var_backup.tar.gz /var
```
 3. Create Partitioning Script
````bash
#!/bin/bash
# filepath: /root/scripts/partition_setup.sh

# Log file setup
LOG_FILE="/var/log/partition_setup.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

# Function to create and mount partition
create_partition() {
    local mount_point=$1
    local size=$2
    local vg_name="system_vg"
    local lv_name=$(echo ${mount_point#/} | tr '/' '_')

    echo "Creating partition for $mount_point"
    
    # Create logical volume
    lvcreate -L ${size}G -n ${lv_name} ${vg_name}
    
    # Create filesystem
    mkfs.xfs /dev/${vg_name}/${lv_name}
    
    # Backup existing data
    if [ -d ${mount_point} ]; then
        mkdir -p ${mount_point}_backup
        rsync -av ${mount_point}/ ${mount_point}_backup/
    fi
    
    # Add to fstab
    echo "/dev/${vg_name}/${lv_name} ${mount_point} xfs defaults 0 2" >> /etc/fstab
    
    # Mount the partition
    mkdir -p ${mount_point}
    mount ${mount_point}
    
    # Restore data if backup exists
    if [ -d ${mount_point}_backup ]; then
        rsync -av ${mount_point}_backup/ ${mount_point}/
    fi
}

# Create partitions
create_partition /home 10
create_partition /tmp 5
create_partition /var 10
create_partition /var/log 5
create_partition /var/log/audit 2
create_partition /var/tmp 5

# Set appropriate permissions
chmod 1777 /tmp
chmod 1777 /var/tmp
````
 4. Configure Mount Options
````bash
#!/bin/bash
# filepath: /root/scripts/mount_options.sh

# Add security options to fstab
sed -i '/[[:space:]]\/tmp[[:space:]]/s/defaults/defaults,nodev,nosuid,noexec/' /etc/fstab
sed -i '/[[:space:]]\/var\/tmp[[:space:]]/s/defaults/defaults,nodev,nosuid,noexec/' /etc/fstab
sed -i '/[[:space:]]\/home[[:space:]]/s/defaults/defaults,nodev/' /etc/fstab
sed -i '/[[:space:]]\/var\/log[[:space:]]/s/defaults/defaults,nodev,nosuid,noexec/' /etc/fstab
sed -i '/[[:space:]]\/var\/log\/audit[[:space:]]/s/defaults/defaults,nodev,nosuid,noexec/' /etc/fstab

# Remount all filesystems
mount -a
````
 5. Verify Configuration
```bash
# Check mount points
mount | grep -E '/home|/tmp|/var'

# Verify mount options
cat /proc/mounts

# Check disk space
df -h
```
#### Best Practices
1. Size partitions appropriately for your use case
2. Use LVM for flexibility
3. Implement proper mount options
4. Regular monitoring of disk usage
5. Maintain backups before changes
6. Document partition layout
#### Automation Script
Create a verification script:
````bash
#!/bin/bash
# filepath: /root/scripts/verify_partitions.sh

# Check partition mount points
check_partition() {
    local mount_point=$1
    if mount | grep -q " $mount_point "; then
        echo "✓ $mount_point is properly mounted"
    else
        echo "✗ $mount_point is not mounted"
    fi
}

# Check mount options
check_mount_options() {
    local mount_point=$1
    local options=$2
    
    if mount | grep " $mount_point " | grep -q "$options"; then
        echo "✓ $mount_point has correct options"
    else
        echo "✗ $mount_point missing required options"
    fi
}

# Verify all partitions
check_partition "/home"
check_partition "/tmp"
check_partition "/var"
check_partition "/var/log"
check_partition "/var/log/audit"
check_partition "/var/tmp"

# Verify mount options
check_mount_options "/tmp" "nodev,nosuid,noexec"
check_mount_options "/var/tmp" "nodev,nosuid,noexec"
check_mount_options "/home" "nodev"
check_mount_options "/var/log" "nodev,nosuid,noexec"
check_mount_options "/var/log/audit" "nodev,nosuid,noexec"
````

Remember to:
- Adjust partition sizes based on system requirements
- Backup all data before repartitioning
- Test in a non-production environment first
- Document all changes
- Monitor disk usage regularly

This implementation will bring your system into compliance with security baselines while maintaining proper system operation.

---
**<center> Passed</center>**
Title   Make sure that the dconf databases are up-to-date with regards to respective keyfiles
Rule    xccdf_org.ssgproject.content_rule_dconf_db_up_to_date
Ident   CCE-81003-6
Result  pass

Title   Install sudo Package
Rule    xccdf_org.ssgproject.content_rule_package_sudo_installed
Ident   CCE-82214-8
Result  pass

---
### Sudo PTY Configuration
Title   Ensure Only Users Logged In To Real tty Can Execute Sudo - sudo use_pty
Rule    xccdf_org.ssgproject.content_rule_sudo_add_use_pty
Ident   CCE-83798-9
Result  fail
#### Overview
The `use_pty` configuration forces sudo to only allow running commands from a real terminal device (PTY), enhancing security by preventing execution from non-terminal processes.
#### Why It's Necessary
- Prevents automated attacks using sudo
- Ensures commands are run interactively
- Provides better audit trails
- Improves security by requiring real terminal sessions
- Helps prevent certain types of privilege escalation attacks
#### Current Status
The OpenSCAP scan shows that PTY requirement for sudo is not configured.
#### Manual Fix
Add or modify the following line in `/etc/sudoers`:
```bash
# Edit sudoers file safely using visudo
sudo visudo 

# Add the following line
Defaults use_pty
```
#### Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/configure_sudo_pty.sh

# Log file setup
LOG_FILE="/var/log/sudo_config.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting sudo PTY configuration at $(date)"

# Backup sudoers file
cp -p /etc/sudoers /etc/sudoers.$(date +%Y%m%d-%H%M%S).bak

# Check if use_pty is already configured
if ! grep -q "^Defaults.*use_pty" /etc/sudoers; then
    # Add use_pty configuration
    echo "Defaults use_pty" >> /etc/sudoers.d/pty_requirement
    chmod 440 /etc/sudoers.d/pty_requirement
    echo "Added use_pty requirement to sudoers configuration"
else
    echo "use_pty requirement already configured"
fi

# Verify the configuration
visudo -c
if [ $? -eq 0 ]; then
    echo "Sudo configuration syntax is valid"
else
    echo "Error: Sudo configuration syntax check failed"
    exit 1
fi

echo "Configuration complete. See $LOG_FILE for details"
````
#### Verification
```bash
# Check if use_pty is configured
sudo grep use_pty /etc/sudoers /etc/sudoers.d/*

# Verify sudo configuration syntax
sudo visudo -c
```

This implementation ensures that sudo commands can only be executed from real terminal sessions, improving system security.

Remember to:
- Test the configuration in a safe environment first
- Backup the sudoers file before making changes
- Verify syntax after changes
- Document all changes in your change management system

---
### Configure Sudo Logfile
Title   Ensure Sudo Logfile Exists - sudo logfile
Rule    xccdf_org.ssgproject.content_rule_sudo_custom_logfile
Ident   CCE-83601-5
Result  fail

#### Overview
The `logfile` configuration in sudo ensures all sudo commands are logged to a specific file, providing an audit trail of privileged commands executed on the system.
#### Why It's Necessary
- Creates audit trail of privileged commands
- Helps in security incident investigations
- Enables monitoring of sudo usage
- Required for compliance and auditing
- Helps detect unauthorized privilege escalation
#### Current Status
The OpenSCAP scan shows that sudo logfile is not properly configured.
#### How to Fix

##### Manual Fix
Add or modify the following line in `/etc/sudoers`:
```bash
# Edit sudoers file safely using visudo
sudo visudo

# Add the following line
Defaults logfile="/var/log/sudo.log"
```
#### Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/configure_sudo_logging.sh

# Log file setup
LOG_FILE="/var/log/sudo_config.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting sudo logging configuration at $(date)"

# Backup sudoers file
cp -p /etc/sudoers /etc/sudoers.$(date +%Y%m%d-%H%M%S).bak

# Check if logfile is already configured
if ! grep -q "^Defaults.*logfile=" /etc/sudoers; then
    # Add logfile configuration
    echo 'Defaults logfile="/var/log/sudo.log"' >> /etc/sudoers.d/logging
    chmod 440 /etc/sudoers.d/logging
    echo "Added logfile configuration to sudoers"
    
    # Create log file with proper permissions
    touch /var/log/sudo.log
    chmod 640 /var/log/sudo.log
    chown root:root /var/log/sudo.log
else
    echo "Sudo logfile already configured"
fi

# Set up log rotation
cat > /etc/logrotate.d/sudo <<EOF
/var/log/sudo.log {
    weekly
    rotate 13
    compress
    delaycompress
    missingok
    notifempty
    create 640 root root
}
EOF

# Verify the configuration
visudo -c
if [ $? -eq 0 ]; then
    echo "Sudo configuration syntax is valid"
else
    echo "Error: Sudo configuration syntax check failed"
    exit 1
fi

echo "Configuration complete. See $LOG_FILE for details"
````
#### Verification
```bash
# Check if logfile is configured
sudo grep logfile /etc/sudoers /etc/sudoers.d/*

# Verify sudo configuration syntax
sudo visudo -c

# Check log file permissions
ls -l /var/log/sudo.log
```
Remember to:
- Test the configuration in a safe environment first
- Backup the sudoers file before making changes
- Verify syntax after changes
- Set up log rotation to manage log size
- Monitor log file growth
- Document all changes in your change management system

---
<font color="#ffff00"><center>Passed</center></font>
Title   Ensure gpgcheck Enabled In Main yum Configuration
Rule    xccdf_org.ssgproject.content_rule_ensure_gpgcheck_globally_activated
Ident   CCE-80790-9
Result  pass

---
### System Login Banner Configuration
Title   Modify the System Login Banner
Rule    xccdf_org.ssgproject.content_rule_banner_etc_issue
Ident   CCE-80763-6
Result  fail

Title   Modify the System Message of the Day Banner
Rule    xccdf_org.ssgproject.content_rule_banner_etc_motd
Ident   CCE-83496-0
Result  fail
#### Overview
The system login banner and` Message of the Day` (`MOTD`) need to be properly configured to display security warnings and legal notices to users attempting to access the system.
#### Current Status
Two banner-related rules have failed:
1. `banner_etc_issue` - System Login Banner
2. `banner_etc_motd` - System Message of the Day
#### Why It's Necessary
- Legal requirement to warn unauthorized users
- Informs users about security policies
- May be required for compliance (HIPAA, PCI, etc.)
- Can be used as legal evidence in case of unauthorized access
- Sets expectations for system usage
##### Manual Fix
1. Create appropriate banners:
```bash
# Edit the login banner
sudo vi /etc/issue

# Edit the MOTD
sudo vi /etc/motd
```
 1a. System Login Banner (/etc/issue)
```bash
# Edit /etc/issue
sudo vi /etc/issue
```
Add the following content:
```text
*******************************************************************************
*                    AUTHORIZED ACCESS ONLY                                     *
*                                                                             *
* This system is restricted to authorized users for legitimate business       *
* purposes only. The actual or attempted unauthorized access, use, or         *
* modification of this system is strictly prohibited.                         *
*                                                                             *
* Unauthorized users are subject to institutional disciplinary proceedings    *
* and/or criminal and civil penalties under state, federal or other          *
* applicable domestic and foreign laws.                                       *
*                                                                             *
* The use of this system may be monitored and recorded for administrative    *
* and security reasons. Anyone accessing this system expressly consents to    *
* such monitoring and is advised that if monitoring reveals possible          *
* criminal activity, system personnel may provide the evidence to law         *
* enforcement officials.                                                      *
*                                                                             *
*******************************************************************************
```
2a. Message of the Day (/etc/motd)
```bash
# Edit /etc/motd
sudo vi /etc/motd
```
Add the following content:
```text
-----------------------------------------------------------------------
                       SECURITY NOTICE
-----------------------------------------------------------------------
- All activities on this system are monitored and logged
- Unauthorized access is prohibited and punishable by law
- Disconnect IMMEDIATELY if you are not an authorized user
-----------------------------------------------------------------------
```
 3a. SSH Banner (`/etc/issue.net`)
```bash
# Edit /etc/issue.net
sudo vi /etc/issue.net
```
Use the same content as` /etc/issue`.
 4a. Set Proper Permissions
```bash
# Set ownership
sudo chown root:root /etc/issue /etc/motd /etc/issue.net

# Set permissions
sudo chmod 644 /etc/issue /etc/motd /etc/issue.net
```
 5a. Enable SSH Banner
```bash
# Edit SSH configuration
sudo vi /etc/ssh/sshd_config
```
Add or modify:
```text
Banner /etc/issue.net
```
 6a. Verify Configuration
```bash
# Check permissions
ls -l /etc/issue /etc/motd /etc/issue.net

# Check content
cat /etc/issue
cat /etc/motd
cat /etc/issue.net

# Restart SSH service
sudo systemctl restart sshd
```
Remember to:
- Review banner content with legal department
- Ensure banners comply with organization policies
- Test SSH login to verify banner display
- Document changes in change management system
#### Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/configure_banners.sh

# Log file setup
LOG_FILE="/var/log/banner_setup.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting banner configuration at $(date)"

# Backup existing files
cp -p /etc/issue /etc/issue.$(date +%Y%m%d-%H%M%S).bak
cp -p /etc/motd /etc/motd.$(date +%Y%m%d-%H%M%S).bak

# Create login banner
cat > /etc/issue <<EOF
AUTHORIZED ACCESS ONLY

This system is for the use of authorized users only. Individuals using this
computer system without authority, or in excess of their authority, are
subject to having all of their activities on this system monitored and
recorded by system personnel.

In the course of monitoring individuals improperly using this system, or in
the course of system maintenance, the activities of authorized users may also
be monitored.

Anyone using this system expressly consents to such monitoring and is advised
that if such monitoring reveals possible evidence of criminal activity, system
personnel may provide the evidence of such monitoring to law enforcement officials.
EOF

# Create MOTD
cat > /etc/motd <<EOF
WARNING: Unauthorized access to this system is forbidden and will be
prosecuted by law. By accessing this system, you agree that your actions
may be monitored if unauthorized usage is suspected.
EOF

# Set proper permissions
chmod 644 /etc/issue /etc/motd
chown root:root /etc/issue /etc/motd

echo "Banner configuration complete. See $LOG_FILE for details"
````
#### Verification
```bash
# Check banner content and permissions
ls -l /etc/issue /etc/motd
cat /etc/issue
cat /etc/motd
```

Remember to:
- Customize banner text according to your organization's policies
- Review legal requirements for banner content
- Ensure proper permissions are maintained
- Document changes in your change management system

---
<center><font color="#ffff00">Passed</font></center>
Title   Verify Group Ownership of System Login Banner
Rule    xccdf_org.ssgproject.content_rule_file_groupowner_etc_issue
Ident   CCE-83708-8
Result  pass

Title   Verify Group Ownership of Message of the Day Banner
Rule    xccdf_org.ssgproject.content_rule_file_groupowner_etc_motd
Ident   CCE-83728-6
Result  pass

Title   Verify ownership of System Login Banner
Rule    xccdf_org.ssgproject.content_rule_file_owner_etc_issue
Ident   CCE-83718-7
Result  pass

Title   Verify ownership of Message of the Day Banner
Rule    xccdf_org.ssgproject.content_rule_file_owner_etc_motd
Ident   CCE-83738-5
Result  pass

Title   Verify permissions on System Login Banner
Rule    xccdf_org.ssgproject.content_rule_file_permissions_etc_issue
Ident   CCE-83348-3
Result  pass

Title   Verify permissions on Message of the Day Banner
Rule    xccdf_org.ssgproject.content_rule_file_permissions_etc_motd
Ident   CCE-83338-4
Result  pass

---
### GNOME3 Login Warning Banner Configuration
Title   Enable GNOME3 Login Warning Banner
Rule    xccdf_org.ssgproject.content_rule_dconf_gnome_banner_enabled
Ident   CCE-80768-5
Result  fail

Title   Set the GNOME3 Login Warning Banner Text
Rule    xccdf_org.ssgproject.content_rule_dconf_gnome_login_banner_text
Ident   CCE-80770-1
Result  fail
#### Overview
The GNOME3 login banner needs to be enabled and configured to display security warnings and legal notices to users before they log in through the graphical interface.
#### Why It's Necessary
- Provides legal protection
- Warns unauthorized users
- Required for compliance (HIPAA, PCI, etc.)
- Consistent warning across all login methods
- Meets security policy requirements
#### Current Status
Two GNOME banner-related rules have failed:
1. `dconf_gnome_banner_enabled` - Banner not enabled
2. `dconf_gnome_login_banner_text` - Banner text not set
##### Manual Fix
```bash
# Create dconf directories
sudo mkdir -p /etc/dconf/db/local.d
sudo mkdir -p /etc/dconf/profile/

# Create profile file
echo "user-db:user
system-db:local" | sudo tee /etc/dconf/profile/user

# Create banner configuration
sudo tee /etc/dconf/db/local.d/01-banner-message <<EOF
[org/gnome/login-screen]
banner-message-enable=true
banner-message-text='AUTHORIZED ACCESS ONLY\n\nThis system is restricted to authorized users for legitimate business purposes only. Unauthorized access is prohibited and will be prosecuted to the full extent of the law.'
EOF

# Update dconf database
sudo dconf update
```
#### Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/configure_gnome_banner.sh

# Log file setup
LOG_FILE="/var/log/gnome_banner_setup.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting GNOME banner configuration at $(date)"

# Create required directories
mkdir -p /etc/dconf/db/local.d
mkdir -p /etc/dconf/profile/

# Create dconf profile
echo "user-db:user
system-db:local" > /etc/dconf/profile/user

# Create banner configuration
cat > /etc/dconf/db/local.d/01-banner-message <<EOF
[org/gnome/login-screen]
banner-message-enable=true
banner-message-text='AUTHORIZED ACCESS ONLY

This system is restricted to authorized users for legitimate business purposes only.
Unauthorized access is prohibited and will be prosecuted to the full extent of the law.

By accessing this system, you agree that:
- Your actions may be monitored and recorded
- Unauthorized use will be reported to law enforcement
- You will comply with all applicable security policies'
EOF

# Update dconf database
dconf update

echo "GNOME banner configuration complete. See $LOG_FILE for details"
````
#### Verification
```bash
# Check banner configuration
grep -r banner-message /etc/dconf/db/local.d/

# Verify dconf database is updated
dconf read /org/gnome/login-screen/banner-message-enable
dconf read /org/gnome/login-screen/banner-message-text
```
Remember to:
- Customize banner text according to your organization's policies
- Review legal requirements for banner content
- Test in graphical environment
- Document changes in your change management system

---
### Password Policy Configuration
Title   Limit Password Reuse: password-auth
Rule    xccdf_org.ssgproject.content_rule_accounts_password_pam_pwhistory_remember_password_auth
Ident   CCE-83478-8
Result  fail

Title   Limit Password Reuse: system-auth
Rule    xccdf_org.ssgproject.content_rule_accounts_password_pam_pwhistory_remember_system_auth
Ident   CCE-83480-4
Result  fail

Title   Ensure PAM Enforces Password Requirements - Minimum Different Categories
Rule    xccdf_org.ssgproject.content_rule_accounts_password_pam_minclass
Ident   CCE-82046-4
Result  fail

Title   Ensure PAM Enforces Password Requirements - Minimum Length
Rule    xccdf_org.ssgproject.content_rule_accounts_password_pam_minlen
Ident   CCE-80656-2
Result  fail

Title   Ensure PAM Enforces Password Requirements - Authentication Retry Prompts Permitted Per-Session
Rule    xccdf_org.ssgproject.content_rule_accounts_password_pam_retry
Ident   CCE-80664-6
Result  fail

#### Overview
The OpenSCAP scan shows multiple password-related policy failures that need to be addressed to improve system security.
#### Current Status
Failed rules:
1. Password reuse limits (password-auth and system-auth)
2. Minimum different password categories
3. Minimum password length
4. Authentication retry limits
#### Why It's Necessary
- Prevents password reuse and weak passwords
- Enforces strong password complexity
- Reduces risk of brute force attacks
- Complies with security standards
- Protects against unauthorized access
#### 1. Configure PAM Password Policies
````bash
# Add or modify these lines
password    required      pam_pwhistory.so remember=5
password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 minlen=14 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1 minclass=4
````

````bash
# Add or modify these lines
password    required      pam_pwhistory.so remember=5
password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 minlen=14 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1 minclass=4
````
#### Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/configure_password_policy.sh

# Log file setup
LOG_FILE="/var/log/password_policy_setup.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting password policy configuration at $(date)"

# Backup original files
cp -p /etc/pam.d/password-auth /etc/pam.d/password-auth.$(date +%Y%m%d-%H%M%S).bak
cp -p /etc/pam.d/system-auth /etc/pam.d/system-auth.$(date +%Y%m%d-%H%M%S).bak

# Configure password policies
for file in /etc/pam.d/{password-auth,system-auth}; do
    # Remove existing password related lines
    sed -i '/^password.*pam_pwhistory.so/d' "$file"
    sed -i '/^password.*pam_pwquality.so/d' "$file"
    
    # Add new configuration
    sed -i '/^password.*sufficient.*pam_unix.so/i password    required      pam_pwhistory.so remember=5' "$file"
    sed -i '/^password.*sufficient.*pam_unix.so/i password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 minlen=14 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1 minclass=4' "$file"
done

echo "Password policy configuration complete. See $LOG_FILE for details"
````
#### Verification
```bash
# Check PAM configurations
grep -E '^password' /etc/pam.d/password-auth
grep -E '^password' /etc/pam.d/system-auth

# Test password change with weak password
passwd testuser
```

Remember to:
- Test changes in a safe environment first
- Backup configuration files
- Document changes in your change management system
- Inform users about new password requirements
- Monitor for failed login attempts

These changes will enforce:
- Minimum 14 character passwords
- At least 1 uppercase, lowercase, numeric, and special character
- Password history of 5 previous passwords
- Maximum 3 password change attempts
- 4 different character classes required

--- 
<center><font color="#ffff00">Passed</font></center>
Title   Set PAM's Password Hashing Algorithm
Rule    xccdf_org.ssgproject.content_rule_set_password_hashing_algorithm_systemauth
Ident   CCE-80893-1
Result  pass

Title   Require Authentication for Emergency Systemd Target
Rule    xccdf_org.ssgproject.content_rule_require_emergency_target_auth
Ident   CCE-82186-8
Result  pass

Title   Require Authentication for Single User Mode
Rule    xccdf_org.ssgproject.content_rule_require_singleuser_auth
Ident   CCE-80855-0
Result  pass

---
### Account Expiration Configuration..etc
Title   Set Account Expiration Following Inactivity
Rule    xccdf_org.ssgproject.content_rule_account_disable_post_pw_expiration
Ident   CCE-80954-1
Result  fail

Title   Set Password Maximum Age
Rule    xccdf_org.ssgproject.content_rule_accounts_maximum_age_login_defs
Ident   CCE-80647-1
Result  fail

Title   Set Password Minimum Age
Rule    xccdf_org.ssgproject.content_rule_accounts_minimum_age_login_defs
Ident   CCE-80648-9
Result  fai

#### Overview
The account expiration settings need to be configured to ensure inactive accounts are properly disabled after a defined period of inactivity.
#### Current Status
Failed rules:
1. `account_disable_post_pw_expiration` - Account expiration following inactivity not set
2. `accounts_maximum_age_login_defs` - Maximum password age not configured
3. `accounts_minimum_age_login_defs` - Minimum password age not configured
#### Why It's Necessary
- Prevents unauthorized access through abandoned accounts
- Ensures regular password changes
- Reduces risk of compromised accounts
- Complies with security standards
- Maintains system security hygiene
##### Manual Fix
1. Edit `/etc/default/useradd`:
```bash
sudo vi /etc/default/useradd

# Set INACTIVE parameter
INACTIVE=35
```
2. Edit `/etc/login.defs`:
```bash
sudo vi /etc/login.defs

# Set password aging controls
PASS_MAX_DAYS   90
PASS_MIN_DAYS   7
PASS_WARN_AGE   7
```
#### Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/account_expiration.sh

# Log file setup
LOG_FILE="/var/log/account_config.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting account expiration configuration at $(date)"

# Backup original files
cp -p /etc/default/useradd /etc/default/useradd.$(date +%Y%m%d-%H%M%S).bak
cp -p /etc/login.defs /etc/login.defs.$(date +%Y%m%d-%H%M%S).bak

# Configure account inactivity
sed -i 's/^INACTIVE=.*/INACTIVE=35/' /etc/default/useradd
if ! grep -q "^INACTIVE=" /etc/default/useradd; then
    echo "INACTIVE=35" >> /etc/default/useradd
fi

# Configure password aging
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/' /etc/login.defs
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   7/' /etc/login.defs

# Apply settings to existing accounts
for user in $(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd); do
    chage --maxdays 90 --mindays 7 --warndays 7 $user
done

echo "Account expiration configuration complete. See $LOG_FILE for details"
````
#### Verification
```bash
# Check account expiration settings
grep INACTIVE /etc/default/useradd

# Check password aging settings
grep "^PASS_" /etc/login.defs

# Verify user settings
for user in $(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd); do
    chage -l $user
done
```

Remember to:
- Test changes in a safe environment first
- Backup configuration files
- Document changes in your change management system
- Inform users about new password policies
- Monitor for account expirations

These changes will enforce:
- Account inactivity limit of 35 days
- Maximum password age of 90 days
- Minimum password age of 7 days
- Password expiration warning of 7 days

---
<center><font color="#ffff00">Passed</font></center>
Title   Ensure All Accounts on the System Have Unique Names
Rule    xccdf_org.ssgproject.content_rule_account_unique_name
Ident   CCE-80674-5
Result  pass

Title   Set Password Warning Age
Rule    xccdf_org.ssgproject.content_rule_accounts_password_warn_age_login_defs
Ident   CCE-80671-1
Result  pass

Title   Ensure there are no legacy + NIS entries in /etc/group
Rule    xccdf_org.ssgproject.content_rule_no_legacy_plus_entries_etc_group
Ident   CCE-83389-7
Result  pass

Title   Ensure there are no legacy + NIS entries in /etc/passwd
Rule    xccdf_org.ssgproject.content_rule_no_legacy_plus_entries_etc_passwd
Ident   CCE-82890-5
Result  pass

Title   Ensure there are no legacy + NIS entries in /etc/shadow
Rule    xccdf_org.ssgproject.content_rule_no_legacy_plus_entries_etc_shadow
Ident   CCE-84290-6
Result  pass

Title   Verify No netrc Files Exist
Rule    xccdf_org.ssgproject.content_rule_no_netrc_files
Ident   CCE-83444-0
Result  pass

Title   Verify Only Root Has UID 0
Rule    xccdf_org.ssgproject.content_rule_accounts_no_uid_except_zero
Ident   CCE-80649-7
Result  pass

Title   Ensure that System Accounts Do Not Run a Shell Upon Login
Rule    xccdf_org.ssgproject.content_rule_no_shelllogin_for_systemaccounts
Ident   CCE-80843-6
Result  pass

---
###  Enforce usage of pam_wheel for su authentication & Interactive Session Timeout Configuration
Title   Enforce usage of pam_wheel for su authentication
Rule    xccdf_org.ssgproject.content_rule_use_pam_wheel_for_su
Ident   CCE-83318-6
Result  fail

Title   Set Interactive Session Timeout
Rule    xccdf_org.ssgproject.content_rule_accounts_tmout
Ident   CCE-80673-7
Result  fail
#### Overview
Systems need to automatically terminate user sessions after a period of inactivity to prevent unauthorized access to unattended sessions.
#### Current Status
The OpenSCAP scan shows two session timeout-related failures:
1. `use_pam_wheel_for_su` - PAM wheel group for su not configured
2. `accounts_tmout` - Interactive session timeout not set
#### Why It's Necessary
- Prevents unauthorized access to unattended sessions
- Reduces risk of session hijacking
- Enforces security policy for inactive sessions
- Required by many compliance standards
- Protects sensitive information

1. Configure PAM Wheel for su
````bash
auth required pam_wheel.so use_uid
````
 2. Configure Session Timeout
````bash
# Add or modify TMOUT setting
TMOUT=900
readonly TMOUT
export TMOUT
````
#### Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/session_timeout.sh

# Log file setup
LOG_FILE="/var/log/session_config.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting session timeout configuration at $(date)"

# Backup original files
cp -p /etc/pam.d/su /etc/pam.d/su.$(date +%Y%m%d-%H%M%S).bak
cp -p /etc/profile /etc/profile.$(date +%Y%m%d-%H%M%S).bak
cp -p /etc/bashrc /etc/bashrc.$(date +%Y%m%d-%H%M%S).bak

# Configure PAM wheel for su
if ! grep -q "^auth.*required.*pam_wheel.so.*use_uid" /etc/pam.d/su; then
    sed -i '1i auth required pam_wheel.so use_uid' /etc/pam.d/su
    echo "Added pam_wheel requirement to su configuration"
fi

# Configure session timeout in multiple locations
for file in /etc/profile /etc/bashrc; do
    if ! grep -q "^readonly.*TMOUT=900" "$file"; then
        echo -e "\n# Set session timeout\nTMOUT=900\nreadonly TMOUT\nexport TMOUT" >> "$file"
        echo "Added session timeout to $file"
    fi
done

echo "Session configuration complete. See $LOG_FILE for details"
````
#### Verification
```bash
# Check PAM wheel configuration
grep pam_wheel /etc/pam.d/su

# Check timeout settings
grep TMOUT /etc/profile /etc/bashrc

# Test session timeout
su - testuser
# Wait for session to timeout
```
#### Best Practices
1. Set appropriate timeout value based on security requirements
2. Apply consistently across all user profiles
3. Consider environment-specific needs
4. Document exceptions
5. Test thoroughly before implementation
6. Monitor for compliance

Remember to:
- Test changes in a safe environment first
- Backup configuration files
- Inform users about new timeout policies
- Document changes in your change management system
- Monitor for user complaints or operational impacts

---
<center><font color="#ffff00">Passed</font></center>

Title   Ensure that Root's Path Does Not Include World or Group-Writable Directories
Rule    xccdf_org.ssgproject.content_rule_accounts_root_path_dirs_no_write
Ident   CCE-80672-9
Result  pass

Title   Ensure that Root's Path Does Not Include Relative Paths or Null Directories
Rule    xccdf_org.ssgproject.content_rule_root_path_no_dot
Ident   CCE-85914-0
Result  pass

---
### Default Umask Configuration
The default umask settings need to be configured correctly to ensure proper file and directory permissions when new files are created.

Title   Ensure the Default Bash Umask is Set Correctly
Rule    xccdf_org.ssgproject.content_rule_accounts_umask_etc_bashrc
Ident   CCE-81036-6
Result  fail

Title   Ensure the Default Umask is Set Correctly in login.defs
Rule    xccdf_org.ssgproject.content_rule_accounts_umask_etc_login_defs
Ident   CCE-82888-9
Result  fail

Title   Ensure the Default Umask is Set Correctly in /etc/profile
Rule    xccdf_org.ssgproject.content_rule_accounts_umask_etc_profile
Ident   CCE-81035-8
Result  fail
#### Current Status
Three umask-related rules have failed:
1. `accounts_umask_etc_bashrc` - Bash umask not set correctly
2. `accounts_umask_etc_login_defs` - Login.defs umask not set correctly
3. `accounts_umask_etc_profile` - Profile umask not set correctly
#### Why It's Necessary
- Controls default permissions for new files
- Prevents accidental exposure of sensitive data
- Ensures consistent file permissions
- Required for security compliance
- Reduces risk of unauthorized access
#### How to Fix
````bash
#!/bin/bash
# filepath: /root/scripts/configure_umask.sh

# Log file setup
LOG_FILE="/var/log/umask_config.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting umask configuration at $(date)"

# Backup original files
cp -p /etc/bashrc /etc/bashrc.$(date +%Y%m%d-%H%M%S).bak
cp -p /etc/profile /etc/profile.$(date +%Y%m%d-%H%M%S).bak
cp -p /etc/login.defs /etc/login.defs.$(date +%Y%m%d-%H%M%S).bak

# Configure umask in /etc/bashrc
sed -i 's/umask [0-9]*/umask 027/' /etc/bashrc
if ! grep -q "^umask" /etc/bashrc; then
    echo "umask 027" >> /etc/bashrc
fi

# Configure umask in /etc/profile
sed -i 's/umask [0-9]*/umask 027/' /etc/profile
if ! grep -q "^umask" /etc/profile; then
    echo "umask 027" >> /etc/profile
fi

# Configure umask in /etc/login.defs
sed -i 's/UMASK[[:space:]]*[0-9]*/UMASK 027/' /etc/login.defs
if ! grep -q "^UMASK" /etc/login.defs; then
    echo "UMASK 027" >> /etc/login.defs
fi

echo "Umask configuration complete. See $LOG_FILE for details"
````
#### Verification
```bash
# Check umask settings
grep umask /etc/bashrc
grep umask /etc/profile
grep UMASK /etc/login.defs

# Test new file creation
touch test_file
ls -l test_file
```
#### Best Practices
1. Set umask to 027 (file: 640, directory: 750)
2. Apply consistently across all configuration files
3. Test impact on applications
4. Document any exceptions
5. Monitor for compliance

Remember to:
- Test changes in a safe environment first
- Backup configuration files
- Verify file permissions after changes
- Document changes in change management system
- Inform users about new default permissions

---
<center><font color="#ffff00">Passed</font></center>
Title   Ensure the audit Subsystem is Installed
Rule    xccdf_org.ssgproject.content_rule_package_audit_installed
Ident   CCE-81043-2
Result  pass

Title   Enable auditd Service
Rule    xccdf_org.ssgproject.content_rule_service_auditd_enabled
Ident   CCE-80872-5
Result  pass
### Audit System Configuration
The audit system needs to be properly configured to monitor system activities and maintain proper logging of security-relevant events.

Title   Enable Auditing for Processes Which Start Prior to the Audit Daemon
Rule    xccdf_org.ssgproject.content_rule_grub2_audit_argument
Ident   CCE-80825-3
Result  fail

Title   Extend Audit Backlog Limit for the Audit Daemon
Rule    xccdf_org.ssgproject.content_rule_grub2_audit_backlog_limit_argument
Ident   CCE-80943-4
Result  fail
#### Current Status
Several audit-related rules have failed:
1. `grub2_audit_argument` - Auditing for early boot processes not enabled
2. `grub2_audit_backlog_limit_argument` - Audit backlog limit not set
3. `audit_rules_immutable` - Audit configuration not immutable
#### Why It's Necessary
- Ensures comprehensive system activity logging
- Prevents audit log overflow
- Protects audit configuration from modification
- Required for compliance and forensics
- Helps detect security incidents
#### How to Fix
 1. Configure GRUB2 Audit Settings
```bash
# Edit GRUB configuration
sudo vi /etc/default/grub

# Add or modify these parameters
GRUB_CMDLINE_LINUX="audit=1 audit_backlog_limit=8192"
```
 2. Update GRUB Configuration
```bash
# Rebuild GRUB configuration
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```
#### Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/configure_audit.sh

# Log file setup
LOG_FILE="/var/log/audit_config.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting audit configuration at $(date)"

# Backup GRUB configuration
cp -p /etc/default/grub /etc/default/grub.$(date +%Y%m%d-%H%M%S).bak

# Configure GRUB audit parameters
if ! grep -q "^GRUB_CMDLINE_LINUX=.*audit=1" /etc/default/grub; then
    # Add audit parameters to existing GRUB_CMDLINE_LINUX
    sed -i 's/\(GRUB_CMDLINE_LINUX=".*\)"/\1 audit=1 audit_backlog_limit=8192"/' /etc/default/grub
    echo "Added audit parameters to GRUB configuration"
fi

# Make audit rules immutable
echo "-e 2" >> /etc/audit/audit.rules

# Rebuild GRUB configuration
grub2-mkconfig -o /boot/grub2/grub.cfg

# Restart audit daemon
systemctl restart auditd

echo "Audit configuration complete. System restart required."
````
#### Verification
```bash
# Check GRUB configuration
grep audit /etc/default/grub

# Verify audit settings
auditctl -s

# Check if rules are immutable
grep "^-e" /etc/audit/audit.rules
```
Remember to:
- Test changes in a safe environment first
- Backup configuration files
- Schedule a system restart
- Monitor audit log size
- Document changes in your change management system
A system restart is required for these changes to take effect.
### Audit Rules Configuration
The system audit rules need to be configured to monitor various system activities for security and compliance purposes.

Title   Make the auditd Configuration Immutable
Rule    xccdf_org.ssgproject.content_rule_audit_rules_immutable
Ident   CCE-80708-1
Result  fail
#### Current Status
Multiple audit rules have failed, including:
1. MAC modifications
2. Media exports
3. Network configuration changes
4. Session events
5. System administrator actions
6. User/Group modifications
7. DAC modifications
8. File deletion events
9. Login events
10. Time changes
#### Why It's Necessary
- Provides audit trail for security investigations
- Required for compliance (HIPAA, PCI-DSS, etc.)
- Helps detect unauthorized system changes
- Enables system activity monitoring
- Supports forensic analysis
#### Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/configure_audit_rules.sh

# Log file setup
LOG_FILE="/var/log/audit_rules_setup.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting audit rules configuration at $(date)"

# Backup existing rules
cp -p /etc/audit/rules.d/audit.rules /etc/audit/rules.d/audit.rules.$(date +%Y%m%d-%H%M%S).bak

# Create new rules file
cat > /etc/audit/rules.d/audit.rules <<EOF
# MAC policy changes
-w /etc/selinux/ -p wa -k MAC-policy

# Media Exports
-a always,exit -F arch=b64 -S mount -k media_export

# Network Environment Changes
-a always,exit -F arch=b64 -S sethostname -S setdomainname -k network_modifications
-w /etc/issue -p wa -k network_modifications
-w /etc/issue.net -p wa -k network_modifications
-w /etc/hosts -p wa -k network_modifications
-w /etc/network/ -p wa -k network_modifications

# User/Group Changes
-w /etc/group -p wa -k identity
-w /etc/passwd -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/security/opasswd -p wa -k identity

# DAC Changes
-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -k perm_mod
-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -k perm_mod

# File Deletions
-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -k delete

# Login Events
-w /var/log/faillog -p wa -k logins
-w /var/log/lastlog -p wa -k logins

# Time Changes
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -S clock_settime -k time-change
-w /etc/localtime -p wa -k time-change

# Make the configuration immutable
-e 2
EOF

# Restart auditd
service auditd restart

echo "Audit rules configuration complete. See $LOG_FILE for details"
````
#### Verification
```bash
# Check if rules are loaded
auditctl -l

# Test rules
# Create a test user
useradd -m testuser
# Remove test user
userdel -r testuser

# Check audit logs
ausearch -k identity
```

Remember to:
- Test in a safe environment first
- Monitor system performance
- Adjust rules based on system resources
- Configure log rotation
- Monitor audit log size
- Plan for log archival

This implementation will:
- Monitor critical system changes
- Track user and group modifications
- Log file permission changes
- Record file deletions
- Monitor time changes
- Make audit configuration immutable
---
#### MAC Modifications Audit Configuration
The system should be configured to audit any modifications to the system's Mandatory Access Controls (MAC), particularly SELinux configuration changes.

Title   Record Events that Modify the System's Mandatory Access Controls
Rule    xccdf_org.ssgproject.content_rule_audit_rules_mac_modification
Ident   CCE-80721-4
Result  fail
#### Why It's Necessary
- Detects unauthorized changes to security policies
- Required for security compliance
- Helps in security incident investigations
- Monitors SELinux policy modifications
- Essential for system integrity monitoring
#### Manual Fix for MAC Audit Rules
1. Create or edit the audit rules file:
```bash
sudo vi /etc/audit/rules.d/audit.rules
```
2. Add the following rules:
```bash
# MAC policy changes
-w /etc/selinux/ -p wa -k MAC-policy
-w /usr/share/selinux/ -p wa -k MAC-policy

# SELinux configuration
-w /etc/selinux/config -p wa -k MAC-policy

# SELinux tools
-w /usr/sbin/semanage -p x -k MAC-policy
-w /usr/sbin/setsebool -p x -k MAC-policy
-w /usr/bin/chcon -p x -k MAC-policy
-w /usr/sbin/setfiles -p x -k MAC-policy

# SELinux policy modules
-w /usr/share/selinux/packages/ -p wa -k MAC-policy
```
3. Set proper permissions:
```bash
sudo chmod 640 /etc/audit/rules.d/audit.rules
sudo chown root:root /etc/audit/rules.d/audit.rules
```
4. Load the new rules:
```bash
sudo augenrules --load
```
5. Verify the configuration:
```bash
# Check if rules are loaded
sudo auditctl -l | grep MAC-policy

# Test the rules
sudo touch /etc/selinux/test_file
sudo rm /etc/selinux/test_file

# Check audit logs
sudo ausearch -k MAC-policy
```
#### Automation Script
Here's the automation script for configuring MAC modification auditing:
````bash
#!/bin/bash
# filepath: /root/scripts/configure_mac_audit.sh

# Log file setup
LOG_FILE="/var/log/audit_mac_setup.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting MAC audit configuration at $(date)"

# Backup existing rules
AUDIT_RULES="/etc/audit/rules.d/mac_policy.rules"
cp -p "$AUDIT_RULES" "${AUDIT_RULES}.$(date +%Y%m%d-%H%M%S).bak" 2>/dev/null

# Create rules for MAC policy changes
cat > "$AUDIT_RULES" <<EOF
# Monitor SELinux policy changes
-w /etc/selinux/ -p wa -k MAC-policy
-w /usr/share/selinux/ -p wa -k MAC-policy

# Monitor SELinux configuration
-w /etc/selinux/config -p wa -k MAC-policy

# Monitor SELinux tools
-w /usr/sbin/semanage -p x -k MAC-policy
-w /usr/sbin/setsebool -p x -k MAC-policy
-w /usr/bin/chcon -p x -k MAC-policy
-w /usr/sbin/setfiles -p x -k MAC-policy

# Monitor SELinux policy modules
-w /usr/share/selinux/packages/ -p wa -k MAC-policy
EOF

# Set proper permissions
chmod 640 "$AUDIT_RULES"
chown root:root "$AUDIT_RULES"

# Reload audit rules
augenrules --load

# Verify rules are loaded
echo "Verifying audit rules..."
auditctl -l | grep MAC-policy

echo "MAC audit configuration complete. See $LOG_FILE for details"
````
Remember to:
- Test in a non-production environment first
- Monitor audit log size
- Configure log rotation appropriately
- Review audit logs regularly
- Document changes in your change management system
---
### Media Export Audit Configuration
The system should be configured to audit successful attempts to export data to media devices, which helps track potential data exfiltration attempts.

Title   Ensure auditd Collects Information on Exporting to Media (successful)
Rule    xccdf_org.ssgproject.content_rule_audit_rules_media_export
Ident   CCE-80722-2
Result  fail
#### Why It's Necessary
- Detects unauthorized data exports
- Tracks removable media usage
- Required for compliance auditing
- Helps investigate data breaches
- Monitors sensitive data movement
#### Manual Fix for Media Export Audit Configuration
1. **Create or edit the audit rules file:**
```bash
sudo vi /etc/audit/rules.d/media_export.rules
```
2. **Add the following rules:**
```bash
# Monitor successful mount operations (media export)
-a always,exit -F arch=b32 -S mount -F success=1 -k media_export
-a always,exit -F arch=b64 -S mount -F success=1 -k media_export

# Monitor related commands
-w /usr/bin/mount -p x -k media_export
-w /usr/bin/umount -p x -k media_export
-w /usr/bin/automount -p x -k media_export
```
3. **Set proper permissions:**
```bash
sudo chmod 640 /etc/audit/rules.d/media_export.rules
sudo chown root:root /etc/audit/rules.d/media_export.rules
```
4. **Load the new rules:**
```bash
sudo augenrules --load
```
5. **Verify the configuration:**
```bash
# Check if rules are loaded
sudo auditctl -l | grep media_export

# Test the rules (mount a USB drive or other media)
sudo mount /dev/sdb1 /mnt

# Check audit logs
sudo ausearch -k media_export
```
#### Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/configure_media_audit.sh

# Log file setup
LOG_FILE="/var/log/audit_media_setup.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting media export audit configuration at $(date)"

# Backup existing rules
AUDIT_RULES="/etc/audit/rules.d/media_export.rules"
cp -p "$AUDIT_RULES" "${AUDIT_RULES}.$(date +%Y%m%d-%H%M%S).bak" 2>/dev/null

# Create rules for media export monitoring
cat > "$AUDIT_RULES" <<EOF
# Monitor successful mount operations
-a always,exit -F arch=b32 -S mount -F success=1 -k media_export
-a always,exit -F arch=b64 -S mount -F success=1 -k media_export

# Monitor related commands
-w /usr/bin/mount -p x -k media_export
-w /usr/bin/umount -p x -k media_export
-w /usr/bin/automount -p x -k media_export
EOF

# Set proper permissions
chmod 640 "$AUDIT_RULES"
chown root:root "$AUDIT_RULES"

# Reload audit rules
augenrules --load

# Verify rules are loaded
echo "Verifying audit rules..."
auditctl -l | grep media_export

echo "Media export audit configuration complete. See $LOG_FILE for details"
````
#### Verification
```bash
# Check if rules are loaded
auditctl -l | grep media_export

# Test the rules (mount a USB drive)
mount /dev/sdb1 /mnt

# Check audit logs
ausearch -k media_export
```
Remember to:
- Test in a non-production environment first
- Monitor audit log size
- Configure log rotation appropriately
- Review audit logs regularly
- Document changes in your change management system
---
### Record Events that Modify the System's Network Environment  
Rule    xccdf_org.ssgproject.content_rule_audit_rules_networkconfig_modification
Ident   CCE-80723-0
Result  fail
#### What is this Rule?
This rule requires that your system’s audit subsystem is configured to record any changes to the network environment. This includes changes to hostnames, domain names, and modifications to critical network configuration files (like `/etc/hosts`, `/etc/issue`, `/etc/network/`, etc.).
#### Why is it Necessary?
- **Detects Unauthorized Changes:** Alerts you to unauthorized or accidental changes to network settings.
- **Compliance:** Required by many security standards (CIS, PCI-DSS, HIPAA, etc.).
- **Forensics:** Provides an audit trail for investigations after a security incident.
- **System Integrity:** Helps ensure that network configurations are not tampered with, which could lead to man-in-the-middle attacks, data leaks, or loss of connectivity.
#### Manual Fix
1. **Create or edit the audit rules file:**
   ```bash
   sudo vi /etc/audit/rules.d/networkconfig_mod.rules
   ```
2. **Add the following rules:**
   ```bash
   # Monitor changes to network environment
   -a always,exit -F arch=b32 -S sethostname -S setdomainname -k network_modifications
   -a always,exit -F arch=b64 -S sethostname -S setdomainname -k network_modifications

   # Monitor changes to important network configuration files
   -w /etc/issue -p wa -k network_modifications
   -w /etc/issue.net -p wa -k network_modifications
   -w /etc/hosts -p wa -k network_modifications
   -w /etc/sysconfig/network -p wa -k network_modifications
   -w /etc/sysconfig/network-scripts/ -p wa -k network_modifications
   ```
3. **Set proper permissions:**
   ```bash
   sudo chmod 640 /etc/audit/rules.d/networkconfig_mod.rules
   sudo chown root:root /etc/audit/rules.d/networkconfig_mod.rules
   ```
4. **Load the new rules:**
   ```bash
   sudo augenrules --load
   ```
5. **Verify the configuration:**
   ```bash
   sudo auditctl -l | grep network_modifications
   ```
#### Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/configure_network_audit.sh

LOG_FILE="/var/log/audit_network_setup.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting network environment audit configuration at $(date)"

AUDIT_RULES="/etc/audit/rules.d/networkconfig_mod.rules"
cp -p "$AUDIT_RULES" "${AUDIT_RULES}.$(date +%Y%m%d-%H%M%S).bak" 2>/dev/null

cat > "$AUDIT_RULES" <<EOF
# Monitor changes to network environment
-a always,exit -F arch=b32 -S sethostname -S setdomainname -k network_modifications
-a always,exit -F arch=b64 -S sethostname -S setdomainname -k network_modifications

# Monitor changes to important network configuration files
-w /etc/issue -p wa -k network_modifications
-w /etc/issue.net -p wa -k network_modifications
-w /etc/hosts -p wa -k network_modifications
-w /etc/sysconfig/network -p wa -k network_modifications
-w /etc/sysconfig/network-scripts/ -p wa -k network_modifications
EOF

chmod 640 "$AUDIT_RULES"
chown root:root "$AUDIT_RULES"

augenrules --load

echo "Verifying audit rules..."
auditctl -l | grep network_modifications

echo "Network environment audit configuration complete. See $LOG_FILE for details"
````
**Remember to:**
- Test in a non-production environment first
- Monitor audit log size and configure log rotation
- Review audit logs regularly
- Document changes in your change management system
---
### Record Attempts to Alter Process and Session Initiation Information  
**Rule:** xccdf_org.ssgproject.content_rule_audit_rules_session_events  
**Ident:** CCE-80742-0  
**Result:** fail
#### What is this Rule?
This rule ensures that your audit subsystem records attempts to alter process and session initiation information, such as changes to `/var/run/utmp`, `/var/log/wtmp`, and `/var/log/btmp`. These files track user logins, logouts, and session activity.
#### Why is it Necessary?
- **Detects Unauthorized Session Changes:** Alerts you to tampering with session records, which could hide malicious activity.
- **Compliance:** Required by many security standards (CIS, PCI-DSS, HIPAA, etc.).
- **Forensics:** Provides an audit trail for investigations after a security incident.
- **System Integrity:** Ensures accurate tracking of user sessions and logins.
#### Manual Fix
1. **Create or edit the audit rules file:**
   ```bash
   sudo vi /etc/audit/rules.d/session_events.rules
   ```
2. **Add the following rules:**
   ```bash
   # Monitor session initiation information
   -w /var/run/utmp -p wa -k session
   -w /var/log/wtmp -p wa -k session
   -w /var/log/btmp -p wa -k session
   ```
3. **Set proper permissions:**
   ```bash
   sudo chmod 640 /etc/audit/rules.d/session_events.rules
   sudo chown root:root /etc/audit/rules.d/session_events.rules
   ```
4. **Load the new rules:**
   ```bash
   sudo augenrules --load
   ```
5. **Verify the configuration:**
   ```bash
   sudo auditctl -l | grep session
   ```
#### Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/configure_session_audit.sh

LOG_FILE="/var/log/audit_session_setup.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting session events audit configuration at $(date)"

AUDIT_RULES="/etc/audit/rules.d/session_events.rules"
cp -p "$AUDIT_RULES" "${AUDIT_RULES}.$(date +%Y%m%d-%H%M%S).bak" 2>/dev/null

cat > "$AUDIT_RULES" <<EOF
# Monitor session initiation information
-w /var/run/utmp -p wa -k session
-w /var/log/wtmp -p wa -k session
-w /var/log/btmp -p wa -k session
EOF

chmod 640 "$AUDIT_RULES"
chown root:root "$AUDIT_RULES"

augenrules --load

echo "Verifying audit rules..."
auditctl -l | grep session

echo "Session events audit configuration complete. See $LOG_FILE for details"
````
**Remember to:**
- Test in a non-production environment first
- Monitor audit log size and configure log rotation
- Review audit logs regularly
- Document changes in your change management system
---
### Ensure auditd Collects System Administrator Actions  
**Rule:** xccdf_org.ssgproject.content_rule_audit_rules_sysadmin_actions  
**Ident:** CCE-80743-8  
**Result:** fail
#### What is this Rule?
This rule requires that your audit subsystem records the execution of privileged commands (typically those run via `sudo` or by root). This is usually done by monitoring the use of the `execve` syscall by users with effective UID 0 (root).
#### Why is it Necessary?
- **Accountability:** Tracks all actions performed by system administrators.
- **Forensics:** Provides an audit trail for investigations after a security incident.
- **Compliance:** Required by many security standards (CIS, PCI-DSS, HIPAA, etc.).
- **Intrusion Detection:** Helps detect unauthorized or suspicious admin activity.
- **System Integrity:** Ensures that all privileged actions are logged.
#### Manual Fix
1. **Create or edit the audit rules file:**
   ```bash
   sudo vi /etc/audit/rules.d/sysadmin_actions.rules
   ```
2. **Add the following rule:**
   ```bash
   # Monitor execution of privileged commands
   -a always,exit -F arch=b64 -C euid=0 -S execve -k actions
   -a always,exit -F arch=b32 -C euid=0 -S execve -k actions
   ```
3. **Set proper permissions:**
   ```bash
   sudo chmod 640 /etc/audit/rules.d/sysadmin_actions.rules
   sudo chown root:root /etc/audit/rules.d/sysadmin_actions.rules
   ```
4. **Load the new rules:**
   ```bash
   sudo augenrules --load
   ```
5. **Verify the configuration:**
   ```bash
   sudo auditctl -l | grep actions
   ```
#### Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/configure_sysadmin_audit.sh

LOG_FILE="/var/log/audit_sysadmin_setup.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting sysadmin actions audit configuration at $(date)"

AUDIT_RULES="/etc/audit/rules.d/sysadmin_actions.rules"
cp -p "$AUDIT_RULES" "${AUDIT_RULES}.$(date +%Y%m%d-%H%M%S).bak" 2>/dev/null

cat > "$AUDIT_RULES" <<EOF
# Monitor execution of privileged commands
-a always,exit -F arch=b64 -C euid=0 -S execve -k actions
-a always,exit -F arch=b32 -C euid=0 -S execve -k actions
EOF

chmod 640 "$AUDIT_RULES"
chown root:root "$AUDIT_RULES"

augenrules --load

echo "Verifying audit rules..."
auditctl -l | grep actions

echo "Sysadmin actions audit configuration complete. See $LOG_FILE for details"
````
**Remember to:**
- Test in a non-production environment first
- Monitor audit log size and configure log rotation
- Review audit logs regularly (e.g., `ausearch -k actions`)
- Document changes in your change management system
---
### Record Events that Modify User/Group Information - /etc/group  
**Rule:** xccdf_org.ssgproject.content_rule_audit_rules_usergroup_modification_group  
**Ident:** CCE-80758-6  
**Result:** fail
#### What is this Rule?
This rule requires the audit subsystem to record any changes to the `/etc/group` file, which contains group account information. Monitoring this file helps detect unauthorized or accidental modifications to group memberships.
#### Why is it Necessary?
- **Detects Unauthorized Group Changes:** Alerts you to privilege escalation or accidental changes.
- **Compliance:** Required by many security standards (CIS, PCI-DSS, HIPAA, etc.).
- **Forensics:** Provides an audit trail for investigations after a security incident.
- **System Integrity:** Ensures group memberships are not tampered with.
#### Manual Fix
1. **Create or edit the audit rules file:**
   ```bash
   sudo vi /etc/audit/rules.d/usergroup_mod_group.rules
   ```
2. **Add the following rule:**
   ```bash
   # Monitor changes to /etc/group
   -w /etc/group -p wa -k identity
   ```
3. **Set proper permissions:**
   ```bash
   sudo chmod 640 /etc/audit/rules.d/usergroup_mod_group.rules
   sudo chown root:root /etc/audit/rules.d/usergroup_mod_group.rules
   ```
4. **Load the new rules:**
   ```bash
   sudo augenrules --load
   ```
5. **Verify the configuration:**
```bash
sudo auditctl -l | grep /etc/group
```
#### Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/configure_usergroup_group_audit.sh

LOG_FILE="/var/log/audit_usergroup_group_setup.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting /etc/group audit configuration at $(date)"

AUDIT_RULES="/etc/audit/rules.d/usergroup_mod_group.rules"
cp -p "$AUDIT_RULES" "${AUDIT_RULES}.$(date +%Y%m%d-%H%M%S).bak" 2>/dev/null

cat > "$AUDIT_RULES" <<EOF
# Monitor changes to /etc/group
-w /etc/group -p wa -k identity
EOF

chmod 640 "$AUDIT_RULES"
chown root:root "$AUDIT_RULES"

augenrules --load

echo "Verifying audit rules..."
auditctl -l | grep /etc/group

echo "/etc/group audit configuration complete. See $LOG_FILE for details"
````
**Remember to:**
- Test in a non-production environment first
- Monitor audit log size and configure log rotation
- Review audit logs regularly (e.g., `ausearch -k identity`)
- Document changes in your change management system
---
### Record Events that Modify User/Group Information - /etc/group  
**Rule:** xccdf_org.ssgproject.content_rule_audit_rules_usergroup_modification_group  
**Ident:** CCE-80758-6  
**Result:** fail  
**What:** Audits changes to the `/etc/group` file, which contains group account information.  
**Why:** Detects unauthorized or accidental group changes, helps with compliance and forensics.
**Manual Fix:**  
```bash
sudo vi /etc/audit/rules.d/usergroup_mod_group.rules
# Add:
-w /etc/group -p wa -k identity
sudo chmod 640 /etc/audit/rules.d/usergroup_mod_group.rules
sudo chown root:root /etc/audit/rules.d/usergroup_mod_group.rules
sudo augenrules --load
```
### Record Events that Modify User/Group Information - /etc/gshadow  
**Rule:** xccdf_org.ssgproject.content_rule_audit_rules_usergroup_modification_gshadow  
**Ident:** CCE-80759-4  
**Result:** fail  
**What:** Audits changes to `/etc/gshadow`, which stores group passwords and admin info.  
**Why:** Detects privilege escalation, ensures group security.
**Manual Fix:**  
```bash
sudo vi /etc/audit/rules.d/usergroup_mod_gshadow.rules
# Add:
-w /etc/gshadow -p wa -k identity
sudo chmod 640 /etc/audit/rules.d/usergroup_mod_gshadow.rules
sudo chown root:root /etc/audit/rules.d/usergroup_mod_gshadow.rules
sudo augenrules --load
```
### Record Events that Modify User/Group Information - /etc/security/opasswd  
**Rule:** xccdf_org.ssgproject.content_rule_audit_rules_usergroup_modification_opasswd  
**Ident:** CCE-80760-2  
**Result:** fail  
**What:** Audits changes to `/etc/security/opasswd`, which stores old passwords for reuse prevention.  
**Why:** Detects tampering with password history.
**Manual Fix:**  
```bash
sudo vi /etc/audit/rules.d/usergroup_mod_opasswd.rules

# Add:
-w /etc/security/opasswd -p wa -k identity

sudo chmod 640 /etc/audit/rules.d/usergroup_mod_opasswd.rules
sudo chown root:root /etc/audit/rules.d/usergroup_mod_opasswd.rules

sudo augenrules --load
```
### Record Events that Modify User/Group Information - /etc/passwd  
**Rule:** xccdf_org.ssgproject.content_rule_audit_rules_usergroup_modification_passwd  
**Ident:** CCE-80761-0  
**Result:** fail  
**What:** Audits changes to `/etc/passwd`, which contains user account info.  
**Why:** Detects unauthorized user creation or modification.

**Manual Fix:**  
```bash
sudo vi /etc/audit/rules.d/usergroup_mod_passwd.rules

# Add:

-w /etc/passwd -p wa -k identity
sudo chmod 640 /etc/audit/rules.d/usergroup_mod_passwd.rules
sudo chown root:root /etc/audit/rules.d/usergroup_mod_passwd.rules

sudo augenrules --load
```
### Record Events that Modify User/Group Information - /etc/shadow  
**Rule:** xccdf_org.ssgproject.content_rule_audit_rules_usergroup_modification_shadow  
**Ident:** CCE-80762-8  
**Result:** fail  
**What:** Audits changes to `/etc/shadow`, which stores user password hashes.  
**Why:** Detects password tampering or privilege escalation.
**Manual Fix:**  
```bash
sudo vi /etc/audit/rules.d/usergroup_mod_shadow.rules
# Add:
-w /etc/shadow -p wa -k identity
sudo chmod 640 /etc/audit/rules.d/usergroup_mod_shadow.rules
sudo chown root:root /etc/audit/rules.d/usergroup_mod_shadow.rules
sudo augenrules --load
```
### Record Events that Modify the System's Discretionary Access Controls (DAC)  
**Files/Rules:** chmod, chown, fchmod, fchmodat, fchown, fchownat, fremovexattr, fsetxattr, lchown, lremovexattr, lsetxattr, removexattr, setxattr  
**Why:** Audits changes to file permissions and ownership, which can be used to escalate privileges or hide activity.

**Manual Fix Example (repeat for each syscall):**  
```bash
sudo vi /etc/audit/rules.d/dac_mod.rules

# Add (example for chmod):
-a always,exit -F arch=b64 -S chmod -k perm_mod

# Repeat for each syscall as needed
sudo chmod 640 /etc/audit/rules.d/dac_mod.rules
sudo chown root:root /etc/audit/rules.d/dac_mod.rules

sudo augenrules --load
```
#### Combined Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/configure_usergroup_dac_audit.sh

LOG_FILE="/var/log/audit_usergroup_dac_setup.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting user/group and DAC audit configuration at $(date)"

cat > /etc/audit/rules.d/usergroup_dac.rules <<EOF
# User/Group modifications
-w /etc/group -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/security/opasswd -p wa -k identity
-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity

# DAC modifications
-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -k perm_mod
-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -k perm_mod
-a always,exit -F arch=b64 -S fremovexattr -S fsetxattr -S lremovexattr -S lsetxattr -S removexattr -S setxattr -k perm_mod
EOF

chmod 640 /etc/audit/rules.d/usergroup_dac.rules
chown root:root /etc/audit/rules.d/usergroup_dac.rules

augenrules --load

echo "Verifying audit rules..."
auditctl -l | grep -E 'identity|perm_mod'

echo "User/group and DAC audit configuration complete. See $LOG_FILE for details"
````
**Remember:**  
- These rules are necessary for compliance, forensics, and detecting privilege escalation or unauthorized changes to user/group info and file permissions.
- Always test in a non-production environment first and monitor audit log size.
---
###  Ensure auditd Collects File Deletion Events by User - rename  
**Rule:** xccdf_org.ssgproject.content_rule_audit_rules_file_deletion_events_rename  
**Ident:** CCE-80703-2  
**Result:** fail  
**What:** Audits file deletions using the `rename` syscall.  
**Why:** Detects when files are renamed (which can be used to hide or remove evidence), helps with compliance and forensic investigations.

**Manual Fix:**  
```bash
sudo vi /etc/audit/rules.d/file_deletion_rename.rules
# Add:
-a always,exit -F arch=b64 -S rename -k delete
sudo chmod 640 /etc/audit/rules.d/file_deletion_rename.rules
sudo chown root:root /etc/audit/rules.d/file_deletion_rename.rules
sudo augenrules --load
```
### Ensure auditd Collects File Deletion Events by User - renameat  
**Rule:** xccdf_org.ssgproject.content_rule_audit_rules_file_deletion_events_renameat  
**Ident:** CCE-80704-0  
**Result:** fail  
**What:** Audits file deletions using the `renameat` syscall.  
**Why:** Detects file renames across directories, which can be used to evade detection or remove files.

**Manual Fix:**  
```bash
sudo vi /etc/audit/rules.d/file_deletion_renameat.rules
# Add:
-a always,exit -F arch=b64 -S renameat -k delete
sudo chmod 640 /etc/audit/rules.d/file_deletion_renameat.rules
sudo chown root:root /etc/audit/rules.d/file_deletion_renameat.rules
sudo augenrules --load
```
### Ensure auditd Collects File Deletion Events by User - unlink  
**Rule:** xccdf_org.ssgproject.content_rule_audit_rules_file_deletion_events_unlink  
**Ident:** CCE-80706-5  
**Result:** fail  
**What:** Audits file deletions using the `unlink` syscall.  
**Why:** Detects when files are deleted, which is critical for monitoring data removal and potential evidence destruction.

**Manual Fix:**  
```bash
sudo vi /etc/audit/rules.d/file_deletion_unlink.rules
# Add:
-a always,exit -F arch=b64 -S unlink -k delete
sudo chmod 640 /etc/audit/rules.d/file_deletion_unlink.rules
sudo chown root:root /etc/audit/rules.d/file_deletion_unlink.rules
sudo augenrules --load
```
### Ensure auditd Collects File Deletion Events by User - unlinkat  
**Rule:** xccdf_org.ssgproject.content_rule_audit_rules_file_deletion_events_unlinkat  
**Ident:** CCE-80707-3  
**Result:** fail  
**What:** Audits file deletions using the `unlinkat` syscall.  
**Why:** Detects file deletions in directories, which can be used to remove files in a more targeted way.

**Manual Fix:**  
```bash
sudo vi /etc/audit/rules.d/file_deletion_unlinkat.rules
# Add:
-a always,exit -F arch=b64 -S unlinkat -k delete
sudo chmod 640 /etc/audit/rules.d/file_deletion_unlinkat.rules
sudo chown root:root /etc/audit/rules.d/file_deletion_unlinkat.rules
sudo augenrules --load
```
#### Combined Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/configure_file_deletion_audit.sh

LOG_FILE="/var/log/audit_file_deletion_setup.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting file deletion audit configuration at $(date)"

cat > /etc/audit/rules.d/file_deletion.rules <<EOF
# File deletion events
-a always,exit -F arch=b64 -S rename -k delete
-a always,exit -F arch=b64 -S renameat -k delete
-a always,exit -F arch=b64 -S unlink -k delete
-a always,exit -F arch=b64 -S unlinkat -k delete
EOF

chmod 640 /etc/audit/rules.d/file_deletion.rules
chown root:root /etc/audit/rules.d/file_deletion.rules

augenrules --load

echo "Verifying audit rules..."
auditctl -l | grep delete

echo "File deletion audit configuration complete. See $LOG_FILE for details"
````
**Remember:**  
- These rules are necessary for compliance, forensics, and detecting unauthorized file deletions.
- Always test in a non-production environment first and monitor audit log size.
---
### Record Unsuccessful Access Attempts to Files - create  
**Rule:** xccdf_org.ssgproject.content_rule_audit_rules_unsuccessful_file_modification_creat  
**Ident:** CCE-80751-1  
**Result:** fail  
**What:** Audits failed attempts to create files using the `creat` syscall.  
**Why:** Detects unauthorized or failed attempts to create files, which may indicate probing or attack attempts.

**Manual Fix:**  
```bash
sudo vi /etc/audit/rules.d/unsuccessful_file_mod_creat.rules
# Add:
-a always,exit -F arch=b64 -S creat -F exit=-EACCES -F auid>=1000 -F auid!=unset -k access
-a always,exit -F arch=b64 -S creat -F exit=-EPERM -F auid>=1000 -F auid!=unset -k access
sudo chmod 640 /etc/audit/rules.d/unsuccessful_file_mod_creat.rules
sudo chown root:root /etc/audit/rules.d/unsuccessful_file_mod_creat.rules
sudo augenrules --load
```
### Record Unsuccessful Access Attempts to Files - ftruncate  
**Rule:** xccdf_org.ssgproject.content_rule_audit_rules_unsuccessful_file_modification_ftruncate  
**Ident:** CCE-80752-9  
**Result:** fail  
**What:** Audits failed attempts to truncate files using the `ftruncate` syscall.  
**Why:** Detects failed attempts to modify file sizes, which may indicate tampering or privilege escalation attempts.

**Manual Fix:**  
```bash
sudo vi /etc/audit/rules.d/unsuccessful_file_mod_ftruncate.rules
# Add:
-a always,exit -F arch=b64 -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -k access
-a always,exit -F arch=b64 -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=unset -k access
sudo chmod 640 /etc/audit/rules.d/unsuccessful_file_mod_ftruncate.rules
sudo chown root:root /etc/audit/rules.d/unsuccessful_file_mod_ftruncate.rules
sudo augenrules --load
```
### Record Unsuccessful Access Attempts to Files - open  
**Rule:** xccdf_org.ssgproject.content_rule_audit_rules_unsuccessful_file_modification_open  
**Ident:** CCE-80753-7  
**Result:** fail  
**What:** Audits failed attempts to open files using the `open` syscall.  
**Why:** Detects failed file access attempts, which may indicate unauthorized access or reconnaissance.

**Manual Fix:**  
```bash
sudo vi /etc/audit/rules.d/unsuccessful_file_mod_open.rules
# Add:
-a always,exit -F arch=b64 -S open -F exit=-EACCES -F auid>=1000 -F auid!=unset -k access
-a always,exit -F arch=b64 -S open -F exit=-EPERM -F auid>=1000 -F auid!=unset -k access
sudo chmod 640 /etc/audit/rules.d/unsuccessful_file_mod_open.rules
sudo chown root:root /etc/audit/rules.d/unsuccessful_file_mod_open.rules
sudo augenrules --load
```
### Record Unsuccessful Access Attempts to Files - openat  
**Rule:** xccdf_org.ssgproject.content_rule_audit_rules_unsuccessful_file_modification_openat  
**Ident:** CCE-80754-5  
**Result:** fail  
**What:** Audits failed attempts to open files using the `openat` syscall.  
**Why:** Detects failed file access attempts in directories, which may indicate unauthorized access or privilege escalation attempts.

**Manual Fix:**  
```bash
sudo vi /etc/audit/rules.d/unsuccessful_file_mod_openat.rules
# Add:
-a always,exit -F arch=b64 -S openat -F exit=-EACCES -F auid>=1000 -F auid!=unset -k access
-a always,exit -F arch=b64 -S openat -F exit=-EPERM -F auid>=1000 -F auid!=unset -k access
sudo chmod 640 /etc/audit/rules.d/unsuccessful_file_mod_openat.rules
sudo chown root:root /etc/audit/rules.d/unsuccessful_file_mod_openat.rules
sudo augenrules --load
```
### Record Unsuccessful Access Attempts to Files - truncate  
**Rule:** xccdf_org.ssgproject.content_rule_audit_rules_unsuccessful_file_modification_truncate  
**Ident:** CCE-80756-0  
**Result:** fail  
**What:** Audits failed attempts to truncate files using the `truncate` syscall.  
**Why:** Detects failed attempts to modify file sizes, which may indicate tampering or privilege escalation attempts.

**Manual Fix:**  
```bash
sudo vi /etc/audit/rules.d/unsuccessful_file_mod_truncate.rules
# Add:
-a always,exit -F arch=b64 -S truncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -k access
-a always,exit -F arch=b64 -S truncate -F exit=-EPERM -F auid>=1000 -F auid!=unset -k access
sudo chmod 640 /etc/audit/rules.d/unsuccessful_file_mod_truncate.rules
sudo chown root:root /etc/audit/rules.d/unsuccessful_file_mod_truncate.rules
sudo augenrules --load
```
#### Combined Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/configure_unsuccessful_file_mod_audit.sh

LOG_FILE="/var/log/audit_unsuccessful_file_mod_setup.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting unsuccessful file modification audit configuration at $(date)"

cat > /etc/audit/rules.d/unsuccessful_file_mod.rules <<EOF
# Unsuccessful file modification events
-a always,exit -F arch=b64 -S creat -F exit=-EACCES -F auid>=1000 -F auid!=unset -k access
-a always,exit -F arch=b64 -S creat -F exit=-EPERM -F auid>=1000 -F auid!=unset -k access
-a always,exit -F arch=b64 -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -k access
-a always,exit -F arch=b64 -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=unset -k access
-a always,exit -F arch=b64 -S open -F exit=-EACCES -F auid>=1000 -F auid!=unset -k access
-a always,exit -F arch=b64 -S open -F exit=-EPERM -F auid>=1000 -F auid!=unset -k access
-a always,exit -F arch=b64 -S openat -F exit=-EACCES -F auid>=1000 -F auid!=unset -k access
-a always,exit -F arch=b64 -S openat -F exit=-EPERM -F auid>=1000 -F auid!=unset -k access
-a always,exit -F arch=b64 -S truncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -k access
-a always,exit -F arch=b64 -S truncate -F exit=-EPERM -F auid>=1000 -F auid!=unset -k access
EOF

chmod 640 /etc/audit/rules.d/unsuccessful_file_mod.rules
chown root:root /etc/audit/rules.d/unsuccessful_file_mod.rules

augenrules --load

echo "Verifying audit rules..."
auditctl -l | grep access

echo "Unsuccessful file modification audit configuration complete. See $LOG_FILE for details"
````
**Remember:**  
- These rules are necessary for compliance, forensics, and detecting unauthorized or failed file access attempts.
- Always test in a non-production environment first and monitor audit log size.
---
### Ensure auditd Collects Information on Kernel Module Unloading - delete_module  
**Rule:** xccdf_org.ssgproject.content_rule_audit_rules_kernel_module_loading_delete  
**Ident:** CCE-80711-5  
**Result:** fail  
**What:** Audits attempts to unload kernel modules using the `delete_module` syscall.  
**Why:** Detects unauthorized or suspicious removal of kernel modules, which could be used to disable security features or hide malicious activity.
**Manual Fix:**  
```bash
sudo vi /etc/audit/rules.d/kernel_module_delete.rules
# Add:
-a always,exit -F arch=b64 -S delete_module -k modules
sudo chmod 640 /etc/audit/rules.d/kernel_module_delete.rules
sudo chown root:root /etc/audit/rules.d/kernel_module_delete.rules
sudo augenrules --load
```
### Ensure auditd Collects Information on Kernel Module Loading - init_module  
**Rule:** xccdf_org.ssgproject.content_rule_audit_rules_kernel_module_loading_init  
**Ident:** CCE-80713-1  
**Result:** fail  
**What:** Audits attempts to load kernel modules using the `init_module` syscall.  
**Why:** Detects unauthorized or suspicious loading of kernel modules, which could be used to introduce malicious code or enable unwanted features.
**Manual Fix:**  
```bash
sudo vi /etc/audit/rules.d/kernel_module_init.rules
# Add:
-a always,exit -F arch=b64 -S init_module -k modules
sudo chmod 640 /etc/audit/rules.d/kernel_module_init.rules
sudo chown root:root /etc/audit/rules.d/kernel_module_init.rules
sudo augenrules --load
```
#### Combined Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/configure_kernel_module_audit.sh

LOG_FILE="/var/log/audit_kernel_module_setup.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting kernel module audit configuration at $(date)"

cat > /etc/audit/rules.d/kernel_module.rules <<EOF
# Kernel module loading/unloading events
-a always,exit -F arch=b64 -S delete_module -k modules
-a always,exit -F arch=b64 -S init_module -k modules
EOF

chmod 640 /etc/audit/rules.d/kernel_module.rules
chown root:root /etc/audit/rules.d/kernel_module.rules

augenrules --load

echo "Verifying audit rules..."
auditctl -l | grep modules

echo "Kernel module audit configuration complete. See $LOG_FILE for details"
````
**Remember:**  
- These rules are necessary for compliance, forensics, and detecting unauthorized kernel module manipulation.
- Always test in a non-production environment first and monitor audit log size.
---
### Record Attempts to Alter Logon and Logout Events - faillock  
**Rule:** xccdf_org.ssgproject.content_rule_audit_rules_login_events_faillock  
**Ident:** CCE-80718-0  
**Result:** fail  
**What:** Audits changes to `/var/run/faillock`, which tracks failed authentication attempts.  
**Why:** Detects tampering with authentication failure records, which could hide brute-force attacks or unauthorized access.

**Manual Fix:**  
```bash
sudo vi /etc/audit/rules.d/login_events_faillock.rules
# Add:
-w /var/run/faillock -p wa -k logins
sudo chmod 640 /etc/audit/rules.d/login_events_faillock.rules
sudo chown root:root /etc/audit/rules.d/login_events_faillock.rules
sudo augenrules --load
```
### Record Attempts to Alter Logon and Logout Events - lastlog  
**Rule:** xccdf_org.ssgproject.content_rule_audit_rules_login_events_lastlog  
**Ident:** CCE-80719-8  
**Result:** fail  
**What:** Audits changes to `/var/log/lastlog`, which records the last login of each user.  
**Why:** Detects tampering with login records, which could hide unauthorized access.

**Manual Fix:**  
```bash
sudo vi /etc/audit/rules.d/login_events_lastlog.rules
# Add:
-w /var/log/lastlog -p wa -k logins
sudo chmod 640 /etc/audit/rules.d/login_events_lastlog.rules
sudo chown root:root /etc/audit/rules.d/login_events_lastlog.rules
sudo augenrules --load
```
### Record attempts to alter time through adjtimex  
**Rule:** xccdf_org.ssgproject.content_rule_audit_rules_time_adjtimex  
**Ident:** CCE-80745-3  
**Result:** fail  
**What:** Audits use of the `adjtimex` syscall, which can change system time.  
**Why:** Detects unauthorized time changes, which can be used to cover tracks or disrupt logs.

**Manual Fix:**  
```bash
sudo vi /etc/audit/rules.d/time_adjtimex.rules
# Add:
-a always,exit -F arch=b64 -S adjtimex -k time-change
sudo chmod 640 /etc/audit/rules.d/time_adjtimex.rules
sudo chown root:root /etc/audit/rules.d/time_adjtimex.rules
sudo augenrules --load
```
### Record Attempts to Alter Time Through clock_settime  
**Rule:** xccdf_org.ssgproject.content_rule_audit_rules_time_clock_settime  
**Ident:** CCE-80746-1  
**Result:** fail  
**What:** Audits use of the `clock_settime` syscall, which can set system clocks.  
**Why:** Detects unauthorized time changes, which can affect system integrity and log accuracy.

**Manual Fix:**  
```bash
sudo vi /etc/audit/rules.d/time_clock_settime.rules
# Add:
-a always,exit -F arch=b64 -S clock_settime -k time-change
sudo chmod 640 /etc/audit/rules.d/time_clock_settime.rules
sudo chown root:root /etc/audit/rules.d/time_clock_settime.rules
sudo augenrules --load
```
### Record Attempts to Alter Time Through stime  
**Rule:** xccdf_org.ssgproject.content_rule_audit_rules_time_stime  
**Ident:** CCE-80748-7  
**Result:** fail  
**What:** Audits use of the `stime` syscall, which can set system time (legacy).  
**Why:** Detects unauthorized time changes, which can affect system integrity and log accuracy.

**Manual Fix:**  
```bash
sudo vi /etc/audit/rules.d/time_stime.rules
# Add:
-a always,exit -F arch=b64 -S stime -k time-change
sudo chmod 640 /etc/audit/rules.d/time_stime.rules
sudo chown root:root /etc/audit/rules.d/time_stime.rules
sudo augenrules --load
```
### Record Attempts to Alter the localtime File  
**Rule:** xccdf_org.ssgproject.content_rule_audit_rules_time_watch_localtime  
**Ident:** CCE-80749-5  
**Result:** fail  
**What:** Audits changes to `/etc/localtime`, which sets the system timezone.  
**Why:** Detects unauthorized timezone changes, which can affect log timestamps and system behavior.
**Manual Fix:**  
```bash
sudo vi /etc/audit/rules.d/time_watch_localtime.rules
# Add:
-w /etc/localtime -p wa -k time-change
sudo chmod 640 /etc/audit/rules.d/time_watch_localtime.rules
sudo chown root:root /etc/audit/rules.d/time_watch_localtime.rules
sudo augenrules --load
```
#### Combined Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/configure_time_login_audit.sh

LOG_FILE="/var/log/audit_time_login_setup.log"
RULES_FILE="/etc/audit/rules.d/time_login.rules"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting time and login event audit configuration at $(date)"

# Define required rules
read -r -d '' RULES <<EOF
# Logon/Logout events
-w /var/run/faillock -p wa -k logins
-w /var/log/lastlog -p wa -k logins

# Time change events
-a always,exit -F arch=b64 -S adjtimex -k time-change
-a always,exit -F arch=b64 -S clock_settime -k time-change
-a always,exit -F arch=b64 -S stime -k time-change
-w /etc/localtime -p wa -k time-change
EOF

# Check if rules file exists and contains all required rules
if [ -f "$RULES_FILE" ]; then
    missing=0
    while read -r rule; do
        [[ -z "$rule" || "$rule" =~ ^# ]] && continue
        if ! grep -Fxq "$rule" "$RULES_FILE"; then
            missing=1
            break
        fi
    done <<< "$RULES"
    if [ $missing -eq 0 ]; then
        echo "All required rules already exist in $RULES_FILE"
    else
        echo "Some rules missing, updating $RULES_FILE"
        echo "$RULES" > "$RULES_FILE"
    fi
else
    echo "Creating $RULES_FILE with required rules"
    echo "$RULES" > "$RULES_FILE"
fi

chmod 640 "$RULES_FILE"
chown root:root "$RULES_FILE"
augenrules --load

echo "Verifying audit rules..."
auditctl -l | grep -E 'logins|time-change'

echo "Time and login event audit configuration complete. See $LOG_FILE for details"
````
**Remember:**  
- These rules are necessary for compliance, forensics, and detecting unauthorized changes to login records and system time.
- Always test in a non-production environment first and monitor audit log size.
---
<center><font color="#ffff00">Passed</font></center>
Title   Configure auditd mail_acct Action on Low Disk Space
Rule    xccdf_org.ssgproject.content_rule_auditd_data_retention_action_mail_acct
Ident   CCE-80678-6
Result  pass

Title   Configure auditd Max Log File Size
Rule    xccdf_org.ssgproject.content_rule_auditd_data_retention_max_log_file
Ident   CCE-80681-0
Result  pass

---
### Configure auditd admin_space_left Action on Low Disk Space  
**Rule:** xccdf_org.ssgproject.content_rule_auditd_data_retention_admin_space_left_action  
**Ident:** CCE-80679-4  
**Result:** fail  
**What:** Configures what action auditd takes when the admin-defined disk space threshold is reached.  
**Why:** Ensures administrators are alerted or action is taken before disk space runs out, preventing audit log loss and maintaining compliance.

**Manual Fix:**  
Edit `/etc/audit/auditd.conf` and set:
```bash
admin_space_left_action = SYSLOG
```
Other valid values: `SUSPEND`, `SINGLE`, `HALT`, `EXEC`, `EMAIL`, `IGNORE`, `SYSLOG` (recommended: `SYSLOG` or `EMAIL`).
### Configure auditd max_log_file_action Upon Reaching Maximum Log Size  
**Rule:** xccdf_org.ssgproject.content_rule_auditd_data_retention_max_log_file_action  
**Ident:** CCE-80682-8  
**Result:** fail  
**What:** Configures what auditd does when the maximum log file size is reached.  
**Why:** Prevents audit logs from filling up the disk, ensures logs are rotated or managed according to policy.

**Manual Fix:**  
Edit `/etc/audit/auditd.conf` and set:
```bash
max_log_file_action = ROTATE
```
Other valid values: `IGNORE`, `SYSLOG`, `SUSPEND`, `HALT`, `EXEC`, `ROTATE` (recommended: `ROTATE`).
### Configure auditd space_left Action on Low Disk Space  
**Rule:** xccdf_org.ssgproject.content_rule_auditd_data_retention_space_left_action  
**Ident:** CCE-80684-4  
**Result:** fail  
**What:** Configures what auditd does when the disk space for logs is low.  
**Why:** Ensures timely notification or action before running out of disk space, so logs are not lost.

**Manual Fix:**  
Edit `/etc/audit/auditd.conf` and set:
```bash
space_left_action = SYSLOG
```
Other valid values: `IGNORE`, `SYSLOG`, `EMAIL`, `SUSPEND`, `HALT`, `EXEC` (recommended: `SYSLOG` or `EMAIL`).
#### Combined Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/configure_auditd_disk_actions.sh

LOG_FILE="/var/log/auditd_disk_actions_setup.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting auditd disk space and log file action configuration at $(date)"

AUDITD_CONF="/etc/audit/auditd.conf"

# Backup original config
cp -p "$AUDITD_CONF" "$AUDITD_CONF.$(date +%Y%m%d-%H%M%S).bak"

# Function to set or update a config option
set_auditd_option() {
    local option="$1"
    local value="$2"
    if grep -q "^$option" "$AUDITD_CONF"; then
        if grep -q "^$option[[:space:]]*=[[:space:]]*$value" "$AUDITD_CONF"; then
            echo "$option already set to $value in $AUDITD_CONF"
        else
            sed -i "s|^$option.*|$option = $value|" "$AUDITD_CONF"
            echo "Updated $option to $value in $AUDITD_CONF"
        fi
    else
        echo "$option = $value" >> "$AUDITD_CONF"
        echo "Added $option = $value to $AUDITD_CONF"
    fi
}

# Set required options
set_auditd_option "admin_space_left_action" "SYSLOG"
set_auditd_option "max_log_file_action" "ROTATE"
set_auditd_option "space_left_action" "SYSLOG"

# Reload auditd to apply changes
if systemctl list-unit-files | grep -q '^auditd\.service'; then
    if systemctl is-active --quiet auditd; then
        systemctl reload auditd
    else
        echo "auditd is not active, skipping reload."
    fi
elif command -v service &>/dev/null; then
    service auditd reload || echo "Could not reload auditd with service command."
else
    echo "Could not reload auditd: service manager not found."
fi

echo "Verifying auditd.conf settings:"
grep -E 'admin_space_left_action|max_log_file_action|space_left_action' "$AUDITD_CONF"

echo "Auditd disk space and log file action configuration complete. See $LOG_FILE for details"
````
**Remember:**  
- These settings ensure audit logs are not lost due to disk space issues and that administrators are notified or logs are rotated as needed.
- Always test in a non-production environment first and monitor audit log size and disk usage.
---
<center><font color="#ffff00">Passed </font></center>
Title   Verify /boot/grub2/grub.cfg Group Ownership
Rule    xccdf_org.ssgproject.content_rule_file_groupowner_grub2_cfg
Ident   CCE-80800-6
Result  pass

Title   Verify /boot/grub2/grub.cfg User Ownership
Rule    xccdf_org.ssgproject.content_rule_file_owner_grub2_cfg
Ident   CCE-80805-5
Result  pass

---
### Verify /boot/grub2/grub.cfg Permissions  
**Rule:** xccdf_org.ssgproject.content_rule_file_permissions_grub2_cfg  
**Ident:** CCE-80814-7  
**Result:** fail  
#### What is this Rule?
This rule ensures that the GRUB2 bootloader configuration file (`/boot/grub2/grub.cfg`) has secure permissions. This file controls the boot process and kernel parameters; if it is writable by unauthorized users, attackers could compromise the system at boot.
#### Why is it Necessary?
- **Prevents Unauthorized Boot Changes:** Protects against tampering with boot parameters or kernel options.
- **Compliance:** Required by security standards (CIS, STIG, PCI-DSS, etc.).
- **System Integrity:** Ensures only root can modify bootloader settings.
- **Prevents Privilege Escalation:** Attackers could gain persistent root access by modifying this file.
#### Manual Fix
```bash
# Set correct permissions (readable by root only)
sudo chmod 600 /boot/grub2/grub.cfg

# Set correct ownership (root:root)
sudo chown root:root /boot/grub2/grub.cfg

# Verify
ls -l /boot/grub2/grub.cfg
```
#### Automated Script
This script checks if `/boot/grub2/grub.cfg` already has the correct permissions and ownership. If not, it sets them.
````bash
#!/bin/bash
# filepath: /root/scripts/fix_grub_cfg_permissions.sh

GRUB_CFG="/boot/grub2/grub.cfg"
LOG_FILE="/var/log/fix_grub_cfg_permissions.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Checking permissions and ownership for $GRUB_CFG at $(date)"

# Check if file exists
if [ ! -f "$GRUB_CFG" ]; then
    echo "Error: $GRUB_CFG does not exist!"
    exit 1
fi

# Check permissions
PERMS=$(stat -c "%a" "$GRUB_CFG")
OWNER=$(stat -c "%U" "$GRUB_CFG")
GROUP=$(stat -c "%G" "$GRUB_CFG")

FIXED=0

if [ "$PERMS" != "600" ]; then
    echo "Incorrect permissions ($PERMS). Setting to 600."
    chmod 600 "$GRUB_CFG"
    FIXED=1
else
    echo "Permissions already set to 600."
fi

if [ "$OWNER" != "root" ] || [ "$GROUP" != "root" ]; then
    echo "Incorrect owner/group ($OWNER:$GROUP). Setting to root:root."
    chown root:root "$GRUB_CFG"
    FIXED=1
else
    echo "Owner and group already set to root:root."
fi

if [ $FIXED -eq 0 ]; then
    echo "No changes needed. $GRUB_CFG is already secure."
else
    echo "Permissions and ownership for $GRUB_CFG have been corrected."
fi

ls -l "$GRUB_CFG"
echo "Done. See $LOG_FILE for details."
````
**Remember:**  
- Always test scripts in a safe environment first.
- Document changes in your change management system.
- Secure bootloader configuration is critical for system security and compliance.

---
### Set Boot Loader Password in grub2  
**Rule:** xccdf_org.ssgproject.content_rule_grub2_password  
**Ident:** CCE-80828-7  
**Result:** fail  
#### What is this Rule?
This rule requires that a password is set for the GRUB2 bootloader. Setting a password prevents unauthorized users from editing boot parameters or entering single-user mode at boot, which could allow them to bypass security controls.
#### Why is it Necessary?
- **Prevents Unauthorized Boot Changes:** Stops attackers from editing kernel parameters or booting into single-user mode without authentication.
- **Compliance:** Required by many security standards (CIS, STIG, PCI-DSS, etc.).
- **System Integrity:** Ensures only authorized users can modify bootloader settings.
- **Prevents Privilege Escalation:** Attackers could gain root access by bypassing authentication at boot.
#### Manual Fix
1. **Generate a GRUB2 password hash:**
   ```bash
   grub2-mkpasswd-pbkdf2
   ```
   Enter your desired password when prompted. Copy the resulting hash (it starts with `grub.pbkdf2.sha512...`).
2. **Edit the GRUB2 configuration file:**
   ```bash
   sudo vi /etc/grub.d/40_custom
   ```
   Add the following lines (replace `<hash>` with your generated hash):
   ```bash
   set superuser="root"
   password_pbkdf2 root <hash>
   ```
3. **Update the GRUB2 configuration:**
   ```bash
   sudo grub2-mkconfig -o /boot/grub2/grub.cfg
   ```
4. **Verify:**
   ```bash
   grep password_pbkdf2 /boot/grub2/grub.cfg
   ```
#### Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/set_grub2_password.sh

LOG_FILE="/var/log/set_grub2_password.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

GRUB_CUSTOM="/etc/grub.d/40_custom"
GRUB_CFG="/boot/grub2/grub.cfg"

echo "Setting GRUB2 bootloader password at $(date)"

# Prompt for password and generate hash
echo "Enter the GRUB2 password you want to set:"
read -s PASSWORD
HASH=$(echo -e "$PASSWORD\n$PASSWORD" | grub2-mkpasswd-pbkdf2 | awk '/grub.pbkdf2.sha512/ {print $7}')

if [ -z "$HASH" ]; then
    echo "Failed to generate password hash."
    exit 1
fi

# Backup original file
cp -p "$GRUB_CUSTOM" "$GRUB_CUSTOM.$(date +%Y%m%d-%H%M%S).bak"

# Add superuser and password to 40_custom if not present
if ! grep -q "password_pbkdf2 root" "$GRUB_CUSTOM"; then
    echo "set superuser=\"root\"" >> "$GRUB_CUSTOM"
    echo "password_pbkdf2 root $HASH" >> "$GRUB_CUSTOM"
    echo "Added GRUB2 password to $GRUB_CUSTOM"
else
    echo "GRUB2 password already set in $GRUB_CUSTOM"
fi

# Update GRUB2 configuration
grub2-mkconfig -o "$GRUB_CFG"

# Verify
if grep -q "password_pbkdf2" "$GRUB_CFG"; then
    echo "GRUB2 password successfully configured."
else
    echo "Failed to configure GRUB2 password."
fi

echo "Done. See $LOG_FILE for details."
````
**Remember:**  
- Always test scripts in a safe environment first.
- Store the password securely.
- Document changes in your change management system.
- After setting a GRUB2 password, only authorized users will be able to edit boot parameters at boot.
---
<center><font color="#ffff00"> Notapplicable</font></center>
Title   Verify the UEFI Boot Loader grub.cfg Group Ownership
Rule    xccdf_org.ssgproject.content_rule_file_groupowner_efi_grub2_cfg
Ident   CCE-85915-7
Result  notapplicable

Title   Verify the UEFI Boot Loader grub.cfg User Ownership
Rule    xccdf_org.ssgproject.content_rule_file_owner_efi_grub2_cfg
Ident   CCE-85913-2
Result  notapplicable

Title   Verify the UEFI Boot Loader grub.cfg Permissions
Rule    xccdf_org.ssgproject.content_rule_file_permissions_efi_grub2_cfg
Ident   CCE-85912-4
Result  notapplicable

Title   Set the UEFI Boot Loader Password
Rule    xccdf_org.ssgproject.content_rule_grub2_uefi_password
Ident   CCE-80829-5
Result  notapplicable

---
<center><font color="#ffff00">Passed</font></center>
Title   Ensure rsyslog is Installed
Rule    xccdf_org.ssgproject.content_rule_package_rsyslog_installed
Ident   CCE-80847-7
Result  pass

Title   Enable rsyslog Service
Rule    xccdf_org.ssgproject.content_rule_service_rsyslog_enabled
Ident   CCE-80886-5
Result  pass

Title   Install firewalld Package
Rule    xccdf_org.ssgproject.content_rule_package_firewalld_installed
Ident   CCE-82998-6
Result  pass

Title   Verify firewalld Enabled
Rule    xccdf_org.ssgproject.content_rule_service_firewalld_enabled
Ident   CCE-80877-4
Result  pass

---

### Set Default firewalld Zone for Incoming Packets  
**Rule:** xccdf_org.ssgproject.content_rule_set_firewalld_default_zone  
**Ident:** CCE-80890-7  
**Result:** fail  
#### What is this Rule?
This rule ensures that the default zone for firewalld is set to a secure value (such as `public` or `drop`). The default zone determines the firewall rules applied to incoming network packets that do not match any other zone.
#### Why is it Necessary?
- **Restricts Unintended Access:** Ensures new or unassigned interfaces are not left open to the network.
- **Compliance:** Required by many security standards (CIS, STIG, PCI-DSS, etc.).
- **System Integrity:** Prevents accidental exposure of services.
- **Reduces Attack Surface:** Applies restrictive rules by default, minimizing risk.
#### Manual Fix
1. **Check current default zone:**
   ```bash
   sudo firewall-cmd --get-default-zone
   ```
2. **Set the default zone (recommended: `public`):**
   ```bash
   sudo firewall-cmd --set-default-zone=public
   ```
3. **Make the change persistent:**
   ```bash
   sudo firewall-cmd --permanent --set-default-zone=public
   ```
4. **Verify the setting:**
   ```bash
   sudo firewall-cmd --get-default-zone
   ```
#### Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/set_firewalld_default_zone.sh

LOG_FILE="/var/log/firewalld_default_zone_setup.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

DEFAULT_ZONE="public"

echo "Checking current firewalld default zone at $(date)"

CURRENT_ZONE=$(firewall-cmd --get-default-zone)

if [ "$CURRENT_ZONE" != "$DEFAULT_ZONE" ]; then
    echo "Setting firewalld default zone to $DEFAULT_ZONE"
    firewall-cmd --set-default-zone=$DEFAULT_ZONE
    firewall-cmd --permanent --set-default-zone=$DEFAULT_ZONE
    echo "Default zone set to $DEFAULT_ZONE"
else
    echo "Default zone is already set to $DEFAULT_ZONE"
fi

echo "Verifying default zone:"
firewall-cmd --get-default-zone

echo "Firewalld default zone configuration complete. See $LOG_FILE for details"
````
**Remember:**  
- Always test firewall changes in a safe environment first.
- Document changes in your change management system.
- The default zone should be restrictive (`public`, `drop`, or `block`) unless your environment requires otherwise.
---
### Configure Accepting Router Advertisements on All IPv6 Interfaces  
**Rule:** xccdf_org.ssgproject.content_rule_sysctl_net_ipv6_conf_all_accept_ra  
**Ident:** CCE-81006-9  
**Result:** fail  
**What:** Controls whether the system accepts IPv6 router advertisements on all interfaces.  
**Why:** Prevents unauthorized network configuration via rogue router advertisements.

**Manual Fix:**  
```bash
sudo sysctl -w net.ipv6.conf.all.accept_ra=0
echo "net.ipv6.conf.all.accept_ra = 0" | sudo tee -a /etc/sysctl.d/99-oscap.conf
sudo sysctl --system
```
### Disable Accepting ICMP Redirects for All IPv6 Interfaces  
**Rule:** xccdf_org.ssgproject.content_rule_sysctl_net_ipv6_conf_all_accept_redirects  
**Ident:** CCE-81009-3  
**Result:** fail  
**What:** Controls acceptance of ICMPv6 redirects on all interfaces.  
**Why:** Prevents attackers from redirecting traffic to malicious hosts.

**Manual Fix:**  
```bash
sudo sysctl -w net.ipv6.conf.all.accept_redirects=0
echo "net.ipv6.conf.all.accept_redirects = 0" | sudo tee -a /etc/sysctl.d/99-oscap.conf
sudo sysctl --system
```
### Disable Kernel Parameter for Accepting Source-Routed Packets on all IPv6 Interfaces  
**Rule:** xccdf_org.ssgproject.content_rule_sysctl_net_ipv6_conf_all_accept_source_route  
**Ident:** CCE-81013-5  
**Result:** fail  
**What:** Controls acceptance of source-routed packets on all IPv6 interfaces.  
**Why:** Source routing can be abused to bypass security controls.

**Manual Fix:**  
```bash
sudo sysctl -w net.ipv6.conf.all.accept_source_route=0
echo "net.ipv6.conf.all.accept_source_route = 0" | sudo tee -a /etc/sysctl.d/99-oscap.conf
sudo sysctl --system
```
### Disable Kernel Parameter for IPv6 Forwarding  
**Rule:** xccdf_org.ssgproject.content_rule_sysctl_net_ipv6_conf_all_forwarding  
**Ident:** CCE-82863-2  
**Result:** fail  
**What:** Controls IPv6 packet forwarding.  
**Why:** Prevents the system from acting as a router unless intended.

**Manual Fix:**  
```bash
sudo sysctl -w net.ipv6.conf.all.forwarding=0
echo "net.ipv6.conf.all.forwarding = 0" | sudo tee -a /etc/sysctl.d/99-oscap.conf
sudo sysctl --system
```
### Disable Accepting Router Advertisements on all IPv6 Interfaces by Default  
**Rule:** xccdf_org.ssgproject.content_rule_sysctl_net_ipv6_conf_default_accept_ra  
**Ident:** CCE-81007-7  
**Result:** fail  
**What:** Controls default acceptance of IPv6 router advertisements on new interfaces.  
**Why:** Ensures new interfaces are not misconfigured.

**Manual Fix:**  
```bash
sudo sysctl -w net.ipv6.conf.default.accept_ra=0
echo "net.ipv6.conf.default.accept_ra = 0" | sudo tee -a /etc/sysctl.d/99-oscap.conf
sudo sysctl --system
```
### Disable Kernel Parameter for Accepting ICMP Redirects by Default on IPv6 Interfaces  
**Rule:** xccdf_org.ssgproject.content_rule_sysctl_net_ipv6_conf_default_accept_redirects  
**Ident:** CCE-81010-1  
**Result:** fail  
**What:** Controls default acceptance of ICMPv6 redirects on new interfaces.  
**Why:** Prevents future interfaces from being vulnerable.

**Manual Fix:**  
```bash
sudo sysctl -w net.ipv6.conf.default.accept_redirects=0
echo "net.ipv6.conf.default.accept_redirects = 0" | sudo tee -a /etc/sysctl.d/99-oscap.conf
sudo sysctl --system
```
### Disable Kernel Parameter for Accepting Source-Routed Packets on IPv6 Interfaces by Default  
**Rule:** xccdf_org.ssgproject.content_rule_sysctl_net_ipv6_conf_default_accept_source_route  
**Ident:** CCE-81015-0  
**Result:** fail  
**What:** Controls default acceptance of source-routed packets on new IPv6 interfaces.  
**Why:** Prevents future interfaces from being vulnerable.

**Manual Fix:**  
```bash
sudo sysctl -w net.ipv6.conf.default.accept_source_route=0
echo "net.ipv6.conf.default.accept_source_route = 0" | sudo tee -a /etc/sysctl.d/99-oscap.conf
sudo sysctl --system
```
### Disable Accepting ICMP Redirects for All IPv4 Interfaces  
**Rule:** xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_conf_all_accept_redirects  
**Ident:** CCE-80917-8  
**Result:** fail  
**What:** Controls acceptance of ICMPv4 redirects on all interfaces.  
**Why:** Prevents attackers from redirecting IPv4 traffic.

**Manual Fix:**  
```bash
sudo sysctl -w net.ipv4.conf.all.accept_redirects=0
echo "net.ipv4.conf.all.accept_redirects = 0" | sudo tee -a /etc/sysctl.d/99-oscap.conf
sudo sysctl --system
```
#### Combined Automation Script **
````bash
#!/bin/bash
# filepath: /root/scripts/sysctl_network_hardening.sh

LOG_FILE="/var/log/sysctl_network_hardening.log"
CONF_FILE="/etc/sysctl.d/99-oscap.conf"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting sysctl network hardening at $(date)"

cat > "$CONF_FILE" <<EOF
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.all.forwarding = 0
net.ipv6.conf.default.accept_ra = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv6.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
EOF

sysctl --system

echo "Verifying settings:"
sysctl net.ipv6.conf.all.accept_ra
sysctl net.ipv6.conf.all.accept_redirects
sysctl net.ipv6.conf.all.accept_source_route
sysctl net.ipv6.conf.all.forwarding
sysctl net.ipv6.conf.default.accept_ra
sysctl net.ipv6.conf.default.accept_redirects
sysctl net.ipv6.conf.default.accept_source_route
sysctl net.ipv4.conf.all.accept_redirects

echo "Sysctl network hardening complete. See $LOG_FILE for details"
````

**Remember:**  
- These settings prevent network-based attacks and misconfigurations.
- Always test in a non-production environment first.
- Document changes in your change management system.

---
<center><font color="#ffff00">Passed</font></center>
Title   Disable Kernel Parameter for Accepting Source-Routed Packets on all IPv4 Interfaces
Rule    xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_conf_all_accept_source_route
Ident   CCE-81011-9
Result  pass

Title   Enable Kernel Parameter to Use Reverse Path Filtering on all IPv4 Interfaces
Rule    xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_conf_all_rp_filter
Ident   CCE-81021-8
Result  pass

---
### Enable Kernel Parameter to Log Martian Packets on all IPv4 Interfaces  
**Rule:** xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_conf_all_log_martians  
**Ident:** CCE-81018-4  
**Result:** fail  
**What:** Enables logging of packets with impossible addresses ("martians").  
**Why:** Helps detect spoofed or misrouted packets, improving network security.

**Manual Fix:**  
```bash
sudo sysctl -w net.ipv4.conf.all.log_martians=1
echo "net.ipv4.conf.all.log_martians = 1" | sudo tee -a /etc/sysctl.d/99-oscap.conf
sudo sysctl --system
```
### Disable Kernel Parameter for Accepting Secure ICMP Redirects on all IPv4 Interfaces  
**Rule:** xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_conf_all_secure_redirects  
**Ident:** CCE-81016-8  
**Result:** fail  
**What:** Disables acceptance of secure ICMP redirects.  
**Why:** Prevents attackers from redirecting traffic, reducing risk of man-in-the-middle attacks.

**Manual Fix:**  
```bash
sudo sysctl -w net.ipv4.conf.all.secure_redirects=0
echo "net.ipv4.conf.all.secure_redirects = 0" | sudo tee -a /etc/sysctl.d/99-oscap.conf
sudo sysctl --system
```
### Disable Kernel Parameter for Accepting ICMP Redirects by Default on IPv4 Interfaces  
**Rule:** xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_conf_default_accept_redirects  
**Ident:** CCE-80919-4  
**Result:** fail  
**What:** Disables acceptance of ICMP redirects by default on new interfaces.  
**Why:** Prevents future interfaces from being vulnerable to redirection attacks.

**Manual Fix:**  
```bash
sudo sysctl -w net.ipv4.conf.default.accept_redirects=0
echo "net.ipv4.conf.default.accept_redirects = 0" | sudo tee -a /etc/sysctl.d/99-oscap.conf
sudo sysctl --system
```
### Disable Kernel Parameter for Accepting Source-Routed Packets on IPv4 Interfaces by Default  
**Rule:** xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_conf_default_accept_source_route  
**Ident:** CCE-80920-2  
**Result:** fail  
**What:** Disables source-routed packets by default on new interfaces.  
**Why:** Source routing can be abused to bypass security controls.

**Manual Fix:**  
```bash
sudo sysctl -w net.ipv4.conf.default.accept_source_route=0
echo "net.ipv4.conf.default.accept_source_route = 0" | sudo tee -a /etc/sysctl.d/99-oscap.conf
sudo sysctl --system
```
### Enable Kernel Parameter to Log Martian Packets on all IPv4 Interfaces by Default  
**Rule:** xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_conf_default_log_martians  
**Ident:** CCE-81020-0  
**Result:** fail  
**What:** Enables logging of martian packets by default on new interfaces.  
**Why:** Ensures new interfaces log suspicious packets.

**Manual Fix:**  
```bash
sudo sysctl -w net.ipv4.conf.default.log_martians=1
echo "net.ipv4.conf.default.log_martians = 1" | sudo tee -a /etc/sysctl.d/99-oscap.conf
sudo sysctl --system
```
### Enable Kernel Parameter to Use Reverse Path Filtering on all IPv4 Interfaces by Default  
**Rule:** xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_conf_default_rp_filter  
**Ident:** CCE-81022-6  
**Result:** fail  
**What:** Enables reverse path filtering by default on new interfaces.  
**Why:** Helps prevent IP spoofing.

**Manual Fix:**  
```bash
sudo sysctl -w net.ipv4.conf.default.rp_filter=1
echo "net.ipv4.conf.default.rp_filter = 1" | sudo tee -a /etc/sysctl.d/99-oscap.conf
sudo sysctl --system
```
### Configure Kernel Parameter for Accepting Secure Redirects By Default  
**Rule:** xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_conf_default_secure_redirects  
**Ident:** CCE-81017-6  
**Result:** fail  
**What:** Disables secure ICMP redirects by default on new interfaces.  
**Why:** Prevents future interfaces from being vulnerable to redirection attacks.

**Manual Fix:**  
```bash
sudo sysctl -w net.ipv4.conf.default.secure_redirects=0
echo "net.ipv4.conf.default.secure_redirects = 0" | sudo tee -a /etc/sysctl.d/99-oscap.conf
sudo sysctl --system
```
### Enable Kernel Parameter to Ignore ICMP Broadcast Echo Requests on IPv4 Interfaces  
**Rule:** xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_icmp_echo_ignore_broadcasts  
**Ident:** CCE-80922-8  
**Result:** fail  
**What:** Ignores ICMP echo requests sent to broadcast addresses.  
**Why:** Prevents smurf attacks (amplified DoS).

**Manual Fix:**  
```bash
sudo sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1
echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" | sudo tee -a /etc/sysctl.d/99-oscap.conf
sudo sysctl --system
```
### Enable Kernel Parameter to Ignore Bogus ICMP Error Responses on IPv4 Interfaces  
**Rule:** xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_icmp_ignore_bogus_error_responses  
**Ident:** CCE-81023-4  
**Result:** fail  
**What:** Ignores bogus ICMP error responses.  
**Why:** Prevents log flooding and potential confusion from invalid ICMP errors.

**Manual Fix:**  
```bash
sudo sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1
echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" | sudo tee -a /etc/sysctl.d/99-oscap.conf
sudo sysctl --system
```
### Enable Kernel Parameter to Use TCP Syncookies on IPv4 Interfaces  
**Rule:** xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_tcp_syncookies  
**Ident:** CCE-80923-6  
**Result:** fail  
**What:** Enables TCP syncookies to protect against SYN flood attacks.  
**Why:** Helps prevent denial-of-service attacks.

**Manual Fix:**  
```bash
sudo sysctl -w net.ipv4.tcp_syncookies=1
echo "net.ipv4.tcp_syncookies = 1" | sudo tee -a /etc/sysctl.d/99-oscap.conf
sudo sysctl --system
```
### Disable Kernel Parameter for Sending ICMP Redirects on all IPv4 Interfaces  
**Rule:** xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_conf_all_send_redirects  
**Ident:** CCE-80918-6  
**Result:** fail  
**What:** Disables sending of ICMP redirects on all interfaces.  
**Why:** Prevents attackers from influencing routing tables.

**Manual Fix:**  
```bash
sudo sysctl -w net.ipv4.conf.all.send_redirects=0
echo "net.ipv4.conf.all.send_redirects = 0" | sudo tee -a /etc/sysctl.d/99-oscap.conf
sudo sysctl --system
```
### Disable Kernel Parameter for Sending ICMP Redirects on all IPv4 Interfaces by Default  
**Rule:** xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_conf_default_send_redirects  
**Ident:** CCE-80921-0  
**Result:** fail  
**What:** Disables sending of ICMP redirects by default on new interfaces.  
**Why:** Prevents future interfaces from being vulnerable.

**Manual Fix:**  
```bash
sudo sysctl -w net.ipv4.conf.default.send_redirects=0
echo "net.ipv4.conf.default.send_redirects = 0" | sudo tee -a /etc/sysctl.d/99-oscap.conf
sudo sysctl --system
```
### Disable Kernel Parameter for IP Forwarding on IPv4 Interfaces  
**Rule:** xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_ip_forward  
**Ident:** CCE-81024-2  
**Result:** fail  
**What:** Disables IPv4 forwarding.  
**Why:** Prevents the system from acting as a router unless intended.

**Manual Fix:**  
```bash
sudo sysctl -w net.ipv4.ip_forward=0
echo "net.ipv4.ip_forward = 0" | sudo tee -a /etc/sysctl.d/99-oscap.conf
sudo sysctl --system
```
#### Combined Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/sysctl_ipv4_hardening.sh

LOG_FILE="/var/log/sysctl_ipv4_hardening.log"
CONF_FILE="/etc/sysctl.d/99-oscap.conf"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting IPv4 sysctl hardening at $(date)"

cat >> "$CONF_FILE" <<EOF
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.default.log_martians = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.ip_forward = 0
EOF

sysctl --system

echo "Verifying settings:"
sysctl net.ipv4.conf.all.log_martians
sysctl net.ipv4.conf.all.secure_redirects
sysctl net.ipv4.conf.default.accept_redirects
sysctl net.ipv4.conf.default.accept_source_route
sysctl net.ipv4.conf.default.log_martians
sysctl net.ipv4.conf.default.rp_filter
sysctl net.ipv4.conf.default.secure_redirects
sysctl net.ipv4.icmp_echo_ignore_broadcasts
sysctl net.ipv4.icmp_ignore_bogus_error_responses
sysctl net.ipv4.tcp_syncookies
sysctl net.ipv4.conf.all.send_redirects
sysctl net.ipv4.conf.default.send_redirects
sysctl net.ipv4.ip_forward

echo "IPv4 sysctl hardening complete. See $LOG_FILE for details"
````

**Remember:**  
- These settings harden the system against spoofing, redirection, and DoS attacks.
- Always test in a non-production environment first.
- Document changes in your change management system.

---
### Disable DCCP Support  
**Rule:** xccdf_org.ssgproject.content_rule_kernel_module_dccp_disabled  
**Ident:** CCE-80833-7  
**Result:** fail  
**What:** Disables the Datagram Congestion Control Protocol (DCCP) kernel module.  
**Why:** DCCP is rarely used and can be exploited for attacks if left enabled.

**Manual Fix:**  
```bash
echo "install dccp /bin/true" | sudo tee /etc/modprobe.d/dccp.conf
sudo rmmod dccp 2>/dev/null || true
```
### Disable RDS Support  
**Rule:** xccdf_org.ssgproject.content_rule_kernel_module_rds_disabled  
**Ident:** CCE-82870-7  
**Result:** fail  
**What:** Disables the Reliable Datagram Sockets (RDS) kernel module.  
**Why:** RDS is not commonly used and has had security vulnerabilities.

**Manual Fix:**  
```bash
echo "install rds /bin/true" | sudo tee /etc/modprobe.d/rds.conf
sudo rmmod rds 2>/dev/null || true
```
### Disable SCTP Support  
**Rule:** xccdf_org.ssgproject.content_rule_kernel_module_sctp_disabled  
**Ident:** CCE-80834-5  
**Result:** fail  
**What:** Disables the Stream Control Transmission Protocol (SCTP) kernel module.  
**Why:** SCTP is rarely needed and can be a vector for attacks.

**Manual Fix:**  
```bash
echo "install sctp /bin/true" | sudo tee /etc/modprobe.d/sctp.conf
sudo rmmod sctp 2>/dev/null || true
```
### Disable TIPC Support  
**Rule:** xccdf_org.ssgproject.content_rule_kernel_module_tipc_disabled  
**Ident:** CCE-82297-3  
**Result:** fail  
**What:** Disables the Transparent Inter-Process Communication (TIPC) kernel module.  
**Why:** TIPC is not widely used and can introduce security risks.

**Manual Fix:**  
```bash
echo "install tipc /bin/true" | sudo tee /etc/modprobe.d/tipc.conf
sudo rmmod tipc 2>/dev/null || true
```
#### Combined Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/disable_unneeded_kernel_modules.sh

LOG_FILE="/var/log/disable_kernel_modules.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Disabling unneeded kernel modules at $(date)"

declare -A modules=(
    [dccp]="Datagram Congestion Control Protocol"
    [rds]="Reliable Datagram Sockets"
    [sctp]="Stream Control Transmission Protocol"
    [tipc]="Transparent Inter-Process Communication"
)

for mod in "${!modules[@]}"; do
    CONF="/etc/modprobe.d/${mod}.conf"
    if ! grep -q "^install $mod /bin/true" "$CONF" 2>/dev/null; then
        echo "install $mod /bin/true" > "$CONF"
        echo "Disabled ${modules[$mod]} ($mod) via $CONF"
    else
        echo "$mod already disabled in $CONF"
    fi
    rmmod $mod 2>/dev/null && echo "Removed loaded module $mod" || true
done

echo "Verifying module disablement:"
for mod in "${!modules[@]}"; do
    lsmod | grep -q "^$mod" && echo "WARNING: $mod is still loaded" || echo "$mod is not loaded"
done

echo "Kernel module disablement complete. See $LOG_FILE for details"
````
**Remember:**  
- These steps prevent loading of unnecessary and potentially vulnerable kernel modules.
- Always test in a non-production environment first.
- Document changes in your change management system.

---
<center><font color="#ffc000">Passed </font></center>
Title   Deactivate Wireless Network Interfaces
Rule    xccdf_org.ssgproject.content_rule_wireless_disable_interfaces
Ident   CCE-83501-7
Result  pass

Title   Verify that All World-Writable Directories Have Sticky Bits Set
Rule    xccdf_org.ssgproject.content_rule_dir_perms_world_writable_sticky_bits
Ident   CCE-80783-4
Result  pass

Title   Ensure No World-Writable Files Exist
Rule    xccdf_org.ssgproject.content_rule_file_permissions_unauthorized_world_writable
Ident   CCE-80818-8
Result  pass

Title   Ensure All Files Are Owned by a Group
Rule    xccdf_org.ssgproject.content_rule_file_permissions_ungroupowned
Ident   CCE-83497-8
Result  pass

Title   Ensure All Files Are Owned by a User
Rule    xccdf_org.ssgproject.content_rule_no_files_unowned_by_user
Ident   CCE-83499-4
Result  pass

Title   Verify Group Who Owns Backup group File
Rule    xccdf_org.ssgproject.content_rule_file_groupowner_backup_etc_group
Ident   CCE-83475-4
Result  pass

Title   Verify Group Who Owns Backup gshadow File
Rule    xccdf_org.ssgproject.content_rule_file_groupowner_backup_etc_gshadow
Ident   CCE-83535-5
Result  pass

Title   Verify Group Who Owns Backup passwd File
Rule    xccdf_org.ssgproject.content_rule_file_groupowner_backup_etc_passwd
Ident   CCE-83324-4
Result  pass

Title   Verify User Who Owns Backup shadow File
Rule    xccdf_org.ssgproject.content_rule_file_groupowner_backup_etc_shadow
Ident   CCE-83415-0
Result  pass

Title   Verify Group Who Owns group File
Rule    xccdf_org.ssgproject.content_rule_file_groupowner_etc_group
Ident   CCE-80796-6
Result  pass

Title   Verify Group Who Owns gshadow File
Rule    xccdf_org.ssgproject.content_rule_file_groupowner_etc_gshadow
Ident   CCE-80797-4
Result  pass

Title   Verify Group Who Owns passwd File
Rule    xccdf_org.ssgproject.content_rule_file_groupowner_etc_passwd
Ident   CCE-80798-2
Result  pass

Title   Verify Group Who Owns shadow File
Rule    xccdf_org.ssgproject.content_rule_file_groupowner_etc_shadow
Ident   CCE-80799-0
Result  pass

Title   Verify User Who Owns Backup group File
Rule    xccdf_org.ssgproject.content_rule_file_owner_backup_etc_group
Ident   CCE-83473-9
Result  pass

Title   Verify User Who Owns Backup gshadow File
Rule    xccdf_org.ssgproject.content_rule_file_owner_backup_etc_gshadow
Ident   CCE-83533-0
Result  pass

Title   Verify User Who Owns Backup passwd File
Rule    xccdf_org.ssgproject.content_rule_file_owner_backup_etc_passwd
Ident   CCE-83326-9
Result  pass

Title   Verify Group Who Owns Backup shadow File
Rule    xccdf_org.ssgproject.content_rule_file_owner_backup_etc_shadow
Ident   CCE-83413-5
Result  pass

Title   Verify User Who Owns group File
Rule    xccdf_org.ssgproject.content_rule_file_owner_etc_group
Ident   CCE-80801-4
Result  pass

Title   Verify User Who Owns gshadow File
Rule    xccdf_org.ssgproject.content_rule_file_owner_etc_gshadow
Ident   CCE-80802-2
Result  pass

Title   Verify User Who Owns passwd File
Rule    xccdf_org.ssgproject.content_rule_file_owner_etc_passwd
Ident   CCE-80803-0
Result  pass

Title   Verify User Who Owns shadow File
Rule    xccdf_org.ssgproject.content_rule_file_owner_etc_shadow
Ident   CCE-80804-8
Result  pass

Title   Verify Permissions on Backup group File
Rule    xccdf_org.ssgproject.content_rule_file_permissions_backup_etc_group
Ident   CCE-83483-8
Result  pass

Title   Verify Permissions on Backup gshadow File
Rule    xccdf_org.ssgproject.content_rule_file_permissions_backup_etc_gshadow
Ident   CCE-83573-6
Result  pass

Title   Verify Permissions on Backup passwd File
Rule    xccdf_org.ssgproject.content_rule_file_permissions_backup_etc_passwd
Ident   CCE-83332-7
Result  pass

Title   Verify Permissions on Backup shadow File
Rule    xccdf_org.ssgproject.content_rule_file_permissions_backup_etc_shadow
Ident   CCE-83417-6
Result  pass

Title   Verify Permissions on group File
Rule    xccdf_org.ssgproject.content_rule_file_permissions_etc_group
Ident   CCE-80810-5
Result  pass

Title   Verify Permissions on gshadow File
Rule    xccdf_org.ssgproject.content_rule_file_permissions_etc_gshadow
Ident   CCE-80811-3
Result  pass

Title   Verify Permissions on passwd File
Rule    xccdf_org.ssgproject.content_rule_file_permissions_etc_passwd
Ident   CCE-80812-1
Result  pass

Title   Verify Permissions on shadow File
Rule    xccdf_org.ssgproject.content_rule_file_permissions_etc_shadow
Ident   CCE-80813-9
Result  pass

Title   Disable the Automounter
Rule    xccdf_org.ssgproject.content_rule_service_autofs_disabled
Ident   CCE-80873-3
Result  pass

---
### Disable Mounting of cramfs  
**Rule:** xccdf_org.ssgproject.content_rule_kernel_module_cramfs_disabled  
**Ident:** CCE-81031-7  
**Result:** fail  
**What:** Disables the Compressed ROM File System (cramfs) kernel module.  
**Why:** cramfs is rarely used and can be a vector for attacks if enabled.

**Manual Fix:**  
```bash
echo "install cramfs /bin/true" | sudo tee /etc/modprobe.d/cramfs.conf
sudo rmmod cramfs 2>/dev/null || true
```
### Disable Mounting of squashfs  
**Rule:** xccdf_org.ssgproject.content_rule_kernel_module_squashfs_disabled  
**Ident:** CCE-83498-6  
**Result:** fail  
**What:** Disables the Squash File System (squashfs) kernel module.  
**Why:** squashfs is not commonly needed and can be abused for privilege escalation or persistence.

**Manual Fix:**  
```bash
echo "install squashfs /bin/true" | sudo tee /etc/modprobe.d/squashfs.conf
sudo rmmod squashfs 2>/dev/null || true
```
### Disable Mounting of udf  
**Rule:** xccdf_org.ssgproject.content_rule_kernel_module_udf_disabled  
**Ident:** CCE-82729-5  
**Result:** fail  
**What:** Disables the Universal Disk Format (udf) kernel module.  
**Why:** udf is used for optical media and is rarely needed on servers; it can be a vector for attacks.

**Manual Fix:**  
```bash
echo "install udf /bin/true" | sudo tee /etc/modprobe.d/udf.conf
sudo rmmod udf 2>/dev/null || true
```
#### Combined Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/disable_filesystem_modules.sh

LOG_FILE="/var/log/disable_filesystem_modules.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Disabling cramfs, squashfs, and udf filesystem modules at $(date)"

declare -A modules=(
    [cramfs]="Compressed ROM File System"
    [squashfs]="Squash File System"
    [udf]="Universal Disk Format"
)

for mod in "${!modules[@]}"; do
    CONF="/etc/modprobe.d/${mod}.conf"
    if ! grep -q "^install $mod /bin/true" "$CONF" 2>/dev/null; then
        echo "install $mod /bin/true" > "$CONF"
        echo "Disabled ${modules[$mod]} ($mod) via $CONF"
    else
        echo "$mod already disabled in $CONF"
    fi
    rmmod $mod 2>/dev/null && echo "Removed loaded module $mod" || true
done

echo "Verifying module disablement:"
for mod in "${!modules[@]}"; do
    lsmod | grep -q "^$mod" && echo "WARNING: $mod is still loaded" || echo "$mod is not loaded"
done

echo "Filesystem module disablement complete. See $LOG_FILE for details"
````
**Remember:**  
- These steps prevent loading of unnecessary and potentially vulnerable filesystem modules.
- Always test in a non-production environment first.
- Document changes in your change management system.

---

### Disable Modprobe Loading of USB Storage Driver  
**Rule:** xccdf_org.ssgproject.content_rule_kernel_module_usb-storage_disabled  
**Ident:** CCE-80835-2  
**Result:** fail  

**What:** Disables the USB storage kernel module (`usb-storage`).  
**Why:** Prevents users from connecting unauthorized USB storage devices, which can be used for data exfiltration, malware introduction, or bypassing network controls. Disabling this module is important for systems where removable storage is not required.
#### Manual Fix
```bash
echo "install usb-storage /bin/true" | sudo tee /etc/modprobe.d/usb-storage.conf
sudo rmmod usb-storage 2>/dev/null || true
```
#### Combined Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/disable_usb_storage.sh

LOG_FILE="/var/log/disable_usb_storage.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Disabling USB storage kernel module at $(date)"

CONF="/etc/modprobe.d/usb-storage.conf"
if ! grep -q "^install usb-storage /bin/true" "$CONF" 2>/dev/null; then
    echo "install usb-storage /bin/true" > "$CONF"
    echo "Disabled USB storage via $CONF"
else
    echo "usb-storage already disabled in $CONF"
fi

rmmod usb-storage 2>/dev/null && echo "Removed loaded module usb-storage" || true

echo "Verifying module disablement:"
lsmod | grep -q "^usb_storage" && echo "WARNING: usb-storage is still loaded" || echo "usb-storage is not loaded"

echo "USB storage module disablement complete. See $LOG_FILE for details"
````

**Remember:**  
- This prevents loading of USB storage devices for all users.
- Always test in a non-production environment first.
- Document changes in your change management system.

---
<center><font color="#ffc000">Passed </font></center>
Title   Add nodev Option to /dev/shm
Rule    xccdf_org.ssgproject.content_rule_mount_option_dev_shm_nodev
Ident   CCE-80837-8
Result  pass

Title   Add nosuid Option to /dev/shm
Rule    xccdf_org.ssgproject.content_rule_mount_option_dev_shm_nosuid
Ident   CCE-80839-4
Result  pass

---
### Add noexec Option to /dev/shm  
**Rule:** xccdf_org.ssgproject.content_rule_mount_option_dev_shm_noexec  
**Ident:** CCE-80838-6  
**Result:** fail  
**What:** Prevents execution of binaries from `/dev/shm`.  
**Why:** Reduces risk of privilege escalation and malware execution from shared memory.
**Manual Fix:**  
Edit `/etc/fstab` and ensure the `/dev/shm` entry includes `noexec`:
```bash
tmpfs /dev/shm tmpfs defaults,nodev,nosuid,noexec 0 0
mount -o remount,nodev,nosuid,noexec /dev/shm
```
### Add nodev Option to /home  
**Rule:** xccdf_org.ssgproject.content_rule_mount_option_home_nodev  
**Ident:** CCE-81048-1  
**Result:** fail  
**What:** Prevents device files from being created on `/home`.  
**Why:** Reduces risk of device-based attacks from user directories.

**Manual Fix:**  
Edit `/etc/fstab` and ensure the `/home` entry includes `nodev`:
```bash
/dev/mapper/centos-home /home xfs defaults,nodev 0 0
mount -o remount,nodev /home
```
### Add nodev Option to /tmp  
**Rule:** xccdf_org.ssgproject.content_rule_mount_option_tmp_nodev  
**Ident:** CCE-82623-0  
**Result:** fail  
**What:** Prevents device files from being created on `/tmp`.  
**Why:** Reduces risk of device-based attacks in temporary storage.

**Manual Fix:**  
Edit `/etc/fstab` and ensure the `/tmp` entry includes `nodev`:
```bash
tmpfs /tmp tmpfs defaults,nodev,nosuid,noexec 0 0
mount -o remount,nodev /tmp
```
### Add noexec Option to /tmp  
**Rule:** xccdf_org.ssgproject.content_rule_mount_option_tmp_noexec  
**Ident:** CCE-82139-7  
**Result:** fail  
**What:** Prevents execution of binaries from `/tmp`.  
**Why:** Reduces risk of privilege escalation and malware execution from temporary storage.

**Manual Fix:**  
Edit `/etc/fstab` and ensure the `/tmp` entry includes `noexec`:
```bash
tmpfs /tmp tmpfs defaults,nodev,nosuid,noexec 0 0
mount -o remount,noexec /tmp
```
### Add nosuid Option to /tmp  
**Rule:** xccdf_org.ssgproject.content_rule_mount_option_tmp_nosuid  
**Ident:** CCE-82140-5  
**Result:** fail  
**What:** Prevents set-user-identifier or set-group-identifier bits from taking effect on `/tmp`.  
**Why:** Reduces risk of privilege escalation via SUID/SGID binaries.

**Manual Fix:**  
Edit `/etc/fstab` and ensure the `/tmp` entry includes `nosuid`:
```bash
tmpfs /tmp tmpfs defaults,nodev,nosuid,noexec 0 0
mount -o remount,nosuid /tmp
```
### Add nodev Option to /var/tmp  
**Rule:** xccdf_org.ssgproject.content_rule_mount_option_var_tmp_nodev  
**Ident:** CCE-82068-8  
**Result:** fail  
**What:** Prevents device files from being created on `/var/tmp`.  
**Why:** Reduces risk of device-based attacks in persistent temporary storage.

**Manual Fix:**  
Edit `/etc/fstab` and ensure the `/var/tmp` entry includes `nodev`:
```bash
tmpfs /var/tmp tmpfs defaults,nodev,nosuid,noexec 0 0
mount -o remount,nodev /var/tmp
```
### Add noexec Option to /var/tmp  
**Rule:** xccdf_org.ssgproject.content_rule_mount_option_var_tmp_noexec  
**Ident:** CCE-82151-2  
**Result:** fail  
**What:** Prevents execution of binaries from `/var/tmp`.  
**Why:** Reduces risk of privilege escalation and malware execution from persistent temporary storage.

**Manual Fix:**  
Edit `/etc/fstab` and ensure the `/var/tmp` entry includes `noexec`:
```bash
tmpfs /var/tmp tmpfs defaults,nodev,nosuid,noexec 0 0
mount -o remount,noexec /var/tmp
```
### Add nosuid Option to /var/tmp  
**Rule:** xccdf_org.ssgproject.content_rule_mount_option_var_tmp_nosuid  
**Ident:** CCE-82154-6  
**Result:** fail  
**What:** Prevents set-user-identifier or set-group-identifier bits from taking effect on `/var/tmp`.  
**Why:** Reduces risk of privilege escalation via SUID/SGID binaries.

**Manual Fix:**  
Edit `/etc/fstab` and ensure the `/var/tmp` entry includes `nosuid`:
```bash
tmpfs /var/tmp tmpfs defaults,nodev,nosuid,noexec 0 0
mount -o remount,nosuid /var/tmp
```
#### Combined Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/configure_mount_options.sh

LOG_FILE="/var/log/mount_options_setup.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting mount options configuration at $(date)"

# Backup fstab
cp -p /etc/fstab /etc/fstab.$(date +%Y%m%d-%H%M%S).bak

# Update /dev/shm
if grep -q '/dev/shm' /etc/fstab; then
    sed -i '/\/dev\/shm/ s/defaults.*/defaults,nodev,nosuid,noexec/' /etc/fstab
else
    echo 'tmpfs /dev/shm tmpfs defaults,nodev,nosuid,noexec 0 0' >> /etc/fstab
fi
mount -o remount,nodev,nosuid,noexec /dev/shm

# Update /home
if grep -q '/home' /etc/fstab; then
    sed -i '/\/home/ s/defaults.*/defaults,nodev/' /etc/fstab
    mount -o remount,nodev /home
fi

# Update /tmp
if grep -q '/tmp' /etc/fstab; then
    sed -i '/\/tmp/ s/defaults.*/defaults,nodev,nosuid,noexec/' /etc/fstab
    mount -o remount,nodev,nosuid,noexec /tmp
else
    echo 'tmpfs /tmp tmpfs defaults,nodev,nosuid,noexec 0 0' >> /etc/fstab
    mount -o remount,nodev,nosuid,noexec /tmp
fi

# Update /var/tmp
if grep -q '/var/tmp' /etc/fstab; then
    sed -i '/\/var\/tmp/ s/defaults.*/defaults,nodev,nosuid,noexec/' /etc/fstab
    mount -o remount,nodev,nosuid,noexec /var/tmp
else
    echo 'tmpfs /var/tmp tmpfs defaults,nodev,nosuid,noexec 0 0' >> /etc/fstab
    mount -o remount,nodev,nosuid,noexec /var/tmp
fi

echo "Mount options configuration complete. See $LOG_FILE for details"
````

**Remember:**  
- These mount options help prevent privilege escalation and malware execution.
- Always test in a non-production environment first.
- Document changes in your change management system.
---
### Disable core dump backtraces  
**Rule:** xccdf_org.ssgproject.content_rule_coredump_disable_backtraces  
**Ident:** CCE-82251-0  
**Result:** fail  
**What:** Disables inclusion of backtraces in core dumps.  
**Why:** Prevents sensitive memory information from being exposed in core dumps.

**Manual Fix:**  
Edit `/etc/systemd/coredump.conf` and set:
```bash
sudo sed -i 's/^#*Backtrace=.*/Backtrace=no/' /etc/systemd/coredump.conf
```
### Disable storing core dump  
**Rule:** xccdf_org.ssgproject.content_rule_coredump_disable_storage  
**Ident:** CCE-82252-8  
**Result:** fail  
**What:** Disables storage of core dumps on disk.  
**Why:** Prevents sensitive data from being written to disk in the event of a crash.

**Manual Fix:**  
Edit `/etc/systemd/coredump.conf` and set:
```bash
sudo sed -i 's/^#*Storage=.*/Storage=none/' /etc/systemd/coredump.conf
```
### Disable Core Dumps for All Users  
**Rule:** xccdf_org.ssgproject.content_rule_disable_users_coredumps  
**Ident:** CCE-81038-2  
**Result:** fail  
**What:** Prevents all users from generating core dumps.  
**Why:** Reduces risk of leaking sensitive information and denial-of-service via disk exhaustion.

**Manual Fix:**  
Add or edit `/etc/security/limits.conf`:
```bash
echo '* hard core 0' | sudo tee -a /etc/security/limits.conf
```
And add to `/etc/profile`:
```bash
echo 'ulimit -c 0' | sudo tee -a /etc/profile
```
### Disable Core Dumps for SUID programs  
**Rule:** xccdf_org.ssgproject.content_rule_sysctl_fs_suid_dumpable  
**Ident:** CCE-80912-9  
**Result:** fail  
**What:** Prevents SUID programs from producing core dumps.  
**Why:** Prevents privilege escalation and information leaks from privileged binaries.

**Manual Fix:**  
Set the sysctl parameter:
```bash
sudo sysctl -w fs.suid_dumpable=0
echo "fs.suid_dumpable = 0" | sudo tee -a /etc/sysctl.d/99-oscap.conf
sudo sysctl --system
```
#### Combined Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/disable_core_dumps.sh

LOG_FILE="/var/log/disable_core_dumps.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Disabling core dumps and related features at $(date)"

# 1. Disable core dump backtraces and storage
COREDUMP_CONF="/etc/systemd/coredump.conf"
cp -p "$COREDUMP_CONF" "$COREDUMP_CONF.$(date +%Y%m%d-%H%M%S).bak"
sed -i 's/^#*Backtrace=.*/Backtrace=no/' "$COREDUMP_CONF"
sed -i 's/^#*Storage=.*/Storage=none/' "$COREDUMP_CONF"

# 2. Disable core dumps for all users
if ! grep -q '^\* hard core 0' /etc/security/limits.conf; then
    echo '* hard core 0' >> /etc/security/limits.conf
fi
if ! grep -q '^ulimit -c 0' /etc/profile; then
    echo 'ulimit -c 0' >> /etc/profile
fi

# 3. Disable core dumps for SUID programs
SYSCTL_CONF="/etc/sysctl.d/99-oscap.conf"
echo "fs.suid_dumpable = 0" >> "$SYSCTL_CONF"
sysctl -w fs.suid_dumpable=0

# Reload systemd and sysctl
systemctl daemon-reload
sysctl --system

echo "Core dump configuration complete. See $LOG_FILE for details"
````

---

**Remember:**  
- These settings prevent sensitive data leaks and reduce attack surface.
- Always test in a non-production environment first.
- Document changes in your change management system.
---
### Enable Randomized Layout of Virtual Address Space  
**Rule:** xccdf_org.ssgproject.content_rule_sysctl_kernel_randomize_va_space  
**Ident:** CCE-80916-0  
**Result:** fail  

**What:**  Enables Address Space Layout Randomization (ASLR) via the `kernel.randomize_va_space` sysctl parameter. ASLR randomizes the memory addresses used by system and application processes, making it more difficult for attackers to predict the location of specific functions or buffers.

**Why:**  
- **Mitigates Exploits:** Makes buffer overflow and memory corruption attacks much harder.
- **Compliance:** Required by many security standards (CIS, STIG, PCI-DSS, etc.).
- **System Integrity:** Increases the difficulty of successful exploitation of vulnerabilities.
#### Manual Fix
```bash
sudo sysctl -w kernel.randomize_va_space=2
echo "kernel.randomize_va_space = 2" | sudo tee -a /etc/sysctl.d/99-oscap.conf
sudo sysctl --system
```
#### Combined Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/enable_aslr.sh

LOG_FILE="/var/log/enable_aslr.log"
CONF_FILE="/etc/sysctl.d/99-oscap.conf"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Enabling Address Space Layout Randomization (ASLR) at $(date)"

# Add or update the sysctl setting
if grep -q "^kernel.randomize_va_space" "$CONF_FILE" 2>/dev/null; then
    sed -i 's/^kernel.randomize_va_space.*/kernel.randomize_va_space = 2/' "$CONF_FILE"
    echo "Updated kernel.randomize_va_space to 2 in $CONF_FILE"
else
    echo "kernel.randomize_va_space = 2" >> "$CONF_FILE"
    echo "Added kernel.randomize_va_space = 2 to $CONF_FILE"
fi

# Apply the setting immediately
sysctl -w kernel.randomize_va_space=2

# Reload all sysctl settings
sysctl --system

# Verify
echo "Current value:"
sysctl kernel.randomize_va_space

echo "ASLR configuration complete. See $LOG_FILE for details"
````
**Remember:**  
- This setting should always be enabled unless you have a specific application compatibility reason not to.
- Always test in a non-production environment first.
- Document changes in your change management system.

---
<center><font color="#ffc000">Passed</font></center> 
Title   Install libselinux Package
Rule    xccdf_org.ssgproject.content_rule_package_libselinux_installed
Ident   CCE-82877-2
Result  pass

Title   Uninstall mcstrans Package
Rule    xccdf_org.ssgproject.content_rule_package_mcstrans_removed
Ident   CCE-82756-8
Result  pass

Title   Uninstall setroubleshoot Package
Rule    xccdf_org.ssgproject.content_rule_package_setroubleshoot_removed
Ident   CCE-82755-0
Result  pass

Title   Ensure SELinux Not Disabled in /etc/default/grub
Rule    xccdf_org.ssgproject.content_rule_grub2_enable_selinux
Ident   CCE-80827-9
Result  pass

Title   Ensure No Daemons are Unconfined by SELinux
Rule    xccdf_org.ssgproject.content_rule_selinux_confinement_of_daemons
Ident   CCE-80867-5
Result  pass

Title   Configure SELinux Policy
Rule    xccdf_org.ssgproject.content_rule_selinux_policytype
Ident   CCE-80868-3
Result  pass

Title   Ensure SELinux State is Enforcing
Rule    xccdf_org.ssgproject.content_rule_selinux_state
Ident   CCE-80869-1
Result  pass

Title   Disable Avahi Server Software
Rule    xccdf_org.ssgproject.content_rule_service_avahi-daemon_disabled
Ident   CCE-82188-4
Result  fail

Title   Enable cron Service
Rule    xccdf_org.ssgproject.content_rule_service_crond_enabled
Ident   CCE-80875-8
Result  pass

Title   Verify Group Who Owns cron.d
Rule    xccdf_org.ssgproject.content_rule_file_groupowner_cron_d
Ident   CCE-82268-4
Result  pass

Title   Verify Group Who Owns cron.daily
Rule    xccdf_org.ssgproject.content_rule_file_groupowner_cron_daily
Ident   CCE-82234-6
Result  pass

Title   Verify Group Who Owns cron.hourly
Rule    xccdf_org.ssgproject.content_rule_file_groupowner_cron_hourly
Ident   CCE-82227-0
Result  pass

Title   Verify Group Who Owns cron.monthly
Rule    xccdf_org.ssgproject.content_rule_file_groupowner_cron_monthly
Ident   CCE-82256-9
Result  pass

Title   Verify Group Who Owns cron.weekly
Rule    xccdf_org.ssgproject.content_rule_file_groupowner_cron_weekly
Ident   CCE-82244-5
Result  pass

Title   Verify Group Who Owns Crontab
Rule    xccdf_org.ssgproject.content_rule_file_groupowner_crontab
Ident   CCE-82223-9
Result  pass

Title   Verify Owner on cron.d
Rule    xccdf_org.ssgproject.content_rule_file_owner_cron_d
Ident   CCE-82272-6
Result  pass

Title   Verify Owner on cron.daily
Rule    xccdf_org.ssgproject.content_rule_file_owner_cron_daily
Ident   CCE-82237-9
Result  pass

Title   Verify Owner on cron.hourly
Rule    xccdf_org.ssgproject.content_rule_file_owner_cron_hourly
Ident   CCE-82209-8
Result  pass

Title   Verify Owner on cron.monthly
Rule    xccdf_org.ssgproject.content_rule_file_owner_cron_monthly
Ident   CCE-82260-1
Result  pass

Title   Verify Owner on cron.weekly
Rule    xccdf_org.ssgproject.content_rule_file_owner_cron_weekly
Ident   CCE-82247-8
Result  pass

Title   Verify Owner on crontab
Rule    xccdf_org.ssgproject.content_rule_file_owner_crontab
Ident   CCE-82224-7
Result  pass

---
### Verify Permissions on cron.d  
**Rule:** xccdf_org.ssgproject.content_rule_file_permissions_cron_d  
**Ident:** CCE-82277-5  
**Result:** fail  
**What:** Ensures `/etc/cron.d` has secure permissions.  
**Why:** Prevents unauthorized users from modifying scheduled tasks.

**Manual Fix:**  
```bash
sudo chmod 700 /etc/cron.d
sudo chown root:root /etc/cron.d
```
### Verify Permissions on cron.daily  
**Rule:** xccdf_org.ssgproject.content_rule_file_permissions_cron_daily  
**Ident:** CCE-82240-3  
**Result:** fail  
**What:** Ensures `/etc/cron.daily` has secure permissions.  
**Why:** Prevents unauthorized modification of daily cron jobs.

**Manual Fix:**  
```bash
sudo chmod 700 /etc/cron.daily
sudo chown root:root /etc/cron.daily
```
### Verify Permissions on cron.hourly  
**Rule:** xccdf_org.ssgproject.content_rule_file_permissions_cron_hourly  
**Ident:** CCE-82230-4  
**Result:** fail  
**What:** Ensures `/etc/cron.hourly` has secure permissions.  
**Why:** Prevents unauthorized modification of hourly cron jobs.

**Manual Fix:**  
```bash
sudo chmod 700 /etc/cron.hourly
sudo chown root:root /etc/cron.hourly
```
### Verify Permissions on cron.monthly  
**Rule:** xccdf_org.ssgproject.content_rule_file_permissions_cron_monthly  
**Ident:** CCE-82263-5  
**Result:** fail  
**What:** Ensures `/etc/cron.monthly` has secure permissions.  
**Why:** Prevents unauthorized modification of monthly cron jobs.

**Manual Fix:**  
```bash
sudo chmod 700 /etc/cron.monthly
sudo chown root:root /etc/cron.monthly
```
### Verify Permissions on cron.weekly  
**Rule:** xccdf_org.ssgproject.content_rule_file_permissions_cron_weekly  
**Ident:** CCE-82253-6  
**Result:** fail  
**What:** Ensures `/etc/cron.weekly` has secure permissions.  
**Why:** Prevents unauthorized modification of weekly cron jobs.

**Manual Fix:**  
```bash
sudo chmod 700 /etc/cron.weekly
sudo chown root:root /etc/cron.weekly
```
### Verify Permissions on crontab  
**Rule:** xccdf_org.ssgproject.content_rule_file_permissions_crontab  
**Ident:** CCE-82206-4  
**Result:** fail  
**What:** Ensures `/etc/crontab` has secure permissions.  
**Why:** Prevents unauthorized modification of the system crontab.

**Manual Fix:**  
```bash
sudo chmod 600 /etc/crontab
sudo chown root:root /etc/crontab
```
#### Combined Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/fix_cron_permissions.sh

LOG_FILE="/var/log/fix_cron_permissions.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Fixing cron directory and file permissions at $(date)"

declare -A cron_dirs=(
    ["/etc/cron.d"]=700
    ["/etc/cron.daily"]=700
    ["/etc/cron.hourly"]=700
    ["/etc/cron.monthly"]=700
    ["/etc/cron.weekly"]=700
)

for dir in "${!cron_dirs[@]}"; do
    if [ -d "$dir" ]; then
        chmod "${cron_dirs[$dir]}" "$dir"
        chown root:root "$dir"
        echo "Set $dir to ${cron_dirs[$dir]} and root:root"
    else
        echo "WARNING: $dir does not exist"
    fi
done

if [ -f "/etc/crontab" ]; then
    chmod 600 /etc/crontab
    chown root:root /etc/crontab
    echo "Set /etc/crontab to 600 and root:root"
else
    echo "WARNING: /etc/crontab does not exist"
fi

echo "Cron permissions configuration complete. See $LOG_FILE for details"
````

---

**Remember:**  
- These permissions prevent unauthorized users from modifying scheduled tasks.
- Always test in a non-production environment first.
- Document changes in your change management system.

---
<center><font color="#ffc000">Passed</font></center>
Title   Disable DHCP Service
Rule    xccdf_org.ssgproject.content_rule_service_dhcpd_disabled
Ident   CCE-82864-0
Result  pass

Title   Disable named Service
Rule    xccdf_org.ssgproject.content_rule_service_named_disabled
Ident   CCE-82409-4
Result  pass

Title   Disable vsftpd Service
Rule    xccdf_org.ssgproject.content_rule_service_vsftpd_disabled
Ident   CCE-82413-6
Result  pass

Title   Disable httpd Service
Rule    xccdf_org.ssgproject.content_rule_service_httpd_disabled
Ident   CCE-82761-8
Result  pass

Title   Disable Dovecot Service
Rule    xccdf_org.ssgproject.content_rule_service_dovecot_disabled
Ident   CCE-82760-0
Result  pass

Title   Ensure LDAP client is not installed
Rule    xccdf_org.ssgproject.content_rule_package_openldap-clients_removed
Ident   CCE-82885-5
Result  pass

Title   Disable Postfix Network Listening
Rule    xccdf_org.ssgproject.content_rule_postfix_network_listening_disabled
Ident   CCE-82174-4
Result  pass

---
### Disable rpcbind Service  
**Rule:** xccdf_org.ssgproject.content_rule_service_rpcbind_disabled  
**Ident:** CCE-82858-2  
**Result:** fail  

**What:**  
Disables the `rpcbind` service, which is used for mapping RPC program numbers to network addresses. It is required for NFS and some legacy services, but is a common attack vector and should be disabled if not needed.

**Why:**  
- **Reduces Attack Surface:** rpcbind is often targeted for remote exploits.
- **Compliance:** Required by many security standards (CIS, STIG, PCI-DSS, etc.).
- **System Integrity:** Prevents unauthorized remote procedure calls.
- **Best Practice:** Only enable if absolutely required for your environment.
#### Manual Fix
```bash
sudo systemctl stop rpcbind
sudo systemctl disable rpcbind
sudo systemctl mask rpcbind
sudo systemctl stop rpcbind.socket
sudo systemctl disable rpcbind.socket
sudo systemctl mask rpcbind.socket
```
#### Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/disable_rpcbind.sh

LOG_FILE="/var/log/disable_rpcbind.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Disabling rpcbind service at $(date)"

for svc in rpcbind rpcbind.socket; do
    if systemctl is-enabled --quiet $svc 2>/dev/null; then
        systemctl stop $svc
        systemctl disable $svc
        systemctl mask $svc
        echo "$svc stopped, disabled, and masked"
    else
        echo "$svc is already disabled or not present"
    fi
done

echo "Verifying rpcbind status:"
systemctl status rpcbind || echo "rpcbind service not found"
systemctl status rpcbind.socket || echo "rpcbind.socket not found"

echo "rpcbind service disablement complete. See $LOG_FILE for details"
````
**Remember:**  
- Only disable rpcbind if not required by your environment (e.g., for NFS or legacy RPC services).
- Always test in a non-production environment first.
- Document changes in your change management system.
---
### Disable Network File System (nfs)  
**Rule:** xccdf_org.ssgproject.content_rule_service_nfs_disabled  
**Ident:** CCE-82762-6  
**Result:** fail  

**What:**  
Disables the NFS (Network File System) service, which allows remote file sharing over the network. NFS is a common attack vector and should be disabled if not required.

**Why:**  
- **Reduces Attack Surface:** NFS can be exploited for unauthorized file access or privilege escalation.
- **Compliance:** Required by many security standards (CIS, STIG, PCI-DSS, etc.).
- **System Integrity:** Prevents unauthorized remote file sharing.
- **Best Practice:** Only enable if absolutely required for your environment.
#### Manual Fix
```bash
sudo systemctl stop nfs-server
sudo systemctl disable nfs-server
sudo systemctl mask nfs-server
sudo systemctl stop nfs
sudo systemctl disable nfs
sudo systemctl mask nfs
```
#### Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/disable_nfs.sh

LOG_FILE="/var/log/disable_nfs.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Disabling NFS service at $(date)"

for svc in nfs-server nfs; do
    if systemctl list-unit-files | grep -q "^$svc"; then
        systemctl stop $svc 2>/dev/null
        systemctl disable $svc 2>/dev/null
        systemctl mask $svc 2>/dev/null
        echo "$svc stopped, disabled, and masked"
    else
        echo "$svc is not installed or already disabled"
    fi
done

echo "Verifying NFS status:"
systemctl status nfs-server || echo "nfs-server service not found"
systemctl status nfs || echo "nfs service not found"

echo "NFS service disablement complete. See $LOG_FILE for details"
````
**Remember:**  
- Only disable NFS if not required by your environment.
- Always test in a non-production environment first.
- Document changes in your change management system.
---
### Ensure that chronyd is running under chrony user account  
**Rule:** xccdf_org.ssgproject.content_rule_chronyd_run_as_chrony_user  
**Ident:** CCE-82879-8  
**Result:** fail  

**What:**  
Ensures the `chronyd` service runs as the unprivileged `chrony` user and group, rather than as root. This limits the impact of any vulnerabilities in the time synchronization daemon.

**Why:**  
- **Reduces Privilege:** Minimizes risk if the service is compromised.
- **Compliance:** Required by many security standards.
- **System Integrity:** Limits potential damage from exploits.
#### Manual Fix
1. Edit the systemd unit file override for chronyd:
   ```bash
   sudo mkdir -p /etc/systemd/system/chronyd.service.d
   sudo tee /etc/systemd/system/chronyd.service.d/10-chrony-user.conf <<EOF
[Service]
User=chrony
Group=chrony
EOF
   ```
2. Reload systemd and restart chronyd:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl restart chronyd
   ```
3. Verify chronyd is running as the chrony user:
   ```bash
   ps -eo user,group,comm | grep chronyd
   ```
#### Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/chronyd_run_as_chrony.sh

LOG_FILE="/var/log/chronyd_user_setup.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Configuring chronyd to run as chrony user at $(date)"

# Create systemd override directory and file
mkdir -p /etc/systemd/system/chronyd.service.d
cat > /etc/systemd/system/chronyd.service.d/10-chrony-user.conf <<EOF
[Service]
User=chrony
Group=chrony
EOF

# Reload systemd and restart chronyd
systemctl daemon-reload
systemctl restart chronyd

# Verify
echo "Current chronyd process:"
ps -eo user,group,comm | grep chronyd

echo "chronyd user configuration complete. See $LOG_FILE for details"
````
**Remember:**  
- Always test in a non-production environment first.  
- Document changes in your change management system.  
- This change helps reduce the risk of privilege escalation via the time synchronization service.

---
<center><font color="#ffc000">Passed</font></center>
Title   A remote time server for Chrony is configured
Rule    xccdf_org.ssgproject.content_rule_chronyd_specify_remote_server
Ident   CCE-82873-1
Result  pass

Title   Ensure rsyncd service is diabled
Rule    xccdf_org.ssgproject.content_rule_service_rsyncd_disabled
Ident   CCE-83335-0
Result  pass

Title   Uninstall xinetd Package
Rule    xccdf_org.ssgproject.content_rule_package_xinetd_removed
Ident   CCE-80850-1
Result  pass

Title   Remove NIS Client
Rule    xccdf_org.ssgproject.content_rule_package_ypbind_removed
Ident   CCE-82181-9
Result  pass

Title   Remove Rsh Trust Files
Rule    xccdf_org.ssgproject.content_rule_no_rsh_trust_files
Ident   CCE-80842-8
Result  pass

Title   Remove telnet Clients
Rule    xccdf_org.ssgproject.content_rule_package_telnet_removed
Ident   CCE-80849-3
Result  pass

Title   Disable Squid
Rule    xccdf_org.ssgproject.content_rule_service_squid_disabled
Ident   CCE-82190-0
Result  pass

Title   Disable Samba
Rule    xccdf_org.ssgproject.content_rule_service_smb_disabled
Ident   CCE-82759-2
Result  pass

Title   Disable snmpd Service
Rule    xccdf_org.ssgproject.content_rule_service_snmpd_disabled
Ident   CCE-82758-4
Result  pass

Title   Verify Group Who Owns SSH Server config file
Rule    xccdf_org.ssgproject.content_rule_file_groupowner_sshd_config
Ident   CCE-82901-0
Result  pass

Title   Verify Owner on SSH Server config file
Rule    xccdf_org.ssgproject.content_rule_file_owner_sshd_config
Ident   CCE-82898-8
Result  pass

Title   Verify Permissions on SSH Server config file
Rule    xccdf_org.ssgproject.content_rule_file_permissions_sshd_config
Ident   CCE-82894-7
Result  pass

Title   Verify Permissions on SSH Server Public *.pub Key Files
Rule    xccdf_org.ssgproject.content_rule_file_permissions_sshd_pub_key
Ident   CCE-82428-4
Result  pass

Title   Disable Host-Based Authentication
Rule    xccdf_org.ssgproject.content_rule_disable_host_auth
Ident   CCE-80786-7
Result  pass

Title   Disable SSH Access via Empty Passwords
Rule    xccdf_org.ssgproject.content_rule_sshd_disable_empty_passwords
Ident   CCE-80896-4
Result  pass

Title   Disable SSH Support for .rhosts Files
Rule    xccdf_org.ssgproject.content_rule_sshd_disable_rhosts
Ident   CCE-80899-8
Result  pass

Title   Do Not Allow SSH Environment Options
Rule    xccdf_org.ssgproject.content_rule_sshd_do_not_permit_user_env
Ident   CCE-80903-8
Result  pass

Title   Set SSH Daemon LogLevel to VERBOSE
Rule    xccdf_org.ssgproject.content_rule_sshd_set_loglevel_verbose
Ident   CCE-82420-1
Result  pass

---
### Disable the CUPS Service  
**Rule:** xccdf_org.ssgproject.content_rule_service_cups_disabled  
**Ident:** CCE-82861-6  
**Result:** fail  
**What:** Disables the CUPS printing service, which is not needed on most servers and can be a security risk.  
**Manual Fix:**  
```bash
sudo systemctl stop cups
sudo systemctl disable cups
sudo systemctl mask cups
```
### Disable SSH Root Login  
**Rule:** xccdf_org.ssgproject.content_rule_sshd_disable_root_login  
**Ident:** CCE-80901-2  
**Result:** fail  
**What:** Prevents direct SSH login as root, reducing risk of brute-force and credential attacks.  
**Manual Fix:**  
Edit `/etc/ssh/sshd_config` and set:
```
PermitRootLogin no
```
Then reload SSH:
```bash
sudo systemctl reload sshd
```
### Disable SSH TCP Forwarding  
**Rule:** xccdf_org.ssgproject.content_rule_sshd_disable_tcp_forwarding  
**Ident:** CCE-83301-2  
**Result:** fail  
**What:** Disables SSH TCP forwarding to prevent tunneling and data exfiltration.  
**Manual Fix:**  
Edit `/etc/ssh/sshd_config` and set:
```
AllowTcpForwarding no
```
Then reload SSH:
```bash
sudo systemctl reload sshd
```
### Disable X11 Forwarding  
**Rule:** xccdf_org.ssgproject.content_rule_sshd_disable_x11_forwarding  
**Ident:** CCE-83360-8  
**Result:** fail  
**What:** Disables X11 forwarding to prevent GUI-based attacks over SSH.  
**Manual Fix:**  
Edit `/etc/ssh/sshd_config` and set:
```
X11Forwarding no
```
Then reload SSH:
```bash
sudo systemctl reload sshd
```
### Set SSH Idle Timeout Interval  
**Rule:** xccdf_org.ssgproject.content_rule_sshd_set_idle_timeout  
**Ident:** CCE-80906-1  
**Result:** fail  
**What:** Disconnects idle SSH sessions after a period of inactivity.  
**Manual Fix:**  
Edit `/etc/ssh/sshd_config` and set:
```
ClientAliveInterval 300
```
Then reload SSH:
```bash
sudo systemctl reload sshd
```
### Set SSH Client Alive Count Max  
**Rule:** xccdf_org.ssgproject.content_rule_sshd_set_keepalive  
**Ident:** CCE-80907-9  
**Result:** fail  
**What:** Limits the number of keepalive messages before disconnecting an idle session.  
**Manual Fix:**  
Edit `/etc/ssh/sshd_config` and set:
```
ClientAliveCountMax 0
```
Then reload SSH:
```bash
sudo systemctl reload sshd
```
### Set SSH authentication attempt limit  
**Rule:** xccdf_org.ssgproject.content_rule_sshd_set_max_auth_tries  
**Ident:** CCE-83500-9  
**Result:** fail  
**What:** Limits the number of authentication attempts per SSH connection.  
**Manual Fix:**  
Edit `/etc/ssh/sshd_config` and set:
```
MaxAuthTries 4
```
Then reload SSH:
```bash
sudo systemctl reload sshd
```
### Set SSH MaxSessions limit  
**Rule:** xccdf_org.ssgproject.content_rule_sshd_set_max_sessions  
**Ident:** CCE-83357-4  
**Result:** fail  
**What:** Limits the number of concurrent SSH sessions per connection.  
**Manual Fix:**  
Edit `/etc/ssh/sshd_config` and set:
```
MaxSessions 10
```
Then reload SSH:
```bash
sudo systemctl reload sshd
```
### Ensure SSH MaxStartups is configured  
**Rule:** xccdf_org.ssgproject.content_rule_sshd_set_maxstartups  
**Ident:** CCE-90718-8  
**Result:** fail  
**What:** Limits unauthenticated SSH connections to prevent DoS attacks.  
**Manual Fix:**  
Edit `/etc/ssh/sshd_config` and set:
```
MaxStartups 10:30:100
```
Then reload SSH:
```bash
sudo systemctl reload sshd
```
### Disable graphical user interface  
**Rule:** xccdf_org.ssgproject.content_rule_xwindows_remove_packages  
**Ident:** CCE-83411-9  
**Result:** fail  
**What:** Removes X Windows packages to reduce attack surface on servers.  
**Manual Fix:**  
```bash
sudo dnf groupremove "X Window System" -y
sudo systemctl set-default multi-user.target
```
#### Combined Automation Script
````bash
#!/bin/bash
# filepath: /root/scripts/harden_ssh_and_services.sh

LOG_FILE="/var/log/harden_ssh_and_services.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting SSH and service hardening at $(date)"

# Disable CUPS
systemctl stop cups 2>/dev/null
systemctl disable cups 2>/dev/nullCombination Automation of All
```sh
#!/bin/bash
# filepath: /root/scripts/system_hardening_and_audit.sh
#
# This comprehensive script combines various hardening and audit configurations
# for a Linux system. It aims for idempotence by checking if rules/settings
# already exist before applying them.
#
# Remember:
# - Always test in a non-production environment first.
# - Have backups of critical configuration files.
# - A system restart is REQUIRED after some changes (e.g., GRUB, FIPS).

LOG_FILE="/var/log/system_hardening_automation.log"

# Redirect all script output (stdout and stderr) to both the console and the log file.
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "--- Starting Comprehensive System Hardening and Audit Configuration ---"
echo "Timestamp: $(date)"
echo ""

# Function to check for package existence (e.g., dnf)
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# --- Section 1: AIDE Configuration ---
echo "--- Section 1: AIDE Configuration ---"

# Install AIDE if not present
if ! rpm -q aide &>/dev/null; then
    echo "AIDE not found. Installing AIDE..."
    sudo dnf install -y aide
else
    echo "AIDE is already installed."
fi

# Backup original AIDE config if exists
if [ -f "/etc/aide.conf" ]; then
    echo "Backing up existing /etc/aide.conf to /etc/aide.conf.bak"
    sudo cp /etc/aide.conf /etc/aide.conf.bak
else
    echo "No existing /etc/aide.conf found to backup."
fi

# Create enhanced AIDE configuration (Always recreate to ensure desired state)
echo "Creating/updating AIDE configuration file /etc/aide.conf..."
sudo tee /etc/aide.conf <<EOF
# AIDE configuration
database=file:/var/lib/aide/aide.db.gz
database_out=file:/var/lib/aide/aide.db.new.gz
gzip_dbout=yes

# Mail configuration - IMPORTANT: Replace root@localhost with a real admin email
report_url=mailto:root@localhost

# Monitoring rules (Examples, adjust as per policy)
/etc PERMS+FTYPE+P+U+G+I+ANF+SHA512
/bin PERMS+FTYPE+P+U+G+I+ANF+SHA512
/sbin PERMS+FTYPE+P+U+G+I+ANF+SHA512
/usr PERMS+FTYPE+P+U+G+I+ANF+SHA512
/var PERMS+FTYPE+P+U+G+I+ANF+SHA512
!/var/log/.* # Exclude logs
!/var/spool/.* # Exclude spools
!/var/tmp/.* # Exclude temporary files (often volatile)

# Custom rules
@@define CONTENT SHA512+FTYPE
@@define SYSTEM PERMS+FTYPE+P+U+G
EOF
echo "AIDE configuration created/updated."

# Initialize AIDE database
# Check if the database already exists and is non-empty before initializing
if [ ! -f "/var/lib/aide/aide.db.gz" ] || [ "$(sudo du -b /var/lib/aide/aide.db.gz 2>/dev/null | awk '{print $1}')" -eq 0 ]; then
    echo "Initializing AIDE database (this may take some time)..."
    sudo aide --init
    if [ -f "/var/lib/aide/aide.db.new.gz" ]; then
        sudo mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
        echo "AIDE database initialized and moved to /var/lib/aide/aide.db.gz."
    else
        echo "Error: aide --init did not create /var/lib/aide/aide.db.new.gz. Check previous output."
    fi
else
    echo "AIDE database /var/lib/aide/aide.db.gz already exists and is not empty. Skipping initialization."
    echo "If you want to re-initialize, manually remove /var/lib/aide/aide.db.gz first."
fi

# Create backup copy on separate media (if available)
if [ -d "/mnt/backup" ]; then
    echo "Backing up AIDE database to /mnt/backup/."
    sudo cp /var/lib/aide/aide.db.gz /mnt/backup/aide.db.gz.$(date +%Y%m%d-%H%M%S)
else
    echo "Backup directory /mnt/backup not found. Skipping AIDE database backup to external media."
fi

# Setup AIDE daily check service and timer
echo "Setting up AIDE daily check service and timer..."
# Create /var/log/aide directory if it doesn't exist
sudo mkdir -p /var/log/aide
sudo chown root:root /var/log/aide
sudo chmod 700 /var/log/aide

# Create aide_check.sh script
sudo tee /root/scripts/aide_check.sh <<'EOF_AIDE_CHECK'
#!/bin/bash
ADMIN_EMAIL="root@localhost" # <<< IMPORTANT: Change this to a real admin email

# Ensure log directory exists
mkdir -p /var/log/aide

# Run AIDE check
/usr/sbin/aide --check > /var/log/aide/aide_check.log 2>&1
CHECK_STATUS=$?

# Send notification if changes detected
if [ $CHECK_STATUS -ne 0 ]; then
    echo "AIDE: System Changes Detected (Exit Code: $CHECK_STATUS). Sending email to $ADMIN_EMAIL"
    mail -s "AIDE: System Changes Detected" "$ADMIN_EMAIL" < /var/log/aide/aide_check.log
else
    echo "AIDE: No system changes detected." >> /var/log/aide/aide_check.log
fi

# Rotate logs (simplified, full logrotate config might be better but this covers basic rotation)
if [ -f "/var/log/aide/aide_check.log" ]; then
    mv /var/log/aide/aide_check.log /var/log/aide/aide_check.log.1
    gzip /var/log/aide/aide_check.log.1
fi
EOF_AIDE_CHECK
sudo chmod +x /root/scripts/aide_check.sh
echo "Created /root/scripts/aide_check.sh"

# Create AIDE systemd service file
sudo tee /etc/systemd/system/aide-check.service <<EOF_AIDE_SERVICE
[Unit]
Description=AIDE check service
After=network.target

[Service]
Type=oneshot
ExecStart=/root/scripts/aide_check.sh
Nice=19
IOSchedulingClass=idle
EOF_AIDE_SERVICE
echo "Created /etc/systemd/system/aide-check.service"

# Create AIDE systemd timer file
sudo tee /etc/systemd/system/aide-check.timer <<EOF_AIDE_TIMER
[Unit]
Description=Daily AIDE check

[Timer]
OnCalendar=*-*-* 05:00:00
RandomizedDelaySec=1800
Persistent=true

[Install]
WantedBy=timers.target
EOF_AIDE_TIMER
echo "Created /etc/systemd/system/aide-check.timer"

# Enable and start the AIDE timer
sudo systemctl daemon-reload
sudo systemctl enable aide-check.timer
sudo systemctl start aide-check.timer
echo "AIDE daily check timer enabled and started."

# Setup AIDE update script
echo "Setting up AIDE database update script..."
sudo tee /root/scripts/aide_update.sh <<'EOF_AIDE_UPDATE'
#!/bin/bash
LOG_FILE="/var/log/aide/updates.log"
# Append output to the log file
exec 1>> "$LOG_FILE" 2>&1

echo "AIDE database update initiated $(date)"

# Backup current database
cp /var/lib/aide/aide.db.gz /var/lib/aide/aide.db.gz.backup.$(date +%Y%m%d-%H%M%S)

# Update database
/usr/sbin/aide --update

# If successful, replace old database
if [ $? -eq 0 ]; then
    if [ -f "/var/lib/aide/aide.db.new.gz" ]; then
        mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
        echo "Database updated successfully."
        # Backup to separate media if available
        if [ -d "/mnt/backup" ]; then
            cp /var/lib/aide/aide.db.gz /mnt/backup/aide.db.gz.$(date +%Y%m%d)
            echo "Updated database backed up to /mnt/backup."
        fi
    else
        echo "Update command succeeded but new database file not found. Check AIDE output."
    fi
else
    echo "AIDE update failed. Review logs."
fi
EOF_AIDE_UPDATE
sudo chmod +x /root/scripts/aide_update.sh
echo "Created /root/scripts/aide_update.sh."
echo ""

# --- Section 2: Cryptographic Policy (FIPS Mode) Configuration ---
echo "--- Section 2: Cryptographic Policy (FIPS Mode) Configuration ---"

check_fips_mode() {
    if command_exists fips-mode-setup && sudo fips-mode-setup --check | grep -q "enabled"; then
        return 0
    else
        return 1
    fi
}

configure_fips() {
    echo "Attempting to configure FIPS mode..."
    sudo cp /etc/crypto-policies/config /etc/crypto-policies/config.backup.$(date +%Y%m%d-%H%M%S)
    if sudo fips-mode-setup --enable; then
        echo "FIPS mode successfully enabled (requires reboot to fully activate)."
        return 0
    else
        echo "Failed to enable FIPS mode."
        return 1
    fi
}

if check_fips_mode; then
    echo "FIPS mode is already enabled."
else
    echo "FIPS mode is not enabled. Attempting to enable..."
    if configure_fips; then
        echo "Updating running system crypto policy to FIPS..."
        sudo update-crypto-policies --set FIPS
        echo "Services that support applying new crypto policies will be restarted (sshd, httpd, nginx, postgresql)."
        for service in sshd httpd nginx postgresql; do
            if command_exists systemctl && sudo systemctl is-active --quiet "$service"; then
                echo "Restarting $service..."
                sudo systemctl restart "$service" || echo "Warning: Failed to restart $service."
            fi
        done
        echo "FIPS configuration will be fully effective after a system reboot."
    else
        echo "FIPS mode configuration failed. Please investigate."
    fi
fi
echo "Current crypto policy: $(sudo update-crypto-policies --show 2>/dev/null || echo 'N/A')"
echo "FIPS status: $(command_exists fips-mode-setup && sudo fips-mode-setup --check 2>/dev/null || echo 'N/A')"
echo ""

# --- Section 3: Sudo Configuration (PTY and Logging) ---
echo "--- Section 3: Sudo Configuration (PTY and Logging) ---"
SUDOERS_D_PATH="/etc/sudoers.d"
SUDOERS_BACKUP="/etc/sudoers.$(date +%Y%m%d-%H%M%S).bak"

# Backup sudoers file
if [ -f "/etc/sudoers" ]; then
    echo "Backing up /etc/sudoers to $SUDOERS_BACKUP"
    sudo cp -p /etc/sudoers "$SUDOERS_BACKUP"
else
    echo "Warning: /etc/sudoers not found. Skipping backup."
fi

# Ensure /etc/sudoers.d exists
sudo mkdir -p "$SUDOERS_D_PATH"
sudo chmod 755 "$SUDOERS_D_PATH"
sudo chown root:root "$SUDOERS_D_PATH"

# Configure sudo PTY
echo "Configuring sudo PTY requirement..."
PTY_RULE_FILE="${SUDOERS_D_PATH}/pty_requirement"
if ! sudo grep -q "^Defaults.*use_pty" "$SUDOERS_D_PATH"/* 2>/dev/null; then
    echo "Defaults use_pty" | sudo tee "$PTY_RULE_FILE" >/dev/null
    sudo chmod 440 "$PTY_RULE_FILE"
    sudo chown root:root "$PTY_RULE_FILE"
    echo "Added use_pty requirement to $PTY_RULE_FILE."
else
    echo "use_pty requirement already configured."
fi

# Configure sudo logging
echo "Configuring sudo logging..."
LOGGING_RULE_FILE="${SUDOERS_D_PATH}/logging"
SUDO_LOG="/var/log/sudo.log"

if ! sudo grep -q "^Defaults.*logfile=" "$SUDOERS_D_PATH"/* 2>/dev/null && \
   ! sudo grep -q "^Defaults.*logfile=" /etc/sudoers 2>/dev/null; then
    echo "Defaults logfile=\"$SUDO_LOG\"" | sudo tee "$LOGGING_RULE_FILE" >/dev/null
    sudo chmod 440 "$LOGGING_RULE_FILE"
    sudo chown root:root "$LOGGING_RULE_FILE"
    echo "Added logfile configuration to $LOGGING_RULE_FILE."

    # Create log file with proper permissions if it doesn't exist
    if [ ! -f "$SUDO_LOG" ]; then
        sudo touch "$SUDO_LOG"
        sudo chmod 640 "$SUDO_LOG"
        sudo chown root:root "$SUDO_LOG"
        echo "Created sudo log file $SUDO_LOG with proper permissions."
    else
        echo "Sudo log file $SUDO_LOG already exists."
    fi
else
    echo "Sudo logfile already configured."
fi

# Set up log rotation for sudo.log
echo "Setting up log rotation for sudo.log..."
SUDO_LOGROTATE_CONF="/etc/logrotate.d/sudo"
if [ ! -f "$SUDO_LOGROTATE_CONF" ] || ! sudo grep -q "$SUDO_LOG" "$SUDO_LOGROTATE_CONF"; then
    sudo tee "$SUDO_LOGROTATE_CONF" <<EOF_LOGROTATE
$SUDO_LOG {
    weekly
    rotate 13
    compress
    delaycompress
    missingok
    notifempty
    create 640 root root
}
EOF_LOGROTATE
    echo "Sudo logrotate configuration created/updated in $SUDO_LOGROTATE_CONF."
else
    echo "Sudo logrotate configuration for $SUDO_LOG already exists."
fi


# Verify the sudoers configuration syntax
echo "Verifying sudoers configuration syntax..."
if sudo visudo -c; then
    echo "Sudo configuration syntax is valid."
else
    echo "Error: Sudo configuration syntax check failed. Please manually review /etc/sudoers.d/ files!"
fi
echo ""

# --- Section 4: System Banners Configuration ---
echo "--- Section 4: System Banners Configuration ---"
ISSUE_FILE="/etc/issue"
MOTD_FILE="/etc/motd"

echo "Configuring login and MOTD banners..."
# Backup existing files
sudo cp -p "$ISSUE_FILE" "${ISSUE_FILE}.$(date +%Y%m%d-%H%M%S).bak"
sudo cp -p "$MOTD_FILE" "${MOTD_FILE}.$(date +%Y%m%d-%H%M%S).bak"

# Create login banner (/etc/issue) - Always recreate to ensure desired content
sudo tee "$ISSUE_FILE" <<EOF_ISSUE
AUTHORIZED ACCESS ONLY

This system is for the use of authorized users only. Individuals using this
computer system without authority, or in excess of their authority, are
subject to having all of their activities on this system monitored and
recorded by system personnel.

In the course of monitoring individuals improperly using this system, or in
the course of system maintenance, the activities of authorized users may also
be monitored.

Anyone using this system expressly consents to such monitoring and is advised
that if such monitoring reveals possible evidence of criminal activity, system
personnel may provide the evidence of such monitoring to law enforcement officials.
EOF_ISSUE
echo "Login banner ($ISSUE_FILE) created/updated."

# Create MOTD (/etc/motd) - Always recreate to ensure desired content
sudo tee "$MOTD_FILE" <<EOF_MOTD
WARNING: Unauthorized access to this system is forbidden and will be
prosecuted by law. By accessing this system, you agree that your actions
may be monitored if unauthorized usage is suspected.
EOF_MOTD
echo "MOTD banner ($MOTD_FILE) created/updated."

# Set proper permissions for banners
echo "Setting permissions for banner files..."
sudo chmod 644 "$ISSUE_FILE" "$MOTD_FILE"
sudo chown root:root "$ISSUE_FILE" "$MOTD_FILE"
echo "Banner file permissions set."
echo ""

# --- Section 5: GNOME Banner Configuration (if applicable) ---
echo "--- Section 5: GNOME Banner Configuration ---"
GNOME_BANNER_DIR="/etc/dconf/db/local.d"
GNOME_PROFILE_DIR="/etc/dconf/profile"
GNOME_BANNER_FILE="${GNOME_BANNER_DIR}/01-banner-message"
GNOME_PROFILE_FILE="${GNOME_PROFILE_DIR}/user"

if command_exists dconf; then
    echo "GNOME dconf detected. Configuring GNOME login banner..."
    # Create required directories
    sudo mkdir -p "$GNOME_BANNER_DIR"
    sudo mkdir -p "$GNOME_PROFILE_DIR"

    # Create dconf profile (Always recreate to ensure desired content)
    sudo tee "$GNOME_PROFILE_FILE" <<EOF_PROFILE
user-db:user
system-db:local
EOF_PROFILE
    echo "dconf profile ($GNOME_PROFILE_FILE) created/updated."

    # Create banner configuration (Always recreate to ensure desired content)
    sudo tee "$GNOME_BANNER_FILE" <<'EOF_GNOME_BANNER'
[org/gnome/login-screen]
banner-message-enable=true
banner-message-text='AUTHORIZED ACCESS ONLY

This system is restricted to authorized users for legitimate business purposes only.
Unauthorized access is prohibited and will be prosecuted to the full extent of the law.

By accessing this system, you agree that:
- Your actions may be monitored and recorded
- Unauthorized use will be reported to law enforcement
- You will comply with all applicable security policies'
EOF_GNOME_BANNER
    echo "GNOME banner configuration ($GNOME_BANNER_FILE) created/updated."

    # Update dconf database
    echo "Updating dconf database..."
    sudo dconf update
    echo "GNOME banner configuration complete."
else
    echo "dconf command not found. Skipping GNOME banner configuration (GUI likely not installed)."
fi
echo ""

# --- Section 6: Password Policy Configuration ---
echo "--- Section 6: Password Policy Configuration ---"
PAM_FILES=("/etc/pam.d/password-auth" "/etc/pam.d/system-auth")

echo "Configuring password policies (pam_pwhistory.so and pam_pwquality.so)..."
for file in "${PAM_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "Processing $file..."
        sudo cp -p "$file" "${file}.$(date +%Y%m%d-%H%M%S).bak" # Backup
        
        # Remove existing related lines to prevent duplicates or conflicts
        sudo sed -i '/^password.*pam_pwhistory.so/d' "$file"
        sudo sed -i '/^password.*pam_pwquality.so/d' "$file"
        
        # Add new configuration above 'password sufficient pam_unix.so'
        # pam_pwhistory.so: remember last 5 passwords
        sudo sed -i '/^password.*sufficient.*pam_unix.so/i password    required        pam_pwhistory.so remember=5' "$file"
        # pam_pwquality.so: minlen=14, at least 1 uppercase, 1 lowercase, 1 digit, 1 special char, retry=3
        sudo sed -i '/^password.*sufficient.*pam_unix.so/i password    requisite       pam_pwquality.so try_first_pass local_users_only retry=3 minlen=14 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1 minclass=4' "$file"
        echo "  Updated $file."
    else
        echo "  Warning: PAM file $file not found. Skipping."
    fi
done
echo "Password policy configuration complete."
echo ""

# --- Section 7: Account Expiration and Password Aging ---
echo "--- Section 7: Account Expiration and Password Aging ---"
USERADD_DEFAULTS="/etc/default/useradd"
LOGIN_DEFS="/etc/login.defs"

echo "Configuring default account inactivity and password aging..."
# Backup original files
sudo cp -p "$USERADD_DEFAULTS" "${USERADD_DEFAULTS}.$(date +%Y%m%d-%H%M%S).bak"
sudo cp -p "$LOGIN_DEFS" "${LOGIN_DEFS}.$(date +%Y%m%d-%H%M%S).bak"

# Configure account inactivity for new users
if sudo grep -q "^INACTIVE=" "$USERADD_DEFAULTS"; then
    sudo sed -i 's/^INACTIVE=.*/INACTIVE=35/' "$USERADD_DEFAULTS"
else
    echo "INACTIVE=35" | sudo tee -a "$USERADD_DEFAULTS" >/dev/null
fi
echo "  Set INACTIVE=35 in $USERADD_DEFAULTS."

# Configure password aging in login.defs
# Note: These values might already be commented out or set differently.
# Using 'sed -i -E' for extended regex to handle optional whitespace.
sudo sed -i -E 's/^(PASS_MAX_DAYS)[[:space:]]*([0-9]+)?/PASS_MAX_DAYS    90/' "$LOGIN_DEFS"
if ! sudo grep -q "^PASS_MAX_DAYS" "$LOGIN_DEFS"; then echo "PASS_MAX_DAYS    90" | sudo tee -a "$LOGIN_DEFS" >/dev/null; fi
echo "  Set PASS_MAX_DAYS=90 in $LOGIN_DEFS."

sudo sed -i -E 's/^(PASS_MIN_DAYS)[[:space:]]*([0-9]+)?/PASS_MIN_DAYS    7/' "$LOGIN_DEFS"
if ! sudo grep -q "^PASS_MIN_DAYS" "$LOGIN_DEFS"; then echo "PASS_MIN_DAYS    7" | sudo tee -a "$LOGIN_DEFS" >/dev/null; fi
echo "  Set PASS_MIN_DAYS=7 in $LOGIN_DEFS."

sudo sed -i -E 's/^(PASS_WARN_AGE)[[:space:]]*([0-9]+)?/PASS_WARN_AGE    7/' "$LOGIN_DEFS"
if ! sudo grep -q "^PASS_WARN_AGE" "$LOGIN_DEFS"; then echo "PASS_WARN_AGE    7" | sudo tee -a "$LOGIN_DEFS" >/dev/null; fi
echo "  Set PASS_WARN_AGE=7 in $LOGIN_DEFS."

# Apply settings to existing local accounts (UID >= 1000 and not 'nobody')
echo "Applying password aging settings to existing local user accounts..."
for user in $(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd); do
    echo "  Applying to user: $user"
    sudo chage --maxdays 90 --mindays 7 --warndays 7 "$user" || echo "Warning: Failed to apply chage to $user."
done
echo "Account expiration configuration complete."
echo ""

# --- Section 8: Session Timeout and PAM Wheel Configuration ---
echo "--- Section 8: Session Timeout and PAM Wheel Configuration ---"
SU_PAM_FILE="/etc/pam.d/su"
PROFILE_FILE="/etc/profile"
BASHRC_FILE="/etc/bashrc"

# Backup original files
sudo cp -p "$SU_PAM_FILE" "${SU_PAM_FILE}.$(date +%Y%m%d-%H%M%S).bak"
sudo cp -p "$PROFILE_FILE" "${PROFILE_FILE}.$(date +%Y%m%d-%H%M%S).bak"
sudo cp -p "$BASHRC_FILE" "${BASHRC_FILE}.$(date +%Y%m%d-%H%M%S).bak"

# Configure PAM wheel for su (restricts 'su' usage to 'wheel' group members)
echo "Configuring 'su' command to restrict access to 'wheel' group via PAM..."
if ! sudo grep -q "^auth.*required.*pam_wheel.so.*use_uid" "$SU_PAM_FILE"; then
    # Add the line at the beginning of the file (or first uncommented 'auth' line)
    # This sed command assumes you want it at the start of 'auth' block.
    # It finds the first line starting with 'auth' and inserts before it.
    # If no 'auth' line, it will be added to the beginning.
    sudo sed -i '1i auth       required    pam_wheel.so use_uid' "$SU_PAM_FILE"
    echo "  Added pam_wheel requirement to $SU_PAM_FILE."
else
    echo "  pam_wheel requirement already configured in $SU_PAM_FILE."
fi

# Configure session timeout in /etc/profile and /etc/bashrc
echo "Configuring session timeout (TMOUT=900 seconds) in /etc/profile and /etc/bashrc..."
TMOUT_CONFIG_BLOCK=$'\n# Set session timeout\nTMOUT=900\nreadonly TMOUT\nexport TMOUT'
for file in "$PROFILE_FILE" "$BASHRC_FILE"; do
    if [ -f "$file" ]; then
        if ! sudo grep -q "^TMOUT=900" "$file"; then
            echo "$TMOUT_CONFIG_BLOCK" | sudo tee -a "$file" >/dev/null
            echo "  Added session timeout to $file."
        else
            echo "  Session timeout already configured in $file."
        fi
    else
        echo "  Warning: Shell profile file $file not found. Skipping."
    fi
done
echo "Session configuration complete."
echo ""

# --- Section 9: Umask Configuration ---
echo "--- Section 9: Umask Configuration ---"
UMASK_FILES=("/etc/bashrc" "/etc/profile" "/etc/login.defs")
TARGET_UMASK="027"

echo "Configuring default umask to $TARGET_UMASK..."
for file in "${UMASK_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "Processing $file..."
        sudo cp -p "$file" "${file}.$(date +%Y%m%d-%H%M%S).bak" # Backup
        
        if sudo grep -q "umask" "$file"; then
            # Replace existing umask lines
            sudo sed -i -E "s/^(umask|UMASK)[[:space:]]*[0-9]*/\1 $TARGET_UMASK/" "$file"
            echo "  Updated umask in $file."
        else
            # Add umask if not found (for bashrc/profile, add to end; for login.defs add as specific line)
            if [[ "$file" == *login.defs ]]; then
                 echo "UMASK $TARGET_UMASK" | sudo tee -a "$file" >/dev/null
            else
                 echo "umask $TARGET_UMASK" | sudo tee -a "$file" >/dev/null
            fi
            echo "  Added umask to $file."
        fi
    else
        echo "  Warning: Umask configuration file $file not found. Skipping."
    fi
done
echo "Umask configuration complete."
echo ""

# --- Section 10: Audit Daemon and Rule Configuration ---
echo "--- Section 10: Audit Daemon and Rule Configuration ---"

# Audit GRUB parameters
echo "Configuring GRUB for audit parameters (audit=1 audit_backlog_limit=8192)..."
GRUB_DEFAULT_FILE="/etc/default/grub"
sudo cp -p "$GRUB_DEFAULT_FILE" "${GRUB_DEFAULT_FILE}.$(date +%Y%m%d-%H%M%S).bak" # Backup

if ! sudo grep -q "audit=1" "$GRUB_DEFAULT_FILE"; then
    sudo sed -i 's/\(GRUB_CMDLINE_LINUX=".*\)"/\1 audit=1 audit_backlog_limit=8192"/' "$GRUB_DEFAULT_FILE"
    echo "  Added audit parameters to GRUB_CMDLINE_LINUX in $GRUB_DEFAULT_FILE."
    echo "  Rebuilding GRUB configuration..."
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    echo "  GRUB configuration rebuilt. A system reboot is required for these changes to take effect."
else
    echo "  Audit parameters already configured in GRUB_CMDLINE_LINUX."
fi

# Ensure auditd service is enabled and running
echo "Ensuring auditd service is enabled and running..."
sudo systemctl enable auditd --now
if sudo systemctl is-active --quiet auditd; then
    echo "  Auditd service is active and running."
else
    echo "  Warning: Auditd service is not active. Please check manually."
fi

# Clear current audit rules in kernel (important before loading new ones)
echo "Clearing existing audit rules from kernel (sudo auditctl -D)..."
sudo auditctl -D

# Define and apply various audit rules files
AUDIT_RULES_DIR="/etc/audit/rules.d"
sudo mkdir -p "$AUDIT_RULES_DIR" # Ensure directory exists
sudo chown root:root "$AUDIT_RULES_DIR"
sudo chmod 755 "$AUDIT_RULES_DIR"

declare -A audit_rule_files=(
    ["mac_policy.rules"]="# Monitor SELinux policy changes
-w /etc/selinux/ -p wa -k MAC-policy
-w /usr/share/selinux/ -p wa -k MAC-policy
-w /etc/selinux/config -p wa -k MAC-policy
-w /usr/sbin/semanage -p x -k MAC-policy
-w /usr/sbin/setsebool -p x -k MAC-policy
-w /usr/bin/chcon -p x -k MAC-policy
-w /usr/sbin/setfiles -p x -k MAC-policy
-w /usr/share/selinux/packages/ -p wa -k MAC-policy"

    ["media_export.rules"]="# Monitor successful mount operations
-a always,exit -F arch=b32 -S mount -F success=1 -k media_export
-a always,exit -F arch=b64 -S mount -F success=1 -k media_export
-w /usr/bin/mount -p x -k media_export
-w /usr/bin/umount -p x -k media_export
-w /usr/bin/automount -p x -k media_export"

    ["networkconfig_mod.rules"]="# Monitor changes to network environment
-a always,exit -F arch=b32 -S sethostname -S setdomainname -k network_modifications
-a always,exit -F arch=b64 -S sethostname -S setdomainname -k network_modifications
-w /etc/issue -p wa -k network_modifications
-w /etc/issue.net -p wa -k network_modifications
-w /etc/hosts -p wa -k network_modifications
-w /etc/sysconfig/network -p wa -k network_modifications
-w /etc/sysconfig/network-scripts/ -p wa -k network_modifications"

    ["session_events.rules"]="# Monitor session initiation information
-w /var/run/utmp -p wa -k session
-w /var/log/wtmp -p wa -k session
-w /var/log/btmp -p wa -k session"

    ["sysadmin_actions.rules"]="# Monitor execution of privileged commands
-a always,exit -F arch=b64 -C euid=0 -S execve -k actions
-a always,exit -F arch=b32 -C euid=0 -S execve -k actions"

    ["usergroup_mod_group.rules"]="# Monitor changes to /etc/group (dedicated file)
-w /etc/group -p wa -k identity"

    ["usergroup_dac.rules"]="# User/Group modifications
-w /etc/group -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/security/opasswd -p wa -k identity
-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity

# DAC modifications
-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -k perm_mod
-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -k perm_mod
-a always,exit -F arch=b64 -S fremovexattr -S fsetxattr -S lremovexattr -S lsetxattr -S removexattr -S setxattr -k perm_mod"

    ["file_deletion.rules"]="# File deletion events
-a always,exit -F arch=b64 -S rename -k delete
-a always,exit -F arch=b64 -S renameat -k delete
-a always,exit -F arch=b64 -S unlink -k delete
-a always,exit -F arch=b64 -S unlinkat -k delete"

    ["kernel_module.rules"]="# Kernel module loading/unloading events
-a always,exit -F arch=b64 -S delete_module -k modules
-a always,exit -F arch=b64 -S init_module -k modules"

    ["time_login.rules"]="# Logon/Logout events
-w /var/run/faillock -p wa -k logins
-w /var/log/lastlog -p wa -k logins

# Time change events
-a always,exit -F arch=b64 -S adjtimex -k time-change
-a always,exit -F arch=b64 -S clock_settime -k time-change
-a always,exit -F arch=b64 -S stime -k time-change
-w /etc/localtime -p wa -k time-change"
)

echo "Creating/updating audit rules files in $AUDIT_RULES_DIR/..."
for filename in "${!audit_rule_files[@]}"; do
    content="${audit_rule_files[$filename]}"
    rule_file="${AUDIT_RULES_DIR}/$filename"

    # Check if the file exists and its content matches
    current_content=""
    if [ -f "$rule_file" ]; then
        current_content=$(sudo cat "$rule_file")
    fi

    if [ "$current_content" = "$content" ]; then
        echo "  Audit rule file '$filename' already exists with correct content. Skipping."
    else
        echo "  Creating/Updating audit rule file: '$filename'"
        sudo tee "$rule_file" <<< "$content" >/dev/null
        sudo chmod 640 "$rule_file"
        sudo chown root:root "$rule_file"
    fi
done

# Add immutable rule to audit.rules
# Note: SSG often places this in /etc/audit/audit.rules directly or via a specific file.
# For simplicity and to avoid augenrules conflicts with -e 2 in separate files,
# I'm modifying /etc/audit/audit.rules after augenrules if not present.
# It's better practice to place it in a rule file that gets picked up by augenrules.
# Forcing it here, but ideally, this would be in a file like /etc/audit/rules.d/99-immutable.rules
if ! sudo grep -q "^-e 2" /etc/audit/audit.rules; then
    echo "Adding immutable rule '-e 2' to /etc/audit/audit.rules."
    sudo echo "-e 2" | sudo tee -a /etc/audit/audit.rules >/dev/null
else
    echo "Immutable rule '-e 2' already exists in /etc/audit/audit.rules."
fi


# Reload all audit rules using augenrules (combines all .rules files in rules.d)
echo "Reloading all audit rules using augenrules --load..."
sudo augenrules --load

echo "Verifying a sample of loaded audit rules:"
sudo auditctl -l | grep -E 'MAC-policy|media_export|network_modifications|identity|perm_mod|delete|modules|logins|time-change|actions' | head -n 10
echo "(Truncated list for brevity. Use 'sudo auditctl -l' for full list.)"

echo "Audit configuration complete. **A system reboot is highly recommended to ensure all audit parameters (especially GRUB ones) are active.**"
echo ""

# --- Section 11: GRUB2 Configuration Hardening ---
echo "--- Section 11: GRUB2 Configuration Hardening ---"
GRUB_CFG_FILE="/boot/grub2/grub.cfg"
GRUB_CUSTOM_FILE="/etc/grub.d/40_custom"

# Fix GRUB.cfg Permissions
echo "Fixing permissions and ownership for $GRUB_CFG_FILE..."
if [ -f "$GRUB_CFG_FILE" ]; then
    CURRENT_PERMS=$(stat -c "%a" "$GRUB_CFG_FILE")
    CURRENT_OWNER=$(stat -c "%U" "$GRUB_CFG_FILE")
    CURRENT_GROUP=$(stat -c "%G" "$GRUB_CFG_FILE")

    FIXED_GRUB_PERMS=0
    if [ "$CURRENT_PERMS" != "600" ]; then
        echo "  Incorrect permissions ($CURRENT_PERMS). Setting to 600."
        sudo chmod 600 "$GRUB_CFG_FILE"
        FIXED_GRUB_PERMS=1
    else
        echo "  Permissions already set to 600."
    fi

    if [ "$CURRENT_OWNER" != "root" ] || [ "$CURRENT_GROUP" != "root" ]; then
        echo "  Incorrect owner/group ($CURRENT_OWNER:$CURRENT_GROUP). Setting to root:root."
        sudo chown root:root "$GRUB_CFG_FILE"
        FIXED_GRUB_PERMS=1
    else
        echo "  Owner and group already set to root:root."
    fi

    if [ $FIXED_GRUB_PERMS -eq 0 ]; then
        echo "  No changes needed for $GRUB_CFG_FILE permissions."
    else
        echo "  Permissions and ownership for $GRUB_CFG_FILE have been corrected."
    fi
    sudo ls -l "$GRUB_CFG_FILE"
else
    echo "  Warning: $GRUB_CFG_FILE does not exist. Skipping permission fix."
fi

# Set GRUB2 password
echo "Setting GRUB2 bootloader password (if not already set)..."
if ! sudo grep -q "password_pbkdf2 root" "$GRUB_CUSTOM_FILE" 2>/dev/null; then
    echo "  GRUB2 password not found. Please enter the GRUB2 password you want to set:"
    read -s PASSWORD
    if [ -z "$PASSWORD" ]; then
        echo "  No password entered. Skipping GRUB2 password setup."
    else
        HASH=$(echo -e "$PASSWORD\n$PASSWORD" | grub2-mkpasswd-pbkdf2 2>/dev/null | awk '/grub.pbkdf2.sha512/ {print $7}')
        if [ -z "$HASH" ]; then
            echo "  Failed to generate password hash. Skipping GRUB2 password setup."
        else
            sudo cp -p "$GRUB_CUSTOM_FILE" "${GRUB_CUSTOM_FILE}.$(date +%Y%m%d-%H%M%S).bak" # Backup
            echo "set superuser=\"root\"" | sudo tee -a "$GRUB_CUSTOM_FILE" >/dev/null
            echo "password_pbkdf2 root $HASH" | sudo tee -a "$GRUB_CUSTOM_FILE" >/dev/null
            echo "  Added GRUB2 password entry to $GRUB_CUSTOM_FILE."
            echo "  Updating GRUB2 configuration..."
            sudo grub2-mkconfig -o "$GRUB_CFG_FILE"
            if sudo grep -q "password_pbkdf2" "$GRUB_CFG_FILE"; then
                echo "  GRUB2 password successfully configured. A system reboot is required."
            else
                echo "  Failed to configure GRUB2 password. Check GRUB config."
            fi
        fi
    fi
else
    echo "  GRUB2 password already set in $GRUB_CUSTOM_FILE. Skipping."
fi
echo ""

# --- Section 12: Firewalld Default Zone Configuration ---
echo "--- Section 12: Firewalld Default Zone Configuration ---"
DEFAULT_FIREWALLD_ZONE="public"

if command_exists firewall-cmd; then
    echo "Firewalld detected. Checking current default zone..."
    CURRENT_FIREWALLD_ZONE=$(sudo firewall-cmd --get-default-zone)

    if [ "$CURRENT_FIREWALLD_ZONE" != "$DEFAULT_FIREWALLD_ZONE" ]; then
        echo "  Current default zone is '$CURRENT_FIREWALLD_ZONE'. Setting to '$DEFAULT_FIREWALLD_ZONE'."
        sudo firewall-cmd --set-default-zone="$DEFAULT_FIREWALLD_ZONE"
        sudo firewall-cmd --permanent --set-default-zone="$DEFAULT_FIREWALLD_ZONE"
        echo "  Default zone set to '$DEFAULT_FIREWALLD_ZONE'."
    else
        echo "  Default zone is already set to '$DEFAULT_FIREWALLD_ZONE'."
    fi
    echo "  Verifying default zone: $(sudo firewall-cmd --get-default-zone)"
else
    echo "Firewall-cmd not found. Skipping Firewalld configuration (Firewalld likely not installed/active)."
fi
echo ""

echo "--- Comprehensive System Hardening and Audit Configuration Complete ---"
echo "Log file: $LOG_FILE"
echo "**IMPORTANT: A system reboot is highly recommended to ensure all changes (especially GRUB and FIPS) take full effect.**"

```
systemctl mask cups 2>/dev/null

# Harden SSH configuration
SSHD_CONFIG="/etc/ssh/sshd_config"
cp -p "$SSHD_CONFIG" "$SSHD_CONFIG.$(date +%Y%m%d-%H%M%S).bak"

declare -A ssh_settings=(
    [PermitRootLogin]="no"
    [AllowTcpForwarding]="no"
    [X11Forwarding]="no"
    [ClientAliveInterval]="300"
    [ClientAliveCountMax]="0"
    [MaxAuthTries]="4"
    [MaxSessions]="10"
    [MaxStartups]="10:30:100"
)

for key in "${!ssh_settings[@]}"; do
    if grep -q "^$key" "$SSHD_CONFIG"; then
        sed -i "s|^$key.*|$key ${ssh_settings[$key]}|" "$SSHD_CONFIG"
    else
        echo "$key ${ssh_settings[$key]}" >> "$SSHD_CONFIG"
    fi
done

systemctl reload sshd

# Remove X Windows
dnf groupremove -y "X Window System"
systemctl set-default multi-user.target

echo "SSH and service hardening complete. See $LOG_FILE for details"
````
**Remember:**  
- Always test changes in a non-production environment first.  
- Backup configuration files before making changes.  
- Document changes in your change management system.

---
