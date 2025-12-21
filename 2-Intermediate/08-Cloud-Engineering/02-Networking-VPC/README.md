# Networking & VPC - Intermediate

The Virtual Private Cloud (VPC) is the networking foundation of your cloud environment. It allows you to launch AWS resources into a virtual network that you've defined.

---

## 1. What is a VPC?

Think of a VPC as your own private data center in the cloud. You have complete control over:
- **IP Address Range**: Defining your internal CIDR blocks.
- **Subnets**: Public (internet-facing) and Private (isolated) segments.
- **Gateways**: Internet Gateways (IGW) for public traffic and NAT Gateways for private internet access.
- **Routing**: Controlling the flow of traffic between subnets and the internet.

---

## 2. Core Components Reference

| Component | Description | Use Case |
| :--- | :--- | :--- |
| **VPC** | Regional virtual network isolation. | Isolation of workloads. |
| **Subnet** | A range of IP addresses in your VPC. | Separating web servers from DBs. |
| **NAT Gateway** | Allows private subnets to access the internet. | Software updates for private DBs. |
| **VPC Peering** | Direct connection between two VPCs. | Shared services across environments. |
| **Transit Gateway** | Hub for connecting hundreds of VPCs/VPNs. | Complex corporate networks. |

---

## 3. Learning Path

1.  **[VPC Hands-on Guide](vpc-hands-on.md)**: Build a public/private subnet VPC from scratch via CLI.
2.  **[Networking Hacks & Tips](networking-hacks.md)**: Speed up troubleshooting and optimize network costs.
3.  **[VPC Best Practices](vpc-best-practices.md)**: Design for high availability and security.

---

## 4. Security Principles
- **NACL vs. Security Groups**: Understand the difference between stateless (network) and stateful (instance) firewalls.
- **Flow Logs**: Enable VPC Flow Logs for auditing and troubleshooting network traffic.
- **Private Link**: Use VPC Endpoints to connect to AWS services without traversing the public internet.
