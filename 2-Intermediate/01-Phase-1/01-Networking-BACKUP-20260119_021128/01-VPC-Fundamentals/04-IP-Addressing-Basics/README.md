# 🔢 Module 04: IP Addressing & CIDR

> **"In the cloud, every resource is a neighbor. IP addresses are the street addresses that ensure your data gets delivered to the right doorstep every time."**

```mermaid
graph TD
    subgraph IPv4_Structure[IPv4 Address: 32 Bits]
        Oct1[Octet 1: 8 bits] --- Oct2[Octet 2: 8 bits]
        Oct2 --- Oct3[Octet 3: 8 bits]
        Oct3 --- Oct4[Octet 4: 8 bits]
    end

    subgraph CIDR_Masking[/24 Mask]
        Network[Network Portion: 24 bits]
        Host[Host Portion: 8 bits]
    end

    Oct1 & Oct2 & Oct3 --> Network
    Oct4 --> Host

    style Oct1 fill:#f0f9ff,stroke:#0369a1
    style Oct2 fill:#f0f9ff,stroke:#0369a1
    style Oct3 fill:#f0f9ff,stroke:#0369a1
    style Oct4 fill:#fef2f2,stroke:#b91c1c
    style Network fill:#e0f2fe,stroke:#0369a1
    style Host fill:#fee2e2,stroke:#b91c1c
```

## 📚 Overview

Understanding IP addressing is not just for network engineers—it is the foundation of VPC design, security, and troubleshooting in DevOps. This module demystifies how 32-bit numbers are sliced and diced using CIDR to create logical boundaries within your cloud environment.

## 🎓 Learning Objectives

By the end of this module, you will:

- ✅ Understand the **Binary-to-Decimal** foundation of IPv4.
- ✅ Master **CIDR Notation** and how prefix lengths determine network size.
- ✅ Identify the **RFC 1918** private address ranges used in VPCs.
- ✅ Calculate **Usable IP Addresses** accounting for the 5 AWS reservations.
- ✅ Plan scalable **IP Schemas** for production-grade environments.

---

## 🏗️ IPv4 Address Structure

An IPv4 address is a 32-bit number written in **dotted-decimal notation**. It is divided into four **octets** (8 bits each), each ranging from 0 to 255.

### Example: 192.168.1.100
| Format | Part 1 | Part 2 | Part 3 | Part 4 |
| :--- | :--- | :--- | :--- | :--- |
| **Decimal** | 192 | 168 | 1 | 100 |
| **Binary** | `11000000` | `10101000` | `00000001` | `01100100` |

---

## 📐 CIDR & Subnet Masking

**CIDR (Classless Inter-Domain Routing)** is the industry standard for specifying network ranges. It uses a "slash" notation (e.g., `/24`) to indicate how many bits belong to the **Network** (the fixed part) vs. the **Host** (the variable part).

### CIDR Quick Reference
| CIDR | Subnet Mask | Total IPs | Usable (AWS) | Typical Use |
| :--- | :--- | :--- | :--- | :--- |
| **/32** | 255.255.255.255 | 1 | 1 | Single EC2 / Route |
| **/28** | 255.255.255.240 | 16 | 11 | Smallest AWS Subnet |
| **/24** | 255.255.255.0 | 256 | 251 | Standard Subnet |
| **/20** | 255.255.240.0 | 4,096 | 4,091 | Large EKS / RDS Tier |
| **/16** | 255.255.0.0 | 65,536 | 65,531 | Standard VPC Size |

---

## 🔒 Private IP Ranges (RFC 1918)

VPCs use private IP ranges that are not routable on the public internet. Choosing the right range is critical to avoid IP conflicts during future VPC Peering or VPN connections.

| Range | CIDR Block | Total Addresses |
| :--- | :--- | :--- |
| **Class A** | `10.0.0.0/8` | 16.7 Million |
| **Class B** | `172.16.0.0/12` | 1.04 Million |
| **Class C** | `192.168.0.0/16` | 65,536 |

---

## ⚠️ The AWS "Tax": 5 Reserved IPs

In every AWS subnet, 5 IP addresses are reserved and cannot be assigned to your instances:

1.  **x.x.x.0**: Network Address.
2.  **x.x.x.1**: VPC Router (Default Gateway).
3.  **x.x.x.2**: DNS Server (AmazonProvidedDNS).
4.  **x.x.x.3**: Reserved by AWS for future use.
5.  **x.x.x.255**: Network Broadcast Address (AWS doesn't support broadcast, but it's still reserved).

**Calculation Formula**: `(2 ^ (32 - CIDR)) - 5 = Usable IPs`

---

## 🚀 Professional Pattern: The Sparse CIDR Strategy

Senior DevOps engineers avoid "packing" subnets too tightly. 

**The Pro Standard**:
1. **Plan for /16**: Always start your VPC with a `/16` if possible. You don't pay for unused IP space.
2. **Standardize Subnets**: Use `/24` (251 usable IPs) for standard tiers. It is easy to remember and provides plenty of growth for most workloads.
3. **Leave "Air"**: If you have 3 Availability Zones, don't use 3 contiguous subnets. Leave a buffer (e.g., 10.0.1.0, 10.0.2.0, 10.0.3.0... and then jump to 10.0.10.0 for the next tier). This allows you to expand existing tiers later without breaking your naming convention.

---

## 🏆 Real-World DevOps Story: The Subnet Miscalculation

**The Scenario**: A startup launched a Kubernetes (EKS) cluster in a `/24` private subnet (251 usable IPs).
**The Crisis**: As they scaled to handle a Black Friday sale, the cluster attempted to launch 300 pods. Because each pod (using the VPC CNI) requires its own private IP, the subnet ran out of addresses immediately. New pods remained in "Pending" state, effectively taking down the site during its busiest hour.
**The Fix**: They had to create a secondary CIDR block for the VPC and provision new, larger `/20` subnets, then migrate the entire cluster—a high-risk operation during a peak event.
**The Discovery**: They realized that AWS services (Load Balancers, NAT Gateways, RDS) and Kubernetes pods consume IPs much faster than anticipated.
**The Lesson**: **Be generous with IP space.** In the cloud, IPs are cheap; downtime is expensive.

---

## ❓ Interview Preparation (IP & CIDR)

1. **Q: Why does AWS reserve 5 IP addresses in a subnet instead of the usual 2 in traditional networking?**
    *A: Traditional networking reserves the first (Network) and last (Broadcast) addresses. AWS also reserves the .1 for the VPC Router, .2 for the Amazon DNS server, and .3 for future use, ensuring core cloud services always have a predictable address.*

2. **Q: How many usable IPs are in a /28 subnet in AWS?**
    *A: A /28 has 16 total IPs (2^(32-28)). Subtracting the 5 reserved AWS IPs leaves 11 usable addresses.*

3. **Q: Can you change the CIDR block of a VPC after it is created?**
    *A: No, you cannot change the primary CIDR block. However, you can add "Secondary CIDR blocks" to an existing VPC if you need more space.*

4. **Q: What happens if you try to connect two VPCs via Peering that have overlapping CIDR blocks?**
    *A: The peering connection will fail or routing will break. You cannot route traffic between two networks that claim the same IP space. This is why planning unique CIDRs is critical.*

5. **Q: What is the purpose of the 169.254.169.254 IP address?**
    *A: This is the **Instance Metadata Service (IMDS)** endpoint. It is a link-local address accessible from within any EC2 instance to retrieve information about the instance (ID, AMI, IAM Roles, etc.).*

---

## 📝 Knowledge Check

1. **How many bits make up an IPv4 address?**
    - [ ] a) 16
    - [x] b) 32
    - [ ] c) 64

2. **Which CIDR prefix provides exactly 256 total IP addresses?**
    - [ ] a) /16
    - [x] b) /24
    - [ ] c) /32

3. **Which IP address in an AWS subnet is typically reserved for the VPC DNS server?**
    - [ ] a) .1
    - [x] b) .2
    - [ ] c) .3

4. **Which RFC 1918 range starts with 172.x.x.x?**
    - [ ] a) Class A
    - [x] b) Class B
    - [ ] c) Class C

5. **What is the smallest subnet size AWS allows you to create?**
    - [ ] a) /32
    - [x] b) /28
    - [ ] c) /24

---

## 🔗 Next Steps

You've mastered the math. Now let's look at the two types of VPCs you'll encounter and why you should almost always build your own.

Proceed to: **[Default vs. Custom VPC](../05-Default-vs-Custom-VPC/README.md)** →
