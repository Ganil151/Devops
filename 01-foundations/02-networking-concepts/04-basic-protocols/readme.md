# 🌐 Basic Protocols: The Packet-Flow Perspective

> **"A protocol is more than a rule; it's a contract. In DevOps, understanding these contracts is the difference between a 'Site Down' and a 'Service Resumed'."**

---

## 🧠 The Mental Model: The Language of the Stack

**The Newbie Struggle**: "I've heard of DNS and HTTP, but I thought they were just things browsers used. I didn't realize that every time my Python script talks to an S3 bucket or my Ansible script configures a server, a complex 'Handshake' is happening in the background."

**The Engineer Solution**: You realize that protocols are the **Operational Realities** of how data moves. You stop seeing "Strings" and start seeing **Packet Flows**. You understand that if DNS (Layer 7) fails, your expensive 100Gbps Fiber (Layer 1) doesn't matter.

### 🏗️ Protocol-to-OSI Mapping
This diagram shows exactly where our core protocols live in the stack.

```mermaid
block-beta
    columns 1
    L7("Application: DNS (Port 53), HTTP/S (80/443), SSH (22)")
    L4("Transport: TCP (Reliability), UDP (Speed)")
    L3("Network: IP (Logical Path), ICMP (Diagnostic)")
    L2("Data Link: ARP (Physical Mapping), MAC")
    
    L7 --> L4
    L4 --> L3
    L3 --> L2
```

### 📋 Famous Ports Reference
| Port | Protocol | Purpose | Standard |
|:-----|:---------|:--------|:---------|
| 22   | SSH      | Secure Remote Access | TCP      |
| 53   | DNS      | Domain Name Resolution | UDP/TCP  |
| 67/68| DHCP     | Dynamic IP Assignment | UDP      |
| 80   | HTTP     | Unencrypted Web Traffic | TCP      |
| 443  | HTTPS    | Encrypted Web (TLS) | TCP      |

---

## 🆚 Junior Way vs. Engineer Way

| Feature | The Junior Way (Problematic) | The Engineer Way (Strategic) |
|:---|:---|:---|
| **Perspective** | Sees HTTP as "just a URL". | Sees HTTP as a **Request/Response Lifecycle** with headers and status codes. |
| **Troubleshooting** | "DNS is down? I'll just use the IP." | **Understanding Service Discovery** (Why is the record missing?). |
| **Security** | "FTP is fine if it's internal." | **Zero Trust Protocols** (Encrypted-by-default: SSH, HTTPS, SFTP). |
| **Reliability** | Ignores timeouts in code. | **Implementing Circuit Breakers** and strict timeouts for all protocol calls. |

---

## 🎯 Learning Objectives
- Master HTTP/HTTPS communication fundamentals
- Understand DNS resolution and configuration
- Learn DHCP operation and management
- Grasp TCP vs UDP differences and use cases
- Explore ICMP for network diagnostics

---

## 🏗️ SSH (Port 22): The Remote Hands

**The Plain English Analogy**: SSH is like a **Secure Portal** or a magical wormhole. You type a command on your laptop, and it instantly happens on a server in a different country, all while being perfectly hidden from prying eyes.

**Why does a DevOps Engineer care?**
> [!NOTE]
> We rarely "log in" via terminal anymore. SREs use SSH as the transport layer for automation toolsets like **Ansible**. If port 22 is blocked, your entire automated deployment pipeline stops working.

- **The Operational Reality**: SREs use libraries like **Paramiko** or **Netmiko** to automate changes across 1,000 servers simultaneously.
- **The Security Wall**: SSH creates an encrypted tunnel. If you use Ansible to push a config change, that change is encrypted at Layer 7 before being sent down the wire.

---

## 🌐 HTTP/HTTPS Protocols

**The Plain English Analogy**: HTTP is like a **Takeout Menu**. You (the client) look at the menu and place an order (The Request), and the restaurant (the server) brings you your food (The Response).

**Why does a DevOps Engineer care?**
> [!TIP]
> We use HTTP status codes to tell our **Load Balancers** if a server is healthy (200 OK) or broken (5xx Server Error). If the LB sees too many 5xx codes, it automatically pulls that server out of rotation to prevent users from seeing errors.

### HTTP (Hypertext Transfer Protocol)
HTTP is the foundation of web communication, operating on port 80. It is a **stateless**, request-response protocol. In DevOps, HTTP is the **API Backbone**. Every time you run `terraform apply` or `kubectl get pods`, you are orchestrating HTTP requests.

### 🍱 Anatomy of an API Request/Response
```mermaid
sequenceDiagram
    participant App as Python/Go Script
    participant API as Cloud API (AWS/GitHub)
    
    App->>API: GET /v1/clusters (Headers: Auth Token, Content-Type)
    Note over API: Verifying Passport (TLS)...
    API-->>App: 200 OK (Body: JSON Data, Headers: Rate-Limit)
```

### 🛡️ The Passport of Automation: TLS Certificates
In an automated world, we don't use usernames and passwords for everything. **HTTPS** adds a TLS layer, where certificates act as the **Passport** of automation, proving that the API you are talking to is legitimate.

#### 🛠️ Visualizing the TLS Handshake
*This diagram represents the "Invisible" negotiation where the client and server agree on an encryption key before any data is sent.*

```mermaid
sequenceDiagram
    participant Client
    participant Server
    Client->>Server: ClientHello (Cipher Suites)
    Server-->>Client: ServerHello + Certificate
    Client->>Client: Verify Certificate with CA
    Client->>Server: Key Exchange (Encrypted)
    Client & Server->>Client & Server: Switch to Symmetric Encryption
```

### The Stateless Nature of HTTP
Statelessness means that the server does not "remember" previous requests. Every request is isolated.
- **Problem**: How do you stay logged in?
- **Solution**: **Cookies** and **Sessions**. The server sends a `Set-Cookie` header, and the browser includes that cookie in every subsequent request to identify the user.

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
*Visualizing the actions: GET (Read), POST (Create), PUT (Update), DELETE (Remove).*

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

### Advanced HTTP Concepts
**HTTP/2 (Binary Protocol):**
- Multiplexing: Multiple requests over a single TCP connection.
- Header Compression (HPACK).
- Server Push.

**HTTP/3 (QUIC):**
- Built on **UDP** (Port 443) instead of TCP.
- Eliminates Head-of-Line (HoL) blocking.
- Faster connection establishment (0-RTT).
- Better performance on unstable networks (e.g., mobile).

**Security Headers:**
- `Strict-Transport-Security` (HSTS): Forces HTTPS.
- `Content-Security-Policy` (CSP): Prevents XSS.
- `X-Frame-Options`: Prevents Clickjacking.

#### 📊 Protocol Evolution Comparison
*Comparison of performance gains from HTTP/1.1 (sequential) to HTTP/2 (parallel) to HTTP/3 (UDP-based resilience).*

**Why DevOps Care about versioning?**
- **HTTP/1.1** results in "Head-of-Line Blocking" where one slow image can block the rest of the page.
- **HTTP/2** introduces **Multiplexing**, allowing a browser to pull 50 images over ONE connection simultaneously.
- **HTTP/3** replaces TCP with **QUIC** (UDP-based), eliminating the "TCP Handshake" delay and making connections much more resilient to packet loss on mobile networks.

### HTTPS (HTTP Secure)
HTTPS adds TLS/SSL encryption to HTTP, operating on port 443.

**TLS/SSL Details for DevOps:**
- **Asymmetric Encryption**: Used during the handshake (RSA/Diffie-Hellman) to securely exchange a "session key."
- **Symmetric Encryption**: Used for the actual data transfer (AES) once the session key is established, as it is much faster.
- **Perfect Forward Secrecy (PFS)**: Ensures that even if the server's private key is compromised in the future, past sessions cannot be decrypted.

**SSL Certificate Verification:**
```bash
# Check SSL certificate
openssl s_client -connect example.com:443 -servername example.com

# Verify certificate details
openssl x509 -in certificate.crt -text -noout

# Check certificate expiration
openssl x509 -in certificate.crt -noout -dates
```

---

## 🔍 DNS (Domain Name System)

**The Plain English Analogy**: DNS is the **GPS of the internet**. You give it a name like `Google.com`, and it returns the exact GPS coordinates (The IP Address) so your computer knows where to drive.

**Why does a DevOps Engineer care?**
> [!TIP]
> In the cloud, servers die and are reborn with different IPs every day. We use DNS as our **Service Discovery** layer so our code always says "Talk to 'db-service-01'" instead of hardcoding an IP that might change an hour from now.

DNS translates human-readable domain names to IP addresses. In DevOps, DNS is the **Phonebook of the Cloud** and our primary **Service Discovery** layer.

### 🏗️ Operational Reality: Service Discovery
When your Python code calls `socket.gethostbyname('my-db.s3.amazonaws.com')`, it's not just a string lookup. It's a recursive journey across the globe to find the exact IP for your storage bucket.

### 🔍 The DNS Resolution Flow
```mermaid
graph TD
    Root["Root Servers (.)"]
    TLD["TLD Servers (.com, .io, .net)"]
    Auth["Authoritative Servers (amazon.com)"]
    Local["Local Resolver (Your Laptop/VPC)"]
    
    Local -->|1. Where is s3.amazon.com?| Root
    Root -->|2. Ask .com| TLD
    TLD -->|3. Ask amazon's DNS| Auth
    Auth -->|4. IP is 52.216.x.x| Local
    
    style Local fill:#f0f7ff,stroke:#0078d4
    style Auth fill:#fdf4f4,stroke:#d13438
```

### DNS Hierarchy
![DNS Hierarchy](../dns-hierarchy.png)

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

**CAA Record (Certificate Authority Authorization):**
Specifies which CAs are allowed to issue certificates for the domain.
```
example.com.        IN    CAA    0 issue "letsencrypt.org"
```

### DNS Security & Modern Privacy
- **DNSSEC (DNS Security Extensions)**: Uses digital signatures to verify that DNS data hasn't been tampered with. It prevents DNS cache poisoning.
- **DoH (DNS over HTTPS)**: Performs DNS queries over an encrypted HTTPS connection (Port 443).
- **DoT (DNS over TLS)**: Performs DNS queries over a TLS connection (Port 853).
- **Anycast DNS**: Routes DNS queries to the geographically closest server using the same IP address, improving speed and DDoS resilience.

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

---

## 📡 DHCP (Dynamic Host Configuration Protocol)

**The Plain English Analogy**: DHCP is the **Registration Desk** of a hotel. When you walk in (Boot up), you don't have a room number (An IP). You go to the desk, and they give you a key (Your IP Address) and the Wi-Fi password (The Gateway and DNS).

**Why does a DevOps Engineer care?**
> [!NOTE]
> Cloud providers use DHCP to automatically give your new Virtual Machines an identity the moment they are "born" (provisioned). Without DHCP, you would have to manually type the IP address into every server you create, which is impossible at scale.

DHCP automatically assigns IP addresses and network configuration to devices. It is the **Registration Desk** of the "Internal Map."

### 🏗️ How Servers get Identities
When a server starts in a VPC, it shouts for an IP (DHCP Discover). The DHCP server gives it an identity (IP, Mask, Gateway). Before that server talks to a neighbor, it uses **ARP** to map that "Identity (IP)" to a "Physical Location (MAC)."

### DHCP Process (DORA)
*Visualizing the Handshake: Discover (Client), Offer (Server), Request (Client), Acknowledge (Server).*

![DHCP DORA Process](../dhcp-dora-process.png)

### DHCP Relay Agents (IP Helper)
Since DHCP Discover packets are broadcasts, they don't cross routers by default. A **DHCP Relay Agent** (installed on a router or server) listens for these broadcasts on a local subnet and forwards them as unicast packets to a DHCP server on a different subnet. This allows one central DHCP server to serve multiple subnets.

### DHCPv6
DHCP for IPv6 (UDP Ports 546/547). It can operate in:
- **Stateful**: Server manages everything (like IPv4).
- **Stateless**: Server only provides optional info (DNS, etc.), while the client auto-configures its IP (SLAAC).

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

---

## 🚛 TCP vs UDP Protocols

**The Plain English Analogy**: **TCP** is like a **Registered Letter**; you get a receipt confirming it arrived exactly as sent. **UDP** is like a **Postcard**; you drop it in the mail and hope for the best; it's faster, but some might get lost in the wind.

**Why does a DevOps Engineer care?**
> [!NOTE]
> Choosing the wrong protocol can destroy app performance. We use **TCP** for things that MUST be accurate (Files, Web Pages, Databases). We use **UDP** for things that must be FAST (Real-time video, Voice calls, or tiny queries like DNS).

### TCP (Transmission Control Protocol)
TCP provides reliable, connection-oriented communication.

**TCP Features:**
- Connection-oriented (3-way handshake)
- Reliable delivery (acknowledgments)
- Flow control (window scaling)
- Error detection and correction
- Ordered data delivery
- Congestion control

**Advanced TCP Concepts:**
- **MTU (Maximum Transmission Unit)**: The largest packet size the network can handle (default 1500 bytes for Ethernet).
- **MSS (Maximum Segment Size)**: The maximum amount of data in a TCP segment (MTU - 40 bytes of headers = 1460 bytes).
- **Sliding Window**: Allows the sender to have multiple packets in flight before receiving an ACK, improving performance.
- **Congestion Control Algorithms**:
    - **CUBIC**: Default in most Linux kernels.
    - **BBR (Bottleneck Bandwidth and RTT)**: Google's algorithm for high-speed networks.

**TCP 3-Way Handshake (Reliability):**
```mermaid
sequenceDiagram
    participant Client
    participant Server
    
    Client->>Server: SYN (Let's Talk)
    Server->>Client: SYN / ACK (I'm ready, you?)
    Client->>Server: ACK (Let's Go!)
    Note over Client,Server: Connection ESTABLISHED
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

**The Plain English Analogy**: ICMP is like the **Maintenance Crew** for a highway. They don't carry any cargo (data), but they put up signs to tell you if a road is closed (Destination Unreachable) or how long the delay is (Ping).

**Why does a DevOps Engineer care?**
> [!TIP]
> We use ICMP and the `ping` command to check if our servers are "up." However, many cloud providers block ICMP by default. If your `ping` fails but your website works, your **Security Group** is likely doing its job!

ICMP provides network diagnostic and error reporting capabilities.

### ICMP Message Types

**Common ICMP Types:**
- Type 0: Echo Reply (ping response)
- Type 3: Destination Unreachable
- Type 5: Redirect
- Type 8: Echo Request (ping)
- Type 11: Time Exceeded (traceroute)

### Advanced ICMP Concepts

- **Path MTU Discovery (PMTUD)**: Uses ICMP Type 3 Code 4 (Fragmentation Needed) to determine the largest possible packet size between two hosts without fragmentation.
- **ICMP Redirects**: Sent by routers to notify hosts that a better route exists for a specific destination.
- **Security Implications**: Many firewalls block ICMP entirely (e.g., in AWS Security Groups) to prevent "Ping sweeps" or OS fingerprinting.

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

## 🐍 Professional Coding Patterns

### Requests vs. Urllib
For modern DevOps, we favor the `requests` library for its human-readable API and robust handling of sessions and SSL.

```python
# 🟢 RECOMMENDED: The Requests Way
import requests
response = requests.get("https://api.github.com", timeout=5)

# 🔴 AVOID: The Urllib Way (Verbose and complex for simple tasks)
import urllib.request
with urllib.request.urlopen("https://api.github.com") as f:
    print(f.read().decode('utf-8'))
```

### 🛡️ The Timeout Pattern
**CRITICAL**: Never execute a network call without a timeout. A hanging connection can freeze your entire CI/CD pipeline or crash your automation service.

```python
# SRE Pattern: Always implement timeout=5 (or appropriate)
try:
    requests.get("http://my-db.internal", timeout=5)
except requests.exceptions.Timeout:
    print("Circuit Breaker Triggered: Connection took too long!")
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

## ❓ Interview & SRE Mastery

### 🎯 High-Impact Questions

1. **Q: What is the difference between TCP (Reliable) and UDP (Fast), and which does DNS use?**
   * *Answer: **TCP** is for 100% accuracy (Files, Web); **UDP** is for speed (Video, Voice). **DNS uses both.** Small queries are UDP (fast), but large responses or Zone Transfers use TCP (reliable).*

2. **Q: How does an MTU (Maximum Transmission Unit) mismatch cause a VPN to drop traffic?**
   * *Answer: MTU is the max packet size (usually 1500 bytes). If a VPN adds a "Header" to a full 1500-byte packet, it becomes too big for the physical wire and gets dropped or fragmented, leading to "hanging" connections.*

---

## 🧠 Concepts Quiz: Basic Protocols (50+ Questions)

Test your knowledge with these real-world scenarios and technical questions.

### 🌐 HTTP & HTTPS

1. **Scenario: A developer reports that their browser is showing a "Too many redirects" error when accessing your site. What HTTP status code is likely involved in the background?**
   - A) 301
   - B) 302
   - C) 404
   - D) 500

2. **Scenario: You are debugging a web server and see many 401 status codes in the access log. What does this typically mean?**
   - A) The page does not exist
   - B) The server is overloaded
   - C) The user failed to authenticate
   - D) The request was blocked by a firewall

3. **Scenario: Your site is secure, but you want to prevent users from ever accidentally visiting the HTTP version. Which header should you use?**
   - A) Content-Security-Policy
   - B) Strict-Transport-Security (HSTS)
   - C) X-Frame-Options
   - D) Cache-Control

4. **Scenario: You see a 502 status code on your Load Balancer (ALB/Nginx). What is the most likely cause?**
   - A) The client sent an invalid request
   - B) The upstream (backend) server is down or returned an invalid response
   - C) The client's certificate is invalid
   - D) DNS resolution failed

5. **Which HTTP/3 feature significantly reduces latency on mobile networks?**
   - A) Server Push
   - B) Header Compression
   - C) 0-RTT Connection Establishment (via QUIC)
   - D) Gzip compression

6. **Scenario: A REST API returns a '201 Created' response. What does this tell you about the request?**
   - A) It was a GET request that succeeded
   - B) It was a POST or PUT request that successfully created a resource
   - C) The request was received but is still being processed
   - D) The resource was modified

7. **In a TLS handshake, which message contains the server's public key?**
   - A) ClientHello
   - B) ServerHello
   - C) Certificate
   - D) ChangeCipherSpec

8. **Scenario: You want to check the expiration date of an SSL certificate for `example.com` from the command line. Which tool do you use?**
   - A) curl
   - B) openssl
   - C) dig
   - D) ping

9. **What is the default port for HTTP?**
   - A) 443
   - B) 80
   - C) 8080
   - D) 22

10. **Which HTTP method is considered 'idempotent' (running it multiple times has the same result as once)?**
    - A) POST
    - B) GET
    - C) PUT
    - D) B and C

### 🔍 DNS

11. **Scenario: You just updated the IP for `api.test.com`, but your server still sees the old IP. What is the most likely cause?**
    - A) DNS Record type is wrong
    - B) TTL (Time To Live) has not expired
    - C) Port 53 is blocked
    - D) The ISP is down

12. **Which DNS record type is used to point a subdomain to another domain name instead of an IP?**
    - A) A Record
    - B) CNAME
    - C) MX Record
    - D) TXT Record

13. **Scenario: You need to set up an email server. Which DNS record is essential for receiving emails?**
    - A) NS
    - B) AAAA
    - C) MX
    - D) PTR

14. **What is the purpose of a PTR record?**
    - A) To map a domain to an IP
    - B) To map an IP to a domain (Reverse DNS)
    - C) To verify domain ownership
    - D) To specify name servers

15. **Scenario: You want to prevent attackers from poisoning your DNS cache. Which technology provides digital signatures for DNS data?**
    - A) DoH
    - B) DoT
    - C) DNSSEC
    - D) Anycast

16. **How many root DNS servers (logical clusters) are there globally?**
    - A) 7
    - B) 10
    - C) 13
    - D) 25

17. **Which command would you use to trace the full path of DNS resolution from the root to the authoritative server?**
    - A) `nslookup`
    - B) `dig +trace`
    - C) `ping -t`
    - D) `traceroute`

20. **Which record type specifies which Certificate Authorities can issue SSL certs for your domain?**
    - A) TXT
    - B) CNAME
    - C) CAA
    - D) SRV

18. **Scenario: You want to resolve DNS queries over an encrypted connection to prevent your ISP from seeing your traffic. Which protocol do you use?**
    - A) HTTP/2
    - B) DNS over HTTPS (DoH)
    - C) ICMP
    - D) BGP

19. **What port does DNS primarily use for standard queries?**
    - A) 53 (UDP/TCP)
    - B) 67
    - C) 443
    - D) 123

### 📡 DHCP

21. **Scenario: A computer enters a new network and needs an IP. What is the first packet it sends in the DORA process?**
    - A) Offer
    - B) Request
    - C) Discover
    - D) Acknowledge

22. **What technology allows a DHCP server on a different subnet to provide IPs to a local client?**
    - A) DHCP Relay (IP Helper)
    - B) NAT
    - C) VLAN
    - D) Subnet Mask

23. **Which DHCP option provides the address of the default gateway?**
    - A) Option 1
    - B) Option 3
    - C) Option 6
    - D) Option 15

24. **Scenario: Your client machine has an IP of 169.254.x.x. What does this typically indicate?**
    - A) The DHCP server assigned a static IP
    - B) The DHCP server is unreachable (APIPA address)
    - C) The network cable is unplugged
    - D) The internet is working perfectly

25. **Is DHCP built on TCP or UDP?**
    - A) TCP
    - B) UDP
    - C) Both
    - D) ICMP

26. **Scenario: You want to ensure your office printer always gets the IP `192.168.1.50`. What should you configure?**
    - A) A larger DHCP range
    - B) A DHCP reservation (mapping MAC to IP)
    - C) A shorter lease time
    - D) A CNAME record

27. **What happens during the 'Request' phase of DHCP?**
    - A) The server offers an IP
    - B) The client broadcasts that it is accepting a specific offer
    - C) The client asks the root server for an IP
    - D) The transaction is closed

28. **In IPv6, what does SLAAC allow a client to do?**
    - A) Manually type an IP
    - B) Self-configure an IP address without a stateful DHCPv6 server
    - C) Connect only to Google
    - D) Skip the DNS setup

29. **Which port does a DHCP server listen on?**
    - A) 67
    - B) 68
    - C) 53
    - D) 80

30. **Scenario: Users are losing their IP addresses every 10 minutes. Which DHCP setting should you investigate?**
    - A) Subnet Mask
    - B) Lease Time
    - C) Option 6
    - D) DNS Server

### 🚛 TCP vs UDP

31. **Scenario: You are building a video streaming app where a few dropped frames are acceptable, but low latency is critical. Which protocol do you use?**
    - A) TCP
    - B) UDP
    - C) HTTP/1.1
    - D) SSH

32. **In the TCP 3-way handshake, what is the second packet sent?**
    - A) SYN
    - B) ACK
    - C) SYN-ACK
    - D) FIN

33. **Which protocol ensures that packets arrive in the correct order?**
    - A) UDP
    - B) IP
    - C) TCP
    - D) ARP

34. **What is the standard Ethernet MTU size (in bytes)?**
    - A) 1000
    - B) 1460
    - C) 1500
    - D) 9000

35. **Scenario: You want to optimize TCP performance on a high-latency network with high bandwidth. Which algorithm might you prefer?**
    - A) RIP
    - B) BBR
    - C) OSPF
    - D) STP

36. **What is 'Window Scaling' in TCP used for?**
    - A) To reduce the port number
    - B) To allow more data to be in flight (larger buffers)
    - C) To secure the payload
    - D) To close the connection faster

37. **Which protocol has a smaller header size?**
    - A) TCP (20 bytes)
    - B) UDP (8 bytes)
    - C) Both are the same
    - D) HTTP

38. **Scenario: A network engineer says there is a 'Head-of-Line' blocking issue. Which combination of protocols is likely causing this?**
    - A) UDP and DNS
    - B) TCP and HTTP/1.1 or HTTP/2
    - C) ICMP and Ping
    - D) DHCP and SSH

39. **What signal does a server send to a client to immediately abort a TCP connection?**
    - A) FIN
    - B) ACK
    - C) RST (Reset)
    - D) SYN

40. **Which packet type is used to close a connection gracefully in TCP?**
    - A) SYN
    - B) PSH
    - C) FIN
    - D) URG

### 🔧 ICMP & Diagnostics

41. **Scenario: You run `ping google.com` and see "Request timed out," but when you visit the site in a browser, it works. Why?**
    - A) DNS is broken
    - B) TCP is slower than ICMP
    - C) A firewall is blocking incoming ICMP Echo Requests
    - D) The internet is offline

42. **Which ICMP type does the `traceroute` command rely on to show path hops?**
    - A) Type 0 (Echo Reply)
    - B) Type 8 (Echo Request)
    - C) Type 11 (Time Exceeded)
    - D) Type 3 (Destination Unreachable)

43. **Scenario: You suspect an MTU problem on your network path. Which technology automatically finds the largest packet size?**
    - A) DNSSEC
    - B) PMTUD (Path MTU Discovery)
    - C) BGP
    - D) VLAN Tagging

44. **What does ICMP Type 3 mean?**
    - A) Echo Request
    - B) Destination Unreachable
    - C) Redirect
    - D) Source Quench

45. **Which command provides a continuous, real-time update of network latency and packet loss across the entire path?**
    - A) ping
    - B) traceroute
    - C) mtr
    - D) curl

46. **What is an 'ICMP Redirect' used for?**
    - A) To block a user
    - B) To notify a host of a more optimal route
    - C) To restart a router
    - D) To translate IPs

47. **Scenario: You see "Destination Port Unreachable" in a packet capture. Which protocol is handling this message?**
    - A) TCP
    - B) UDP
    - C) ICMP
    - D) HTTP

48. **In AWS, if your Security Group 'Outbound' rules allow 'All Traffic', but 'Inbound' only allows Port 80, will `ping` work from the internet?**
    - A) Yes, because outbound is open
    - B) No, because ICMP is its own protocol and not Port 80
    - C) Only if the server is a Linux machine
    - D) Yes, if DNS is working

49. **Does an ICMP message have a port number?**
    - A) Yes, Port 0
    - B) No, it uses Type and Code fields
    - C) Yes, Port 7
    - D) Only on Windows

50. **Scenario: You want to check if a specific port is open without using Nmap or Telnet. Which tool is best?**
    - A) ping
    - B) nc (netcat) or ss
    - C) dig
    - D) route

### 🏁 Mixed Technical Mastery

51. **Which protocol is used by the `ping` utility?**
    - A) TCP
    - B) UDP
    - C) ICMP
    - D) ARP

52. **Scenario: You are configuring a web server and want to support the latest, fastest version of HTTP that uses QUIC. Which port and protocol must you open on your firewall?**
    - A) Port 80, TCP
    - B) Port 443, TCP
    - C) Port 443, UDP
    - D) Port 53, UDP

53. **What is the primary function of an ARP (Address Resolution Protocol)?**
    - A) To map Domain Names to IP addresses
    - B) To map IP addresses to MAC addresses
    - C) To route packets between subnets
    - D) To assign IP addresses dynamically

54. **Scenario: You are seeing "Connection Refused" when trying to SSH into a server. What is a likely reason?**
    - A) The server is down
    - B) The SSH service (sshd) is not running on the target port
    - C) There is a network timeout
    - D) The client's keyboard is broken

55. **Which layer of the OSI model do protocols like HTTP, DNS, and DHCP operate at?**
    - A) Layer 3 (Network)
    - B) Layer 4 (Transport)
    - C) Layer 7 (Application)
    - D) Layer 2 (Data Link)

---

### 🔑 Answer Key

<b>1. B</b>
<details>
<summary>Show Answer</summary>
Answer: 302 Found (Too many redirects often involves 301/302 loops)
</details>

<b>2. C</b>
<details>
<summary>Show Answer</summary>
Answer: Unauthorized
</details>

<b>3. B</b>
<details>
<summary>Show Answer</summary>
Answer: HSTS
</details>

<b>4. B</b>
<details>
<summary>Show Answer</summary>
Answer: Bad Gateway / Upstream failure
</details>

<b>5. C</b>
<details>
<summary>Show Answer</summary>
Answer: QUIC / 0-RTT
</details>

<b>6. B</b>
<details>
<summary>Show Answer</summary>
Answer: Resource created
</details>

<b>7. C</b>
<details>
<summary>Show Answer</summary>
Answer: Certificate
</details>

<b>8. B</b>
<details>
<summary>Show Answer</summary>
Answer: openssl
</details>

<b>9. B</b>
<details>
<summary>Show Answer</summary>
Answer: 80
</details>

<b>10. D</b>
<details>
<summary>Show Answer</summary>
Answer: GET and PUT
</details>

<b>11. B</b>
<details>
<summary>Show Answer</summary>
Answer: TTL
</details>

<b>12. B</b>
<details>
<summary>Show Answer</summary>
Answer: CNAME
</details>

<b>13. C</b>
<details>
<summary>Show Answer</summary>
Answer: MX record
</details>

<b>14. B</b>
<details>
<summary>Show Answer</summary>
Answer: Reverse DNS
</details>

<b>15. C</b>
<details>
<summary>Show Answer</summary>
Answer: DNSSEC
</details>

<b>16. C</b>
<details>
<summary>Show Answer</summary>
Answer: 13 clusters
</details>

<b>17. B</b>
<details>
<summary>Show Answer</summary>
Answer: dig +trace
</details>

<b>18. B</b>
<details>
<summary>Show Answer</summary>
Answer: DoH
</details>

<b>19. A</b>
<details>
<summary>Show Answer</summary>
Answer: 53
</details>

<b>20. C</b>
<details>
<summary>Show Answer</summary>
Answer: CAA
</details>

<b>21. C</b>
<details>
<summary>Show Answer</summary>
Answer: Discover
</details>

<b>22. A</b>
<details>
<summary>Show Answer</summary>
Answer: DHCP Relay
</details>

<b>23. B</b>
<details>
<summary>Show Answer</summary>
Answer: Option 3
</details>

<b>24. B</b>
<details>
<summary>Show Answer</summary>
Answer: APIPA / DHCP failure
</details>

<b>25. B</b>
<details>
<summary>Show Answer</summary>
Answer: UDP
</details>

<b>26. B</b>
<details>
<summary>Show Answer</summary>
Answer: Reservation
</details>

<b>27. B</b>
<details>
<summary>Show Answer</summary>
Answer: Client accepts offer
</details>

<b>28. B</b>
<details>
<summary>Show Answer</summary>
Answer: Stateless address config
</details>

<b>29. A</b>
<details>
<summary>Show Answer</summary>
Answer: 67
</details>

<b>30. B</b>
<details>
<summary>Show Answer</summary>
Answer: Lease Time
</details>

<b>31. B</b>
<details>
<summary>Show Answer</summary>
Answer: UDP
</details>

<b>32. C</b>
<details>
<summary>Show Answer</summary>
Answer: SYN-ACK
</details>

<b>33. C</b>
<details>
<summary>Show Answer</summary>
Answer: TCP
</details>

<b>34. C</b>
<details>
<summary>Show Answer</summary>
Answer: 1500
</details>

<b>35. B</b>
<details>
<summary>Show Answer</summary>
Answer: BBR
</details>

<b>36. B</b>
<details>
<summary>Show Answer</summary>
Answer: Window Scaling
</details>

<b>37. B</b>
<details>
<summary>Show Answer</summary>
Answer: UDP - 8 bytes
</details>

<b>38. B</b>
<details>
<summary>Show Answer</summary>
Answer: TCP congestion / HOL blocking
</details>

<b>39. C</b>
<details>
<summary>Show Answer</summary>
Answer: RST
</details>

<b>40. C</b>
<details>
<summary>Show Answer</summary>
Answer: FIN
</details>

<b>41. C</b>
<details>
<summary>Show Answer</summary>
Answer: Firewall blocking ICMP
</details>

<b>42. C</b>
<details>
<summary>Show Answer</summary>
Answer: Time Exceeded / TTL expiration
</details>

<b>43. B</b>
<details>
<summary>Show Answer</summary>
Answer: PMTUD
</details>

<b>44. B</b>
<details>
<summary>Show Answer</summary>
Answer: Unreachable
</details>

<b>45. C</b>
<details>
<summary>Show Answer</summary>
Answer: MTR
</details>

<b>46. B</b>
<details>
<summary>Show Answer</summary>
Answer: Optimal route notification
</details>

<b>47. C</b>
<details>
<summary>Show Answer</summary>
Answer: ICMP
</details>

<b>48. B</b>
<details>
<summary>Show Answer</summary>
Answer: NACLs/SGs must allow ICMP specifically
</details>

<b>49. B</b>
<details>
<summary>Show Answer</summary>
Answer: No ports in ICMP
</details>

<b>50. B</b>
<details>
<summary>Show Answer</summary>
Answer: Netcat / ss
</details>

<b>51. C</b>
<details>
<summary>Show Answer</summary>
Answer: ICMP
</details>

<b>52. C</b>
<details>
<summary>Show Answer</summary>
Answer: Port 443, UDP for HTTP/3
</details>

<b>53. B</b>
<details>
<summary>Show Answer</summary>
Answer: IP to MAC
</details>

<b>54. B</b>
<details>
<summary>Show Answer</summary>
Answer: Port closed/Service down
</details>

<b>55. C</b>
<details>
<summary>Show Answer</summary>
Answer: Application Layer
</details>


---

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

- **[Network Devices](../05-network-devices/)** - Learn about network infrastructure
- **[Basic Troubleshooting](../06-basic-troubleshooting/)** - Develop diagnostic skills
- **[Intermediate Level](../../../02-phase-2/)** - Advanced concepts

---

*Understanding these fundamental protocols provides the foundation for all network communication in DevOps environments.*