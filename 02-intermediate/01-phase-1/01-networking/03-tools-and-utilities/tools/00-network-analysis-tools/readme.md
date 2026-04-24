# 🧰 Module 00: Network Analysis Tools

## 📖 Overview
In the world of DevOps, "I think the network is slow" is not an actionable statement. You need data. This module covers the core tools used to capture, analyze, and troubleshoot network traffic at the packet level.

## 🎓 Learning Objectives
- ✅ Master **Tcpdump** for command-line packet capture.
- ✅ Analyze complex traffic patterns using **Wireshark**.
- ✅ Perform network discovery and security audits with **Nmap**.
- ✅ Monitor active connections and sockets with **Netstat/SS**.

## 🛠️ The Toolkit

### 1. Tcpdump (The CLI Sniffer)
The standard tool for capturing traffic on remote Linux servers.
- **Example**: `tcpdump -i eth0 port 80 -w capture.pcap`
- **Key Skill**: Using filters (`host`, `port`, `net`) to avoid "Information Overload."

### 2. Wireshark (The GUI Analyzer)
The "Microscope" of the network. Use it to open `.pcap` files and see the exact handshake of a failing TLS connection.
- **Feature**: "Follow TCP Stream" to see the human-readable conversation.

### 3. Nmap (The Network Mapper)
Used to find what's "alive" on a network and which ports are open.
- **Example**: `nmap -sV 10.0.1.0/24` (Scans a subnet and identifies service versions).

### 4. Netstat / SS (The Internal View)
Seeing what's happening *inside* the OS.
- **Example**: `ss -tulnp` (Shows all listening TCP/UDP ports and the process ID using them).

---
Check the main Part 3 README for next steps.
