# 🌐 Networking Fundamentals Guide
*Version 1.0 | Detailed Analysis of Cloud Subnetting and Routing*

---

## 🏗️ Technical Architecture
<img src="https://raw.githubusercontent.com/Ganil151/Devops/main/1-Beginner/01-Phase-1/07-Cloud-Foundations/REFERENCE/assets/cloud-networking.webp" alt="Cloud VPC Architecture" width="800">

### Subnet Calculation (The Math of Scale)
A CIDR (Classless Inter-Domain Routing) block consists of an IP and a mask (e.g., `/24`).
- **Formula**: Usable IPs = $2^{(32 - Mask)} - 5$ (AWS subtracts 5 for network, gateway, DNS, and broadcast).
- **/24**: 251 usable IPs.
- **/28**: 11 usable IPs. **Avoid** for general subnets; use for dedicated endpoints only.

---

## ⚙️ BGP & Cloud Routing Mechanics
**BGP (Border Gateway Protocol)** is the "Glue" of the internet. In AWS:
1. **AS Numbers**: Every network has an Autonomous System Number.
2. **Path Selection**: BGP finds the shortest path of "Hops" to a destination.
3. **Failover**: BGP automatically re-routes traffic if a primary link (Direct Connect) goes down, switching to a backup VPN.

---

## 💰 Pricing & Limitations

### Pricing Tiers
- **VPC / Subnets**: Free of charge.
- **NAT Gateways**: **$0.045 per hour** + data processing fees. (Cost trap!)
- **Data Transfer**: Standard rates apply between AZs ($0.01/GB).

### Quotas & Limits (Default)
- **VPCs per Region**: 5.
- **Internet Gateways per Region**: 5.
- **Subnets per VPC**: 200.
*Request increases via the Service Quotas console.*

---

## 🧪 Real-World Troubleshooting
**Scenario**: "My server in the Private Subnet can't download updates from the internet."
- **Root Cause**: Private subnets reach the internet via a **NAT Gateway**. Check if:
  1. The NAT Gateway exists in a Public Subnet.
  2. The Private Subnet Route Table points `0.0.0.0/0` to the NAT Gateway ID.
  3. The NAT Gateway has an Elastic IP assigned.

---
**Back to Module**: [Networking Overview](./README.md)
