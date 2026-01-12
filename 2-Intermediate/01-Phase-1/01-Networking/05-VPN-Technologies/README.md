# VPN Technologies for DevOps

Virtual Private Network implementations for secure remote connectivity and site-to-site communications in DevOps environments.

## 🎯 Learning Objectives

- Implement site-to-site VPN connections
- Configure remote access VPN solutions
- Understand IPSec and SSL/TLS VPN protocols
- Deploy modern SD-WAN technologies
- Optimize VPN performance and security

## 🔐 VPN Fundamentals

### VPN Types

**Site-to-Site VPN:**
- Connects entire networks
- Always-on connectivity
- Transparent to end users
- Used for branch offices

**Remote Access VPN:**
- Individual user connections
- On-demand connectivity
- Client software required
- Used for remote workers

**SSL/TLS VPN:**
- Browser-based access
- Application-level security
- Easy deployment
- Granular access control

## 🛡️ IPSec VPN Implementation

### IPSec Fundamentals

**IPSec Protocols:**
- **AH (Authentication Header)**: Authentication only
- **ESP (Encapsulating Security Payload)**: Encryption + Authentication
- **IKE (Internet Key Exchange)**: Key management

### Site-to-Site IPSec Configuration

**Cisco Router IPSec VPN:**
```bash
# Phase 1 (IKE) Configuration
crypto isakmp policy 10
 encryption aes 256
 hash sha256
 authentication pre-share
 group 14
 lifetime 86400

crypto isakmp key cisco123 address 203.0.113.2

# Phase 2 (IPSec) Configuration
crypto ipsec transform-set MYSET esp-aes 256 esp-sha256-hmac
 mode tunnel

# Access List for Interesting Traffic
access-list 101 permit ip 192.168.1.0 0.0.0.255 192.168.2.0 0.0.0.255

# Crypto Map
crypto map MYMAP 10 ipsec-isakmp
 set peer 203.0.113.2
 set transform-set MYSET
 match address 101

# Apply to Interface
interface gigabitethernet0/0
 crypto map MYMAP
```

**Linux strongSwan Configuration:**
```bash
# /etc/ipsec.conf
config setup
    charondebug="ike 1, knl 1, cfg 0"
    uniqueids=no

conn site-to-site
    auto=start
    left=203.0.113.1
    leftsubnet=192.168.1.0/24
    leftid=@site1.example.com
    right=203.0.113.2
    rightsubnet=192.168.2.0/24
    rightid=@site2.example.com
    ike=aes256-sha256-modp2048!
    esp=aes256-sha256!
    keyexchange=ikev2
    ikelifetime=86400s
    lifetime=3600s
    margintime=540s
    keyingtries=%forever
    authby=secret

# /etc/ipsec.secrets
203.0.113.1 203.0.113.2 : PSK "your-pre-shared-key"
```

### Remote Access IPSec VPN

**Cisco ASA Configuration:**
```bash
# Group Policy
group-policy REMOTE_USERS internal
group-policy REMOTE_USERS attributes
 vpn-tunnel-protocol ikev2 ssl-client
 split-tunnel-policy tunnelspecified
 split-tunnel-network-list SPLIT_TUNNEL_ACL
 address-pools VPN_POOL

# IP Pool
ip local pool VPN_POOL 192.168.100.1-192.168.100.100 mask 255.255.255.0

# Split Tunnel ACL
access-list SPLIT_TUNNEL_ACL standard permit 192.168.1.0 255.255.255.0
access-list SPLIT_TUNNEL_ACL standard permit 10.0.0.0 255.0.0.0

# User Configuration
username john password Password123
username john attributes
 vpn-group-policy REMOTE_USERS
```

## 🌐 SSL/TLS VPN Solutions

### OpenVPN Server Configuration

**Server Setup:**
```bash
# /etc/openvpn/server.conf
port 1194
proto udp
dev tun

ca ca.crt
cert server.crt
key server.key
dh dh.pem

server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt

# Push routes to clients
push "route 192.168.1.0 255.255.255.0"
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

# Client certificate verification
verify-client-cert require
```

**Client Configuration:**
```bash
# client.ovpn
client
dev tun
proto udp
remote vpn.example.com 1194
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
cert client.crt
key client.key
cipher AES-256-CBC
verb 3
```

### WireGuard VPN

**Server Configuration:**
```bash
# /etc/wireguard/wg0.conf
[Interface]
PrivateKey = <server-private-key>
Address = 10.0.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

# Client 1
[Peer]
PublicKey = <client1-public-key>
AllowedIPs = 10.0.0.2/32

# Client 2
[Peer]
PublicKey = <client2-public-key>
AllowedIPs = 10.0.0.3/32
```

**Client Configuration:**
```bash
# /etc/wireguard/wg0.conf
[Interface]
PrivateKey = <client-private-key>
Address = 10.0.0.2/24
DNS = 8.8.8.8

[Peer]
PublicKey = <server-public-key>
Endpoint = vpn.example.com:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

## 🚀 SD-WAN Technologies

### SD-WAN Fundamentals

**Key Features:**
- Centralized management
- Dynamic path selection
- Application-aware routing
- Zero-touch provisioning
- Cloud integration

### Cisco SD-WAN (Viptela)

**vEdge Configuration:**
```bash
# System configuration
system
 host-name branch-router
 system-ip 1.1.1.1
 site-id 100
 organization-name "MyCompany"
 vbond 203.0.113.10

# VPN 0 (Transport)
vpn 0
 interface ge0/0
  ip address 203.0.113.100/24
  tunnel-interface
   encapsulation ipsec
   color biz-internet
  no shutdown

# VPN 512 (Management)
vpn 512
 interface eth0
  ip address 192.168.1.10/24
  no shutdown

# VPN 1 (Service)
vpn 1
 interface ge0/1
  ip address 10.1.1.1/24
  no shutdown
```

### Open Source SD-WAN (FlexiWAN)

**Agent Configuration:**
```yaml
# /etc/flexiwan/agent.conf
server: https://app.flexiwan.com
token: "your-device-token"
interfaces:
  - name: eth0
    type: wan
    dhcp: true
  - name: eth1
    type: lan
    ip: 192.168.1.1/24
    dhcp_server:
      enabled: true
      range: 192.168.1.100-192.168.1.200
```

## 🔧 VPN Performance Optimization

### Bandwidth Optimization

**Compression Configuration:**
```bash
# OpenVPN compression
comp-lzo adaptive

# IPSec compression (Cisco)
crypto ipsec transform-set MYSET esp-aes esp-sha-hmac
 mode tunnel
 comp-lzs
```

### Quality of Service (QoS)

**VPN Traffic Prioritization:**
```bash
# Cisco QoS for VPN
class-map match-all VPN_TRAFFIC
 match protocol ipsec

policy-map WAN_QOS
 class VPN_TRAFFIC
  priority percent 30
  set dscp af31

interface gigabitethernet0/0
 service-policy output WAN_QOS
```

### Load Balancing

**Multi-Path VPN:**
```bash
# Cisco DMVPN with load balancing
interface tunnel0
 ip address 10.0.0.1 255.255.255.0
 tunnel source gigabitethernet0/0
 tunnel mode gre multipoint
 tunnel key 12345
 ip nhrp authentication cisco
 ip nhrp map multicast dynamic
 ip nhrp network-id 1

interface tunnel1
 ip address 10.0.1.1 255.255.255.0
 tunnel source gigabitethernet0/1
 tunnel mode gre multipoint
 tunnel key 12346
 ip nhrp authentication cisco
 ip nhrp map multicast dynamic
 ip nhrp network-id 2
```

## 🐳 Container VPN Integration

### Docker VPN Container

**OpenVPN in Docker:**
```yaml
# docker-compose.yml
version: '3'
services:
  openvpn:
    image: kylemanna/openvpn
    container_name: openvpn
    ports:
      - "1194:1194/udp"
    restart: always
    volumes:
      - ./openvpn-data:/etc/openvpn
    cap_add:
      - NET_ADMIN
    environment:
      - OVPN_SERVER_URL=udp://vpn.example.com
```

### Kubernetes VPN Gateway

**VPN Gateway Pod:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vpn-gateway
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vpn-gateway
  template:
    metadata:
      labels:
        app: vpn-gateway
    spec:
      containers:
      - name: strongswan
        image: strongswan:latest
        securityContext:
          capabilities:
            add: ["NET_ADMIN"]
        volumeMounts:
        - name: ipsec-config
          mountPath: /etc/ipsec.conf
          subPath: ipsec.conf
        - name: ipsec-secrets
          mountPath: /etc/ipsec.secrets
          subPath: ipsec.secrets
      volumes:
      - name: ipsec-config
        configMap:
          name: ipsec-config
      - name: ipsec-secrets
        secret:
          secretName: ipsec-secrets
```

## 🧪 Practical Labs

### Lab 1: Site-to-Site IPSec VPN

**Objective:** Connect two office locations

**Topology:**
```
Site A (192.168.1.0/24) ── Internet ── Site B (192.168.2.0/24)
```

**Tasks:**
1. Configure IPSec parameters
2. Set up interesting traffic
3. Test connectivity
4. Monitor tunnel status

### Lab 2: Remote Access VPN

**Objective:** Enable secure remote work

**Components:**
- OpenVPN server
- Certificate authority
- Client configurations
- Network routing

### Lab 3: WireGuard Mesh Network

**Objective:** Create peer-to-peer VPN mesh

**Configuration:**
```bash
# Generate keys
wg genkey | tee privatekey | wg pubkey > publickey

# Configure mesh topology
# Each peer connects to all others
```

## 🔍 VPN Troubleshooting

### Common Issues

**IPSec Troubleshooting:**
```bash
# Cisco diagnostics
show crypto isakmp sa
show crypto ipsec sa
show crypto map
debug crypto isakmp
debug crypto ipsec

# Linux strongSwan
ipsec status
ipsec statusall
journalctl -u strongswan
```

**OpenVPN Diagnostics:**
```bash
# Server logs
tail -f /var/log/openvpn/server.log

# Client connectivity test
openvpn --config client.ovpn --verb 4

# Network connectivity
ping -I tun0 192.168.1.1
traceroute -i tun0 192.168.1.1
```

### Performance Analysis

**Bandwidth Testing:**
```bash
# Through VPN tunnel
iperf3 -c server_ip -B vpn_interface_ip

# Latency measurement
ping -c 100 remote_host | grep avg
```

## 📊 VPN Monitoring

### SNMP Monitoring

**VPN Tunnel Status:**
```bash
# Monitor tunnel state
snmpwalk -v2c -c public router_ip 1.3.6.1.4.1.9.9.171.1.2.3.1.6

# Tunnel traffic statistics
snmpget -v2c -c public router_ip 1.3.6.1.4.1.9.9.171.1.2.3.1.26.1
```

### Automated Monitoring Script

**VPN Health Check:**
```python
#!/usr/bin/env python3
import subprocess
import smtplib
from email.mime.text import MIMEText

def check_vpn_tunnel(tunnel_ip):
    try:
        result = subprocess.run(['ping', '-c', '3', tunnel_ip], 
                              capture_output=True, text=True, timeout=10)
        return result.returncode == 0
    except subprocess.TimeoutExpired:
        return False

def send_alert(message):
    msg = MIMEText(message)
    msg['Subject'] = 'VPN Tunnel Alert'
    msg['From'] = 'monitoring@example.com'
    msg['To'] = 'admin@example.com'
    
    server = smtplib.SMTP('localhost')
    server.send_message(msg)
    server.quit()

# Monitor multiple tunnels
tunnels = {
    'Site-A': '192.168.1.1',
    'Site-B': '192.168.2.1',
    'Site-C': '192.168.3.1'
}

for site, ip in tunnels.items():
    if not check_vpn_tunnel(ip):
        send_alert(f"VPN tunnel to {site} ({ip}) is down!")
        print(f"ALERT: {site} tunnel down")
    else:
        print(f"OK: {site} tunnel up")
```

## ✅ Knowledge Check

- [ ] Configure site-to-site IPSec VPN
- [ ] Deploy remote access VPN solutions
- [ ] Implement SSL/TLS VPN
- [ ] Set up WireGuard VPN
- [ ] Optimize VPN performance
- [ ] Troubleshoot VPN connectivity
- [ ] Monitor VPN tunnel health

## 🔗 Next Steps

- [Network Security](../Network-Security/) - VPN security hardening
- [Advanced Level](../../Advanced-Level/) - Cloud VPN integration
- [Network Automation](../../Advanced-Level/Network-Automation/) - VPN automation