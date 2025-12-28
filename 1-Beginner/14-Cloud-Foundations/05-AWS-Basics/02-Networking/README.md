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

## Quiz
<details>
<summary><b>1. A VPC is scoped to:</b></summary>
A) Region<br>
B) AZ<br>
C) Global<br>
D) Server<br>
<br>
<b>Answer: A) Region</b>
</details>

<details>
<summary><b>2. How many Internet Gateways can you attach to one VPC?</b></summary>
A) 1<br>
B) 2<br>
C) 5<br>
D) Unlimited<br>
<br>
<b>Answer: A) 1</b>
</details>

<details>
<summary><b>3. The default maximum VPCs per region per account is:</b></summary>
A) 1<br>
B) 5<br>
C) 100<br>
D) 10<br>
<br>
<b>Answer: B) 5</b>
</details>

<details>
<summary><b>4. A Subnet is scoped to:</b></summary>
A) Region<br>
B) Availability Zone (AZ)<br>
C) VPC<br>
D) Global<br>
<br>
<b>Answer: B) Availability Zone (AZ)</b>
</details>

<details>
<summary><b>5. Which IP address is reserved by AWS in every subnet for the Router?</b></summary>
A) .1<br>
B) .255<br>
C) .0<br>
D) .2<br>
<br>
<b>Answer: A) .1</b>
</details>

<details>
<summary><b>6. Can a subnet span multiple AZs?</b></summary>
A) Yes<br>
B) No<br>
<br>
<b>Answer: B) No</b>
</details>

<details>
<summary><b>7. Security Groups act at the:</b></summary>
A) Subnet level<br>
B) Instance (ENI) level<br>
C) VPC level<br>
D) Region level<br>
<br>
<b>Answer: B) Instance (ENI) level</b>
</details>

<details>
<summary><b>8. Network ACLs (NACLs) act at the:</b></summary>
A) Subnet level<br>
B) Instance level<br>
C) Account level<br>
D) Internet level<br>
<br>
<b>Answer: A) Subnet level</b>
</details>

<details>
<summary><b>9. VPC Flow Logs captures:</b></summary>
A) Packet content (payload)<br>
B) IP traffic metadata (source, dest, port, action)<br>
C) Database queries<br>
D) User clicks<br>
<br>
<b>Answer: B) IP traffic metadata (source, dest, port, action)</b>
</details>

<details>
<summary><b>10. To peer two VPCs in different regions, you use:</b></summary>
A) Inter-Region VPC Peering<br>
B) VPN<br>
C) It's impossible<br>
D) Email<br>
<br>
<b>Answer: A) Inter-Region VPC Peering</b>
</details>

<details>
<summary><b>11. What is an Elastic IP (EIP)?</b></summary>
A) A static public IPv4 address<br>
B) A dynamic IP<br>
C) A private IP<br>
D) An IPv6 address<br>
<br>
<b>Answer: A) A static public IPv4 address</b>
</details>

<details>
<summary><b>12. Are you charged for an unattached Elastic IP?</b></summary>
A) Yes<br>
B) No<br>
<br>
<b>Answer: A) Yes (to discourage hoarding)</b>
</details>

<details>
<summary><b>13. Which gateway allows IPv6 traffic out to the internet?</b></summary>
A) NAT Gateway<br>
B) Egress-Only Internet Gateway<br>
C) Internet Gateway<br>
D) VPN Gateway<br>
<br>
<b>Answer: B) Egress-Only Internet Gateway</b>
</details>

<details>
<summary><b>14. DHCP Options Sets configure:</b></summary>
A) Domain name servers, NTP servers for instances<br>
B) IP ranges<br>
C) Firewall rules<br>
D) Billing<br>
<br>
<b>Answer: A) Domain name servers, NTP servers for instances</b>
</details>

<details>
<summary><b>15. Can you resize a VPC CIDR after creation?</b></summary>
A) No, you can only add secondary CIDR blocks<br>
B) Yes, easily<br>
<br>
<b>Answer: A) No, you can only add secondary CIDR blocks</b>
</details>

<details>
<summary><b>16. Default Security Group allows:</b></summary>
A) All inbound traffic from itself, all outbound traffic<br>
B) No traffic<br>
C) All traffic everywhere<br>
D) Only SSH<br>
<br>
<b>Answer: A) All inbound traffic from itself, all outbound traffic</b>
</details>

<details>
<summary><b>17. Transit Gateway supports:</b></summary>
A) Multicast usage<br>
B) Only Unicast<br>
<br>
<b>Answer: A) Multicast usage (in specific regions)</b>
</details>

<details>
<summary><b>18. "Bring Your Own IP" (BYOIP) allows you to:</b></summary>
A) Move your public IP range to AWS<br>
B) Steal an IP<br>
C) Use private IPs publicly<br>
D) None of the above<br>
<br>
<b>Answer: A) Move your public IP range to AWS</b>
</details>

<details>
<summary><b>19. VPC Endpoints come in two types:</b></summary>
A) Interface and Gateway<br>
B) Public and Private<br>
C) Fast and Slow<br>
D) In and Out<br>
<br>
<b>Answer: A) Interface (PrivateLink) and Gateway (S3/DynamoDB)</b>
</details>

<details>
<summary><b>20. PrivateLink allows:</b></summary>
A) Private connectivity between VPCs/Services without traversing public internet<br>
B) Public connectivity<br>
C) VPN<br>
D) Peering<br>
<br>
<b>Answer: A) Private connectivity between VPCs/Services without traversing public internet</b>
</details>

<details>
<summary><b>21. Before deleting a VPC, you must:</b></summary>
A) Terminate all instances inside it<br>
B) Pay a fee<br>
C) Archive it<br>
D) Call AWS Support<br>
<br>
<b>Answer: A) Terminate all instances inside it</b>
</details>
