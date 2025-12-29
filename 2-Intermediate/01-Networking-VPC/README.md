# Networking & VPC: Advanced Infrastructure

Welcome to the **Networking & VPC** module. This is the foundation of the Intermediate level, where you move from basic connectivity to architecting secure, high-availability cloud environments.

---

## 🗺️ The Networking Learning Path

Follow these modules in order to master cloud networking:

1.  **[01-VPC-Basics](The%20Core%20of%20Cloud%20Networking.md)**: CIDR blocks, IGWs, and Route Tables.
2.  **[02-Subnetting-Strategy](Subnetting%20Strategy.md)**: Public vs. Private subnets and NAT Gateways.
3.  **[03-VPC-Peering](VPC%20Peering%20Guide.md)**: Connecting multiple VPCs securely.
4.  **[04-Load-Balancing](Load%20Balancer%20Setup%20(ALB-NLB).md)**: Distributing traffic with ALB and NLB.
5.  **[05-Interview-Questions-and-Quizzes](Interview%20Questions%20&%20Quiz.md)**: Test your knowledge and prepare for interviews.
6.  **[06-Real-Life-Scenarios](2-Intermediate/01-Networking-VPC/06-Real-Life-Scenarios/Real-Life%20Scenarios.md)**: Practical troubleshooting and architectural challenges.

---

## 🎯 Final Learning Objectives
By the end of this module, you will be able to:
1.  **Design**: Build a multi-AZ VPC with a clear public/private separation.
2.  **Secure**: Use Security Groups and NACLs to enforce the principle of least privilege.
3.  **Scale**: Implement Load Balancers to handle varying traffic demands.
4.  **Connect**: Peer VPCs and understand the limitations of non-transitive routing.
5.  **Debug**: Resolve connectivity issues using a systematic troubleshooting approach.

---

## ✅ Knowledge Check
- [x] Understand the difference between Layer 4 and Layer 7 Load Balancing.
- [x] Explain why a NAT Gateway is placed in a public subnet.
- [x] Route traffic between two peered VPCs.
- [x] Passed the 20-Question Assessment.

---
*The network is the computer. Build it strong.*

# VPC Best Practices

Designing a VPC is foundational. Mistakes here are hard to fix later without rebuilding the network.

## 1. High Availability (HA)

### Multi-AZ Deployment
Always span your VPC across at least **two Availability Zones (AZs)**.
- **Why**: If one data center (AZ) goes down, your application continues running in the other.
- **Pattern**: Create a Public and Private subnet in AZ-1, and a Public and Private subnet in AZ-2.

## 2. Security

### Security Groups vs. NACLs
- **Security Groups (Stateful)**: Use these as your primary firewall. Allow specific traffic in; return traffic is automatically allowed.
- **NACLs (Stateless)**: Use these sparingly for broad blocking (e.g., blocking a specific malicious IP subnet). Avoid complex rules here as they are stateless (you must explicitly allow return traffic).

### Least Privilege
- Never open port `0.0.0.0/0` for SSH (Port 22) or RDP (Port 3389). Use AWS Systems Manager Session Manager instead.
- Database Security Groups should only allow inbound traffic from the **App Server Security Group ID**, not IP ranges.

## 3. IP Addressing (CIDR)

### Avoid Overlap
If you plan to peer this VPC with another (or on-premise), ensure the CIDR blocks do not overlap.
- **Bad**: VPC A (10.0.0.0/16) <--> VPC B (10.0.0.0/16)
- **Good**: VPC A (10.0.0.0/16) <--> VPC B (10.1.0.0/16)

### Size Matters
- Don't make subnets too small. AWS reserves 5 IP addresses in every subnet.
- A `/24` (256 IPs) is a good standard size for most application subnets.

## 4. Tagging Strategy
Tag everything. It is essential for cost allocation and automation.
- `Name`: Resource name.
- `Environment`: dev, stage, prod.
- `Owner`: Team or individual responsible.
- `CostCenter`: Billing code.

## 5. Subnet Design
- **Public Subnets**: Only for resources that *must* accept incoming traffic from the internet (Load Balancers, Bastion Hosts).
- **Private Subnets**: For everything else (App Servers, Databases).
