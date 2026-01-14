# VPC Fundamentals: Building Blocks of Cloud Networking

Master the foundational concepts of Virtual Private Clouds across all major cloud providers.

## 📚 Learning Path

```mermaid
graph LR
    A[1. What is VPC] --> B[2. VPC vs Traditional]
    B --> C[3. Components Overview]
    C --> D[4. IP Addressing]
    D --> E[5. Default vs Custom]
    E --> F[6. Limits & Quotas]
    F --> G[7. Multi-VPC Strategies]
    G --> H[8. Best Practices]
    H --> I[9. Cloud Comparison]
    I --> J[10. Getting Started]

style A fill:#e1f5ff,stroke:#333,stroke-width:2px
    style J fill:#4caf50,stroke:#333,stroke-width:2px
```

### Module Structure

1.  **[What is a VPC?](./01-What-is-a-VPC/README.md)**: VPC definition and core concepts.
2.  **[VPC vs. Traditional Networks](./02-VPC-vs-Traditional-Networks/README.md)**: Physical vs. virtual infrastructure.
3.  **[VPC Components Overview](./03-VPC-Components-Overview/README.md)**: Core components and security layers.
4.  **[IP Addressing Basics](./04-IP-Addressing-Basics/README.md)**: CIDR notation and RFC 1918.
5.  **[Default vs. Custom VPC](./05-Default-vs-Custom-VPC/README.md)**: Security and compliance considerations.
6.  **[VPC Limits and Quotas](./06-VPC-Limits-and-Quotas/README.md)**: Quotas and design constraints.
7.  **[Multi-VPC Strategies](./07-Multi-VPC-Strategies/README.md)**: Peering and Transit Gateways.
8.  **[VPC Best Practices](./08-VPC-Best-Practices/README.md)**: High availability and security.
9.  **[Cloud Provider Comparison](./09-Cloud-Provider-Comparison/README.md)**: AWS vs. Azure vs. GCP.
10. **[Getting Started Guide](./10-Getting-Started-Guide/README.md)**: Step-by-step implementation.

---

## 🎯 Module Architecture

```mermaid
graph TD
    VPC[VPC: 10.0.0.0/16] --> Components[Core Components]
    VPC --> Security[Security Layers]
    VPC --> Connectivity[Connectivity Options]

Components --> Subnets[Subnets]
    Components --> IGW[Internet Gateway]
    Components --> NAT[NAT Gateway]
    Components --> RT[Route Tables]

Security --> SG[Security Groups<br/>Stateful]
    Security --> NACL[Network ACLs<br/>Stateless]
    Security --> FlowLogs[VPC Flow Logs]

Connectivity --> Peering[VPC Peering]
    Connectivity --> TGW[Transit Gateway]
    Connectivity --> VPN[VPN Gateway]
    Connectivity --> Endpoints[VPC Endpoints]

style VPC fill:#e1f5ff,stroke:#333,stroke-width:3px
    style Security fill:#ffeb3b,stroke:#333,stroke-width:2px
    style Connectivity fill:#4caf50,stroke:#333,stroke-width:2px
```

---

## 🏗️ Real-Life Scenarios

### Scenario 1: The "IP Exhaustion" Crisis
**Problem**: A fast-growing startup created their VPC with a small /24 CIDR block (256 IPs), thinking it would be plenty for their initial 10 servers.
**Crisis**: Six months later, they launched a Kubernetes cluster and an auto-scaling group. Within hours, new pods failed to start because the VPC had run out of available private IP addresses.
**Outcome**: The team had to build an entirely new VPC with a /16 range and perform a risky live migration of all services, leading to 4 hours of scheduled downtime.
**Solution**: Use a large CIDR block (like /16) from the start. IP addresses in a VPC are free; running out of them is expensive.
**Result**: The company now uses a standard 10.x.0.0/16 template for all new regions, ensuring they never face exhaustion again.

### Scenario 2: The "Open Door" Security Breach
**Problem**: A developer created a "Default" VPC and launched a database server. To make debugging easier, they attached an Internet Gateway and set the Security Group to allow `0.0.0.0/0` on port 3306.
**Crisis**: Within 48 hours, the database was hit by a ransomware attack that encrypted all customer records because the server was directly reachable from the public internet.
**Outcome**: The company lost 2 days of data and had to pay a consultant to harden their infrastructure.
**Solution**: Implement a "Private Subnet" strategy. Databases should never have a public IP or a path to an Internet Gateway. Use a Bastion Host or VPN for management.
**Result**: All sensitive workloads were moved to isolated subnets with no direct internet ingress, reducing the attack surface by 99%.

### Scenario 3: The "Regional Outage" Survival
**Problem**: A SaaS provider hosted their entire application in a single Availability Zone (AZ) to save on "Inter-AZ data transfer" costs.
**Crisis**: AWS experienced a power failure in that specific data center (Zone A). The entire SaaS platform went offline for 8 hours.
**Outcome**: The company violated their SLA and lost several high-value enterprise clients who demanded high availability.
**Solution**: Redeployed the VPC components across three different Availability Zones (Multi-AZ). They used an Application Load Balancer to distribute traffic across all three zones.
**Result**: When a similar AZ failure occurred a year later, the application stayed online with zero downtime as traffic automatically shifted to the healthy zones.

---

## ❓ Interview Questions

1.  **What is the 'Default VPC' and why do production environments usually avoid it?**
    - *Answer*: A Default VPC is pre-configured by the cloud provider in every region to help beginners get started quickly. Production environments avoid it because it has public subnets by default, uses a standard CIDR block that might overlap with other networks, and doesn't follow the "Least Privilege" security model required for enterprise compliance.
2.  **Explain the difference between a 'Soft Limit' and a 'Hard Limit' in VPC quotas.**
    - *Answer*: A **Soft Limit** (e.g., number of VPCs per region) can be increased by submitting a support ticket to the cloud provider. A **Hard Limit** (e.g., the maximum size of a CIDR block being /16 in some legacy contexts or specific hardware constraints) cannot be changed regardless of the request.
3.  **Why should you avoid overlapping CIDR blocks when designing a Multi-VPC architecture?**
    - *Answer*: Overlapping IP ranges make it impossible to connect those VPCs via VPC Peering or a Transit Gateway. Routine routing cannot distinguish between the two networks if they share the same IP space, preventing hybrid cloud or cross-account communication.
4.  **What is the purpose of the 'Primary' CIDR block vs. 'Secondary' CIDR blocks?**
    - *Answer*: The Primary block is defined at VPC creation and is immutable. If a VPC grows unexpectedly and runs out of IPs, cloud providers allow you to add "Secondary" CIDR blocks to the existing VPC to expand capacity without rebuilding the entire network.
5.  **How does 'Software Defined Networking' (SDN) differ from traditional hardware networking?**
    - *Answer*: SDN abstracts the network hardware into software. In a VPC, routers, switches, and firewalls are "Virtual instances" managed via API. This allows for near-instant provisioning, global scalability, and programmatic control that physical hardware cannot match.
6.  **In a 3-Tier architecture, which tier should have a 'Public IP'?**
    - *Answer*: Only the **Web/Load Balancer** tier (Tier 1) should have public access. The Application tier (Tier 2) and Database tier (Tier 3) should reside in private subnets with only private IPs to ensure security.

---

## 🧠 Comprehensive Quiz (25 Questions)

<b>1. What is the maximum size of a VPC CIDR block in AWS?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>2. True/False: VPCs are globally scoped and span all regions automatically.</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>3. Which component provides a path for a VPC to communicate with the Public Internet?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>4. A 'Subnet' exists within a single:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>5. Which protocol is used by cloud providers to isolate VPC traffic on shared hardware?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>6. RFC 1918 defines which of the following?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>7. True/False: You can increase the number of VPCs in your account by contacting support.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>8. Which architectural pattern connects multiple VPCs in a 'Hub and Spoke' model?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>9. A 'Public Subnet' is defined by having a route to:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>10. What happens if you try to peer two VPCs with overlapping CIDR blocks?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>11. Which 'Security' component is stateful?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>12. 'Elasticity' in a VPC refers to:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>13. How many 'Availability Zones' should a production VPC span at minimum?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>14. A 'Private IP' address is reachable from:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>15. 'Default VPCs' are created in:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>16. True/False: VPC Peering supports 'Transitive Routing' (A -> B -> C).</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>17. What is the smallest CIDR block allowed for a VPC subnet in AWS?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>18. Which service allows private connection to AWS services without an IGW?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>19. 'Tenancy' in a VPC refers to:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>20. True/False: You can delete the Default VPC.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>21. A 'Route Table' contains a set of rules called:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>22. Which range is a valid RFC 1918 Private IP range?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>23. 'VPC Flow Logs' capture:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>24. The main disadvantage of 'Multi-AZ' architectures is:</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>25. A VPC is an implementation of:</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>
