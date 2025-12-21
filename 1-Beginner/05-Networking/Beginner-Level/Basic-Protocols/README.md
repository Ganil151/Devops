# Basic Network Protocols for DevOps

Understanding fundamental network protocols is essential for DevOps professionals. This section covers the most important protocols you'll encounter in modern infrastructure.

## 🎯 Learning Objectives

- Master HTTP/HTTPS communication fundamentals
- Understand DNS resolution and configuration
- Learn DHCP operation and management
- Grasp TCP vs UDP differences and use cases
- Explore ICMP for network diagnostics

## 🌐 HTTP/HTTPS Protocols

### HTTP (Hypertext Transfer Protocol)

HTTP is the foundation of web communication, operating on port 80.

**HTTP Request Structure:**
```
GET /api/users HTTP/1.1
Host: api.example.com
User-Agent: Mozilla/5.0
Accept: application/json
Authorization: Bearer token123
Content-Type: application/json

{
  "query": "active_users"
}
```

**HTTP Response Structure:**
```
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 156
Cache-Control: max-age=3600
Set-Cookie: session=abc123; HttpOnly; Secure

{
  "users": [
    {"id": 1, "name": "John", "status": "active"},
    {"id": 2, "name": "Jane", "status": "active"}
  ]
}
```

### HTTP Methods

| Method | Purpose | Idempotent | Safe |
|--------|---------|------------|------|
| GET | Retrieve data | Yes | Yes |
| POST | Create/Submit data | No | No |
| PUT | Update/Replace data | Yes | No |
| PATCH | Partial update | No | No |
| DELETE | Remove data | Yes | No |
| HEAD | Get headers only | Yes | Yes |
| OPTIONS | Get allowed methods | Yes | Yes |

### HTTP Status Codes

**Success (2xx):**
- `200 OK` - Request successful
- `201 Created` - Resource created
- `204 No Content` - Success, no response body

**Redirection (3xx):**
- `301 Moved Permanently` - Resource permanently moved
- `302 Found` - Temporary redirect
- `304 Not Modified` - Use cached version

**Client Error (4xx):**
- `400 Bad Request` - Invalid request syntax
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Access denied
- `404 Not Found` - Resource not found
- `429 Too Many Requests` - Rate limit exceeded

**Server Error (5xx):**
- `500 Internal Server Error` - Generic server error
- `502 Bad Gateway` - Invalid response from upstream
- `503 Service Unavailable` - Server temporarily unavailable
- `504 Gateway Timeout` - Upstream server timeout

### HTTPS (HTTP Secure)

HTTPS adds TLS/SSL encryption to HTTP, operating on port 443.

**TLS Handshake Process:**
```
Client                          Server
  │                               │
  ├─── ClientHello ──────────────►│
  │                               │
  │◄─── ServerHello ──────────────┤
  │◄─── Certificate ──────────────┤
  │◄─── ServerHelloDone ──────────┤
  │                               │
  ├─── ClientKeyExchange ────────►│
  ├─── ChangeCipherSpec ─────────►│
  ├─── Finished ─────────────────►│
  │                               │
  │◄─── ChangeCipherSpec ─────────┤
  │◄─── Finished ─────────────────┤
  │                               │
  ├─── Encrypted Data ───────────►│
  │◄─── Encrypted Data ───────────┤
```

**SSL Certificate Verification:**
```bash
# Check SSL certificate
openssl s_client -connect example.com:443 -servername example.com

# Verify certificate details
openssl x509 -in certificate.crt -text -noout

# Check certificate expiration
openssl x509 -in certificate.crt -noout -dates
```

## 🔍 DNS (Domain Name System)

DNS translates human-readable domain names to IP addresses.

### DNS Hierarchy

```
Root (.)
├── Top-Level Domain (.com, .org, .net)
│   ├── Second-Level Domain (example.com)
│   │   ├── Subdomain (www.example.com)
│   │   ├── Subdomain (api.example.com)
│   │   └── Subdomain (mail.example.com)
│   └── Another Domain (google.com)
└── Country Code TLD (.uk, .de, .jp)
```

### DNS Record Types

**A Record (Address):**
```
www.example.com.    IN    A    192.168.1.10
```

**AAAA Record (IPv6 Address):**
```
www.example.com.    IN    AAAA    2001:db8::1
```

**CNAME Record (Canonical Name):**
```
blog.example.com.   IN    CNAME    www.example.com.
```

**MX Record (Mail Exchange):**
```
example.com.        IN    MX    10 mail.example.com.
```

**TXT Record (Text):**
```
example.com.        IN    TXT    "v=spf1 mx ~all"
```

**NS Record (Name Server):**
```
example.com.        IN    NS    ns1.example.com.
```

**PTR Record (Pointer - Reverse DNS):**
```
10.1.168.192.in-addr.arpa.    IN    PTR    www.example.com.
```

### DNS Resolution Process

```
1. User types "www.example.com" in browser
2. Browser checks local DNS cache
3. If not cached, query local DNS resolver
4. Resolver queries root DNS servers
5. Root server responds with .com TLD servers
6. Resolver queries .com TLD servers
7. TLD server responds with example.com authoritative servers
8. Resolver queries authoritative servers
9. Authoritative server responds with IP address
10. IP address returned to browser
11. Browser connects to web server
```

### DNS Configuration Examples

**BIND9 Zone File:**
```
$TTL    86400
@       IN      SOA     ns1.example.com. admin.example.com. (
                        2023010101      ; Serial
                        3600            ; Refresh
                        1800            ; Retry
                        604800          ; Expire
                        86400 )         ; Minimum TTL

; Name servers
@       IN      NS      ns1.example.com.
@       IN      NS      ns2.example.com.

; A records
@       IN      A       192.168.1.10
www     IN      A       192.168.1.10
mail    IN      A       192.168.1.20
ftp     IN      A       192.168.1.30

; CNAME records
blog    IN      CNAME   www
shop    IN      CNAME   www

; MX record
@       IN      MX      10      mail.example.com.

; TXT records
@       IN      TXT     "v=spf1 mx ~all"
```

**DNS Tools and Commands:**
```bash
# DNS lookup
dig example.com
nslookup example.com
host example.com

# Specific record types
dig example.com MX
dig example.com TXT
dig example.com NS

# Reverse DNS lookup
dig -x 192.168.1.10

# Trace DNS resolution
dig +trace example.com

# DNS performance testing
dig @8.8.8.8 example.com +stats
dig @1.1.1.1 example.com +stats
```

## 📡 DHCP (Dynamic Host Configuration Protocol)

DHCP automatically assigns IP addresses and network configuration to devices.

### DHCP Process (DORA)

```
Client                          DHCP Server
  │                               │
  ├─── DHCP Discover ────────────►│ (Broadcast)
  │                               │
  │◄─── DHCP Offer ───────────────┤ (Unicast/Broadcast)
  │                               │
  ├─── DHCP Request ─────────────►│ (Broadcast)
  │                               │
  │◄─── DHCP Acknowledge ─────────┤ (Unicast)
  │                               │
```

### DHCP Configuration

**ISC DHCP Server Configuration:**
```
# /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;
authoritative;

subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.100 192.168.1.200;
    option routers 192.168.1.1;
    option domain-name-servers 8.8.8.8, 8.8.4.4;
    option domain-name "example.com";
    option broadcast-address 192.168.1.255;
}

# Static IP reservation
host server1 {
    hardware ethernet 00:11:22:33:44:55;
    fixed-address 192.168.1.50;
}
```

**DHCP Options:**
- Option 1: Subnet Mask
- Option 3: Router/Gateway
- Option 6: DNS Servers
- Option 15: Domain Name
- Option 28: Broadcast Address
- Option 42: NTP Servers
- Option 66: TFTP Server Name
- Option 67: Boot File Name

### DHCP Troubleshooting

```bash
# Check DHCP lease information
dhcp-lease-list

# Release and renew IP address
sudo dhclient -r eth0  # Release
sudo dhclient eth0     # Renew

# View DHCP logs
tail -f /var/log/syslog | grep dhcp

# Test DHCP server
nmap --script broadcast-dhcp-discover
```

## 🚛 TCP vs UDP Protocols

### TCP (Transmission Control Protocol)

TCP provides reliable, connection-oriented communication.

**TCP Features:**
- Connection-oriented (3-way handshake)
- Reliable delivery (acknowledgments)
- Flow control (window scaling)
- Error detection and correction
- Ordered data delivery
- Congestion control

**TCP 3-Way Handshake:**
```
Client                          Server
  │                               │
  ├─── SYN ──────────────────────►│
  │                               │
  │◄─── SYN-ACK ──────────────────┤
  │                               │
  ├─── ACK ──────────────────────►│
  │                               │
  │◄──── Data Exchange ──────────►│
```

**TCP Connection Termination:**
```
Client                          Server
  │                               │
  ├─── FIN ──────────────────────►│
  │                               │
  │◄─── ACK ──────────────────────┤
  │◄─── FIN ──────────────────────┤
  │                               │
  ├─── ACK ──────────────────────►│
```

### UDP (User Datagram Protocol)

UDP provides fast, connectionless communication.

**UDP Features:**
- Connectionless (no handshake)
- Unreliable delivery (no acknowledgments)
- No flow control
- No error correction
- Faster than TCP
- Lower overhead

### TCP vs UDP Comparison

| Feature | TCP | UDP |
|---------|-----|-----|
| Connection | Connection-oriented | Connectionless |
| Reliability | Reliable | Unreliable |
| Speed | Slower | Faster |
| Overhead | Higher | Lower |
| Use Cases | Web, Email, File Transfer | DNS, DHCP, Streaming |
| Header Size | 20 bytes | 8 bytes |

### Protocol Selection Guidelines

**Use TCP for:**
- Web applications (HTTP/HTTPS)
- Email (SMTP, POP3, IMAP)
- File transfer (FTP, SFTP)
- Remote access (SSH, Telnet)
- Database connections

**Use UDP for:**
- DNS queries
- DHCP requests
- Video/audio streaming
- Online gaming
- Network time synchronization (NTP)
- SNMP monitoring

## 🔧 ICMP (Internet Control Message Protocol)

ICMP provides network diagnostic and error reporting capabilities.

### ICMP Message Types

**Common ICMP Types:**
- Type 0: Echo Reply (ping response)
- Type 3: Destination Unreachable
- Type 5: Redirect
- Type 8: Echo Request (ping)
- Type 11: Time Exceeded (traceroute)

### Network Diagnostic Tools

**Ping (ICMP Echo):**
```bash
# Basic ping
ping google.com

# Ping with specific count
ping -c 4 google.com

# Ping with specific interval
ping -i 2 google.com

# Ping with specific packet size
ping -s 1000 google.com

# Continuous ping with timestamp
ping google.com | while read pong; do echo "$(date): $pong"; done
```

**Traceroute (Path Discovery):**
```bash
# Basic traceroute
traceroute google.com

# Traceroute with specific protocol
traceroute -I google.com  # ICMP
traceroute -T google.com  # TCP
traceroute -U google.com  # UDP

# MTR (My Traceroute) - continuous
mtr google.com
```

## 🛠️ Practical DevOps Applications

### Load Balancer Health Checks

**HTTP Health Check:**
```bash
# Simple health check endpoint
curl -f http://server1:8080/health || echo "Server1 down"

# Advanced health check with timeout
timeout 5 curl -f http://server1:8080/health
```

**TCP Health Check:**
```bash
# Check if port is open
nc -z server1 8080 && echo "Port open" || echo "Port closed"

# Telnet test
telnet server1 8080
```

### DNS-Based Service Discovery

**Consul DNS Integration:**
```bash
# Register service
curl -X PUT http://localhost:8500/v1/agent/service/register \
  -d '{
    "ID": "web1",
    "Name": "web",
    "Port": 8080,
    "Check": {
      "HTTP": "http://localhost:8080/health",
      "Interval": "10s"
    }
  }'

# Query service via DNS
dig @localhost -p 8600 web.service.consul SRV
```

### Container Networking

**Docker DNS Resolution:**
```bash
# Create custom network
docker network create --driver bridge mynetwork

# Run containers with custom DNS
docker run -d --name web1 --network mynetwork nginx
docker run -d --name web2 --network mynetwork nginx

# Test internal DNS resolution
docker exec web1 ping web2
```

## 🧪 Hands-On Labs

### Lab 1: HTTP/HTTPS Analysis

**Objective:** Analyze HTTP traffic and implement HTTPS

**Tasks:**
1. Capture HTTP traffic with tcpdump
2. Analyze requests/responses with Wireshark
3. Configure SSL certificate
4. Compare HTTP vs HTTPS performance

```bash
# Capture HTTP traffic
sudo tcpdump -i eth0 -w http_capture.pcap port 80

# Generate SSL certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout server.key -out server.crt

# Configure nginx with SSL
server {
    listen 443 ssl;
    ssl_certificate /path/to/server.crt;
    ssl_certificate_key /path/to/server.key;
}
```

### Lab 2: DNS Server Setup

**Objective:** Configure and test DNS server

**Tasks:**
1. Install and configure BIND9
2. Create forward and reverse zones
3. Test DNS resolution
4. Implement DNS security features

```bash
# Install BIND9
sudo apt-get install bind9 bind9utils bind9-doc

# Configure named.conf.local
zone "example.com" {
    type master;
    file "/etc/bind/db.example.com";
};

# Test DNS configuration
named-checkconf
named-checkzone example.com /etc/bind/db.example.com
```

### Lab 3: DHCP Server Configuration

**Objective:** Set up DHCP server with reservations

**Tasks:**
1. Install ISC DHCP server
2. Configure DHCP scopes
3. Create static reservations
4. Monitor DHCP leases

```bash
# Install DHCP server
sudo apt-get install isc-dhcp-server

# Start DHCP service
sudo systemctl start isc-dhcp-server
sudo systemctl enable isc-dhcp-server

# Monitor DHCP leases
tail -f /var/lib/dhcp/dhcpd.leases
```

## ✅ Knowledge Check

Before proceeding, ensure you can:
- [ ] Explain HTTP request/response cycle
- [ ] Configure HTTPS with SSL certificates
- [ ] Set up DNS server with various record types
- [ ] Configure DHCP server with static reservations
- [ ] Distinguish between TCP and UDP use cases
- [ ] Use ICMP tools for network diagnostics
- [ ] Troubleshoot common protocol issues
- [ ] Implement protocol-based health checks

## 🔗 Next Steps

- **[Network Devices](../Network-Devices/)** - Learn about network infrastructure
- **[Basic Troubleshooting](../Basic-Troubleshooting/)** - Develop diagnostic skills
- **[Intermediate Level](../../Intermediate-Level/)** - Advanced protocol concepts

---

*Understanding these fundamental protocols provides the foundation for all network communication in DevOps environments.*