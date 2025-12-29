# VPC Foundations: The Core of Cloud Networking

A **Virtual Private Cloud (VPC)** is your private, isolated corner of the cloud. Understanding how to build one correctly is essential for every DevOps engineer.

---

## 🏗️ Core Components

### 1. The CIDR Block
Your VPC's address space. It defines the range of private IP addresses your resources can use.
*Example:* `10.0.0.0/16` gives you 65,536 possible IP addresses.

### 2. Internet Gateway (IGW)
The "Door" to the internet. Without an IGW attached to your VPC, your servers cannot talk to the outside world, nor can the world talk to them.

### 3. Route Tables (RT)
The "Traffic Police." Route tables contain sets of rules (routes) that determine where network traffic from your subnet or gateway is directed.

### 4. Network ACLs (NACLs) vs. Security Groups
- **NACLs**: Stateless, subnet-level security.
- **Security Groups**: Stateful, instance-level security (The "Virtual Firewall").

---

## 🚦 Basic Connectivity Workflow

1. **Create the VPC** and assign a CIDR.
2. **Create Subnets** across different Availability Zones (AZs).
3. **Create an Internet Gateway** and attach it to the VPC.
4. **Create a Route Table** and add a route: `0.0.0.0/0 -> igw-id`.
5. **Associate the Subnet** with that Public Route Table.

---

## 🎯 Key Terms to Remember
- **IPv4**: 32-bit address (e.g., `172.16.0.1`).
- **Subnet Mask**: Defines the network and host portion of an IP.
- **RFC 1918**: The standard that defines private IP address ranges (`10.x`, `172.16.x`, `192.168.x`).
