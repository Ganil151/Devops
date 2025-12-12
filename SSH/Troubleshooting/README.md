# SSH Troubleshooting

Comprehensive guide to diagnosing and resolving SSH connection issues and problems.

## Common Connection Issues

### Connection Refused

#### Symptoms
```bash
ssh: connect to host example.com port 22: Connection refused
```

#### Diagnosis and Solutions
```bash
# Check if SSH service is running
sudo systemctl status sshd
sudo systemctl status ssh  # Ubuntu/Debian

# Start SSH service if stopped
sudo systemctl start sshd
sudo systemctl enable sshd

# Check SSH port configuration
sudo grep "^Port" /etc/ssh/sshd_config

# Test connectivity to SSH port
telnet example.com 22
nc -zv example.com 22

# Check firewall rules
sudo ufw status
sudo iptables -L INPUT | grep ssh

# Allow SSH through firewall
sudo ufw allow ssh
sudo ufw allow 22/tcp
```

### Connection Timeout

#### Symptoms
```bash
ssh: connect to host example.com port 22: Connection timed out
```

#### Diagnosis and Solutions
```bash
# Test network connectivity
ping example.com
traceroute example.com

# Check if port is filtered
nmap -p 22 example.com

# Test from different network
ssh -o ConnectTimeout=10 user@example.com

# Check client-side firewall
sudo iptables -L OUTPUT | grep ssh

# Use verbose mode for debugging
ssh -v user@example.com
```

### Permission Denied

#### Symptoms
```bash
user@example.com: Permission denied (publickey).
user@example.com: Permission denied (publickey,password).
```

#### Key-Based Authentication Issues
```bash
# Check key permissions
ls -la ~/.ssh/
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# Verify key is loaded in agent
ssh-add -l

# Add key to agent
ssh-add ~/.ssh/id_rsa

# Test key authentication
ssh -i ~/.ssh/id_rsa -o PreferredAuthentications=publickey user@example.com

# Check authorized_keys on server
ls -la ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Verify key format
ssh-keygen -l -f ~/.ssh/id_rsa.pub
```

#### Password Authentication Issues
```bash
# Check if password auth is enabled
sudo grep "PasswordAuthentication" /etc/ssh/sshd_config

# Enable password authentication temporarily
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Force password authentication
ssh -o PreferredAuthentications=password user@example.com

# Check user account status
sudo passwd -S username
sudo chage -l username
```

## Authentication Debugging

### Verbose SSH Output

#### Client-Side Debugging
```bash
# Basic verbose output
ssh -v user@example.com

# More verbose output
ssh -vv user@example.com

# Maximum verbosity
ssh -vvv user@example.com

# Save debug output to file
ssh -vvv user@example.com 2>&1 | tee ssh-debug.log
```

#### Server-Side Debugging
```bash
# Increase SSH daemon log level
sudo sed -i 's/#LogLevel INFO/LogLevel DEBUG/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Monitor SSH logs in real-time
sudo tail -f /var/log/auth.log  # Debian/Ubuntu
sudo tail -f /var/log/secure    # RHEL/CentOS

# Run sshd in debug mode (test mode)
sudo /usr/sbin/sshd -d -p 2222
```

### Key Authentication Troubleshooting

#### Key Validation Script
```bash
#!/bin/bash
# ssh-key-debug.sh

USER="$1"
HOST="$2"
KEY_FILE="$3"

if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <user> <host> <key_file>"
    exit 1
fi

echo "SSH Key Authentication Debug"
echo "============================"

# Check local key file
echo "1. Checking local key file..."
if [[ -f "$KEY_FILE" ]]; then
    echo "✓ Key file exists: $KEY_FILE"
    
    # Check permissions
    PERMS=$(stat -c "%a" "$KEY_FILE")
    if [[ "$PERMS" == "600" ]]; then
        echo "✓ Key permissions correct (600)"
    else
        echo "✗ Key permissions incorrect ($PERMS), should be 600"
        echo "  Fix: chmod 600 $KEY_FILE"
    fi
    
    # Check key format
    if ssh-keygen -l -f "$KEY_FILE" &>/dev/null; then
        echo "✓ Key format valid"
        ssh-keygen -l -f "$KEY_FILE"
    else
        echo "✗ Invalid key format"
    fi
else
    echo "✗ Key file not found: $KEY_FILE"
    exit 1
fi

# Check SSH agent
echo -e "\n2. Checking SSH agent..."
if ssh-add -l &>/dev/null; then
    echo "✓ SSH agent running"
    if ssh-add -l | grep -q "$KEY_FILE"; then
        echo "✓ Key loaded in agent"
    else
        echo "! Key not loaded in agent"
        echo "  Fix: ssh-add $KEY_FILE"
    fi
else
    echo "! SSH agent not running"
    echo "  Fix: eval \$(ssh-agent) && ssh-add $KEY_FILE"
fi

# Test connection
echo -e "\n3. Testing connection..."
ssh -o BatchMode=yes -o ConnectTimeout=5 -i "$KEY_FILE" "$USER@$HOST" exit
if [[ $? -eq 0 ]]; then
    echo "✓ SSH connection successful"
else
    echo "✗ SSH connection failed"
    echo "  Run with verbose: ssh -vvv -i $KEY_FILE $USER@$HOST"
fi
```

## Network and Connectivity Issues

### Network Diagnostics

#### Connection Testing Script
```bash
#!/bin/bash
# ssh-network-test.sh

HOST="$1"
PORT="${2:-22}"

if [[ -z "$HOST" ]]; then
    echo "Usage: $0 <host> [port]"
    exit 1
fi

echo "SSH Network Diagnostics for $HOST:$PORT"
echo "======================================="

# Basic connectivity
echo "1. Testing basic connectivity..."
if ping -c 3 "$HOST" &>/dev/null; then
    echo "✓ Host is reachable via ping"
else
    echo "✗ Host unreachable via ping"
fi

# DNS resolution
echo -e "\n2. Testing DNS resolution..."
if nslookup "$HOST" &>/dev/null; then
    echo "✓ DNS resolution successful"
    nslookup "$HOST" | grep "Address:"
else
    echo "✗ DNS resolution failed"
fi

# Port connectivity
echo -e "\n3. Testing port connectivity..."
if nc -zv "$HOST" "$PORT" 2>&1 | grep -q "succeeded"; then
    echo "✓ Port $PORT is open"
else
    echo "✗ Port $PORT is closed or filtered"
fi

# Traceroute
echo -e "\n4. Network path analysis..."
traceroute -m 10 "$HOST" 2>/dev/null | head -10

# MTU discovery
echo -e "\n5. MTU discovery..."
ping -M do -s 1472 -c 1 "$HOST" &>/dev/null
if [[ $? -eq 0 ]]; then
    echo "✓ Standard MTU (1500) works"
else
    echo "! MTU issues detected, trying smaller sizes..."
    for size in 1400 1300 1200; do
        if ping -M do -s $((size-28)) -c 1 "$HOST" &>/dev/null; then
            echo "✓ MTU $size works"
            break
        fi
    done
fi
```

### Firewall and Security

#### Firewall Diagnostics
```bash
# Check local firewall rules
sudo iptables -L -n -v | grep -E "(ssh|22)"
sudo ufw status verbose

# Check remote firewall (if accessible)
nmap -p 22 target-host
nmap -sS -O target-host

# Test from different source IPs
ssh -b source-ip user@target-host

# Check fail2ban status
sudo fail2ban-client status sshd
sudo fail2ban-client get sshd banip
```

## Performance Issues

### Slow Connections

#### Connection Speed Diagnostics
```bash
# Test connection establishment time
time ssh -o BatchMode=yes user@host exit

# Disable DNS lookups
ssh -o UseDNS=no user@host

# Use compression for slow links
ssh -C user@host

# Optimize cipher selection
ssh -c aes128-ctr user@host

# Test with different algorithms
ssh -o Ciphers=aes128-gcm@openssh.com user@host
```

#### Performance Optimization
```bash
# ~/.ssh/config optimizations
Host slow-server
    HostName slow.example.com
    User admin
    
    # Connection multiplexing
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 600
    
    # Compression
    Compression yes
    
    # Fast ciphers
    Ciphers aes128-gcm@openssh.com,aes128-ctr
    
    # Disable unnecessary features
    GSSAPIAuthentication no
    UseDNS no
    
    # Keep-alive
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

### High Latency Connections

#### Latency Optimization
```bash
# Enable TCP keep-alive
ssh -o TCPKeepAlive=yes user@host

# Adjust SSH keep-alive
ssh -o ServerAliveInterval=30 -o ServerAliveCountMax=3 user@host

# Use connection multiplexing
mkdir -p ~/.ssh/sockets
ssh -M -S ~/.ssh/sockets/host user@host

# Subsequent connections use existing socket
ssh -S ~/.ssh/sockets/host user@host
```

## File Transfer Issues

### SCP/SFTP Problems

#### Transfer Diagnostics
```bash
# Test basic file transfer
echo "test" | ssh user@host 'cat > /tmp/test.txt'

# Check disk space on remote
ssh user@host 'df -h'

# Test with verbose SCP
scp -v file.txt user@host:/tmp/

# Use rsync for better error handling
rsync -avz -e ssh file.txt user@host:/tmp/

# Check file permissions
ssh user@host 'ls -la /tmp/test.txt'
```

#### Large File Transfer Optimization
```bash
# Use compression
scp -C large-file.tar user@host:/tmp/

# Resume interrupted transfers with rsync
rsync -avz --partial --progress large-file.tar user@host:/tmp/

# Parallel transfers
parallel -j 4 scp {} user@host:/tmp/ ::: file1 file2 file3 file4
```

## SSH Agent Issues

### Agent Troubleshooting

#### Agent Diagnostics Script
```bash
#!/bin/bash
# ssh-agent-debug.sh

echo "SSH Agent Diagnostics"
echo "===================="

# Check if agent is running
if [[ -n "$SSH_AUTH_SOCK" ]]; then
    echo "✓ SSH_AUTH_SOCK is set: $SSH_AUTH_SOCK"
    
    if [[ -S "$SSH_AUTH_SOCK" ]]; then
        echo "✓ Agent socket exists"
        
        # Test agent communication
        if ssh-add -l &>/dev/null; then
            echo "✓ Agent is responsive"
            
            # List loaded keys
            KEY_COUNT=$(ssh-add -l | wc -l)
            echo "✓ Loaded keys: $KEY_COUNT"
            ssh-add -l
        else
            echo "✗ Agent not responsive"
            echo "  Try: ssh-agent bash"
        fi
    else
        echo "✗ Agent socket doesn't exist"
    fi
else
    echo "✗ SSH_AUTH_SOCK not set"
    echo "  Try: eval \$(ssh-agent)"
fi

# Check agent forwarding
echo -e "\nAgent Forwarding Test:"
if ssh -A user@host 'ssh-add -l' 2>/dev/null; then
    echo "✓ Agent forwarding works"
else
    echo "✗ Agent forwarding failed"
    echo "  Check: ForwardAgent yes in ~/.ssh/config"
fi
```

## Log Analysis

### SSH Log Parser
```bash
#!/bin/bash
# ssh-log-analyzer.sh

LOG_FILE="${1:-/var/log/auth.log}"

if [[ ! -f "$LOG_FILE" ]]; then
    echo "Log file not found: $LOG_FILE"
    exit 1
fi

echo "SSH Log Analysis Report"
echo "======================"

# Connection attempts
echo -e "\nConnection Attempts (last 24h):"
grep "$(date --date='1 day ago' '+%b %d')" "$LOG_FILE" | \
grep "sshd.*Connection from" | \
awk '{print $NF}' | sort | uniq -c | sort -nr

# Failed authentication
echo -e "\nFailed Authentication Attempts:"
grep "Failed password\|Failed publickey" "$LOG_FILE" | \
awk '{print $(NF-3), $NF}' | sort | uniq -c | sort -nr | head -10

# Successful logins
echo -e "\nSuccessful Logins (last 24h):"
grep "$(date --date='1 day ago' '+%b %d')" "$LOG_FILE" | \
grep "Accepted password\|Accepted publickey" | \
awk '{print $9, $11}' | sort | uniq -c

# Disconnection reasons
echo -e "\nDisconnection Reasons:"
grep "Disconnected from" "$LOG_FILE" | \
awk '{for(i=4;i<=NF;i++) printf "%s ", $i; print ""}' | \
sort | uniq -c | sort -nr
```

This comprehensive SSH troubleshooting guide provides systematic approaches to diagnosing and resolving SSH connectivity, authentication, and performance issues.