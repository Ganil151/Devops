
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