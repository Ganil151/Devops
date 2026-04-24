# 🔧 Network Diagnostic & Troubleshooting: The SRE Playbook
*Version 1.0 | Systematic Resolution of Connectivity Incidents*

---

## 📖 Overview
Network issues are rarely "random." They follow specific logic based on the OSI model. For a DevOps professional, the goal is not to guess but to prove **exactly** where the packet is dying using systematic diagnostic tools.

---

## 🛠️ The Standard Toolset

### `ping`
**Definition**: Verifies connectivity to a remote host and measures round-trip time (latency) using ICMP.
**Example**: `ping 8.8.8.8` (Test internet connectivity).

### `traceroute` / `tracert`
**Definition**: Shows the path (hops) that a packet takes to reach its destination. Identifying exactly which router is dropping the traffic.
**Example**: `traceroute google.com` (Find latency spikes at a specific ISP hop).

### `dig` / `nslookup`
**Definition**: DNS query tools used to verify hostname resolution and check specific records (A, MX, TXT).
**Example**: `dig +trace api.example.com` (Trace DNS resolution from root to authoritative).

### `netstat` / `ss`
**Definition**: Displays active network connections, listening ports, and routing tables on the local machine.
**Example**: `ss -tulpn` (List all processes listening on TCP/UDP ports).

### `tcpdump` / `Wireshark`
**Definition**: Packet sniffers used to capture and analyze live network traffic at the packet/frame level.
**Example**: `tcpdump -i eth0 port 80` (Inspect raw HTTP traffic on interface eth0).

### `nmap`
**Definition**: A security scanner used to discover hosts and services on a computer network.
**Example**: `nmap -p 1-1000 192.168.1.0/24` (Scan local subnet for open ports).

### `nc` (Netcat)
**Definition**: The "Swiss Army Knife" of networking. Used to test raw TCP/UDP port connectivity.
**Example**: `nc -zv database.server 3306` (Test if a database port is reachable).

---

## 🔍 Systematic Troubleshooting Strategy (Bottom-Up)

1.  **Layer 1 (Physical)**: check logs for interface "LINK-UP" or "DOWN."
2.  **Layer 2 (Data Link)**: check ARP tables (`arp -a`) to see if we can resolve local MAC addresses.
3.  **Layer 3 (Network)**: try to `ping` the default gateway and then an external IP.
4.  **Layer 4 (Transport)**: use `telnet` or `nc` to see if the specific application port is open.
5.  **Layer 7 (Application)**: check application logs and used `curl -v` to inspect HTTP headers.

---

## 💡 Real-World SRE Scenarios

### Scenario: "The app is down!"
- **Step 1**: Use `ping` to see if the server is alive.
- **Step 2**: Use `nc -zv <host> <port>` to see if the app is listening.
- **Step 3**: Use `dig` to verify the hostname isn't pointing to an old IP.
- **Step 4**: Use `curl -I` to see if the webserver is returning a `5xx` error.

### Scenario: "It's slow for some users but not others."
- **Step 1**: Run `mtr` (My Traceroute) from the affected user's location.
- **Step 2**: Check for "Packet Loss" at specific hops.
- **Step 3**: Inspect the Load Balancer latency metrics in CloudWatch/Grafana.

---
**Next Step**: [Back to Fundamentals →](./network-models-ref.md)
