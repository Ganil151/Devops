# 🏗️ Network Infrastructure: The Foundational Connectivity

The cloud network is the backbone of your infrastructure. It defines how resources communicate, how they are isolated, and how they connect to the physical world.

## 🌉 Core Concepts

### 1. The Virtual Private Cloud (VPC)
A logically isolated section of the cloud where you can launch resources.
- **Subnets**: Compartmentalizing the VPC (Public vs. Private).
- **Gateways**: Internet Gateway (IGW) for public access, NAT Gateway for outbound-only access from private subnets.
- **Routing**: Route Tables determining traffic flow.

### 2. Hybrid Connectivity
Connecting your on-premises data center to the cloud.
- **VPN (Site-to-Site)**: Encrypted tunnel over the public internet (fast to set up, variable performance).
- **Direct Connect / ExpressRoute**: Dedicated physical line (consistent performance, expensive).

---

## 🛠️ The "DevOps Why": Micro-segmentation
In a traditional data center, once you're inside the network, you're trusted. In DevOps, we use **Micro-segmentation**:
- Use **Security Groups** to wrap every individual service in its own firewall.
- Only allow the specific port (e.g., 5432 for DB) from the specific security group (e.g., Web App).
- This ensures that if a web server is compromised, the attacker cannot automatically scan the entire network.

---

## 📂 Multi-Cloud Implementations
- [AWS-VPC](./aws-vpc): Security Groups, NACLs, and VPC Endpoints.
- [Azure-VNet](./azure-vnet): NSGs, ASGs, and VNet Peering.
- [GCP-Virtual-Network](./gcp-virtual-network): Global VPCs and Firewall Rules.
