# 🌐 IP Addressing & Subnetting: The Architect's Manual
*Version 1.0 | Logical Addressing & Network Segmentation*

---

## 📖 Overview
IP addressing is the GPS of network communication. In DevOps, mastering subnetting and CIDR is mandatory for designing VPCs (Virtual Private Clouds), managing container orchestration (Kubernetes), and ensuring secure network isolation.

---

## 🔢 IPv4 Fundamentals

### IPv4 Structure
**Definition**: A 32-bit logical address represented as four "octets" in dotted-decimal format.
**Example**: `192.168.1.100`

### CIDR Notation
**Definition**: A compact representation of an IP address and its associated network mask. The "slash" (/) indicates the number of network bits.
**Example**:
- `/24` (255.255.255.0): 254 usable hosts.
- `/16` (255.255.0.0): 65,534 usable hosts.
- `/32`: Exactly one single host IP.

### RFC 1918 (Private IP Ranges)
**Definition**: Standard IP ranges reserved for internal private networks, never routable on the public internet.
**Ranges**:
- **10.0.0.0/8**: Used for large data centers and enterprise VPCs.
- **172.16.0.0/12**: Often used for Docker/Container networks.
- **192.168.0.0/16**: Standard for home and small office networks.

---

## 🌐 IPv6 Essentials

### IPv6 Structure
**Definition**: A 128-bit address represented in hexadecimal to overcome IPv4 exhaustion.
**Example**: `2001:0db8:85a3:0000:0000:8a2e:0370:7334`

### IPv6 Types
**Global Unicast**: Equivalent to a public IPv4 address (`2000::/3`).
**Link-Local**: Used for communication within a single network segment (`fe80::/10`).
**Unique Local**: Private IPv6 ranges (`fc00::/7`).

---

## 🔄 NAT & Translation

### Static NAT
**Definition**: A permanent 1-to-1 mapping between a private IP and a public IP.
**Example**: Mapping a specific internal Web Server to a dedicated Public IP for incoming traffic.

### PAT (Port Address Translation)
**Definition**: Also known as "NAT Overload." Maps multiple private IPs to a single public IP by rotating ports.
**Example**: An entire office of 100 people browsing the web using one single public WAN IP on their router.

---

## 🏗️ Subnetting in Practice

### Subnet Identification
**Definition**: The process of dividing a large network into smaller segments to increase security and reduce broadcast traffic.
**Example**:
- **VPC Subnet 1 (Public)**: `10.0.1.0/24` (Web Servers)
- **VPC Subnet 2 (Private)**: `10.0.2.0/24` (Databases)

### VLSM (Variable Length Subnet Masking)
**Definition**: Efficiently allocating subnets of different sizes to match the exact host requirements.
**Example**: Assigning a `/30` for point-to-point router links (2 IPs) and a `/24` for a server farm (254 IPs) within the same network block.

---

## 💡 Pro-Tips for DevOps Architects
- **Overlap Prevention**: When peering two VPCs, ensure their CIDR blocks do not overlap (e.g., don't connect `10.0.0.0/16` to another `10.0.0.0/16`).
- **The First and Last IP**: Remember that in any subnet, the **First IP** is the Network ID and the **Last IP** is the Broadcast ID. Neither can be assigned to a server.
- **Gateway Standard**: By convention, the `.1` IP in a subnet is usually reserved for the Default Gateway (the router).

---
**Next Step**: [Network Protocols & Services →](./network-protocols-ref.md)
