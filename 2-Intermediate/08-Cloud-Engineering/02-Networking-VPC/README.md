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

## 3. Advanced Architectural Patterns

Designing for scale and security in the enterprise requires more than just subnets.

### Hub-and-Spoke (Centralized Networking)
Instead of peering every VPC to every other VPC (which creates a "mesh" that is hard to manage), use a **Transit Gateway** as a central hub.
- **Spoke VPCs**: Contain your applications.
- **Hub VPC**: Contains shared services (DNS, Active Directory) and central firewalls or Internet Gateways.

### Centralized Egress
Rather than putting a NAT Gateway in every Spoke VPC (which is expensive), route all internet-bound traffic through a single Transit Gateway to a centralized **Inspection VPC** containing a NAT Gateway and an egress firewall.

---

## 4. Hybrid Connectivity
Connecting your on-premises data center to your Cloud VPC:

- **Site-to-Site VPN**: Uses the public internet with an encrypted tunnel (IPsec). Fast to set up, but bandwidth is limited by internet speeds.
- **Direct Connect (DX)**: A dedicated physical fiber connection between your data center and a cloud provider's office. Offers consistent performance and lower latency, but takes weeks/months to install.
- **AWS VPN Client**: Allows individual developers to connect directly to the private VPC network from their local machines.

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

---

## 🏆 Certifications in Context

While Cloud Certs (AWS SAA, AZ-104) are the primary goal here, your foundational networking knowledge (Network+, CCNA) is what saves you during deep troubleshooting.

### How CCNA/Network+ Concepts Apply Here
- **CIDR & Subnetting**: The `/24` vs `/16` decisions you make in VPC creation are pure Network+ math.
- **Route Tables**: AWS Route Tables function exactly like static routes in a Cisco router—if the packet doesn't have a route, it drops.
- **NACLs vs Security Groups**: This mirrors the CCNA concept of *Stateless ACLs* (Router standard ACLs) vs *Stateful Firewalls* (ASA/Zone-based firewalls).
