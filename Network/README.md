# Networking for DevOps

Complete guide to networking concepts, protocols, and tools essential for DevOps professionals.

## Network Fundamentals

### OSI Model
```bash
# Layer 7: Application Layer
- HTTP/HTTPS, FTP, SMTP, DNS
- Application protocols
- User interface

# Layer 6: Presentation Layer
- Encryption/Decryption
- Data compression
- Character encoding

# Layer 5: Session Layer
- Session management
- Authentication
- Connection establishment

# Layer 4: Transport Layer
- TCP/UDP protocols
- Port numbers
- Reliability and flow control

# Layer 3: Network Layer
- IP addressing
- Routing protocols
- Packet forwarding

# Layer 2: Data Link Layer
- MAC addresses
- Switching
- Frame formatting

# Layer 1: Physical Layer
- Cables, wireless signals
- Electrical specifications
- Physical topology
```

### TCP/IP Protocol Suite
```bash
# Internet Protocol (IP)
IPv4: 32-bit addressing (192.168.1.1)
IPv6: 128-bit addressing (2001:db8::1)

# Transmission Control Protocol (TCP)
- Connection-oriented
- Reliable delivery
- Flow control
- Error detection and correction

# User Datagram Protocol (UDP)
- Connectionless
- Fast transmission
- No reliability guarantees
- Real-time applications

# Internet Control Message Protocol (ICMP)
- Network diagnostics
- Error reporting
- Ping and traceroute
```

## Network Security

### Firewalls
```bash
# iptables (Linux)
# Allow SSH access
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP and HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Block all other incoming traffic
iptables -A INPUT -j DROP

# Save rules
iptables-save > /etc/iptables/rules.v4

# UFW (Uncomplicated Firewall)
ufw enable
ufw allow ssh
ufw allow http
ufw allow https
ufw deny incoming
ufw allow outgoing
```

### VPN (Virtual Private Network)
```bash
# OpenVPN Server Configuration
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
cipher AES-256-CBC
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
verb 3

# WireGuard Configuration
[Interface]
PrivateKey = <server-private-key>
Address = 10.0.0.1/24
ListenPort = 51820

[Peer]
PublicKey = <client-public-key>
AllowedIPs = 10.0.0.2/32
```

### SSL/TLS
```bash
# Generate SSL Certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout private.key -out certificate.crt

# Let's Encrypt with Certbot
certbot --nginx -d example.com -d www.example.com

# SSL Configuration (Nginx)
server {
    listen 443 ssl http2;
    server_name example.com;
    
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;
    
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## Load Balancing

### Layer 4 Load Balancing
```bash
# HAProxy Configuration
global
    daemon
    maxconn 4096

defaults
    mode tcp
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

frontend web_frontend
    bind *:80
    default_backend web_servers

backend web_servers
    balance roundrobin
    server web1 192.168.1.10:80 check
    server web2 192.168.1.11:80 check
    server web3 192.168.1.12:80 check
```

### Layer 7 Load Balancing
```bash
# Nginx Load Balancer
upstream backend {
    least_conn;
    server 192.168.1.10:8080 weight=3;
    server 192.168.1.11:8080 weight=2;
    server 192.168.1.12:8080 weight=1;
}

server {
    listen 80;
    server_name example.com;
    
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    
    location /api/ {
        proxy_pass http://api_backend;
    }
    
    location /static/ {
        root /var/www/static;
    }
}
```

## DNS (Domain Name System)

### DNS Configuration
```bash
# BIND9 Zone File
$TTL    604800
@       IN      SOA     ns1.example.com. admin.example.com. (
                              2023010101         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL

; Name servers
        IN      NS      ns1.example.com.
        IN      NS      ns2.example.com.

; A records
@       IN      A       192.168.1.10
www     IN      A       192.168.1.10
mail    IN      A       192.168.1.20
ftp     IN      A       192.168.1.30

; CNAME records
blog    IN      CNAME   www.example.com.
shop    IN      CNAME   www.example.com.

; MX records
@       IN      MX      10      mail.example.com.

; TXT records
@       IN      TXT     "v=spf1 mx ~all"
```

### DNS Tools
```bash
# DNS Lookup Tools
dig example.com
nslookup example.com
host example.com

# DNS Performance Testing
dig @8.8.8.8 example.com +stats
dig @1.1.1.1 example.com +stats

# DNS Cache Flush
# Linux
sudo systemctl flush-dns
# macOS
sudo dscacheutil -flushcache
# Windows
ipconfig /flushdns
```

## Network Monitoring

### Monitoring Tools
```bash
# Network Traffic Analysis
# tcpdump
tcpdump -i eth0 -n -c 100 port 80

# Wireshark (GUI)
wireshark

# iftop - Interface bandwidth usage
iftop -i eth0

# nethogs - Process network usage
nethogs eth0

# ss - Socket statistics
ss -tuln
ss -p | grep :80
```

### SNMP Monitoring
```bash
# SNMP Configuration
# /etc/snmp/snmpd.conf
rocommunity public 127.0.0.1
syslocation "Data Center 1"
syscontact "admin@example.com"

# SNMP Queries
snmpwalk -v2c -c public localhost 1.3.6.1.2.1.1
snmpget -v2c -c public localhost 1.3.6.1.2.1.1.1.0

# Prometheus SNMP Exporter
snmp_exporter:
  image: prom/snmp-exporter
  ports:
    - "9116:9116"
  volumes:
    - ./snmp.yml:/etc/snmp_exporter/snmp.yml
```

## Container Networking

### Docker Networking
```bash
# Docker Network Types
# Bridge (default)
docker network create --driver bridge my-bridge

# Host networking
docker run --network host nginx

# Overlay networking (Swarm)
docker network create --driver overlay --attachable my-overlay

# Custom bridge with subnet
docker network create --driver bridge \
    --subnet=172.20.0.0/16 \
    --ip-range=172.20.240.0/20 \
    custom-bridge

# Container communication
docker run -d --name web --network my-bridge nginx
docker run -d --name db --network my-bridge postgres
```

### Kubernetes Networking
```yaml
# Network Policy Example
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: web-netpol
spec:
  podSelector:
    matchLabels:
      app: web
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: database
    ports:
    - protocol: TCP
      port: 5432
```

### Service Mesh
```yaml
# Istio Service Mesh
# Virtual Service
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  http:
  - match:
    - headers:
        end-user:
          exact: jason
    route:
    - destination:
        host: reviews
        subset: v2
  - route:
    - destination:
        host: reviews
        subset: v1

# Destination Rule
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: reviews
spec:
  host: reviews
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
```

## Cloud Networking

### AWS Networking
```bash
# VPC Creation
aws ec2 create-vpc --cidr-block 10.0.0.0/16

# Subnet Creation
aws ec2 create-subnet \
    --vpc-id vpc-12345678 \
    --cidr-block 10.0.1.0/24 \
    --availability-zone us-west-2a

# Security Group
aws ec2 create-security-group \
    --group-name web-sg \
    --description "Web server security group" \
    --vpc-id vpc-12345678

# Route Table
aws ec2 create-route-table --vpc-id vpc-12345678
```

### Azure Networking
```bash
# Virtual Network
az network vnet create \
    --resource-group myResourceGroup \
    --name myVNet \
    --address-prefix 10.0.0.0/16 \
    --subnet-name mySubnet \
    --subnet-prefix 10.0.1.0/24

# Network Security Group
az network nsg create \
    --resource-group myResourceGroup \
    --name myNetworkSecurityGroup

# Load Balancer
az network lb create \
    --resource-group myResourceGroup \
    --name myLoadBalancer \
    --public-ip-address myPublicIP \
    --frontend-ip-name myFrontEnd \
    --backend-pool-name myBackEndPool
```

## Network Troubleshooting

### Common Tools
```bash
# Connectivity Testing
ping google.com
traceroute google.com
mtr google.com

# Port Testing
telnet example.com 80
nc -zv example.com 80-443

# Network Configuration
ip addr show
ip route show
netstat -tuln
ss -tuln

# Bandwidth Testing
iperf3 -s  # Server
iperf3 -c server_ip  # Client

# DNS Testing
dig +trace example.com
nslookup example.com 8.8.8.8
```

### Performance Optimization
```bash
# TCP Tuning
# /etc/sysctl.conf
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 65536 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_congestion_control = bbr

# Apply changes
sysctl -p

# Network Interface Optimization
ethtool -K eth0 gro on
ethtool -K eth0 gso on
ethtool -G eth0 rx 4096 tx 4096
```

This comprehensive networking guide provides DevOps professionals with essential knowledge for managing network infrastructure, security, and troubleshooting in modern environments.