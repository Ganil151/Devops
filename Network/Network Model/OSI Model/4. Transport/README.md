# Transport Layer (Layer 4) - OSI Model

## Overview

The Transport Layer provides reliable data transfer services to upper layers. It handles end-to-end communication, error recovery, flow control, and ensures data integrity between applications.

## Key Functions

### 1. Segmentation and Reassembly
- **Segmentation**: Breaks large messages into smaller segments
- **Reassembly**: Reconstructs original message from segments
- **Sequence Numbers**: Ensures proper ordering of segments

### 2. Connection Management
- **Connection Establishment**: Three-way handshake (TCP)
- **Connection Maintenance**: Keep-alive mechanisms
- **Connection Termination**: Graceful connection closure

### 3. Flow Control
- **Window Size**: Controls amount of data sent before acknowledgment
- **Sliding Window**: Dynamic adjustment of transmission rate
- **Congestion Control**: Prevents network overload

### 4. Error Detection and Recovery
- **Checksums**: Detect corrupted data
- **Acknowledgments**: Confirm successful delivery
- **Retransmission**: Resend lost or corrupted segments

## Transport Layer Protocols

### Transmission Control Protocol (TCP)

#### TCP Header Structure
```bash
# TCP Header (20 bytes minimum)
Source Port (16 bits) | Destination Port (16 bits)
Sequence Number (32 bits)
Acknowledgment Number (32 bits)
Header Length (4 bits) | Reserved (6 bits) | Flags (6 bits) | Window Size (16 bits)
Checksum (16 bits) | Urgent Pointer (16 bits)
Options (variable) | Padding (variable)
```

#### TCP Flags
```bash
# TCP Control Flags
URG (Urgent): Urgent pointer field is significant
ACK (Acknowledgment): Acknowledgment field is significant
PSH (Push): Push function
RST (Reset): Reset the connection
SYN (Synchronize): Synchronize sequence numbers
FIN (Finish): No more data from sender
```

#### TCP Three-Way Handshake
```bash
# Connection Establishment
Client → Server: SYN (seq=x)
Server → Client: SYN-ACK (seq=y, ack=x+1)
Client → Server: ACK (seq=x+1, ack=y+1)

# Connection established, data transfer begins
```

#### TCP Connection Termination
```bash
# Four-Way Handshake
Client → Server: FIN (seq=x)
Server → Client: ACK (ack=x+1)
Server → Client: FIN (seq=y)
Client → Server: ACK (ack=y+1)

# Connection closed
```

### User Datagram Protocol (UDP)

#### UDP Header Structure
```bash
# UDP Header (8 bytes)
Source Port (16 bits) | Destination Port (16 bits)
Length (16 bits) | Checksum (16 bits)
Data (variable)
```

#### UDP Characteristics
```bash
# UDP Features
- Connectionless protocol
- No reliability guarantees
- No flow control
- No congestion control
- Minimal overhead
- Fast transmission
- Used for real-time applications
```

## Port Numbers and Services

### Well-Known Ports (0-1023)
```bash
# Common TCP Ports
20/21: FTP (File Transfer Protocol)
22: SSH (Secure Shell)
23: Telnet
25: SMTP (Simple Mail Transfer Protocol)
53: DNS (Domain Name System)
80: HTTP (Hypertext Transfer Protocol)
110: POP3 (Post Office Protocol)
143: IMAP (Internet Message Access Protocol)
443: HTTPS (HTTP Secure)
993: IMAPS (IMAP Secure)
995: POP3S (POP3 Secure)

# Common UDP Ports
53: DNS
67/68: DHCP (Dynamic Host Configuration Protocol)
69: TFTP (Trivial File Transfer Protocol)
123: NTP (Network Time Protocol)
161/162: SNMP (Simple Network Management Protocol)
514: Syslog
```

### Registered Ports (1024-49151)
```bash
# Application-Specific Ports
1433: Microsoft SQL Server
1521: Oracle Database
3306: MySQL
3389: RDP (Remote Desktop Protocol)
5432: PostgreSQL
5900: VNC (Virtual Network Computing)
8080: HTTP Alternative
8443: HTTPS Alternative
```

## TCP Flow Control and Congestion Control

### Sliding Window Protocol
```bash
# Window Size Management
Initial Window Size: Negotiated during handshake
Window Scaling: Allows larger windows (RFC 1323)
Zero Window: Receiver buffer full, stop sending

# Example Window Operation
Sender Window: [1][2][3][4][5][ ][ ][ ]
Sent and ACKed: [✓][✓][ ][ ][ ][ ][ ][ ]
Can Send: [ ][ ][3][4][5][ ][ ][ ]
```

### Congestion Control Algorithms
```bash
# TCP Congestion Control
Slow Start: Exponential increase in window size
Congestion Avoidance: Linear increase after threshold
Fast Retransmit: Retransmit on 3 duplicate ACKs
Fast Recovery: Avoid slow start after fast retransmit

# Modern Algorithms
TCP Cubic: Default in Linux
TCP BBR: Google's algorithm for high-speed networks
```

## Socket Programming

### TCP Socket Example (Python)
```python
# TCP Server
import socket

server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind(('localhost', 8080))
server_socket.listen(5)

while True:
    client_socket, address = server_socket.accept()
    data = client_socket.recv(1024)
    client_socket.send(b"HTTP/1.1 200 OK\r\n\r\nHello World")
    client_socket.close()

# TCP Client
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_socket.connect(('localhost', 8080))
client_socket.send(b"GET / HTTP/1.1\r\n\r\n")
response = client_socket.recv(1024)
client_socket.close()
```

### UDP Socket Example (Python)
```python
# UDP Server
import socket

server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
server_socket.bind(('localhost', 8080))

while True:
    data, address = server_socket.recvfrom(1024)
    server_socket.sendto(b"Echo: " + data, address)

# UDP Client
client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
client_socket.sendto(b"Hello UDP", ('localhost', 8080))
response, address = client_socket.recvfrom(1024)
client_socket.close()
```

## Load Balancing at Transport Layer

### Layer 4 Load Balancing
```bash
# HAProxy Layer 4 Configuration
global
    daemon
    maxconn 4096

defaults
    mode tcp
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

frontend tcp_frontend
    bind *:80
    default_backend tcp_servers

backend tcp_servers
    balance roundrobin
    server web1 192.168.1.10:80 check
    server web2 192.168.1.11:80 check
    server web3 192.168.1.12:80 check
```

### Connection Multiplexing
```bash
# Nginx Stream Module
stream {
    upstream backend {
        server 192.168.1.10:3306 weight=3;
        server 192.168.1.11:3306 weight=2;
        server 192.168.1.12:3306 weight=1;
    }
    
    server {
        listen 3306;
        proxy_pass backend;
        proxy_timeout 1s;
        proxy_responses 1;
    }
}
```

## Transport Layer Security

### TLS/SSL at Transport Layer
```bash
# TLS Handshake Process
1. Client Hello (supported ciphers, random number)
2. Server Hello (chosen cipher, certificate, random number)
3. Client Key Exchange (pre-master secret)
4. Change Cipher Spec (both sides)
5. Finished messages (encrypted)

# TLS Configuration (Nginx)
server {
    listen 443 ssl http2;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;
}
```

## Performance Tuning

### TCP Tuning Parameters
```bash
# Linux TCP Tuning
# /etc/sysctl.conf

# TCP Buffer Sizes
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 65536 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# TCP Congestion Control
net.ipv4.tcp_congestion_control = bbr

# TCP Window Scaling
net.ipv4.tcp_window_scaling = 1

# TCP Timestamps
net.ipv4.tcp_timestamps = 1

# Apply changes
sysctl -p
```

### Connection Pooling
```python
# Connection Pool Example (Python)
import psycopg2.pool

# Create connection pool
connection_pool = psycopg2.pool.ThreadedConnectionPool(
    minconn=1,
    maxconn=20,
    host='localhost',
    database='mydb',
    user='user',
    password='password'
)

# Use connection from pool
def execute_query(query):
    conn = connection_pool.getconn()
    try:
        cursor = conn.cursor()
        cursor.execute(query)
        result = cursor.fetchall()
        return result
    finally:
        connection_pool.putconn(conn)
```

## Monitoring and Troubleshooting

### Network Analysis Tools
```bash
# netstat - Network connections
netstat -tuln                     # List listening ports
netstat -an | grep :80           # Check specific port
netstat -i                       # Interface statistics

# ss - Socket statistics (modern replacement for netstat)
ss -tuln                         # List listening sockets
ss -t state established          # Show established TCP connections
ss -s                           # Summary statistics

# tcpdump - Packet capture
tcpdump -i eth0 port 80          # Capture HTTP traffic
tcpdump -i eth0 -w capture.pcap  # Save to file
tcpdump -r capture.pcap          # Read from file
```

### Performance Monitoring
```bash
# iftop - Interface bandwidth usage
iftop -i eth0                    # Monitor interface traffic

# nethogs - Process network usage
nethogs eth0                     # Show per-process bandwidth

# iperf3 - Network performance testing
iperf3 -s                        # Server mode
iperf3 -c server_ip              # Client mode
iperf3 -c server_ip -u           # UDP test
```

## DevOps Integration

### Container Networking
```yaml
# Docker Compose with custom networks
version: '3.8'
services:
  web:
    image: nginx
    ports:
      - "80:80"
    networks:
      - frontend
  
  api:
    image: myapi
    networks:
      - frontend
      - backend
  
  db:
    image: postgres
    networks:
      - backend

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true
```

### Kubernetes Services
```yaml
# Kubernetes Service (Layer 4)
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 8080
      protocol: TCP
  selector:
    app: web
```

### Infrastructure Monitoring
```yaml
# Prometheus configuration for transport layer metrics
scrape_configs:
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
    metrics_path: /metrics
    scrape_interval: 15s
```

## Best Practices

### 1. Protocol Selection
- Use TCP for reliable data transfer
- Use UDP for real-time applications
- Consider QUIC for modern web applications
- Implement proper error handling

### 2. Performance Optimization
- Tune TCP parameters for your workload
- Use connection pooling
- Implement proper timeout values
- Monitor connection states

### 3. Security
- Use TLS for encrypted communication
- Implement proper certificate management
- Regular security updates
- Monitor for suspicious connections

### 4. Scalability
- Design for horizontal scaling
- Use load balancers effectively
- Implement connection limits
- Plan for traffic growth