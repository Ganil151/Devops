# 🌐 Part 1: Networking Fundamentals

Welcome to the foundational module of the Networking Track. This section covers the essential concepts that drive data communication across the globe. Understanding these fundamentals is critical for any DevOps engineer managing cloud or on-premise infrastructure.

---

## 📖 Overview

Networking is the study of how computers communicate. In this part, we break down the complex web of protocols and hardware into manageable concepts:

- **Foundational Models**: OSI and TCP/IP layers.
- **Addressing**: How machines find each other using IP addresses (IPv4 & IPv6).
- **Organization**: Subnetting and CIDR for efficient network design.
- **Discovery & Resolution**: DNS for naming and DHCP for address assignment.
- **Pathfinding**: How routers move data toward its final destination.

## 🔑 Key Topics Covered

### 1. The OSI & TCP/IP Models

The standard frameworks for understanding network communication.

- **Layer 7 (Application)**: HTTP, DNS, SSH.
- **Layer 4 (Transport)**: TCP (Reliable) vs UDP (Fast).
- **Layer 3 (Network)**: IP Addressing and Routing.
- **Layer 2 (Data Link)**: MAC addresses and Switching.

### 2. IP Addressing & Subnetting

- **Public vs Private IPs**: RFC 1918 space (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16).
- **CIDR Notation**: Understanding `/24`, `/16`, and beyond.
- **IPv4 vs IPv6**: The transition to a larger address space.

### 3. DNS & DHCP

- **DNS (Domain Name System)**: Translating `google.com` to `142.250.190.46`.
- **DHCP (Dynamic Host Configuration Protocol)**: Automatically assigning IPs to devices as they join a network.

### 4. Routing

- **Default Gateways**: Where to go when you don't know the path.
- **Route Tables**: The maps used by systems to decide where to send packets.

## 🛠️ Practical Examples (Terminal)

Check the **[Examples/](./Examples/)** directory for more detailed walkthroughs.

- `ping google.com`: Test basic connectivity.
- `nslookup google.com`: Resolve a domain name to an IP.
- `traceroute google.com`: See every hop a packet takes across the internet.
- `ip addr` (Linux) or `ipconfig` (Windows): View your local connection details.

---

## 📂 Subdirectories

- **[Key-Concepts/](./Key-Concepts/)**: Detailed deep-dives into DNS, DHCP, Subnetting, and Routing.
- **[Diagrams/](./Diagrams/)**: Visual aids illustrating network topologies and packet lifecycles.
- **[Examples/](./Examples/)**: Hands-on scripts and command logs for practicing networking skills.

---

## 🔗 Learning Path

1. Start with **[OSI Model Explained](./Key-Concepts/04-Routing-and-Route-Tables/README.md)** (Routing covers layer 3).
2. Master **[Subnetting & CIDR](./Key-Concepts/02-Subnetting-and-CIDR/README.md)** to design secure networks.
3. Understand infrastructure services in **[DNS & DHCP](./Key-Concepts/01-DNS-DHCP/README.md)**.
