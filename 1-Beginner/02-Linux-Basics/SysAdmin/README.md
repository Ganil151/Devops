# System Administration for DevOps

Complete guide to system administration practices, tools, and methodologies essential for DevOps professionals.

## System Administration Fundamentals

### Core Responsibilities
```bash
# Infrastructure Management
- Server provisioning and configuration
- Operating system maintenance
- Hardware monitoring and management
- Capacity planning and scaling

# Security Administration
- User access management
- Security patch management
- Firewall and network security
- Compliance and auditing

# Performance Optimization
- System performance monitoring
- Resource utilization analysis
- Bottleneck identification
- Performance tuning

# Backup and Recovery
- Data backup strategies
- Disaster recovery planning
- Business continuity
- Recovery testing
```

## User and Access Management

### Identity and Access Management (IAM)
```bash
# Linux User Management
# Create user with home directory
useradd -m -s /bin/bash -G sudo,docker username

# Set password policy
chage -M 90 -m 7 -W 7 username  # Max 90 days, min 7 days, warn 7 days

# SSH Key Management
ssh-keygen -t rsa -b 4096 -C "user@company.com"
ssh-copy-id user@server

# Sudo Configuration (/etc/sudoers)
username ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx
%developers ALL=(ALL) NOPASSWD: /usr/local/bin/deploy.sh

# Group Management
groupadd -g 1001 developers
usermod -aG developers username
gpasswd -d username developers  # Remove from group
```

### LDAP Integration
```bash
# LDAP Client Configuration
# /etc/ldap/ldap.conf
BASE    dc=company,dc=com
URI     ldap://ldap.company.com
TLS_CACERT /etc/ssl/certs/ca-certificates.crt

# PAM LDAP Configuration
# /etc/pam.d/common-auth
auth    [success=2 default=ignore]      pam_unix.so nullok_secure
auth    [success=1 default=ignore]      pam_ldap.so use_first_pass
auth    requisite                       pam_deny.so

# NSS LDAP Configuration
# /etc/nsswitch.conf
passwd:         files ldap
group:          files ldap
shadow:         files ldap
```

## System Monitoring and Alerting

### Monitoring Stack
```bash
# Prometheus Configuration
# /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

scrape_configs:
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
  
  - job_name: 'application'
    static_configs:
      - targets: ['app1:8080', 'app2:8080']

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093
```

### System Metrics Collection
```bash
# Node Exporter Installation
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar xvfz node_exporter-1.3.1.linux-amd64.tar.gz
sudo cp node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/

# Systemd Service
# /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
```

### Log Management
```bash
# Centralized Logging with ELK Stack
# Elasticsearch Configuration
# /etc/elasticsearch/elasticsearch.yml
cluster.name: logging-cluster
node.name: node-1
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
network.host: 0.0.0.0
http.port: 9200

# Logstash Configuration
# /etc/logstash/conf.d/syslog.conf
input {
  beats {
    port => 5044
  }
}

filter {
  if [fileset][module] == "system" {
    if [fileset][name] == "auth" {
      grok {
        match => { "message" => "%{SYSLOGTIMESTAMP:timestamp} %{IPORHOST:server} %{PROG:program}: %{GREEDYDATA:message}" }
      }
    }
  }
}

output {
  elasticsearch {
    hosts => ["localhost:9200"]
    index => "syslog-%{+YYYY.MM.dd}"
  }
}

# Filebeat Configuration
# /etc/filebeat/filebeat.yml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/*.log
    - /var/log/nginx/*.log

output.logstash:
  hosts: ["logstash:5044"]
```

## Backup and Disaster Recovery

### Backup Strategies
```bash
# Full System Backup with rsync
#!/bin/bash
BACKUP_DIR="/backup/$(date +%Y%m%d)"
SOURCE_DIRS="/etc /home /var/www /opt"

mkdir -p $BACKUP_DIR

for dir in $SOURCE_DIRS; do
    rsync -avz --delete $dir $BACKUP_DIR/
done

# Database backup
mysqldump --all-databases --single-transaction > $BACKUP_DIR/mysql_backup.sql

# Compress backup
tar -czf $BACKUP_DIR.tar.gz $BACKUP_DIR
rm -rf $BACKUP_DIR

# Upload to cloud storage
aws s3 cp $BACKUP_DIR.tar.gz s3://company-backups/
```

### Automated Backup with Bacula
```bash
# Bacula Director Configuration
# /etc/bacula/bacula-dir.conf
Director {
  Name = backup-dir
  DIRport = 9101
  QueryFile = "/etc/bacula/scripts/query.sql"
  WorkingDirectory = "/var/lib/bacula"
  PidDirectory = "/run/bacula"
  Maximum Concurrent Jobs = 20
  Password = "backup-password"
  Messages = Daemon
}

Job {
  Name = "BackupClient1"
  Type = Backup
  Level = Incremental
  Client = client1-fd
  FileSet = "Full Set"
  Schedule = "WeeklyCycle"
  Storage = File1
  Messages = Standard
  Pool = File
  SpoolAttributes = yes
  Priority = 10
  Write Bootstrap = "/var/lib/bacula/%c.bsr"
}

# File Daemon Configuration
# /etc/bacula/bacula-fd.conf
FileDaemon {
  Name = client1-fd
  FDport = 9102
  WorkingDirectory = /var/lib/bacula
  Pid Directory = /run/bacula
  Maximum Concurrent Jobs = 20
  Plugin Directory = /usr/lib/bacula
}
```

### Disaster Recovery Planning
```bash
# Recovery Time Objective (RTO) and Recovery Point Objective (RPO)
# RTO: Maximum acceptable downtime
# RPO: Maximum acceptable data loss

# Disaster Recovery Procedures
1. Incident Detection and Assessment
2. Disaster Declaration
3. Recovery Team Activation
4. Infrastructure Recovery
5. Data Recovery
6. Application Recovery
7. Testing and Validation
8. Failback Procedures

# Recovery Testing Script
#!/bin/bash
echo "Starting DR test at $(date)"

# Test database recovery
mysql < /backup/latest/mysql_backup.sql
if [ $? -eq 0 ]; then
    echo "Database recovery: SUCCESS"
else
    echo "Database recovery: FAILED"
    exit 1
fi

# Test application deployment
systemctl start nginx
systemctl start application
sleep 30

# Test application health
curl -f http://localhost/health
if [ $? -eq 0 ]; then
    echo "Application health check: SUCCESS"
else
    echo "Application health check: FAILED"
fi

echo "DR test completed at $(date)"
```

## Security Hardening

### System Security
```bash
# Security Updates
# Automatic security updates (Ubuntu)
echo 'Unattended-Upgrade::Automatic-Reboot "false";' >> /etc/apt/apt.conf.d/50unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades

# Kernel Security
# /etc/sysctl.conf
# Disable IP forwarding
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# Disable ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0

# Enable SYN flood protection
net.ipv4.tcp_syncookies = 1

# Disable source routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
```

### File System Security
```bash
# File Permissions Audit
find / -type f -perm -4000 -ls  # Find SUID files
find / -type f -perm -2000 -ls  # Find SGID files
find / -type f -perm -1000 -ls  # Find sticky bit files

# Secure Mount Options
# /etc/fstab
/dev/sda1 / ext4 defaults,nodev,nosuid 0 1
/dev/sda2 /tmp ext4 defaults,nodev,nosuid,noexec 0 2
/dev/sda3 /var ext4 defaults,nodev 0 2

# File Integrity Monitoring with AIDE
aide --init
mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
aide --check  # Check for changes
```

### Network Security
```bash
# Firewall Configuration (iptables)
#!/bin/bash
# Flush existing rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

# Default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow SSH (change port as needed)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP/HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Save rules
iptables-save > /etc/iptables/rules.v4

# Fail2ban Configuration
# /etc/fail2ban/jail.local
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3

[nginx-http-auth]
enabled = true
filter = nginx-http-auth
logpath = /var/log/nginx/error.log
maxretry = 3
```

## Performance Tuning

### System Performance Analysis
```bash
# Performance Monitoring Tools
# CPU Analysis
top -p $(pgrep -d',' nginx)  # Monitor specific processes
htop                         # Interactive process viewer
sar -u 1 10                 # CPU utilization over time

# Memory Analysis
free -h                     # Memory usage
vmstat 1 5                  # Virtual memory statistics
pmap -x PID                 # Process memory map

# I/O Analysis
iostat -x 1 5              # I/O statistics
iotop                       # I/O usage by process
lsof +D /var/log           # Files open in directory

# Network Analysis
netstat -i                  # Network interface statistics
ss -s                       # Socket statistics summary
iftop -i eth0              # Network bandwidth usage
```

### System Optimization
```bash
# Kernel Parameter Tuning
# /etc/sysctl.conf
# Virtual memory tuning
vm.swappiness = 10          # Reduce swap usage
vm.dirty_ratio = 15         # Dirty page cache ratio
vm.dirty_background_ratio = 5

# Network tuning
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 65536 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# File system tuning
fs.file-max = 65536         # Maximum open files

# Apply changes
sysctl -p

# I/O Scheduler Optimization
echo mq-deadline > /sys/block/sda/queue/scheduler

# CPU Governor Settings
echo performance > /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

## Automation and Scripting

### System Automation
```bash
# Health Check Script
#!/bin/bash
LOGFILE="/var/log/health-check.log"
ALERT_EMAIL="admin@company.com"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOGFILE
}

check_service() {
    local service=$1
    if systemctl is-active --quiet $service; then
        log_message "Service $service is running"
        return 0
    else
        log_message "ERROR: Service $service is not running"
        systemctl restart $service
        sleep 5
        if systemctl is-active --quiet $service; then
            log_message "Service $service restarted successfully"
        else
            log_message "CRITICAL: Failed to restart $service"
            echo "Service $service failed to restart on $(hostname)" | mail -s "Service Alert" $ALERT_EMAIL
        fi
        return 1
    fi
}

check_disk_space() {
    local threshold=90
    df -h | awk 'NR>1 {print $5 " " $6}' | while read output; do
        usage=$(echo $output | awk '{print $1}' | sed 's/%//')
        partition=$(echo $output | awk '{print $2}')
        if [ $usage -ge $threshold ]; then
            log_message "WARNING: Disk usage on $partition is ${usage}%"
            echo "Disk usage on $partition is ${usage}% on $(hostname)" | mail -s "Disk Space Alert" $ALERT_EMAIL
        fi
    done
}

# Main execution
log_message "Starting health check"
check_service nginx
check_service mysql
check_disk_space
log_message "Health check completed"
```

### Configuration Management
```yaml
# Ansible Playbook for System Configuration
---
- name: System Configuration Playbook
  hosts: all
  become: yes
  vars:
    ntp_servers:
      - 0.pool.ntp.org
      - 1.pool.ntp.org
    
  tasks:
    - name: Update package cache
      apt:
        update_cache: yes
        cache_valid_time: 3600
      when: ansible_os_family == "Debian"
    
    - name: Install essential packages
      package:
        name:
          - htop
          - vim
          - curl
          - wget
          - unzip
        state: present
    
    - name: Configure NTP
      template:
        src: ntp.conf.j2
        dest: /etc/ntp.conf
        backup: yes
      notify: restart ntp
    
    - name: Configure SSH
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^#?PermitRootLogin'
        line: 'PermitRootLogin no'
        backup: yes
      notify: restart ssh
    
    - name: Set up log rotation
      copy:
        content: |
          /var/log/application/*.log {
              daily
              missingok
              rotate 30
              compress
              delaycompress
              notifempty
              create 0644 app app
              postrotate
                  systemctl reload application
              endscript
          }
        dest: /etc/logrotate.d/application
  
  handlers:
    - name: restart ntp
      service:
        name: ntp
        state: restarted
    
    - name: restart ssh
      service:
        name: ssh
        state: restarted
```

This comprehensive system administration guide provides DevOps professionals with essential knowledge and practical tools for managing modern infrastructure efficiently and securely.