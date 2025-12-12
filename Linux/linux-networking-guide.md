# Linux Networking Guide for DevOps Engineers

## Network Configuration and Management

### Network Interface Configuration

#### Using `ip` Command (Modern Approach)
```bash
# View network interfaces
ip link show                      # Show all network interfaces
ip addr show                      # Show IP addresses for all interfaces
ip addr show eth0                 # Show specific interface details

# Configure IP addresses
ip addr add 192.168.1.100/24 dev eth0    # Add IP address
ip addr del 192.168.1.100/24 dev eth0    # Remove IP address
ip link set eth0 up               # Bring interface up
ip link set eth0 down             # Bring interface down

# Configure routes
ip route show                     # Show routing table
ip route add default via 192.168.1.1     # Add default gateway
ip route add 10.0.0.0/8 via 192.168.1.1  # Add specific route
ip route del 10.0.0.0/8           # Delete route
```

#### Network Configuration Files

##### Ubuntu/Debian - Netplan
```yaml
# /etc/netplan/01-network-manager-all.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: false
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
        search:
          - example.com

# Apply configuration
sudo netplan apply
sudo netplan try    # Test configuration with rollback
```

##### Red Hat/CentOS - Network Scripts
```bash
# /etc/sysconfig/network-scripts/ifcfg-eth0
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=static
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
NAME=eth0
UUID=12345678-1234-1234-1234-123456789abc
DEVICE=eth0
ONBOOT=yes
IPADDR=192.168.1.100
PREFIX=24
GATEWAY=192.168.1.1
DNS1=8.8.8.8
DNS2=8.8.4.4

# Restart networking
sudo systemctl restart network
sudo nmcli connection reload
```

### DNS Configuration

#### DNS Resolution Files
```bash
# /etc/resolv.conf - DNS resolver configuration
nameserver 8.8.8.8
nameserver 8.8.4.4
search example.com internal.local
options timeout:2 attempts:3

# /etc/hosts - Local hostname resolution
127.0.0.1   localhost
127.0.1.1   hostname.example.com hostname
192.168.1.10 server1.example.com server1
192.168.1.11 server2.example.com server2

# /etc/nsswitch.conf - Name service switch configuration
hosts: files dns myhostname
networks: files
```

#### DNS Testing and Troubleshooting
```bash
# DNS lookup tools
nslookup google.com               # Basic DNS lookup
dig google.com                    # Detailed DNS information
dig @8.8.8.8 google.com          # Query specific DNS server
dig google.com MX                 # Query MX records
dig google.com ANY                # Query all record types
host google.com                   # Simple DNS lookup

# Reverse DNS lookup
dig -x 8.8.8.8                   # Reverse lookup
nslookup 8.8.8.8                 # Reverse lookup

# DNS cache management
sudo systemctl flush-dns          # Flush DNS cache (systemd-resolved)
sudo resolvectl flush-caches      # Alternative flush command
```

---

## Firewall Management

### iptables - Traditional Firewall

#### Basic iptables Commands
```bash
# View current rules
iptables -L                       # List all rules
iptables -L -n                    # List with numeric output
iptables -L -v                    # Verbose output with packet counts
iptables -t nat -L                # List NAT table rules

# Basic rule management
iptables -A INPUT -p tcp --dport 22 -j ACCEPT     # Allow SSH
iptables -A INPUT -p tcp --dport 80 -j ACCEPT     # Allow HTTP
iptables -A INPUT -p tcp --dport 443 -j ACCEPT    # Allow HTTPS
iptables -A INPUT -j DROP                         # Drop all other traffic

# Delete rules
iptables -D INPUT 1               # Delete rule by number
iptables -D INPUT -p tcp --dport 80 -j ACCEPT     # Delete specific rule

# Save and restore rules
iptables-save > /etc/iptables/rules.v4           # Save rules
iptables-restore < /etc/iptables/rules.v4        # Restore rules
```

#### Advanced iptables Rules
```bash
# Connection state filtering
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m state --state NEW -p tcp --dport 22 -j ACCEPT

# Rate limiting (DDoS protection)
iptables -A INPUT -p tcp --dport 22 -m limit --limit 5/min -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/min -j ACCEPT

# Source IP filtering
iptables -A INPUT -s 192.168.1.0/24 -j ACCEPT    # Allow local network
iptables -A INPUT -s 10.0.0.0/8 -j DROP          # Block private range

# Port forwarding (NAT)
iptables -t nat -A PREROUTING -p tcp --dport 8080 -j REDIRECT --to-port 80
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Logging
iptables -A INPUT -j LOG --log-prefix "DROPPED: " --log-level 4
```

### UFW - Uncomplicated Firewall

#### Basic UFW Commands
```bash
# Enable/disable firewall
sudo ufw enable                   # Enable firewall
sudo ufw disable                  # Disable firewall
sudo ufw --force reset            # Reset to defaults

# Basic rules
sudo ufw allow ssh                # Allow SSH (port 22)
sudo ufw allow 80                 # Allow HTTP
sudo ufw allow 443/tcp            # Allow HTTPS (TCP only)
sudo ufw allow from 192.168.1.0/24  # Allow from subnet

# Application profiles
sudo ufw app list                 # List available applications
sudo ufw allow 'Nginx Full'       # Allow Nginx (HTTP + HTTPS)
sudo ufw allow 'OpenSSH'          # Allow SSH

# Advanced rules
sudo ufw allow from 192.168.1.100 to any port 3306  # MySQL from specific IP
sudo ufw deny out 25              # Block outgoing SMTP
sudo ufw limit ssh                # Rate limit SSH connections

# Status and management
sudo ufw status                   # Show firewall status
sudo ufw status numbered          # Show numbered rules
sudo ufw delete 2                 # Delete rule by number
```

### firewalld - Dynamic Firewall (Red Hat/CentOS)

#### Basic firewalld Commands
```bash
# Service management
sudo systemctl start firewalld    # Start firewalld
sudo systemctl enable firewalld   # Enable at boot
sudo firewall-cmd --state         # Check firewall state

# Zone management
firewall-cmd --get-zones          # List available zones
firewall-cmd --get-default-zone   # Show default zone
firewall-cmd --set-default-zone=public  # Set default zone
firewall-cmd --get-active-zones   # Show active zones

# Service and port management
firewall-cmd --list-all           # List all rules in default zone
firewall-cmd --add-service=http   # Allow HTTP service
firewall-cmd --add-port=8080/tcp  # Allow specific port
firewall-cmd --remove-service=http  # Remove HTTP service

# Permanent rules
firewall-cmd --permanent --add-service=https  # Add permanent rule
firewall-cmd --reload             # Reload configuration
```

## Network Monitoring and Troubleshooting

### Connection Monitoring

#### Active Connections
```bash
# Modern tools (ss command)
ss -tuln                          # Show listening TCP/UDP ports
ss -tulpn                         # Show with process names
ss -an                            # Show all connections
ss -s                             # Show socket statistics
ss 'sport = :22'                  # Show connections on port 22
ss 'dport = :80'                  # Show connections to port 80

# Legacy netstat (still useful)
netstat -tuln                     # Show listening ports
netstat -tulpn                    # Show with process names
netstat -an                       # Show all connections
netstat -i                        # Show interface statistics
netstat -r                        # Show routing table
```

#### Network Traffic Analysis
```bash
# Real-time network monitoring
iftop                             # Show bandwidth usage by connection
nethogs                           # Show bandwidth usage by process
nload                             # Show total bandwidth usage
bmon                              # Bandwidth monitor with graphs

# Packet capture and analysis
tcpdump -i eth0                   # Capture packets on interface
tcpdump -i eth0 port 80           # Capture HTTP traffic
tcpdump -i eth0 host 192.168.1.100  # Capture traffic to/from host
tcpdump -w capture.pcap -i eth0   # Save capture to file
tcpdump -r capture.pcap           # Read from capture file

# Advanced tcpdump filters
tcpdump 'tcp and port 80'         # TCP traffic on port 80
tcpdump 'udp and port 53'         # DNS queries
tcpdump 'icmp'                    # ICMP traffic (ping)
tcpdump 'net 192.168.1.0/24'     # Traffic from/to subnet
```

### Performance Monitoring

#### Network Performance Tools
```bash
# Bandwidth testing
iperf3 -s                         # Start iperf3 server
iperf3 -c server_ip               # Test bandwidth to server
iperf3 -c server_ip -t 60         # Test for 60 seconds
iperf3 -c server_ip -P 4          # Use 4 parallel streams

# Latency testing
ping -c 10 google.com             # Basic ping test
ping -i 0.1 -c 100 server_ip      # High-frequency ping
mtr google.com                    # Continuous traceroute
traceroute google.com             # Route tracing
tracepath google.com              # Path MTU discovery

# Network interface statistics
cat /proc/net/dev                 # Interface statistics
ip -s link show eth0              # Interface statistics with ip
ethtool eth0                      # Ethernet tool information
ethtool -S eth0                   # Detailed interface statistics
```

## Network Services Configuration

### SSH Configuration and Security

#### SSH Server Configuration (/etc/ssh/sshd_config)
```bash
# Basic security settings
Port 2222                         # Change default port
PermitRootLogin no                # Disable root login
PasswordAuthentication no         # Disable password auth
PubkeyAuthentication yes          # Enable key-based auth
MaxAuthTries 3                    # Limit auth attempts
ClientAliveInterval 300           # Keep-alive interval
ClientAliveCountMax 2             # Max keep-alive messages

# Access control
AllowUsers user1 user2            # Allow specific users
DenyUsers baduser                 # Deny specific users
AllowGroups sshusers              # Allow specific groups

# Advanced settings
Protocol 2                        # Use SSH protocol 2 only
X11Forwarding no                  # Disable X11 forwarding
UseDNS no                         # Disable DNS lookups
Compression yes                   # Enable compression
```

#### SSH Client Configuration (~/.ssh/config)
```bash
# Global settings
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    Compression yes
    ControlMaster auto
    ControlPath ~/.ssh/master-%r@%h:%p
    ControlPersist 10m

# Specific host configuration
Host webserver
    HostName 192.168.1.100
    User deploy
    Port 2222
    IdentityFile ~/.ssh/webserver_key
    ForwardAgent yes

Host jumpbox
    HostName jump.example.com
    User admin
    ProxyJump bastion.example.com
```

#### SSH Key Management
```bash
# Generate SSH keys
ssh-keygen -t rsa -b 4096 -C "user@example.com"     # RSA 4096-bit
ssh-keygen -t ed25519 -C "user@example.com"         # Ed25519 (recommended)
ssh-keygen -t ecdsa -b 521 -C "user@example.com"    # ECDSA

# Copy public key to server
ssh-copy-id user@server           # Copy default key
ssh-copy-id -i ~/.ssh/custom_key.pub user@server    # Copy specific key

# SSH agent management
eval $(ssh-agent)                 # Start SSH agent
ssh-add ~/.ssh/id_rsa             # Add key to agent
ssh-add -l                        # List loaded keys
ssh-add -D                        # Remove all keys from agent
```

### Web Server Network Configuration

#### Nginx Network Configuration
```nginx
# /etc/nginx/sites-available/default
server {
    listen 80;
    listen [::]:80;
    server_name example.com www.example.com;
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    
    # Rate limiting
    limit_req_zone $binary_remote_addr zone=login:10m rate=1r/s;
    limit_req zone=login burst=5 nodelay;
    
    # SSL redirect
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name example.com www.example.com;
    
    # SSL configuration
    ssl_certificate /etc/ssl/certs/example.com.crt;
    ssl_certificate_key /etc/ssl/private/example.com.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    
    # Load balancing
    upstream backend {
        server 192.168.1.10:8080 weight=3;
        server 192.168.1.11:8080 weight=2;
        server 192.168.1.12:8080 backup;
    }
    
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Network Security and Monitoring

### Network Security Scanning

#### Port Scanning with Nmap
```bash
# Basic scans
nmap target_host                  # Basic port scan
nmap -sS target_host              # SYN stealth scan
nmap -sT target_host              # TCP connect scan
nmap -sU target_host              # UDP scan

# Advanced scans
nmap -sV target_host              # Version detection
nmap -O target_host               # OS detection
nmap -A target_host               # Aggressive scan (OS, version, scripts)
nmap -sC target_host              # Default script scan

# Network discovery
nmap -sn 192.168.1.0/24          # Ping sweep
nmap -PS22,80,443 192.168.1.0/24 # SYN ping on specific ports

# Output formats
nmap -oN scan.txt target_host     # Normal output
nmap -oX scan.xml target_host     # XML output
nmap -oG scan.gnmap target_host   # Grepable output
```

#### Network Vulnerability Assessment
```bash
# Nmap vulnerability scripts
nmap --script vuln target_host    # Run vulnerability scripts
nmap --script ssl-enum-ciphers target_host  # SSL/TLS analysis
nmap --script http-enum target_host         # HTTP enumeration

# SSL/TLS testing
sslscan target_host:443           # SSL/TLS scanner
testssl.sh target_host:443        # Comprehensive SSL/TLS test

# Web application scanning
nikto -h http://target_host       # Web vulnerability scanner
dirb http://target_host           # Directory brute forcer
```

### Network Intrusion Detection

#### Fail2Ban Configuration
```bash
# Install and configure Fail2Ban
sudo apt install fail2ban         # Install on Debian/Ubuntu
sudo yum install fail2ban          # Install on Red Hat/CentOS

# /etc/fail2ban/jail.local
[DEFAULT]
bantime = 3600                    # Ban for 1 hour
findtime = 600                    # Look for failures in 10 minutes
maxretry = 3                      # Max failures before ban
backend = systemd                 # Use systemd backend

[sshd]
enabled = true
port = ssh,2222                   # Monitor SSH ports
logpath = /var/log/auth.log       # Log file to monitor
maxretry = 3                      # SSH-specific retry limit

[nginx-http-auth]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log

# Fail2Ban management
sudo fail2ban-client status       # Show status
sudo fail2ban-client status sshd # Show SSH jail status
sudo fail2ban-client unban IP    # Unban IP address
```

#### Network Monitoring with Nagios/Icinga
```bash
# Basic network checks
define command {
    command_name    check_ping
    command_line    $USER1$/check_ping -H $HOSTADDRESS$ -w 100,20% -c 500,60%
}

define command {
    command_name    check_ssh
    command_line    $USER1$/check_ssh -H $HOSTADDRESS$ -p $ARG1$
}

define command {
    command_name    check_http
    command_line    $USER1$/check_http -H $HOSTADDRESS$ -p $ARG1$ -u $ARG2$
}
```

## Network Automation and Scripting

### Network Configuration Scripts

#### Network Interface Management Script
```bash
#!/bin/bash
# Network interface management script

INTERFACE="eth0"
IP_ADDRESS="192.168.1.100"
NETMASK="255.255.255.0"
GATEWAY="192.168.1.1"

configure_static_ip() {
    echo "Configuring static IP for $INTERFACE"
    
    # Backup current configuration
    cp /etc/netplan/01-netcfg.yaml /etc/netplan/01-netcfg.yaml.bak
    
    # Create new configuration
    cat > /etc/netplan/01-netcfg.yaml << EOF
network:
  version: 2
  ethernets:
    $INTERFACE:
      dhcp4: false
      addresses: [$IP_ADDRESS/24]
      gateway4: $GATEWAY
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
EOF
    
    # Apply configuration
    netplan apply
    echo "Static IP configured successfully"
}

configure_dhcp() {
    echo "Configuring DHCP for $INTERFACE"
    
    cat > /etc/netplan/01-netcfg.yaml << EOF
network:
  version: 2
  ethernets:
    $INTERFACE:
      dhcp4: true
EOF
    
    netplan apply
    echo "DHCP configured successfully"
}

case "$1" in
    static)
        configure_static_ip
        ;;
    dhcp)
        configure_dhcp
        ;;
    *)
        echo "Usage: $0 {static|dhcp}"
        exit 1
        ;;
esac
```

#### Network Monitoring Script
```bash
#!/bin/bash
# Network monitoring and alerting script

HOSTS=("8.8.8.8" "google.com" "192.168.1.1")
ALERT_EMAIL="admin@example.com"
LOG_FILE="/var/log/network-monitor.log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

check_connectivity() {
    local host="$1"
    local status="UP"
    
    if ! ping -c 3 -W 5 "$host" >/dev/null 2>&1; then
        status="DOWN"
        log_message "ALERT: $host is unreachable"
        
        # Send email alert
        echo "Network connectivity to $host is down" | \
            mail -s "Network Alert: $host DOWN" "$ALERT_EMAIL"
    else
        log_message "INFO: $host is reachable"
    fi
    
    echo "$host: $status"
}

check_bandwidth() {
    local interface="eth0"
    local rx_bytes=$(cat /sys/class/net/$interface/statistics/rx_bytes)
    local tx_bytes=$(cat /sys/class/net/$interface/statistics/tx_bytes)
    
    log_message "INFO: Interface $interface - RX: $rx_bytes bytes, TX: $tx_bytes bytes"
}

main() {
    log_message "Starting network monitoring check"
    
    for host in "${HOSTS[@]}"; do
        check_connectivity "$host"
    done
    
    check_bandwidth
    
    log_message "Network monitoring check completed"
}

main "$@"
```

This comprehensive networking guide covers essential network configuration, security, monitoring, and automation topics that DevOps engineers need to master for managing Linux systems in production environments.