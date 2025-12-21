# Basic Network Troubleshooting for DevOps

Network troubleshooting is an essential skill for DevOps professionals. This section covers fundamental diagnostic techniques, tools, and methodologies for identifying and resolving network issues.

## 🎯 Learning Objectives

- Master essential network diagnostic tools
- Understand systematic troubleshooting methodology
- Learn to read and interpret network configurations
- Identify common connectivity issues and solutions
- Develop basic performance monitoring skills

## 🔧 Essential Diagnostic Tools

### Connectivity Testing Tools

**ping - ICMP Echo Test:**
```bash
# Basic ping test
ping google.com
ping 8.8.8.8

# Ping with specific count
ping -c 4 google.com

# Ping with specific interval (2 seconds)
ping -i 2 google.com

# Ping with specific packet size
ping -s 1000 google.com

# Continuous ping with timestamp
ping google.com | while read pong; do echo "$(date): $pong"; done

# Ping IPv6
ping6 2001:4860:4860::8888
```

**traceroute/tracert - Path Discovery:**
```bash
# Linux/macOS traceroute
traceroute google.com
traceroute -I google.com  # Use ICMP instead of UDP
traceroute -T google.com  # Use TCP

# Windows tracert
tracert google.com

# MTR (My Traceroute) - Continuous traceroute
mtr google.com
mtr --report --report-cycles 10 google.com
```

**telnet - Port Connectivity:**
```bash
# Test if port is open
telnet google.com 80
telnet 192.168.1.1 22

# Test SMTP server
telnet mail.example.com 25

# Test HTTP manually
telnet google.com 80
GET / HTTP/1.1
Host: google.com
```

**netcat (nc) - Network Swiss Army Knife:**
```bash
# Test port connectivity
nc -zv google.com 80
nc -zv 192.168.1.1 22

# Scan port range
nc -zv google.com 80-443

# Listen on port (server mode)
nc -l 8080

# Send data to port (client mode)
echo "Hello" | nc 192.168.1.1 8080

# UDP test
nc -u 192.168.1.1 53
```

### DNS Diagnostic Tools

**nslookup - DNS Lookup:**
```bash
# Basic DNS lookup
nslookup google.com

# Specify DNS server
nslookup google.com 8.8.8.8

# Reverse DNS lookup
nslookup 8.8.8.8

# Query specific record types
nslookup -type=MX google.com
nslookup -type=NS google.com
nslookup -type=TXT google.com
```

**dig - Domain Information Groper:**
```bash
# Basic DNS query
dig google.com

# Query specific record type
dig google.com MX
dig google.com NS
dig google.com TXT
dig google.com AAAA

# Reverse DNS lookup
dig -x 8.8.8.8

# Trace DNS resolution path
dig +trace google.com

# Query specific DNS server
dig @8.8.8.8 google.com

# Short output format
dig +short google.com
```

**host - DNS Lookup Utility:**
```bash
# Basic lookup
host google.com

# All record types
host -a google.com

# Specific record type
host -t MX google.com
host -t NS google.com
```

### Network Configuration Tools

**ip - Modern Network Configuration:**
```bash
# Show all interfaces
ip addr show
ip a

# Show specific interface
ip addr show eth0

# Show routing table
ip route show
ip r

# Show ARP table
ip neighbor show
ip n

# Show network statistics
ip -s link show eth0
```

**ifconfig - Interface Configuration (Legacy):**
```bash
# Show all interfaces
ifconfig

# Show specific interface
ifconfig eth0

# Configure IP address
sudo ifconfig eth0 192.168.1.100 netmask 255.255.255.0

# Bring interface up/down
sudo ifconfig eth0 up
sudo ifconfig eth0 down
```

**netstat - Network Statistics:**
```bash
# Show all connections
netstat -a

# Show listening ports
netstat -l

# Show TCP connections
netstat -t

# Show UDP connections
netstat -u

# Show with process IDs
netstat -p

# Show numerical addresses
netstat -n

# Common combinations
netstat -tuln  # TCP/UDP listening ports with numbers
netstat -tulpn # Include process information
```

**ss - Socket Statistics (Modern netstat):**
```bash
# Show all sockets
ss -a

# Show listening sockets
ss -l

# Show TCP sockets
ss -t

# Show UDP sockets
ss -u

# Show with process information
ss -p

# Show numerical addresses
ss -n

# Common combinations
ss -tuln   # TCP/UDP listening with numbers
ss -tulpn  # Include process information
```

## 🔍 Systematic Troubleshooting Methodology

### OSI Layer Approach

**Layer 1 (Physical):**
```bash
# Check cable connections
# Verify link lights on network interfaces
# Check interface status
ip link show
ethtool eth0

# Check for physical errors
ip -s link show eth0
cat /proc/net/dev
```

**Layer 2 (Data Link):**
```bash
# Check MAC address table
# Verify VLAN configuration
# Check for frame errors

# View ARP table
arp -a
ip neighbor show

# Check interface statistics
cat /sys/class/net/eth0/statistics/rx_errors
cat /sys/class/net/eth0/statistics/tx_errors
```

**Layer 3 (Network):**
```bash
# Check IP configuration
ip addr show

# Verify routing table
ip route show

# Test local network connectivity
ping 192.168.1.1  # Default gateway

# Test remote connectivity
ping 8.8.8.8
```

**Layer 4 (Transport):**
```bash
# Check port connectivity
telnet target_host 80
nc -zv target_host 80

# Verify listening services
ss -tuln
netstat -tuln
```

**Layer 7 (Application):**
```bash
# Test application-specific connectivity
curl -I http://example.com
wget --spider http://example.com

# Check application logs
tail -f /var/log/apache2/error.log
journalctl -u nginx -f
```

### Troubleshooting Flowchart

```
Network Issue Reported
         │
         ▼
┌─────────────────┐
│ Define Problem  │
│ - What's broken?│
│ - When started? │
│ - Who affected? │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Check Physical  │
│ - Cables OK?    │
│ - Link lights?  │
│ - Interface up? │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Check IP Config │
│ - Correct IP?   │
│ - Subnet mask?  │
│ - Gateway set?  │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Test Local Net  │
│ - Ping gateway  │
│ - Ping local IP │
│ - ARP working?  │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Test Remote     │
│ - Ping 8.8.8.8 │
│ - Traceroute    │
│ - DNS working?  │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Check Services  │
│ - Ports open?   │
│ - Service up?   │
│ - Firewall OK?  │
└─────────────────┘
```

## 🚨 Common Network Issues

### No Internet Connectivity

**Symptoms:**
- Cannot reach external websites
- DNS resolution fails
- Local network works

**Troubleshooting Steps:**
```bash
# 1. Check IP configuration
ip addr show

# 2. Test default gateway
ping $(ip route | grep default | awk '{print $3}')

# 3. Test external connectivity
ping 8.8.8.8

# 4. Test DNS resolution
nslookup google.com
dig google.com

# 5. Check routing table
ip route show

# 6. Verify DNS servers
cat /etc/resolv.conf
```

### Slow Network Performance

**Symptoms:**
- High latency
- Low throughput
- Intermittent connectivity

**Diagnostic Commands:**
```bash
# Check interface statistics
ip -s link show eth0

# Monitor bandwidth usage
iftop -i eth0
nethogs eth0

# Test bandwidth
iperf3 -c server_ip

# Check for packet loss
ping -c 100 target_host | grep "packet loss"

# Monitor network traffic
tcpdump -i eth0 -c 100

# Check system resources
top
iostat 1
```

### DNS Resolution Issues

**Symptoms:**
- Cannot resolve domain names
- Slow DNS responses
- Intermittent resolution failures

**Troubleshooting:**
```bash
# Check DNS configuration
cat /etc/resolv.conf

# Test different DNS servers
nslookup google.com 8.8.8.8
nslookup google.com 1.1.1.1

# Clear DNS cache
# Ubuntu/Debian
sudo systemctl restart systemd-resolved

# CentOS/RHEL
sudo systemctl restart NetworkManager

# Test DNS resolution path
dig +trace google.com

# Check local DNS cache
dig google.com
```

### Port Connectivity Issues

**Symptoms:**
- Cannot connect to specific services
- Connection timeouts
- Connection refused errors

**Diagnostic Steps:**
```bash
# Test port connectivity
telnet target_host 80
nc -zv target_host 80

# Check if service is listening
ss -tuln | grep :80
netstat -tuln | grep :80

# Check firewall rules
# Linux
sudo iptables -L
sudo ufw status

# Check service status
systemctl status apache2
systemctl status nginx

# Test from different source
# Use online port checkers
# Test from different network
```

## 📊 Network Monitoring Basics

### Real-Time Monitoring

**iftop - Interface Bandwidth Monitor:**
```bash
# Monitor interface bandwidth
sudo iftop -i eth0

# Show port numbers
sudo iftop -i eth0 -P

# Show bytes instead of bits
sudo iftop -i eth0 -B
```

**nethogs - Process Network Usage:**
```bash
# Monitor per-process network usage
sudo nethogs eth0

# Refresh every 2 seconds
sudo nethogs -d 2 eth0
```

**nload - Network Load Monitor:**
```bash
# Monitor network load
nload eth0

# Monitor multiple interfaces
nload eth0 eth1
```

### Packet Capture and Analysis

**tcpdump - Command Line Packet Capture:**
```bash
# Capture all traffic on interface
sudo tcpdump -i eth0

# Capture specific protocol
sudo tcpdump -i eth0 tcp
sudo tcpdump -i eth0 udp
sudo tcpdump -i eth0 icmp

# Capture specific port
sudo tcpdump -i eth0 port 80
sudo tcpdump -i eth0 port 22

# Capture to file
sudo tcpdump -i eth0 -w capture.pcap

# Read from file
tcpdump -r capture.pcap

# Capture with verbose output
sudo tcpdump -i eth0 -v -n

# Capture specific host
sudo tcpdump -i eth0 host 192.168.1.1
```

**Wireshark - GUI Packet Analysis:**
```bash
# Install Wireshark
sudo apt-get install wireshark

# Capture traffic (GUI)
wireshark

# Command line version
tshark -i eth0

# Capture to file with tshark
tshark -i eth0 -w capture.pcap

# Read and filter
tshark -r capture.pcap -Y "http"
```

## 🔧 Configuration File Analysis

### Network Configuration Files

**Ubuntu/Debian - Netplan:**
```yaml
# /etc/netplan/01-network-manager-all.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

**CentOS/RHEL - Network Scripts:**
```bash
# /etc/sysconfig/network-scripts/ifcfg-eth0
TYPE=Ethernet
BOOTPROTO=static
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
NAME=eth0
DEVICE=eth0
ONBOOT=yes
IPADDR=192.168.1.100
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS1=8.8.8.8
DNS2=8.8.4.4
```

**DNS Configuration:**
```bash
# /etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
search example.com
options timeout:2 attempts:3
```

**Hosts File:**
```bash
# /etc/hosts
127.0.0.1   localhost
192.168.1.10   server1.example.com server1
192.168.1.20   server2.example.com server2
```

## 🧪 Practical Troubleshooting Labs

### Lab 1: Connectivity Troubleshooting

**Scenario:** Users cannot access the internet

**Symptoms:**
- Local network access works
- Cannot ping external IPs
- DNS resolution fails

**Troubleshooting Steps:**
```bash
# 1. Verify local connectivity
ping 192.168.1.1

# 2. Check IP configuration
ip addr show

# 3. Test gateway connectivity
ping $(ip route | grep default | awk '{print $3}')

# 4. Test external connectivity
ping 8.8.8.8

# 5. Check DNS
nslookup google.com

# 6. Verify routing
ip route show
```

### Lab 2: Performance Issues

**Scenario:** Network is slow

**Investigation:**
```bash
# Check interface errors
ip -s link show eth0

# Monitor bandwidth usage
iftop -i eth0

# Test latency
ping -c 10 google.com

# Check for packet loss
mtr --report --report-cycles 10 google.com

# Monitor system resources
top
iostat 1 5
```

### Lab 3: Service Connectivity

**Scenario:** Cannot connect to web server

**Troubleshooting:**
```bash
# Test port connectivity
telnet webserver 80
nc -zv webserver 80

# Check if service is running
ssh webserver "systemctl status apache2"

# Verify firewall rules
ssh webserver "sudo iptables -L"

# Test from different location
curl -I http://webserver/
```

## 📝 Troubleshooting Documentation

### Creating Incident Reports

**Template:**
```
Incident Report: Network Connectivity Issue

Date/Time: 2024-01-15 14:30 UTC
Reporter: John Doe
Severity: High

Problem Description:
- Users in Building A cannot access internet
- Local network connectivity works
- Started approximately 14:00 UTC

Affected Systems:
- VLAN 10 (192.168.10.0/24)
- Approximately 50 users

Troubleshooting Steps Taken:
1. Verified local connectivity - OK
2. Tested gateway ping - FAILED
3. Checked router configuration - Found issue
4. Router interface was down

Resolution:
- Brought up router interface
- Verified connectivity restored
- Monitored for 30 minutes

Root Cause:
- Router interface administratively down
- Likely caused by maintenance activity

Prevention:
- Implement change control procedures
- Add monitoring for critical interfaces
```

### Building Knowledge Base

**Common Issues Database:**
```markdown
# Issue: DNS Resolution Slow

## Symptoms
- Web pages load slowly
- DNS queries timeout
- nslookup takes >5 seconds

## Causes
- DNS server overloaded
- Network congestion
- Incorrect DNS configuration

## Solutions
1. Change DNS servers to 8.8.8.8, 1.1.1.1
2. Clear DNS cache
3. Check network connectivity to DNS servers

## Prevention
- Monitor DNS server performance
- Implement redundant DNS servers
- Regular DNS cache maintenance
```

## ✅ Knowledge Check

Before proceeding, ensure you can:
- [ ] Use ping, traceroute, and telnet effectively
- [ ] Perform DNS troubleshooting with dig and nslookup
- [ ] Analyze network configuration files
- [ ] Follow systematic troubleshooting methodology
- [ ] Identify common network issues and solutions
- [ ] Use packet capture tools for analysis
- [ ] Monitor network performance in real-time
- [ ] Document troubleshooting procedures

## 🔗 Next Steps

- **[Intermediate Level](../../Intermediate-Level/)** - Advanced troubleshooting techniques
- **[Network Security](../../Intermediate-Level/Network-Security/)** - Security-focused diagnostics
- **[Performance Optimization](../../Advanced-Level/Performance-Optimization/)** - Advanced performance analysis

---

*Effective troubleshooting skills are essential for maintaining reliable network infrastructure in DevOps environments. Practice these techniques regularly to build expertise.*