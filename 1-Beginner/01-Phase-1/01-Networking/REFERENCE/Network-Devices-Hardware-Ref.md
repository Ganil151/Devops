# 🔌 Network Hardware & Devices: The Infrastructure Manual
*Version 1.0 | Physical & Virtual Appliances for Traffic Management*

---

## 📖 Overview
Network hardware form the physical components that carry data. In the modern cloud era, these physical boxes have been replaced by "Virtual Appliances" (VPCs, NLBs, ALBs), but the logical principles remain identical. Understanding these devices is key to building highly available architectures.

---

## 🏗️ Essential Network Hardware

### Router
**Definition**: A Layer 3 device that forwards packets between different networks and makes path determinations using a Routing Table.
**Example**: An AWS Route Table directing traffic from a private subnet to an NAT Gateway.

### Switch
**Definition**: A Layer 2 device that connects devices within the same network and forwards frames based on MAC addresses.
**Example**: An on-premise Cisco switch connecting all servers in a single rack.

### Hub
**Definition**: A Layer 1 legacy device that broadcasts all incoming data to every port. Creating huge collision domains.
**Status**: Obsolete in modern production environments.

---

## 🛡️ Security & Performance Appliances

### Firewall
**Definition**: A security appliance that monitors and controls incoming/outgoing traffic based on predefined security rules.
**Example**: An AWS Security Group (Stateful) or a Network ACL (Stateless).

### Load Balancer
**Definition**: A device or service that distributes network traffic across multiple servers to ensure high availability and performance.
**Types**:
- **ALB (Application)**: Layer 7 (HTTP/HTTPS logic).
- **NLB (Network)**: Layer 4 (TCP/UDP high-speed).

### WAP (Wireless Access Point)
**Definition**: A hardware device that allows other Wi-Fi devices to connect to a wired network.
**Example**: The office router providing wireless internet for corporate laptops.

---

## 🧱 Connectivity Media

### Ethernet Cable (Cat5e/6/6a)
**Definition**: Twisted-pair copper cables used for high-speed local connections.
**Standard**: RJ45 Connector.

### Fiber Optic
**Definition**: Glass or plastic fibers that transmit data as light pulses. Used for extremely long distances and high bandwidth.
**Example**: Data center backend links and trans-Atlantic internet cables.

---

## 💡 Troubleshooting Device Failures
- **Interface Flapping**: When a router or switch port rapidly goes Up and Down. Usually caused by a faulty cable or bad NIC.
- **ARP Poisoning**: A Layer 2 attack where a device claims to have the MAC address of the Gateway to intercept local traffic.
- **Port Saturation**: When the physical bandwidth of a switch port (e.g., 1Gbps) is hit, causing packet drops.

---
**Next Step**: [Diagnostic Tools & Troubleshooting →](./Network-Troubleshooting-Ref.md)
