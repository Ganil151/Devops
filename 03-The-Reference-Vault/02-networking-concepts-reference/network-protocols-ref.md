# 📡 Network Protocols & Services: The Connectivity Guide
*Version 1.0 | Standardized Languages of the Internet*

---

## 📖 Overview
Protocols are the "rules of engagement" that allow different systems to communicate. For SREs, mastering these protocols is essential for configuring load balancers, securing APIs, and diagnosing multi-tier application failures.

---

## 🌐 Web & Application Protocols

### HTTP / HTTPS
**Definition**: The foundation of data exchange on the web. Operating on Ports 80 (HTTP) and 443 (HTTPS).
**Examples**:
- **HTTP Methods**: GET (read), POST (create), PUT (update), DELETE (remove).
- **Status Codes**: 200 (OK), 404 (Not Found), 503 (Service Unavailable).

### DNS (Domain Name System)
**Definition**: The "Phonebook of the Internet." Translates hostnames (`google.com`) to IP addresses.
**Examples**:
- **A Record**: Maps name to IPv4.
- **CNAME**: Alias (maps name to another name).
- **MX**: Route mail to a mail server.

---

## 🏗️ Core Transmission Protocols

### TCP (Transmission Control Protocol)
**Definition**: A reliable, connection-oriented protocol that ensures packets arrive in order and without errors via the "3-Way Handshake." 
**Usage**: Web browsing, Databases, SSH, Email.
**Example**: Standard HTTP request over a TCP connection.

### UDP (User Datagram Protocol)
**Definition**: A fast, connectionless protocol that sends data without checking for success (Fire-and-forget).
**Usage**: DNS Queries, Voice/Video streaming, DHCP, SNMP.
**Example**: A real-time video call dropping a frame without stopping the stream.

### ICMP (Internet Control Message Protocol)
**Definition**: A diagnostic protocol used by network devices to send error messages and operational information.
**Usage**: Connectivity testing and path discovery.
**Example**: Running a `ping` or `traceroute`.

---

## ⚙️ Infrastructure Services

### DHCP (Dynamic Host Configuration Protocol)
**Definition**: Automatically assigns IP addresses, subnet masks, and gateways to devices on a network.
**Process**: **DORA** (Discover, Offer, Request, Acknowledge).
**Example**: Your laptop getting an IP address automatically the moment it joins a Wi-Fi network.

### SSH (Secure Shell)
**Definition**: A protocol for secure remote login and command execution over an unsecured network. Port 22.
**Example**: `ssh root@production-server-01`.

### SMTP (Simple Mail Transfer Protocol)
**Definition**: The standard protocol for sending emails across the internet. Port 25.
**Example**: Your application sending a "Password Reset" email to a user.

---

## 🛡️ SRE Troubleshooting Scenarios
- **DNS Issues**: "It works by IP but not by name." → Check local DNS resolver (`/etc/resolv.conf`) or the Cloud DNS zone.
- **Port Blocking**: "I can ping it but I can't load the web page." → Check if Port 80/443 is open in the firewall.
- **Handshake Failures**: "Connection Reset by Peer." → Usually implies a firewall dropped the TCP SYN-ACK or the service isn't listening.

---
**Next Step**: [Network Hardware & Devices →](./network-devices-hardware-ref.md)
