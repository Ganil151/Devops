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