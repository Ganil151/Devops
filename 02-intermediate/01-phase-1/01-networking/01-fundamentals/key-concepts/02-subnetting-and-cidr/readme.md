# 🔢 Subnetting & CIDR: The Architecture of Isolation

> **"Junior, Subnetting isn't math for the sake of math. It's about Blast Radius. If you put the Database and the Public Web Server in the same subnet, one bad firewall rule exposes your user data to the world. We separate to protect."**

---

## 🏗️ The Junior NRE Briefing

**Subject**: Classless Inter-Domain Routing (CIDR)
**The Problem**: "The Cloud" isn't infinite. A VPC is a finite block of IP addresses. If you slice it wrong, you run out of IPs, and your Autoscaling Group crashes.

**Terminology Upgrade**:
*   **CIDR Block**: The total range (e.g., `10.0.0.0/16`).
*   **Netmask**: The filter that defines the sub-network boundaries.
*   **Slash Notation**: `/24` (Smaller network, 256 IPs) vs `/16` (Huge network, 65,536 IPs).

---

## 🛑 The "AWS 5" Rule

In any standard networking textbook, a `/24` subnet has **256** IPs.
In AWS (and most clouds), you only get **251**.

NREs memorize the **5 Reserved IPs** that disappear from every subnet:
1.  **x.x.x.0**: Network Address.
2.  **x.x.x.1**: VPC Router (The Gateway).
3.  **x.x.x.2**: DNS Server (The Resolver).
4.  **x.x.x.3**: Reserved for future use.
5.  **x.x.x.255**: Broadcast Address.

**Impact**: If you create a tiny `/28` subnet (16 IPs), AWS eats 5. You have **11** left. One Load Balancer (2 IPs) + 3 Nodes... you are already full.

---

## 📐 Pro Sizing Strategy

Don't guess. Use the **Standard Tier Model**.

| Tier | Recommended CIDR | Usable IPs | Purpose |
| :--- | :--- | :--- | :--- |
| **VPC** | `/16` | 65,531 | The whole house. |
| **Public Subnet** | `/24` | 251 | Load Balancers, Bastions, NAT Gateways. |
| **App Subnet** | `/22` | 1,019 | K8s Pods, EC2 Fleets (High Scale). |
| **DB Subnet** | `/24` | 251 | RDS, ElastiCache (Low Scale). |

**Why `/22` for Apps?** Containers eat IPs. A single EKS Node might want to allocate 30 IPs for its pods. A `/24` runs out instantly in Kubernetes.

---

## 🎫 Junior's First Ticket: "The Autoscaler is Stuck"

**Scenario**: The Marketing team launched a campaign. The `web-prod` Autoscaling Group tried to scale from 2 instances to 50. It stopped at 14.
**Error**: `InsufficientFreeAddressesInSubnet`.

**Your Mission**: Audit the Subnet.

**The NRE Workflow**:
1.  **Check the CIDR**:
    ```bash
    aws ec2 describe-subnets --subnet-ids subnet-123456
    # Output: CidrBlock: 10.0.1.0/28
    ```
2.  **Do the Math**:
    *   `/28` = 16 IPs.
    *   Minus 5 Reserved = 11 Usable.
    *   Existing instances = 2.
    *   Available = 9.
3.  **The Diagnosis**: The Architect (or the previous junior) made the subnet too small.
4.  **The Fix**: You cannot resize a subnet. You must:
    *   Create a new Subnet (`/24`).
    *   Update the Autoscaling Group to use the new Subnet.
    *   Terminate the old/stuck instances.

---

## 📝 Knowledge Check

1.  **Why do we avoid `/28` subnets for application tiers?**
    *   After the 5 reserved IPs, 11 IPs is usually too small for scaling.

2.  **If you need 1,000 IPs for a Kubernetes cluster, which CIDR is safest?**
    *   `/24` (251) -> Too small.
    *   `/22` (1024) -> Just right.
    *   `/16` (65k) -> Too big (Wasteful usage of VPC space).

3.  **Can you peer two VPCs that both use `10.0.0.0/16`?**
    *   **NO**. IP Overlap prevents routing. Always pick unique ranges for Production vs. Staging.

---

## 🔗 Next Steps

You have the addresses. Now, how do packets know which road to take?

Proceed to: **[Routing & Traffic Control](../04-routing-and-route-tables/readme.md)** →


---
## 🧭 Additional Modules
- [02 CIDR Math and Calculation](02-cidr-math-and-calculation/readme.md)
- [03 Public and Private Zoning](03-public-and-private-zoning/readme.md)
