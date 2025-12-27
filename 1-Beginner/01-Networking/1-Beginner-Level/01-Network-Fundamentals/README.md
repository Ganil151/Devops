# Network Fundamentals

Understanding the core concepts of computer networking is essential for any DevOps professional. This section covers the foundational knowledge needed to work with modern network infrastructure.

## 🎯 Learning Objectives

- Understand the OSI and TCP/IP models
- Learn network topologies and architectures
- Grasp data transmission fundamentals
- Identify different network types
- Master essential networking terminology

## 📖 Core Concepts

### OSI Model (Open Systems Interconnection)

The OSI model is a conceptual framework that standardizes network communication functions into seven layers:

```
┌─────────────────────────────────────────┐
│ Layer 7: Application Layer              │ ← HTTP, FTP, SMTP, DNS
├─────────────────────────────────────────┤
│ Layer 6: Presentation Layer             │ ← Encryption, Compression
├─────────────────────────────────────────┤
│ Layer 5: Session Layer                  │ ← Session Management
├─────────────────────────────────────────┤
│ Layer 4: Transport Layer                │ ← TCP, UDP
├─────────────────────────────────────────┤
│ Layer 3: Network Layer                  │ ← IP, Routing
├─────────────────────────────────────────┤
│ Layer 2: Data Link Layer                │ ← Ethernet, Switching
├─────────────────────────────────────────┤
│ Layer 1: Physical Layer                 │ ← Cables, Signals
└─────────────────────────────────────────┘
```

#### Layer Functions:

**Layer 1 - Physical Layer**
- Transmits raw bits over physical medium
- Defines electrical and physical specifications
- Examples: Ethernet cables, fiber optics, wireless signals

**Layer 2 - Data Link Layer**
- Provides node-to-node delivery
- Error detection and correction
- MAC addressing and frame formatting
- Examples: Ethernet, Wi-Fi, PPP

**Layer 3 - Network Layer**
- Routing between different networks
- Logical addressing (IP addresses)
- Path determination
- Examples: IPv4, IPv6, ICMP

**Layer 4 - Transport Layer**
- End-to-end communication
- Reliability and flow control
- Port addressing
- Examples: TCP, UDP

**Layer 5 - Session Layer**
- Establishes, manages, and terminates sessions
- Synchronization and checkpointing
- Examples: NetBIOS, RPC

**Layer 6 - Presentation Layer**
- Data translation and encryption
- Compression and decompression
- Examples: SSL/TLS, JPEG, ASCII

**Layer 7 - Application Layer**
- Network services to applications
- User interface
- Examples: HTTP, FTP, SMTP, DNS

### TCP/IP Model

The TCP/IP model is a simpler, more practical model used in real networks:

```
┌─────────────────────────────────────────┐
│ Application Layer                       │ ← Combines OSI Layers 5-7
├─────────────────────────────────────────┤
│ Transport Layer                         │ ← TCP, UDP
├─────────────────────────────────────────┤
│ Internet Layer                          │ ← IP, ICMP
├─────────────────────────────────────────┤
│ Network Access Layer                    │ ← Combines OSI Layers 1-2
└─────────────────────────────────────────┘
```

## 🏗️ Network Topologies

### Physical Topologies

**Bus Topology**
```
Device1 ──── Device2 ──── Device3 ──── Device4
```
- All devices connected to a single cable
- Simple but single point of failure

**Star Topology**
```
    Device2
        │
Device1 ─── Hub/Switch ─── Device3
        │
    Device4
```
- All devices connect to central hub/switch
- Most common in modern networks

**Ring Topology**
```
Device1 ──── Device2
   │            │
Device4 ──── Device3
```
- Devices connected in circular fashion
- Data travels in one direction

**Mesh Topology**
```
Device1 ──── Device2
   │    \  /    │
   │     \/     │
   │     /\     │
   │    /  \    │
Device4 ──── Device3
```
- Every device connected to every other device
- Highly redundant but expensive

### Logical Topologies

**Broadcast Domain**: All devices that receive broadcast frames
**Collision Domain**: Network segment where collisions can occur

## 🌐 Network Types

### By Geographic Scope

**LAN (Local Area Network)**
- Limited geographic area (building, campus)
- High-speed, low-latency connections
- Typically owned by single organization
- Examples: Office networks, home networks

**WAN (Wide Area Network)**
- Covers large geographic areas
- Connects multiple LANs
- Often uses public infrastructure
- Examples: Internet, corporate networks

**MAN (Metropolitan Area Network)**
- Covers city or metropolitan area
- Larger than LAN, smaller than WAN
- Examples: City-wide Wi-Fi, cable TV networks

**PAN (Personal Area Network)**
- Very small area around individual
- Examples: Bluetooth, USB connections

### By Ownership

**Private Networks**
- Owned and operated by organization
- Full control over infrastructure
- Examples: Corporate LANs, data centers

**Public Networks**
- Available to general public
- Examples: Internet, public Wi-Fi

**Hybrid Networks**
- Combination of private and public
- Examples: VPN over Internet

## 📡 Data Transmission Fundamentals

### Transmission Methods

**Simplex Communication**
- One-way communication only
- Example: Radio broadcast

**Half-Duplex Communication**
- Two-way communication, but not simultaneous
- Example: Walkie-talkies

**Full-Duplex Communication**
- Simultaneous two-way communication
- Example: Telephone conversation

### Transmission Media

**Guided Media (Wired)**
- Twisted Pair Cable (Cat5e, Cat6, Cat6a)
- Coaxial Cable
- Fiber Optic Cable

**Unguided Media (Wireless)**
- Radio Waves
- Microwaves
- Infrared

### Signal Types

**Analog Signals**
- Continuous wave forms
- Can have infinite values
- Susceptible to noise

**Digital Signals**
- Discrete values (0s and 1s)
- More reliable over long distances
- Easier to process and store

## 🔧 Essential Networking Terminology

**Bandwidth**: Maximum data transfer rate of a network path
**Latency**: Time delay in data transmission
**Throughput**: Actual data transfer rate achieved
**Jitter**: Variation in packet arrival times
**Packet Loss**: Percentage of packets that fail to reach destination

**Protocol**: Set of rules governing communication
**Port**: Logical endpoint for network communication
**Socket**: Combination of IP address and port number
**Frame**: Data unit at Layer 2 (Data Link)
**Packet**: Data unit at Layer 3 (Network)
**Segment**: Data unit at Layer 4 (Transport)

**Unicast**: One-to-one communication
**Broadcast**: One-to-all communication
**Multicast**: One-to-many communication
**Anycast**: One-to-nearest communication

## 🛠️ Practical Examples

### Network Communication Flow

When you access a website (www.example.com):

1. **Application Layer**: Browser creates HTTP request
2. **Transport Layer**: TCP adds port information (80/443)
3. **Network Layer**: IP adds source/destination addresses
4. **Data Link Layer**: Ethernet adds MAC addresses
5. **Physical Layer**: Electrical signals transmitted over cable

### DevOps Relevance

Understanding these fundamentals helps with:
- **Infrastructure Design**: Choosing appropriate network architectures
- **Troubleshooting**: Identifying which layer has issues
- **Security**: Understanding attack vectors at each layer
- **Performance**: Optimizing based on network characteristics
- **Monitoring**: Knowing what metrics to track

## 🧪 Hands-On Labs

### Lab 1: OSI Model Analysis
Use Wireshark to capture network traffic and identify OSI layers:
```bash
# Install Wireshark
sudo apt-get install wireshark

# Capture HTTP traffic
sudo tcpdump -i eth0 -w capture.pcap port 80

# Analyze in Wireshark
wireshark capture.pcap
```

### Lab 2: Network Topology Discovery
Map your local network topology:
```bash
# Discover devices on network
nmap -sn 192.168.1.0/24

# Trace network path
traceroute google.com

# Show network interfaces
ip addr show
```

## 📚 Additional Resources

- [OSI Model Interactive Tutorial](https://www.cisco.com/c/en/us/support/docs/lan-switching/spanning-tree-protocol/5234-5.html)
- [TCP/IP Protocol Suite Documentation](https://tools.ietf.org/rfc/)
- [Network+ Study Guide](https://www.comptia.org/certifications/network)

## ✅ Knowledge Check

Before proceeding, ensure you can:
- [ ] Explain each OSI layer and its function
- [ ] Compare OSI and TCP/IP models
- [ ] Identify different network topologies
- [ ] Distinguish between network types (LAN, WAN, MAN)
- [ ] Define key networking terminology
- [ ] Describe data transmission methods

---

*Next: [IP Addressing](../IP-Addressing/) - Learn about network addressing and subnetting*