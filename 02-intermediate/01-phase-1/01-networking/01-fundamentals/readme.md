# 🌐 Part 1: Networking Fundamentals (NRE Edition)

> **"Junior, anyone can plug in a cable. A Network Reliability Engineer (NRE) understands the invisible currents of data. If you don't know *why* a packet dropped, you can't fix it. We are moving from 'Connecting' to 'Diagnosing'."**

---

## 🏗️ The Junior NRE Briefing

**Your Status**: You know what an IP address is. You know what HTTP is.
**Your New Goal**: Diagnostics, Reliability, and Scale.

**The Shift**:
*   **Beginner**: "My computer has IP `192.168.1.5`."
*   **Intermediate**: "My VPC peering connection failed because of overlapping `/16` CIDR blocks, and now the route table is blackholing traffic."

**Key Tools We Will Use**:
*   `dig +trace` (DNS Diagnostics)
*   `mtr` (Real-time Latency Analysis)
*   `ss -tulpn` (Socket Inspection)
*   `tcpdump` (Packet Capture)

---

## � Module Structure

This isn't a textbook. It's a field manual.

### 1. [DNS & DHCP: Service Discovery or Service Disaster?](./key-concepts/01-dns-dhcp/readme.md)
*   **Why**: DNS is the #1 cause of "It works on my machine" but fails in production.
*   **Focus**: TTL Caching, Recursive vs. Iterative, and K8s CoreDNS.

### 2. [Subnetting & CIDR: The Architecture of Isolation](./key-concepts/02-subnetting-and-cidr/readme.md)
*   **Why**: If you pick the wrong CIDR size today, you will rebuild the entire network in 6 months.
*   **Focus**: VPC Sizing, The "Reserved 5", and Zoning Strategies.

### 3. [Routing & Traffic Control](./key-concepts/04-routing-and-route-tables/readme.md)
*   **Why**: Packets are dumb. Route tables are the map.
*   **Focus**: Longest Prefix Match (LPM), Blackholes, and Peering logic.

---

## 🛠️ The "NRE" Toolkit Setup

Before you start, ensure you have these tools installed in your lab environment (Linux):

```bash
# The "Swiss Army Knife" of counters
sudo apt install iproute2 -y

# DNS Tools
sudo apt install dnsutils -y 

# Network Diagnostics
sudo apt install mtr tcpdump traceroute -y
```

### Quick Diagnostic Check
Run this to see your *real* connectivity profile:

```bash
# Show all listening TCP ports (Sockets)
ss -tulpn

# Trace the full path to Google with latency data
mtr -r -c 5 google.com
```

---

## 🔗 Learning Path

1.  Start with **[DNS & DHCP](./key-concepts/01-dns-dhcp/readme.md)**.
2.  Move to **[Subnetting & CIDR](./key-concepts/02-subnetting-and-cidr/readme.md)**.
3.  Finish with **[Routing & Tables](./key-concepts/04-routing-and-route-tables/readme.md)**.
