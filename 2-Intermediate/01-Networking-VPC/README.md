# Networking & VPC: Advanced Infrastructure

Welcome to the **Networking & VPC** module. This is the foundation of the Intermediate level, where you move from basic connectivity to architecting secure, high-availability cloud environments.

---

## 🗺️ The Networking Learning Path

Follow these modules in order to master cloud networking:

1.  **[01-VPC-Fundamentals](./01-VPC-Fundamentals/README.md)**: Core concepts, differences from traditional networks.
2.  **[02-Subnetting-and-CIDR](./02-Subnetting-and-CIDR/README.md)**: Binary math, host calculation, Public/Private zoning, AWS reserved IPs.
3.  **[03-Internet-and-NAT-Gateways](./03-Internet-and-NAT-Gateways/README.md)**: Attachments, packet flow, managed NAT, IPv6 egress, HA designs.
4.  **[04-Routing-and-Route-Tables](./04-Routing-and-Route-Tables/README.md)**: Fundamentals, Priority logic (LPM), Ingress gates, Blackhole troubleshooting.
5.  **[05-Network-Security-NACLs-SGs](./05-Network-Security-NACLs-SGs/README.md)**: Stateful SGs vs Stateless NACLs, layered defense, ephemeral port trap.
6.  **[06-VPC-Peering-and-Transit-Gateway](./06-VPC-Peering-and-Transit-Gateway/README.md)**: Peering Lifecycle, DNS Support, Transit Gateway Hub-and-Spoke.
7.  **[07-Load-Balancing-ALB-NLB](./07-Load-Balancing-ALB-NLB/README.md)**: ALB/NLB/GLB deep dive, L7 Routing, Static IPs, SSL Offloading.
8.  **[08-High-Availability-and-Multi-Region](./08-High-Availability-and-Multi-Region/README.md)**: RTO/RPO, Pilot Light vs Warm Standby, Global Accelerator.
9.  **[09-Hybrid-Connectivity](./09-Hybrid-Connectivity/README.md)**: Site-to-Site VPN, Direct Connect, DX Gateway, Resiliency Models.
10. **[10-Monitoring-and-Troubleshooting](./10-Monitoring-and-Troubleshooting/README.md)**: Flow Logs, Reachability Analyzer, and Traffic Mirroring.

---

## 🏗️ Module Features
- **250+ Total Quiz Questions**: Comprehensive mastery with interactive collapsible answers.
- **60+ SRE/Network Interview Questions**: Advanced prep for Cloud Architect and Network Lead roles.
- **30+ "War Stories"**: Real-life scenarios on IP exhaustion, security breaches, and global outages.
- **Visual Workflows**: Mermaid diagrams for VPC architecture, priority routing, and layered defense.

---

## 🎯 Final Learning Objectives
By the end of this module, you will be able to:
1.  **Design**: Build a multi-AZ VPC with a clear public/private separation and non-overlapping CIDRs.
2.  **Secure**: Implement a layered defense using Security Groups and stateless NACLs.
3.  **Scale**: Deploy high-performance Load Balancers for millions of requests per second.
4.  **Connect**: Bridge VPCs and On-Premises data centers with professional resiliency models.
5.  **Debug**: Resolve complex packet loss and routing loops using Flow Logs and Packet Capture.

---

## ✅ Knowledge Check
- [x] Understand the difference between Layer 4 and Layer 7 Load Balancing.
- [x] Explain why a NAT Gateway is placed in a public subnet.
- [x] Design a CIDR scheme that supports future organic growth.
- [x] Passed the 250-Question Master Assessment.

---

# VPC Best Practices Summary

## 1. High Availability (HA)
- **Multi-AZ**: Always span a region with at least 2 (preferably 3) Availability Zones.
- **Independence**: Keep your NAT Gateways and Load Balancers AZ-independent to prevent cross-AZ failure.

## 2. Security
- **Defense in Depth**: Use Security Groups for fine-grained instance security and NACLs for broad subnet-level protection.
- **Private First**: Resources like Databases and Internal APIs should *never* have a public IP address.

## 3. IP Addressing (CIDR)
- **Plan for Growth**: Use large blocks like /16 for VPCs and /24 for subnets to avoid future migration costs.
- **No Overlap**: Coordinate with your organization's IP registry to prevent peering conflicts.

## 4. Operational Excellence
- **VPC Flow Logs**: Enable these across all production subnets to ensure full visibility into network activity.
- **Tagging**: Standardize on `Environment`, `Owner`, and `CostCenter` for all networking resources.

---
*The network is the computer. Build it strong.*
