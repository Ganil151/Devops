# 🌐 Cloud Networking Foundations
*The Backbone of Distributed Infrastructure*

---

## 🏛️ Executive Summary
Cloud networking is the practice of virtually connecting resources like VMs, containers, and databases within a logically isolated environment. This module covers the core protocols that make the internet and the cloud function, moving from the physical wire (OSI Layer 1) to the global routing table (BGP).

---

## 🚀 The "DevOps Why"
Networking is the #1 source of deployment failures. A DevOps engineer must understand **Subnetting** to prevent IP exhaustion, **Security Groups** to implement zero-trust, and **BGP** to manage hybrid-cloud connectivity via VPNs or Direct Connect.

---

## 🏗️ Core Architecture (OSI to Cloud)
In the cloud, physical hardware is abstracted, but the logic remains the same:

### 1. The OSI Model in the Cloud
- **Layer 7 (Application)**: AWS Application Load Balancer (ALB) - Routing based on URL paths.
- **Layer 4 (Transport)**: Network Load Balancers (NLB) - Routing based on TCP/UDP ports.
- **Layer 3 (Network)**: VPC Routers & IP Addresses - Moving packets between subnets.
- **Layer 2 (Data Link)**: Virtual Interfaces (VIFs) - Encapsulated frames within the provider's physical network.

### 2. Global Routing (BGP)
**Border Gateway Protocol (BGP)** is how cloud networks announce their IP ranges to the internet and each other.
- **Direct Connect**: Uses BGP to establish a dedicated link between your on-prem router and the AWS router.

---

## 🛠️ CLI & IaC Quickstart

### Inspect your local route table:
```bash
ip route show # Linux
route print   # Windows
```

### Basic VPC Subnet (Terraform):
```hcl
resource "aws_subnet" "managed_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24" # Provides 251 usable IPs
  availability_zone = "us-east-1a"
}
```

---

## ❓ Interview "Deep-Cut" Questions
1. **How is the BGP protocol used in AWS Site-to-Site VPN configurations?**
2. **Explain the "5 Reserved IPs" in an AWS Subnet. What are they used for?**
3. **What happens at the packet level when a request hits a Layer 7 Load Balancer vs a Layer 4 Load Balancer?**
4. **Calculate the usable host range for a `/27` CIDR block.**
5. **Describe "VPC Peering" transitive routing limitations and how Transit Gateway solves them.**

---
**Detailed Guide**: [Networking Fundamentals](./networking-fundamentals.md)
