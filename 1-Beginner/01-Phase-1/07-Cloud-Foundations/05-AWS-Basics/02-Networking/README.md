# AWS Networking (VPC)

Virtual Private Cloud (VPC) is your isolated network in the AWS cloud. This module explores specific AWS implementation details.

## AWS VPC Architecture
```mermaid
graph TB
    subgraph VPC [VPC 10.0.0.0/16]
        IGW[Internet Gateway]
        NAT[NAT Gateway]

subgraph Public [Public Subnet]
            Bastion[Bastion Host]
        end

subgraph Private [Private Subnet]
            EC2[App Instance]
        end
    end

Internet((Internet)) <--> IGW
    IGW <--> Public
    Public -.-> Private
    Private --> NAT
    NAT --> IGW

classDef public fill:#e3f2fd,stroke:#0d47a1
    classDef private fill:#fff3e0,stroke:#e65100

class Public public
    class Private private
```

## Real World Scenarios
### Scenario: Secure Backend
**Context:** Your database must NOT be accessible from the internet, but needs updates from S3.
**Solution:**
- **VPC Endpoint (Gateway Type):** Create an S3 Gateway Endpoint in the VPC.
- **Route Table:** Add route to S3 Endpoint.
**Benefit:** Traffic to S3 stays within the AWS network, faster and more secure than NAT Gateway.

<b>1. A VPC is scoped to:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Region</b>
</details>


<b>2. How many Internet Gateways can you attach to one VPC?</b>
<details>
<summary>Show Answer</summary>
Answer: A) 1</b>
</details>


<b>3. The default maximum VPCs per region per account is:</b>
<details>
<summary>Show Answer</summary>
Answer: B) 5</b>
</details>


<b>4. A Subnet is scoped to:</b>
<details>
<summary>Show Answer</summary>
Answer: B) Availability Zone (AZ)</b>
</details>


<b>5. Which IP address is reserved by AWS in every subnet for the Router?</b>
<details>
<summary>Show Answer</summary>
Answer: A) .1</b>
</details>


<b>6. Can a subnet span multiple AZs?</b>
<details>
<summary>Show Answer</summary>
Answer: B) No</b>
</details>


<b>7. Security Groups act at the:</b>
<details>
<summary>Show Answer</summary>
Answer: B) Instance (ENI) level</b>
</details>


<b>8. Network ACLs (NACLs) act at the:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Subnet level</b>
</details>


<b>9. VPC Flow Logs captures:</b>
<details>
<summary>Show Answer</summary>
Answer: B) IP traffic metadata (source, dest, port, action)</b>
</details>


<b>10. To peer two VPCs in different regions, you use:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Inter-Region VPC Peering</b>
</details>


<b>11. What is an Elastic IP (EIP)?</b>
<details>
<summary>Show Answer</summary>
Answer: A) A static public IPv4 address</b>
</details>


<b>12. Are you charged for an unattached Elastic IP?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes (to discourage hoarding)</b>
</details>


<b>13. Which gateway allows IPv6 traffic out to the internet?</b>
<details>
<summary>Show Answer</summary>
Answer: B) Egress-Only Internet Gateway</b>
</details>


<b>14. DHCP Options Sets configure:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Domain name servers, NTP servers for instances</b>
</details>


<b>15. Can you resize a VPC CIDR after creation?</b>
<details>
<summary>Show Answer</summary>
Answer: A) No, you can only add secondary CIDR blocks</b>
</details>


<b>16. Default Security Group allows:</b>
<details>
<summary>Show Answer</summary>
Answer: A) All inbound traffic from itself, all outbound traffic</b>
</details>


<b>17. Transit Gateway supports:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Multicast usage (in specific regions)</b>
</details>


<b>18. "Bring Your Own IP" (BYOIP) allows you to:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Move your public IP range to AWS</b>
</details>


<b>19. VPC Endpoints come in two types:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Interface (PrivateLink) and Gateway (S3/DynamoDB)</b>
</details>


<b>20. PrivateLink allows:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Private connectivity between VPCs/Services without traversing public internet</b>
</details>


<b>21. Before deleting a VPC, you must:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Terminate all instances inside it</b>
</details>


---
## 🧭 Additional Modules
- [VPC Networking](VPC-Networking/README.md)
