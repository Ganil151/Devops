# SSH Best Practices

Comprehensive guide to SSH best practices for security, performance, and operational excellence in production environments.

## Security Best Practices

### Authentication Security
```bash
# Use strong key algorithms
ssh-keygen -t ed25519 -b 256  # Preferred
ssh-keygen -t rsa -b 4096     # Alternative

# Disable password authentication
PasswordAuthentication no
PubkeyAuthentication yes
AuthenticationMethods publickey

# Implement key-based authentication only
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM no
```

### Server Hardening
```bash
# /etc/ssh/sshd_config security configuration
Protocol 2
Port 2222                    # Non-standard port
PermitRootLogin no
MaxAuthTries 3
MaxSessions 2
LoginGraceTime 60
ClientAliveInterval 300
ClientAliveCountMax 2

# Restrict users and groups
AllowUsers deploy admin monitoring
AllowGroups ssh-users

# Disable unused features
X11Forwarding no
AllowTcpForwarding yes       # Only if needed
GatewayPorts no
PermitTunnel no
PermitUserEnvironment no

# Strong cryptography
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group16-sha512
```

### Network Security
```bash
# Firewall configuration
# Allow SSH only from specific networks
sudo ufw allow from 192.168.1.0/24 to any port 2222
sudo ufw deny 2222

# Use fail2ban for intrusion prevention
sudo apt install fail2ban

# /etc/fail2ban/jail.local
[sshd]
enabled = true
port = 2222
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600
```

### Key Management Security
```bash
# Use passphrases for private keys
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_secure -N "strong-passphrase"

# Rotate keys regularly (quarterly recommended)
# Implement automated key rotation
0 2 1 */3 * /usr/local/bin/rotate-ssh-keys.sh

# Use different keys for different purposes
~/.ssh/id_ed25519_prod      # Production access
~/.ssh/id_ed25519_dev       # Development access
~/.ssh/id_ed25519_deploy    # Deployment automation

# Secure key storage
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/id_*.pub
chmod 600 ~/.ssh/authorized_keys
```

## Performance Optimization

### Connection Optimization
```bash
# ~/.ssh/config performance settings
Host *
    # Connection multiplexing
    ControlMaster auto
    ControlPath ~/.ssh/control-%r@%h:%p
    ControlPersist 10m
    
    # Keep connections alive
    ServerAliveInterval 60
    ServerAliveCountMax 3
    TCPKeepAlive yes
    
    # Compression for slow connections
    Compression yes
    CompressionLevel 6
    
    # Faster authentication
    GSSAPIAuthentication no
    IdentitiesOnly yes
```

### Server Performance Tuning
```bash
# /etc/ssh/sshd_config performance settings
# Increase concurrent connections
MaxStartups 10:30:100
MaxSessions 10

# Disable DNS lookups
UseDNS no

# Optimize authentication
GSSAPIAuthentication no
UsePAM yes

# Connection keep-alive
ClientAliveInterval 300
ClientAliveCountMax 2
TCPKeepAlive yes
```

### Batch Operations
```bash
#!/bin/bash
# parallel-ssh-execution.sh - Execute commands on multiple servers in parallel

SERVERS=("web1" "web2" "web3" "db1" "db2")
COMMAND="uptime"
MAX_PARALLEL=5

execute_command() {
    local server=$1
    local cmd=$2
    
    echo "Executing on $server: $cmd"
    ssh -o ConnectTimeout=10 "$server" "$cmd" 2>&1 | sed "s/^/$server: /"
}

# Export function for parallel execution
export -f execute_command

# Execute in parallel
printf '%s\n' "${SERVERS[@]}" | xargs -n 1 -P "$MAX_PARALLEL" -I {} bash -c 'execute_command "$@"' _ {} "$COMMAND"
```

## Operational Excellence

### Configuration Management
```bash
# Standardized SSH configuration template
# ~/.ssh/config.template
Host prod-*
    User deploy
    Port 2222
    IdentityFile ~/.ssh/id_ed25519_prod
    IdentitiesOnly yes
    StrictHostKeyChecking yes
    UserKnownHostsFile ~/.ssh/known_hosts_prod
    
Host dev-*
    User developer
    Port 22
    IdentityFile ~/.ssh/id_ed25519_dev
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    LogLevel QUIET

# Configuration deployment script
#!/bin/bash
# deploy-ssh-config.sh
cp ~/.ssh/config.template ~/.ssh/config
chmod 600 ~/.ssh/config
```

### Monitoring and Logging
```bash
# Enhanced SSH logging
# /etc/ssh/sshd_config
LogLevel VERBOSE
SyslogFacility AUTH

# Log analysis script
#!/bin/bash
# ssh-log-analysis.sh

LOG_FILE="/var/log/auth.log"

echo "=== SSH Connection Analysis ==="
echo "Successful logins (last 24h):"
grep "$(date --date='1 day ago' '+%b %d')" "$LOG_FILE" | grep "Accepted" | wc -l

echo "Failed login attempts (last 24h):"
grep "$(date --date='1 day ago' '+%b %d')" "$LOG_FILE" | grep "Failed" | wc -l

echo "Top failed login sources:"
grep "Failed password" "$LOG_FILE" | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr | head -10

echo "Active sessions:"
who | grep pts
```

### Backup and Recovery
```bash
#!/bin/bash
# ssh-backup-strategy.sh

BACKUP_DIR="/backup/ssh"
DATE=$(date +%Y%m%d_%H%M%S)

# Backup SSH configuration
mkdir -p "$BACKUP_DIR/config"
cp -r /etc/ssh/ "$BACKUP_DIR/config/ssh_$DATE"
cp -r ~/.ssh/ "$BACKUP_DIR/config/user_ssh_$DATE"

# Backup host keys
mkdir -p "$BACKUP_DIR/host_keys"
cp /etc/ssh/ssh_host_* "$BACKUP_DIR/host_keys/"

# Create encrypted archive
tar -czf - "$BACKUP_DIR" | gpg --symmetric --cipher-algo AES256 --output "$BACKUP_DIR/ssh_backup_$DATE.tar.gz.gpg"

# Cleanup old backups (keep 30 days)
find "$BACKUP_DIR" -name "ssh_backup_*.tar.gz.gpg" -mtime +30 -delete

echo "SSH backup completed: ssh_backup_$DATE.tar.gz.gpg"
```

## Automation Best Practices

### Infrastructure as Code
```yaml
# Ansible SSH configuration playbook
---
- name: Configure SSH security
  hosts: all
  become: yes
  
  tasks:
    - name: Configure SSH daemon
      template:
        src: sshd_config.j2
        dest: /etc/ssh/sshd_config
        backup: yes
        validate: 'sshd -t -f %s'
      notify: restart sshd
    
    - name: Set SSH file permissions
      file:
        path: "{{ item.path }}"
        mode: "{{ item.mode }}"
        owner: root
        group: root
      loop:
        - { path: '/etc/ssh/sshd_config', mode: '0600' }
        - { path: '/etc/ssh', mode: '0755' }
    
    - name: Configure fail2ban for SSH
      template:
        src: jail.local.j2
        dest: /etc/fail2ban/jail.local
      notify: restart fail2ban
  
  handlers:
    - name: restart sshd
      service:
        name: sshd
        state: restarted
    
    - name: restart fail2ban
      service:
        name: fail2ban
        state: restarted
```

### Deployment Automation
```bash
#!/bin/bash
# automated-deployment.sh - Zero-downtime deployment with SSH

SERVERS=("web1.prod.com" "web2.prod.com" "web3.prod.com")
APP_PATH="/opt/myapp"
DEPLOY_USER="deploy"
HEALTH_CHECK_URL="http://localhost:8080/health"

deploy_to_server() {
    local server=$1
    
    echo "Deploying to $server..."
    
    # Remove from load balancer
    ssh "$DEPLOY_USER@$server" "sudo /usr/local/bin/remove-from-lb.sh"
    
    # Deploy application
    scp -r ./dist/ "$DEPLOY_USER@$server:$APP_PATH/"
    
    # Restart service
    ssh "$DEPLOY_USER@$server" "sudo systemctl restart myapp"
    
    # Health check
    local retries=0
    local max_retries=30
    
    while [[ $retries -lt $max_retries ]]; do
        if ssh "$DEPLOY_USER@$server" "curl -f $HEALTH_CHECK_URL" >/dev/null 2>&1; then
            echo "✓ Health check passed for $server"
            break
        fi
        
        ((retries++))
        sleep 10
    done
    
    if [[ $retries -eq $max_retries ]]; then
        echo "✗ Health check failed for $server"
        return 1
    fi
    
    # Add back to load balancer
    ssh "$DEPLOY_USER@$server" "sudo /usr/local/bin/add-to-lb.sh"
    
    echo "✓ Deployment completed for $server"
}

# Deploy to servers one by one
for server in "${SERVERS[@]}"; do
    if ! deploy_to_server "$server"; then
        echo "Deployment failed on $server. Stopping deployment."
        exit 1
    fi
done

echo "Deployment completed successfully on all servers!"
```

## Compliance and Auditing

### Security Compliance
```bash
# CIS Benchmark compliance script
#!/bin/bash
# ssh-cis-compliance.sh

echo "=== SSH CIS Benchmark Compliance Check ==="

# Check SSH protocol version
if grep -q "^Protocol 2" /etc/ssh/sshd_config; then
    echo "✓ SSH Protocol 2 is configured"
else
    echo "✗ SSH Protocol 2 is not configured"
fi

# Check root login
if grep -q "^PermitRootLogin no" /etc/ssh/sshd_config; then
    echo "✓ Root login is disabled"
else
    echo "✗ Root login is not disabled"
fi

# Check password authentication
if grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config; then
    echo "✓ Password authentication is disabled"
else
    echo "✗ Password authentication is not disabled"
fi

# Check SSH banner
if grep -q "^Banner" /etc/ssh/sshd_config; then
    echo "✓ SSH banner is configured"
else
    echo "✗ SSH banner is not configured"
fi
```

### Audit Logging
```bash
# SSH session recording
#!/bin/bash
# ssh-session-recorder.sh

USER_SESSION_DIR="/var/log/ssh-sessions"
SESSION_FILE="$USER_SESSION_DIR/session-$(date +%Y%m%d-%H%M%S)-${USER}-$$"

# Create session directory
mkdir -p "$USER_SESSION_DIR"

# Start session recording
script -f -q "$SESSION_FILE"

# Set proper permissions
chmod 640 "$SESSION_FILE"
chown root:adm "$SESSION_FILE"
```

### Access Review
```bash
#!/bin/bash
# ssh-access-review.sh - Generate SSH access report

REPORT_FILE="ssh-access-report-$(date +%Y%m%d).txt"

echo "SSH Access Review Report - $(date)" > "$REPORT_FILE"
echo "======================================" >> "$REPORT_FILE"

# List all users with SSH access
echo -e "\nUsers with SSH access:" >> "$REPORT_FILE"
getent passwd | awk -F: '$7 ~ /bash|sh/ {print $1}' >> "$REPORT_FILE"

# List authorized keys
echo -e "\nAuthorized keys summary:" >> "$REPORT_FILE"
for user_home in /home/*; do
    user=$(basename "$user_home")
    auth_keys="$user_home/.ssh/authorized_keys"
    
    if [[ -f "$auth_keys" ]]; then
        key_count=$(wc -l < "$auth_keys")
        echo "$user: $key_count keys" >> "$REPORT_FILE"
    fi
done

# Recent SSH connections
echo -e "\nRecent SSH connections (last 7 days):" >> "$REPORT_FILE"
grep "Accepted" /var/log/auth.log | grep "$(date --date='7 days ago' '+%b')" | tail -20 >> "$REPORT_FILE"

echo "Access review report generated: $REPORT_FILE"
```

## Disaster Recovery

### SSH Infrastructure Recovery
```bash
#!/bin/bash
# ssh-disaster-recovery.sh

BACKUP_LOCATION="/backup/ssh"
RECOVERY_LOG="/var/log/ssh-recovery.log"

recover_ssh_config() {
    echo "$(date): Starting SSH configuration recovery" >> "$RECOVERY_LOG"
    
    # Restore SSH daemon configuration
    if [[ -f "$BACKUP_LOCATION/sshd_config" ]]; then
        cp "$BACKUP_LOCATION/sshd_config" /etc/ssh/sshd_config
        chmod 600 /etc/ssh/sshd_config
        echo "$(date): SSH daemon config restored" >> "$RECOVERY_LOG"
    fi
    
    # Restore host keys
    for key_file in "$BACKUP_LOCATION"/ssh_host_*; do
        if [[ -f "$key_file" ]]; then
            cp "$key_file" /etc/ssh/
            chmod 600 "/etc/ssh/$(basename "$key_file")"
            echo "$(date): Host key $(basename "$key_file") restored" >> "$RECOVERY_LOG"
        fi
    done
    
    # Restart SSH service
    systemctl restart sshd
    
    if systemctl is-active --quiet sshd; then
        echo "$(date): SSH service restarted successfully" >> "$RECOVERY_LOG"
    else
        echo "$(date): ERROR: SSH service failed to start" >> "$RECOVERY_LOG"
        exit 1
    fi
}

# Execute recovery
recover_ssh_config
echo "SSH disaster recovery completed. Check $RECOVERY_LOG for details."
```

This comprehensive best practices guide ensures secure, performant, and maintainable SSH operations in production environments.