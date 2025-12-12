# Linux Security and Hardening Guide for DevOps/DevSecOps Engineers

## System Security Fundamentals

### Security Assessment and Baseline

#### Initial Security Assessment
```bash
# System information gathering
uname -a                        # Kernel and system info
cat /etc/os-release             # OS version information
lscpu                           # CPU architecture
free -h                         # Memory information
df -h                           # Disk usage
mount | grep -E "(nodev|nosuid|noexec)"  # Security mount options

# Network assessment
ss -tuln                        # Listening services
netstat -tulpn                  # Alternative listening services
lsof -i                         # Network connections
iptables -L -n                  # Firewall rules
```

#### Security Baseline Script
```bash
#!/bin/bash
# Security baseline assessment script

REPORT_FILE="/tmp/security_baseline_$(date +%Y%m%d_%H%M%S).txt"

echo "=== Linux Security Baseline Report ===" > "$REPORT_FILE"
echo "Generated: $(date)" >> "$REPORT_FILE"
echo "Hostname: $(hostname)" >> "$REPORT_FILE"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Check for world-writable files
echo "=== World-Writable Files ===" >> "$REPORT_FILE"
find / -type f -perm /o+w 2>/dev/null | head -20 >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Check SUID/SGID files
echo "=== SUID/SGID Files ===" >> "$REPORT_FILE"
find / -type f \( -perm /4000 -o -perm /2000 \) 2>/dev/null >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Check listening services
echo "=== Listening Services ===" >> "$REPORT_FILE"
ss -tuln >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Check user accounts
echo "=== User Accounts ===" >> "$REPORT_FILE"
awk -F: '$3 >= 1000 {print $1 ":" $3 ":" $7}' /etc/passwd >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Check sudo access
echo "=== Sudo Access ===" >> "$REPORT_FILE"
grep -E "^[^#].*ALL.*ALL" /etc/sudoers /etc/sudoers.d/* 2>/dev/null >> "$REPORT_FILE"

echo "Security baseline report generated: $REPORT_FILE"
```

## User and Access Control Security

### User Account Security

#### Password Policy Configuration
```bash
# /etc/login.defs - Password aging controls
PASS_MAX_DAYS   90              # Maximum password age
PASS_MIN_DAYS   1               # Minimum password age
PASS_MIN_LEN    12              # Minimum password length
PASS_WARN_AGE   7               # Password expiration warning

# /etc/security/pwquality.conf - Password complexity
minlen = 12                     # Minimum length
minclass = 3                    # Minimum character classes
maxrepeat = 2                   # Maximum repeated characters
dcredit = -1                    # Require at least 1 digit
ucredit = -1                    # Require at least 1 uppercase
lcredit = -1                    # Require at least 1 lowercase
ocredit = -1                    # Require at least 1 special character
```

#### Account Lockout Policy
```bash
# /etc/pam.d/common-auth (Debian/Ubuntu)
auth required pam_tally2.so deny=5 unlock_time=900 onerr=fail

# /etc/pam.d/system-auth (Red Hat/CentOS)
auth required pam_faillock.so preauth silent audit deny=5 unlock_time=900
auth [default=die] pam_faillock.so authfail audit deny=5 unlock_time=900

# Check locked accounts
pam_tally2 --user username      # Check lockout status
pam_tally2 --user username --reset  # Reset lockout counter
```

#### User Account Auditing
```bash
# Find accounts with empty passwords
awk -F: '($2 == "") {print $1}' /etc/shadow

# Find accounts with UID 0 (root privileges)
awk -F: '($3 == 0) {print $1}' /etc/passwd

# Check for duplicate UIDs
awk -F: '{print $3}' /etc/passwd | sort | uniq -d

# Find accounts that haven't changed passwords recently
awk -F: '$3 >= 1000 {print $1}' /etc/passwd | while read user; do
    chage -l "$user" | grep "Last password change"
done

# Check for accounts with no expiry
awk -F: '$2 != "*" && $2 != "!" {print $1}' /etc/shadow | while read user; do
    chage -l "$user" | grep "Account expires" | grep -q "never" && echo "$user: No expiry set"
done
```

### SSH Security Hardening

#### SSH Server Configuration (/etc/ssh/sshd_config)
```bash
# Basic security settings
Port 2222                       # Change default port
Protocol 2                      # Use SSH protocol 2 only
PermitRootLogin no              # Disable root login
PasswordAuthentication no       # Disable password authentication
PubkeyAuthentication yes        # Enable key-based authentication
AuthorizedKeysFile .ssh/authorized_keys

# Connection limits
MaxAuthTries 3                  # Maximum authentication attempts
MaxSessions 2                   # Maximum concurrent sessions
MaxStartups 2:30:10             # Connection rate limiting
LoginGraceTime 30               # Time limit for authentication

# Security features
PermitEmptyPasswords no         # Don't allow empty passwords
X11Forwarding no                # Disable X11 forwarding
AllowTcpForwarding no           # Disable TCP forwarding
GatewayPorts no                 # Disable gateway ports
PermitTunnel no                 # Disable tunneling
UseDNS no                       # Disable DNS lookups

# Access control
AllowUsers deploy admin         # Allow specific users
DenyUsers guest test            # Deny specific users
AllowGroups sshusers            # Allow specific groups

# Logging and monitoring
LogLevel VERBOSE                # Detailed logging
SyslogFacility AUTH             # Log to auth facility

# Keep-alive settings
ClientAliveInterval 300         # Send keep-alive every 5 minutes
ClientAliveCountMax 2           # Disconnect after 2 failed keep-alives

# Cryptographic settings
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-512
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
```

#### SSH Key Management
```bash
# Generate secure SSH keys
ssh-keygen -t ed25519 -b 4096 -C "user@hostname-$(date +%Y%m%d)"
ssh-keygen -t rsa -b 4096 -C "user@hostname-$(date +%Y%m%d)"

# Set proper permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/id_*.pub
chmod 600 ~/.ssh/authorized_keys
chmod 600 ~/.ssh/config

# SSH key rotation script
#!/bin/bash
# SSH key rotation script
OLD_KEY="$HOME/.ssh/id_rsa_old"
NEW_KEY="$HOME/.ssh/id_rsa"
SERVERS=("server1.example.com" "server2.example.com")

# Generate new key
ssh-keygen -t rsa -b 4096 -f "$NEW_KEY" -N ""

# Deploy new key to servers
for server in "${SERVERS[@]}"; do
    ssh-copy-id -i "$NEW_KEY.pub" "$server"
done

# Test new key
for server in "${SERVERS[@]}"; do
    if ssh -i "$NEW_KEY" -o PasswordAuthentication=no "$server" "echo 'Key test successful'"; then
        echo "New key working on $server"
    else
        echo "ERROR: New key failed on $server"
        exit 1
    fi
done

# Remove old key from authorized_keys on servers
for server in "${SERVERS[@]}"; do
    OLD_KEY_CONTENT=$(cat "$OLD_KEY.pub")
    ssh -i "$NEW_KEY" "$server" "sed -i '/$OLD_KEY_CONTENT/d' ~/.ssh/authorized_keys"
done

echo "SSH key rotation completed successfully"
```

## Network Security

### Firewall Configuration

#### iptables Security Rules
```bash
#!/bin/bash
# Comprehensive iptables security script

# Flush existing rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

# Set default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established and related connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow SSH (change port as needed)
iptables -A INPUT -p tcp --dport 2222 -m state --state NEW -m limit --limit 5/min -j ACCEPT

# Allow HTTP and HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Allow ping (rate limited)
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT

# Drop invalid packets
iptables -A INPUT -m state --state INVALID -j DROP

# Protection against port scanning
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP

# Protection against SYN flood
iptables -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j ACCEPT
iptables -A INPUT -p tcp --syn -j DROP

# Log dropped packets
iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 7

# Save rules
iptables-save > /etc/iptables/rules.v4
```

#### UFW Advanced Configuration
```bash
# Reset UFW to defaults
sudo ufw --force reset

# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH with rate limiting
sudo ufw limit ssh comment 'SSH rate limited'

# Allow specific services
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'

# Allow from specific networks
sudo ufw allow from 192.168.1.0/24 comment 'Local network'
sudo ufw allow from 10.0.0.0/8 to any port 3306 comment 'MySQL from private network'

# Application profiles
sudo ufw app list
sudo ufw allow 'Nginx Full'
sudo ufw allow 'OpenSSH'

# Advanced rules
sudo ufw deny out 25 comment 'Block outgoing SMTP'
sudo ufw allow out 53 comment 'Allow DNS'
sudo ufw allow out 123/udp comment 'Allow NTP'

# Logging
sudo ufw logging on

# Enable firewall
sudo ufw enable

# Status and management
sudo ufw status verbose
sudo ufw status numbered
sudo ufw delete 2
```

### Network Intrusion Detection

#### Fail2Ban Configuration
```bash
# /etc/fail2ban/jail.local
[DEFAULT]
# Ban settings
bantime = 3600                  # Ban for 1 hour
findtime = 600                  # Look for failures in 10 minutes
maxretry = 3                    # Max failures before ban
backend = systemd               # Use systemd backend

# Email notifications
destemail = admin@example.com
sendername = Fail2Ban
mta = sendmail
action = %(action_mwl)s         # Ban and send email with logs

[sshd]
enabled = true
port = ssh,2222
logpath = /var/log/auth.log
maxretry = 3
bantime = 7200                  # 2 hours for SSH

[nginx-http-auth]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log
maxretry = 5

[nginx-noscript]
enabled = true
port = http,https
logpath = /var/log/nginx/access.log
maxretry = 6

[nginx-badbots]
enabled = true
port = http,https
logpath = /var/log/nginx/access.log
maxretry = 2

[nginx-noproxy]
enabled = true
port = http,https
logpath = /var/log/nginx/access.log
maxretry = 2

# Custom jail for application logs
[myapp]
enabled = true
port = 8080
logpath = /var/log/myapp/security.log
failregex = ^.*Failed login attempt from <HOST>.*$
maxretry = 3
bantime = 1800
```

#### Network Monitoring Script
```bash
#!/bin/bash
# Network security monitoring script

LOG_FILE="/var/log/network-security.log"
ALERT_EMAIL="security@example.com"

log_alert() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') SECURITY ALERT: $message" | tee -a "$LOG_FILE"
    echo "$message" | mail -s "Security Alert - $(hostname)" "$ALERT_EMAIL"
}

# Monitor for port scans
check_port_scans() {
    local scan_attempts=$(grep "$(date '+%b %d %H:%M')" /var/log/syslog | grep -c "iptables denied")
    if [ "$scan_attempts" -gt 50 ]; then
        log_alert "High number of port scan attempts detected: $scan_attempts"
    fi
}

# Monitor for failed SSH attempts
check_ssh_failures() {
    local ssh_failures=$(grep "$(date '+%b %d %H:%M')" /var/log/auth.log | grep -c "Failed password")
    if [ "$ssh_failures" -gt 10 ]; then
        log_alert "High number of SSH login failures: $ssh_failures"
    fi
}

# Monitor for new network connections
check_new_connections() {
    local current_connections=$(ss -tuln | wc -l)
    local baseline_file="/tmp/network_baseline.txt"
    
    if [ -f "$baseline_file" ]; then
        local baseline_connections=$(cat "$baseline_file")
        local difference=$((current_connections - baseline_connections))
        
        if [ "$difference" -gt 10 ]; then
            log_alert "Significant increase in network connections: +$difference"
        fi
    fi
    
    echo "$current_connections" > "$baseline_file"
}

# Monitor for suspicious processes
check_suspicious_processes() {
    # Check for processes listening on unusual ports
    local unusual_ports=$(ss -tuln | awk '$4 ~ /:/ {split($4,a,":"); print a[2]}' | sort -n | grep -E '^(1337|31337|4444|5555|6666|7777|8888|9999)$')
    
    if [ -n "$unusual_ports" ]; then
        log_alert "Processes listening on suspicious ports: $unusual_ports"
    fi
}

main() {
    check_port_scans
    check_ssh_failures
    check_new_connections
    check_suspicious_processes
}

main "$@"
```

## File System Security

### File Integrity Monitoring

#### AIDE Configuration
```bash
# Install AIDE
sudo apt install aide               # Debian/Ubuntu
sudo yum install aide               # Red Hat/CentOS

# /etc/aide/aide.conf
# Database location
database=file:/var/lib/aide/aide.db
database_out=file:/var/lib/aide/aide.db.new

# Rules
All=p+i+n+u+g+s+m+c+md5+sha1+rmd160+tiger+haval+gost+crc32
Norm=s+n+b+md5+sha1+rmd160+tiger+haval+gost+crc32
Dir=p+i+n+u+g+acl+selinux+xattrs
LoG=p+u+g+n+S+acl+selinux+xattrs

# Directories to monitor
/bin Norm
/sbin Norm
/usr/bin Norm
/usr/sbin Norm
/etc All
/root All
/var/log LoG
!/var/log/.*\.log$
!/var/log/.*\.gz$

# Initialize database
sudo aide --init
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# Check for changes
sudo aide --check

# Update database after legitimate changes
sudo aide --update
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
```

#### File Permission Monitoring
```bash
#!/bin/bash
# File permission monitoring script

BASELINE_FILE="/var/lib/security/file_permissions_baseline.txt"
CURRENT_FILE="/tmp/file_permissions_current.txt"
ALERT_FILE="/var/log/file_permission_alerts.log"

# Create baseline if it doesn't exist
if [ ! -f "$BASELINE_FILE" ]; then
    mkdir -p "$(dirname "$BASELINE_FILE")"
    find /etc /usr/bin /usr/sbin /bin /sbin -type f -exec stat -c "%n %a %U %G" {} \; > "$BASELINE_FILE"
    echo "Baseline created: $BASELINE_FILE"
    exit 0
fi

# Generate current permissions
find /etc /usr/bin /usr/sbin /bin /sbin -type f -exec stat -c "%n %a %U %G" {} \; > "$CURRENT_FILE"

# Compare with baseline
if ! diff "$BASELINE_FILE" "$CURRENT_FILE" > /dev/null; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - File permission changes detected:" >> "$ALERT_FILE"
    diff "$BASELINE_FILE" "$CURRENT_FILE" >> "$ALERT_FILE"
    echo "---" >> "$ALERT_FILE"
    
    # Send alert
    echo "File permission changes detected on $(hostname)" | \
        mail -s "Security Alert: File Permission Changes" admin@example.com
fi

# Cleanup
rm -f "$CURRENT_FILE"
```

### Access Control Lists (ACLs)

#### ACL Configuration and Management
```bash
# Check if ACLs are supported
mount | grep acl

# Enable ACLs on filesystem (add to /etc/fstab)
/dev/sda1 /home ext4 defaults,acl 0 2

# Remount with ACL support
mount -o remount,acl /home

# Set ACLs
setfacl -m u:username:rwx /path/to/file        # User permissions
setfacl -m g:groupname:rx /path/to/file        # Group permissions
setfacl -m o::r /path/to/file                  # Other permissions
setfacl -m d:u:username:rwx /path/to/dir       # Default ACL for directory

# View ACLs
getfacl /path/to/file

# Remove ACLs
setfacl -x u:username /path/to/file            # Remove user ACL
setfacl -b /path/to/file                       # Remove all ACLs

# Copy ACLs
getfacl /source/file | setfacl --set-file=- /dest/file

# Backup and restore ACLs
getfacl -R /path > acl_backup.txt
setfacl --restore=acl_backup.txt
```

## System Hardening

### Kernel Security

#### Kernel Parameter Hardening
```bash
# /etc/sysctl.d/99-security.conf

# Network security
net.ipv4.ip_forward = 0                        # Disable IP forwarding
net.ipv4.conf.all.send_redirects = 0          # Disable ICMP redirects
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_redirects = 0        # Don't accept redirects
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0        # Don't accept secure redirects
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.accept_source_route = 0     # Don't accept source routing
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1            # Log martian packets
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1      # Ignore ping broadcasts
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1                   # Enable SYN cookies

# IPv6 security (if not using IPv6, disable it)
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1

# Memory protection
kernel.dmesg_restrict = 1                      # Restrict dmesg access
kernel.kptr_restrict = 2                       # Hide kernel pointers
kernel.yama.ptrace_scope = 1                   # Restrict ptrace
kernel.kexec_load_disabled = 1                 # Disable kexec
kernel.unprivileged_bpf_disabled = 1           # Disable unprivileged BPF

# File system security
fs.protected_hardlinks = 1                     # Protect hardlinks
fs.protected_symlinks = 1                      # Protect symlinks
fs.suid_dumpable = 0                          # Disable core dumps for SUID

# Process security
kernel.core_uses_pid = 1                       # Append PID to core filename
kernel.ctrl-alt-del = 0                        # Disable Ctrl+Alt+Del

# Apply settings
sysctl -p /etc/sysctl.d/99-security.conf
```

#### Module Security
```bash
# List loaded modules
lsmod

# Module information
modinfo module_name

# Blacklist unnecessary modules
# /etc/modprobe.d/blacklist-security.conf
blacklist dccp                    # Datagram Congestion Control Protocol
blacklist sctp                    # Stream Control Transmission Protocol
blacklist rds                     # Reliable Datagram Sockets
blacklist tipc                    # Transparent Inter Process Communication
blacklist cramfs                  # Compressed ROM filesystem
blacklist freevxfs                # Veritas filesystem
blacklist jffs2                   # Journalling Flash filesystem
blacklist hfs                     # Hierarchical filesystem (Mac)
blacklist hfsplus                 # Extended Mac filesystem
blacklist squashfs                # Compressed read-only filesystem
blacklist udf                     # Universal Disk Format

# Prevent module loading
echo 'install dccp /bin/true' >> /etc/modprobe.d/blacklist-security.conf
echo 'install sctp /bin/true' >> /etc/modprobe.d/blacklist-security.conf
```

### Service Hardening

#### Service Security Configuration
```bash
# Disable unnecessary services
systemctl list-unit-files --type=service --state=enabled

# Common services to disable (if not needed)
systemctl disable avahi-daemon    # Network discovery
systemctl disable cups            # Printing service
systemctl disable bluetooth       # Bluetooth service
systemctl disable nfs-client      # NFS client
systemctl disable rpcbind         # RPC service

# Secure service configurations
# Example: Nginx security
# /etc/nginx/nginx.conf
server_tokens off;                 # Hide version information
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";
```

#### Application Security
```bash
# Run applications with minimal privileges
# Create dedicated users for services
useradd -r -s /bin/false -d /var/lib/myapp myapp

# Systemd service security
# /etc/systemd/system/myapp.service
[Service]
User=myapp
Group=myapp
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/lib/myapp /var/log/myapp
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE
```

## Security Monitoring and Incident Response

### Log Analysis and SIEM

#### Centralized Logging with rsyslog
```bash
# /etc/rsyslog.conf
# Send logs to central server
*.* @@logserver.example.com:514

# Receive logs from remote hosts (on log server)
$ModLoad imudp
$UDPServerRun 514
$UDPServerAddress 0.0.0.0

# Log filtering and routing
if $programname == 'sshd' then /var/log/ssh.log
if $programname == 'nginx' then /var/log/nginx/nginx.log
& stop
```

#### Security Event Correlation
```bash
#!/bin/bash
# Security event correlation script

LOG_DIR="/var/log"
ALERT_THRESHOLD=10
TIME_WINDOW=300  # 5 minutes

# Function to check for brute force attacks
check_brute_force() {
    local current_time=$(date +%s)
    local start_time=$((current_time - TIME_WINDOW))
    
    # SSH brute force
    local ssh_failures=$(awk -v start="$start_time" '
        {
            cmd="date -d \""$1" "$2" "$3"\" +%s"
            cmd | getline timestamp
            close(cmd)
            if (timestamp >= start && /Failed password/) count++
        }
        END {print count+0}
    ' /var/log/auth.log)
    
    if [ "$ssh_failures" -gt "$ALERT_THRESHOLD" ]; then
        echo "ALERT: SSH brute force detected - $ssh_failures failures in last 5 minutes"
    fi
}

# Function to check for privilege escalation
check_privilege_escalation() {
    local sudo_commands=$(grep "$(date '+%b %d %H:%M')" /var/log/auth.log | grep -c "sudo.*COMMAND")
    
    if [ "$sudo_commands" -gt 20 ]; then
        echo "ALERT: High sudo activity detected - $sudo_commands commands in last minute"
    fi
}

# Function to check for file system changes
check_file_changes() {
    local critical_files=("/etc/passwd" "/etc/shadow" "/etc/sudoers")
    
    for file in "${critical_files[@]}"; do
        if [ -f "$file" ]; then
            local mod_time=$(stat -c %Y "$file")
            local current_time=$(date +%s)
            local age=$((current_time - mod_time))
            
            if [ "$age" -lt 300 ]; then  # Modified in last 5 minutes
                echo "ALERT: Critical file modified recently: $file"
            fi
        fi
    done
}

main() {
    check_brute_force
    check_privilege_escalation
    check_file_changes
}

main "$@"
```

### Automated Security Response

#### Incident Response Script
```bash
#!/bin/bash
# Automated incident response script

INCIDENT_DIR="/var/log/incidents"
QUARANTINE_DIR="/var/quarantine"

create_incident_report() {
    local incident_id="INC_$(date +%Y%m%d_%H%M%S)"
    local incident_file="$INCIDENT_DIR/$incident_id.txt"
    
    mkdir -p "$INCIDENT_DIR"
    
    echo "=== SECURITY INCIDENT REPORT ===" > "$incident_file"
    echo "Incident ID: $incident_id" >> "$incident_file"
    echo "Timestamp: $(date)" >> "$incident_file"
    echo "Hostname: $(hostname)" >> "$incident_file"
    echo "" >> "$incident_file"
    
    # System state
    echo "=== SYSTEM STATE ===" >> "$incident_file"
    ps aux >> "$incident_file"
    echo "" >> "$incident_file"
    
    # Network connections
    echo "=== NETWORK CONNECTIONS ===" >> "$incident_file"
    ss -tuln >> "$incident_file"
    echo "" >> "$incident_file"
    
    # Recent logins
    echo "=== RECENT LOGINS ===" >> "$incident_file"
    last -n 20 >> "$incident_file"
    echo "" >> "$incident_file"
    
    echo "$incident_file"
}

quarantine_process() {
    local pid="$1"
    local process_name=$(ps -p "$pid" -o comm=)
    
    echo "Quarantining process: $pid ($process_name)"
    
    # Stop the process
    kill -STOP "$pid"
    
    # Create quarantine record
    mkdir -p "$QUARANTINE_DIR"
    echo "$(date): PID $pid ($process_name) quarantined" >> "$QUARANTINE_DIR/quarantine.log"
}

block_ip_address() {
    local ip_address="$1"
    
    echo "Blocking IP address: $ip_address"
    
    # Add to iptables
    iptables -I INPUT -s "$ip_address" -j DROP
    
    # Add to fail2ban (if available)
    if command -v fail2ban-client >/dev/null; then
        fail2ban-client set sshd banip "$ip_address"
    fi
    
    # Log the action
    echo "$(date): IP $ip_address blocked" >> /var/log/security_blocks.log
}

main() {
    local action="$1"
    local target="$2"
    
    case "$action" in
        "report")
            create_incident_report
            ;;
        "quarantine")
            quarantine_process "$target"
            ;;
        "block")
            block_ip_address "$target"
            ;;
        *)
            echo "Usage: $0 {report|quarantine <pid>|block <ip>}"
            exit 1
            ;;
    esac
}

main "$@"
```

This comprehensive security and hardening guide provides DevOps and DevSecOps engineers with the essential knowledge and tools needed to secure Linux systems in production environments, covering everything from basic security assessment to advanced incident response procedures.