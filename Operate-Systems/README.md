# Operating Systems for DevOps

Complete guide to operating systems commonly used in DevOps environments, focusing on Linux distributions and Windows Server.

## Linux Distributions

### Ubuntu
```bash
# Characteristics
- Debian-based distribution
- LTS (Long Term Support) versions
- Extensive package repository
- Strong community support
- Default choice for many cloud providers

# Package Management
apt update && apt upgrade
apt install nginx docker.io
apt search package-name
apt remove package-name

# System Services
systemctl start nginx
systemctl enable nginx
systemctl status nginx
systemctl restart nginx

# Version Information
lsb_release -a
cat /etc/os-release
```

### CentOS/RHEL/Rocky Linux
```bash
# Characteristics
- Red Hat ecosystem
- Enterprise-focused
- RPM package management
- SELinux security
- Long support cycles

# Package Management (YUM/DNF)
yum update
yum install httpd
yum search package-name
yum remove package-name

# DNF (newer systems)
dnf update
dnf install nginx
dnf group install "Development Tools"

# System Services
systemctl start httpd
systemctl enable httpd
firewall-cmd --permanent --add-service=http
firewall-cmd --reload
```

### Amazon Linux
```bash
# Characteristics
- AWS-optimized distribution
- Based on RHEL/CentOS
- Pre-configured for AWS services
- Regular security updates
- Optimized for cloud workloads

# Package Management
yum update
amazon-linux-extras install docker
yum install aws-cli

# AWS Integration
# Pre-installed AWS CLI
aws configure
aws s3 ls

# CloudWatch agent
yum install amazon-cloudwatch-agent
```

### Alpine Linux
```bash
# Characteristics
- Security-oriented
- Lightweight (5MB base image)
- musl libc and busybox
- Popular for containers
- Package manager: apk

# Package Management
apk update
apk add nginx
apk search package-name
apk del package-name

# Container Usage
FROM alpine:latest
RUN apk add --no-cache nginx
COPY nginx.conf /etc/nginx/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## Linux System Administration

### File System Management
```bash
# Disk Usage and Management
df -h                    # Disk space usage
du -sh /var/log         # Directory size
lsblk                   # Block devices
fdisk -l                # Partition information

# File System Operations
mkfs.ext4 /dev/sdb1     # Create filesystem
mount /dev/sdb1 /mnt    # Mount filesystem
umount /mnt             # Unmount filesystem

# Persistent Mounts (/etc/fstab)
/dev/sdb1 /data ext4 defaults 0 2

# LVM (Logical Volume Management)
pvcreate /dev/sdb       # Create physical volume
vgcreate vg01 /dev/sdb  # Create volume group
lvcreate -L 10G -n lv01 vg01  # Create logical volume
mkfs.ext4 /dev/vg01/lv01      # Format logical volume
```

### Process Management
```bash
# Process Monitoring
ps aux                  # All processes
top                     # Real-time process viewer
htop                    # Enhanced process viewer
pstree                  # Process tree

# Process Control
kill PID               # Terminate process
killall process_name   # Kill by name
pkill -f pattern       # Kill by pattern
nohup command &        # Run in background

# Job Control
jobs                   # List active jobs
bg %1                  # Background job
fg %1                  # Foreground job
disown %1              # Detach job
```

### User and Permission Management
```bash
# User Management
useradd -m -s /bin/bash username
usermod -aG sudo username
passwd username
userdel -r username

# Group Management
groupadd developers
usermod -aG developers username
groups username

# File Permissions
chmod 755 file.sh      # rwxr-xr-x
chmod u+x file.sh      # Add execute for user
chown user:group file  # Change ownership
chgrp group file       # Change group

# Special Permissions
chmod +t /tmp          # Sticky bit
chmod g+s /shared      # SGID
chmod u+s /usr/bin/sudo # SUID
```

### Network Configuration
```bash
# Network Interfaces
ip addr show           # Show IP addresses
ip route show          # Show routing table
ip link show           # Show network interfaces

# Network Configuration (systemd-networkd)
# /etc/systemd/network/eth0.network
[Match]
Name=eth0

[Network]
DHCP=yes
DNS=8.8.8.8
DNS=8.8.4.4

# Network Configuration (netplan - Ubuntu)
# /etc/netplan/01-network-manager-all.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

## Windows Server

### PowerShell Administration
```powershell
# System Information
Get-ComputerInfo
Get-WmiObject -Class Win32_OperatingSystem
Get-Service | Where-Object {$_.Status -eq "Running"}

# User Management
New-LocalUser -Name "devops" -Password (ConvertTo-SecureString "Password123!" -AsPlainText -Force)
Add-LocalGroupMember -Group "Administrators" -Member "devops"
Get-LocalUser
Remove-LocalUser -Name "devops"

# Service Management
Get-Service -Name "IIS"
Start-Service -Name "W3SVC"
Stop-Service -Name "W3SVC"
Set-Service -Name "W3SVC" -StartupType Automatic

# Windows Features
Get-WindowsFeature
Install-WindowsFeature -Name IIS-WebServerRole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpRedirect
```

### IIS (Internet Information Services)
```powershell
# IIS Management
Import-Module WebAdministration

# Create Website
New-Website -Name "MyApp" -Port 80 -PhysicalPath "C:\inetpub\wwwroot\myapp"

# Application Pool
New-WebAppPool -Name "MyAppPool"
Set-ItemProperty -Path "IIS:\AppPools\MyAppPool" -Name processModel.identityType -Value ApplicationPoolIdentity

# SSL Certificate
New-SelfSignedCertificate -DnsName "myapp.local" -CertStoreLocation "cert:\LocalMachine\My"
New-WebBinding -Name "MyApp" -Protocol https -Port 443
```

### Active Directory
```powershell
# Domain Controller Setup
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName "company.local" -SafeModeAdministratorPassword (ConvertTo-SecureString "Password123!" -AsPlainText -Force)

# User Management
New-ADUser -Name "John Doe" -SamAccountName "jdoe" -UserPrincipalName "jdoe@company.local" -Path "OU=Users,DC=company,DC=local"
Add-ADGroupMember -Identity "Domain Admins" -Members "jdoe"

# Group Policy
New-GPO -Name "Security Policy"
Set-GPRegistryValue -Name "Security Policy" -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ValueName "NoAutoUpdate" -Type DWord -Value 1
```

## Container Operating Systems

### Container-Optimized OS
```bash
# CoreOS/Flatcar Linux
- Immutable infrastructure
- Automatic updates
- Container-focused
- Minimal attack surface

# Docker Desktop
- Windows and macOS
- Development environment
- Kubernetes integration
- Easy container management

# Rancher OS
- Lightweight container OS
- Docker as init system
- Minimal resource usage
- Cloud-native design
```

### Container Runtime Security
```bash
# Security Best Practices
# Run as non-root user
FROM alpine:latest
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup
USER appuser

# Read-only filesystem
docker run --read-only --tmpfs /tmp myapp

# Security scanning
docker scan myapp:latest
trivy image myapp:latest

# Runtime security
docker run --security-opt=no-new-privileges myapp
docker run --cap-drop=ALL --cap-add=NET_BIND_SERVICE myapp
```

## System Monitoring and Logging

### System Metrics
```bash
# CPU and Memory
free -h                # Memory usage
vmstat 1 5            # Virtual memory statistics
iostat -x 1 5         # I/O statistics
sar -u 1 5            # CPU utilization

# Disk I/O
iotop                 # I/O usage by process
lsof                  # Open files
fuser -v /path        # Processes using file/directory

# Network
netstat -tuln         # Network connections
ss -tuln              # Socket statistics
iftop                 # Network bandwidth usage
```

### Log Management
```bash
# System Logs (systemd)
journalctl -u nginx   # Service logs
journalctl -f         # Follow logs
journalctl --since "2023-01-01"
journalctl -p err     # Error level logs

# Traditional Syslog
tail -f /var/log/syslog
grep "error" /var/log/apache2/error.log
logrotate /etc/logrotate.conf

# Centralized Logging
# rsyslog configuration
*.info;mail.none;authpriv.none;cron.none    @logserver:514

# Fluentd configuration
<source>
  @type tail
  path /var/log/nginx/access.log
  pos_file /var/log/fluentd/nginx.log.pos
  tag nginx.access
  format nginx
</source>
```

## Performance Tuning

### Linux Performance Optimization
```bash
# Kernel Parameters (/etc/sysctl.conf)
# Network performance
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 65536 16777216

# File system performance
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
vm.swappiness = 10

# Security
kernel.dmesg_restrict = 1
net.ipv4.conf.all.send_redirects = 0

# Apply changes
sysctl -p
```

### Storage Performance
```bash
# I/O Scheduler
echo mq-deadline > /sys/block/sda/queue/scheduler

# File System Tuning
# ext4 mount options
/dev/sda1 /data ext4 defaults,noatime,data=writeback 0 2

# XFS tuning
mkfs.xfs -f -d agcount=32 /dev/sdb1

# SSD Optimization
fstrim -v /                # Manual TRIM
echo 'fstrim -v /' | crontab -e  # Scheduled TRIM
```

## Automation and Configuration Management

### System Automation
```bash
# Cron Jobs
# Edit crontab
crontab -e

# Examples
0 2 * * * /usr/local/bin/backup.sh
*/5 * * * * /usr/local/bin/health-check.sh
0 0 1 * * /usr/local/bin/monthly-cleanup.sh

# Systemd Timers
# /etc/systemd/system/backup.timer
[Unit]
Description=Run backup daily

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

### Configuration Management
```yaml
# Ansible Playbook
---
- hosts: webservers
  become: yes
  tasks:
    - name: Install nginx
      package:
        name: nginx
        state: present
    
    - name: Start nginx service
      service:
        name: nginx
        state: started
        enabled: yes
    
    - name: Configure firewall
      ufw:
        rule: allow
        port: '80'
        proto: tcp
```

This comprehensive operating systems guide provides DevOps professionals with essential knowledge for managing Linux and Windows environments in modern infrastructure.