# SSH Administration

Comprehensive guide to SSH configuration, security, and management for DevOps environments.

## SSH Overview

### What is SSH?
SSH (Secure Shell) is a cryptographic network protocol for secure communication over unsecured networks. It provides secure remote access, file transfers, and tunneling capabilities.

### Key Features
- **Encrypted Communication**: All data is encrypted in transit
- **Authentication**: Multiple authentication methods (keys, passwords, certificates)
- **Port Forwarding**: Local and remote port tunneling
- **File Transfer**: Secure file copy (SCP/SFTP)
- **X11 Forwarding**: Remote GUI applications
- **Agent Forwarding**: Key delegation for multi-hop connections

## Directory Structure

```bash
SSH/
├── Configuration/         # SSH client and server configuration
├── Key-Management/        # SSH key generation and management
├── Security/             # Hardening and security practices
├── Tunneling/            # Port forwarding and tunneling
├── Automation/           # SSH automation and scripting
├── Troubleshooting/      # Common issues and solutions
└── Best-Practices/       # Production guidelines
```

## Quick Start

### Generate SSH Key Pair
```bash
# Generate RSA key (4096 bits)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa

# Generate Ed25519 key (recommended)
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519

# Generate with comment
ssh-keygen -t ed25519 -C "user@example.com" -f ~/.ssh/id_ed25519
```

### Copy Public Key to Remote Server
```bash
# Copy default key
ssh-copy-id user@remote-host

# Copy specific key
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@remote-host

# Copy to custom port
ssh-copy-id -p 2222 user@remote-host
```

### Basic SSH Connection
```bash
# Connect to remote host
ssh user@remote-host

# Connect with specific key
ssh -i ~/.ssh/id_ed25519 user@remote-host

# Connect to custom port
ssh -p 2222 user@remote-host
```

## Core Operations

### Key Management
```bash
# List SSH keys
ls -la ~/.ssh/

# View public key
cat ~/.ssh/id_ed25519.pub

# Add key to SSH agent
ssh-add ~/.ssh/id_ed25519

# List loaded keys
ssh-add -l

# Remove all keys from agent
ssh-add -D
```

### File Transfer
```bash
# Copy file to remote
scp file.txt user@remote-host:/path/to/destination/

# Copy file from remote
scp user@remote-host:/path/to/file.txt ./

# Copy directory recursively
scp -r directory/ user@remote-host:/path/to/destination/

# SFTP interactive session
sftp user@remote-host
```

### Port Forwarding
```bash
# Local port forwarding
ssh -L 8080:localhost:80 user@remote-host

# Remote port forwarding
ssh -R 8080:localhost:80 user@remote-host

# Dynamic port forwarding (SOCKS proxy)
ssh -D 1080 user@remote-host
```

## Security Configuration

### SSH Server Hardening
```bash
# /etc/ssh/sshd_config
Port 2222
Protocol 2
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
PrintMotd no
ClientAliveInterval 300
ClientAliveCountMax 2
MaxAuthTries 3
MaxSessions 2
```

### Client Configuration
```bash
# ~/.ssh/config
Host production-server
    HostName prod.example.com
    User deploy
    Port 2222
    IdentityFile ~/.ssh/prod_key
    IdentitiesOnly yes
    
Host *.example.com
    User admin
    IdentityFile ~/.ssh/company_key
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

## Advanced Features

### SSH Agent and Key Management
```bash
# Start SSH agent
eval $(ssh-agent)

# Add key with passphrase
ssh-add ~/.ssh/id_ed25519

# Forward SSH agent
ssh -A user@jump-host

# Agent forwarding in config
Host jump-server
    ForwardAgent yes
```

### Jump Hosts and ProxyJump
```bash
# Connect through jump host
ssh -J jump-host target-host

# Multiple jump hosts
ssh -J jump1,jump2 target-host

# ProxyJump in config
Host target-server
    HostName 10.0.1.100
    ProxyJump jump-server
    User admin
```

## Automation and Scripting

### Automated SSH Operations
```bash
#!/bin/bash
# deploy.sh - Automated deployment script

SERVERS=("web1.example.com" "web2.example.com" "web3.example.com")
DEPLOY_USER="deploy"
APP_PATH="/opt/myapp"

for server in "${SERVERS[@]}"; do
    echo "Deploying to $server..."
    
    # Copy application files
    scp -r ./dist/ $DEPLOY_USER@$server:$APP_PATH/
    
    # Restart service
    ssh $DEPLOY_USER@$server "sudo systemctl restart myapp"
    
    # Verify deployment
    if ssh $DEPLOY_USER@$server "curl -f http://localhost:8080/health"; then
        echo "✓ Deployment successful on $server"
    else
        echo "✗ Deployment failed on $server"
        exit 1
    fi
done
```

### SSH Key Distribution
```bash
#!/bin/bash
# distribute-keys.sh

PUBLIC_KEY="~/.ssh/id_ed25519.pub"
SERVERS_FILE="servers.txt"

while IFS= read -r server; do
    echo "Adding key to $server..."
    ssh-copy-id -i $PUBLIC_KEY $server
done < "$SERVERS_FILE"
```

## Monitoring and Logging

### SSH Connection Monitoring
```bash
# View active SSH sessions
who
w

# Check SSH logs
sudo tail -f /var/log/auth.log  # Debian/Ubuntu
sudo tail -f /var/log/secure    # RHEL/CentOS

# Monitor failed login attempts
sudo grep "Failed password" /var/log/auth.log

# Check successful logins
sudo grep "Accepted" /var/log/auth.log
```

### Connection Statistics
```bash
# Show SSH connection statistics
ss -tuln | grep :22
netstat -tuln | grep :22

# Active SSH connections
ss -o state established '( dport = :22 or sport = :22 )'
```

This comprehensive SSH guide provides secure remote access and automation capabilities for DevOps environments.