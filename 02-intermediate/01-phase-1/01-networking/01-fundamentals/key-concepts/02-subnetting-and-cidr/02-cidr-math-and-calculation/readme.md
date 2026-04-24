# 🔢 Module 02.02: CIDR Math & Mental Models

> **"Junior, I don't expect you to calculate binary in your head. I do expect you to know that a /28 is too small for an EKS cluster before you launch it. Math is cheap. Re-IPing a production VPC is a resume-generating event."**

---

## 🏗️ Junior’s Mission

**Goal**: Develop "Mental Math" for IP ranges. You should see `/24` and instantly think "250 hosts," not "lets count bits."
**Why it matters**: Every AWS VPC has a limit. Every Load Balancer needs 2 IPs. Every Pod needs 1 IP. If you miscalculate, your autoscaler halts.

---

## 🌍 Operational Reality

**In Theory**: "We can use Variable Length Subnet Masking (VLSM) to perfectly resize every subnet."
**In Production**:
*   **The Standard**: We use `/24` (256 IPs) for almost everything because it's human-readable. It aligns with the last octet (e.g., `10.0.1.x`).
*   **The Exception**: We use `/20` (4096 IPs) for Container subnets (EKS/ECS) because pods destroy IP space.
*   **The Tiny Slices**: We use `/28` (16 IPs) for "Infrastructure" subnets (Transit Gateways, VPN Endpoints) that never scale.

---

## 🛠️ The Toolbelt

Stop doing math on paper. Use the CLI.

| Tool | Command | Purpose |
| :--- | :--- | :--- |
| **ipcalc** | `ipcalc 10.0.0.0/24` | Shows HostMin, HostMax, Broadcast, and Binary map. |
| **Python** | `import ipaddress; print(ipaddress.ip_network('10.0.0.0/24').num_addresses)` | Scriptable math for automation. |
| **Terraform** | `cidrsubnet("10.0.0.0/16", 8, 2)` | The `cidrsubnet` function is how we generate subnets in Infrastructure as Code. |

---

## 📐 The Golden Reference (Memorize This)

You only need to know these 5 numbers.

| CIDR | Total IPs | Usable IPs (AWS -5) | Use Case |
| :--- | :--- | :--- | :--- |
| **/32** | 1 | 1 | A specific Host or Route Target. |
| **/28** | 16 | 11 | **Infra Subnet** (ALB, TGW, VPN). |
| **/24** | 256 | 251 | **App/DB Tier** (Standard EC2). |
| **/20** | 4,096 | 4,091 | **K8s/Container Tier** (High Scale). |
| **/16** | 65,536 | 65,531 | **Entire VPC** (Max Size). |

---

## � Deep Dive: Binary Boundaries

Understanding the "Bit Slide".

```mermaid
graph LR
    subgraph VPC[/16 - The City]
        direction TB
        Bit16[11111111.11111111.00000000.00000000]
        Human16["10.0.x.x (65k IPs)"]
    end
    
    subgraph Subnet[/24 - The Neighborhood]
        direction TB
        Bit24[11111111.11111111.11111111.00000000]
        Human24["10.0.1.x (256 IPs)"]
    end
    
    VPC --> Subnet
    style Bit16 font-family:monospace
    style Bit24 font-family:monospace
```

**The "Power of 2" Rule**:
*   **+1 Bit** (e.g., /24 -> /25) = **Half the IPs**.
*   **-1 Bit** (e.g., /24 -> /23) = **Double the IPs**.

---

## > [!IMPORTANT] Senior SRE Pro-Tips

1.  **The "Plus Two" Rule for ALBs**: Application Load Balancers (ALBs) scale by launching new nodes in valid subnets. Each node needs an IP. A massive traffic spike can require 50+ IPs for the ALB alone. **Never put an ALB in a /28**.
2.  **Peering Overlaps**: If Company A uses `10.0.0.0/16` and buys Company B who uses `10.0.0.0/16`, you **cannot** connect them via VPC Peering. You need a Transit Gateway with NAT (Complexity Hell). **Always use unique CIDRs if possible.**
3.  **Terrorform `cidrsubnet`**: In Terraform, we define proper boundaries like this:
    ```hcl
    # Create a /24 inside a /16
    cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
    ```
    This ensures we never make a math error manually.

---

## 🎫 Junior's First Ticket: Incident #005 "IP Exhaustion"

**Scenario**: "The EKS cluster nodes can't launch pods. They are stuck in `ContainerCreating`."
**Metrics**: CloudWatch shows `AssignPrivateIpAddress` failures.

**Investigation Steps**:
1.  **Check Subnet**: `aws ec2 describe-subnets --subnet-ids subnet-xyz`.
    *   *Result*: `AvailableIpAddressCount: 0`.
2.  **Check CIDR**: It is a `/24` (251 IPs).
3.  **Check Count**: There are 5 Nodes. Each Node allows 50 Pods (Secondary IPs).
    *   5 Nodes * 50 IPs = 250 IPs.
    *   The Subnet is full.
4.  **The Fix**: You cannot resize a subnet. You must create a new Secondary CIDR for the VPC (e.g., `100.64.0.0/16` - Carrier Grade NAT range) and migrate the pods.

---

## 📝 Knowledge Check

1.  **You have a `/24` subnet. You need to split it into two equal halves. What CIDR mask do you use?**
    - [ ] a) /23
    - [x] b) /25 (Each has 128 IPs)
    - [ ] c) /26
    - [ ] d) /12

2.  **How many usable IPs remain in a `/28` subnet after AWS reserves their portion?**
    - [ ] a) 16
    - [ ] b) 14
    - [x] c) 11 (16 total - 5 reserved)
    - [ ] d) 6

3.  **Why is `10.0.1.0/24` preferred over `10.0.1.0/23` for human readability?**
    - [x] a) /24 perfectly matches the 4th octet (0-255), making it easy to spot boundaries.
    - [ ] b) /23 is not a valid CIDR.

---

## 🔗 Next Steps

The math is done. Now let's draw the map.

Proceed to: **[03. Public and Private Zoning](../03-public-and-private-zoning/readme.md)** →