# Linux Firewall Management

Complete guide to Linux firewall configuration and management.

## UFW (Uncomplicated Firewall)

### Basic UFW Commands
```bash
# Enable/Disable UFW
ufw enable
ufw disable
ufw status verbose

# Default Policies
ufw default deny incoming
ufw default allow outgoing
ufw default deny forward

# Allow/Deny Rules
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw deny 23/tcp
```

### Advanced UFW Rules
```bash
# Port ranges
ufw allow 6000:6007/tcp

# Specific IP addresses
ufw allow from 192.168.1.100
ufw allow from 192.168.1.0/24 to any port 22

# Application profiles
ufw app list
ufw allow 'Nginx Full'
ufw allow 'Apache Secure'

# Delete rules
ufw delete allow 80/tcp
ufw --force reset
```

## iptables

### Basic iptables Rules
```bash
# View current rules
iptables -L -n -v
iptables -t nat -L -n -v

# Flush rules
iptables -F
iptables -X
iptables -t nat -F

# Default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
```

### Common iptables Rules
```bash
# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow SSH
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP/HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Save rules
iptables-save > /etc/iptables/rules.v4
```

## firewalld (CentOS/RHEL)

### firewalld Management
```bash
# Service management
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --state

# Zone management
firewall-cmd --get-default-zone
firewall-cmd --set-default-zone=public
firewall-cmd --get-active-zones

# Service management
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload
```

### Advanced firewalld Configuration
```bash
# Port management
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --permanent --remove-port=8080/tcp

# Rich rules
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" accept'

# Custom services
firewall-cmd --permanent --new-service=myapp
firewall-cmd --permanent --service=myapp --set-description="My Application"
firewall-cmd --permanent --service=myapp --add-port=8080/tcp
```