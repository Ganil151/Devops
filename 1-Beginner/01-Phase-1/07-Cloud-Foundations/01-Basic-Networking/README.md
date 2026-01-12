# Cloud Networking

Comprehensive guide to cloud networking concepts, architectures, and implementation across cloud platforms.

## Networking Fundamentals

### Virtual Private Cloud (VPC)
```yaml
Core Concepts:
  - Isolated network environment
  - IP address ranges (CIDR blocks)
  - Subnets for segmentation
  - Route tables for traffic control
  - Internet and NAT gateways
  - Security groups and NACLs

Benefits:
  - Network isolation
  - Scalable architecture
  - Security control
  - Hybrid connectivity
```

### Subnets and Availability Zones
```bash
# Public Subnet (Internet accessible)
CIDR: 10.0.1.0/24
Route: 0.0.0.0/0 -> Internet Gateway

# Private Subnet (Internal only)
CIDR: 10.0.2.0/24
Route: 0.0.0.0/0 -> NAT Gateway

# Database Subnet (Isolated)
CIDR: 10.0.3.0/24
Route: Local traffic only
```

### VPC Architecture
```mermaid
graph TB
    subgraph VPC [Virtual Private Cloud]
        IGW[Internet Gateway]
        NAT[NAT Gateway]

subgraph Public_Zone [Public Subnet 10.0.1.0/24]
            Web[Web Server]
            LB[Load Balancer]
        end

subgraph Private_Zone [Private Subnet 10.0.2.0/24]
            App[App Server]
            end

subgraph Data_Zone [Database Subnet 10.0.3.0/24]
            DB[(Database)]
        end
    end

Internet((Internet)) <--> IGW
    IGW <--> LB
    LB <--> Web
    Web <--> App
    App <--> DB
    App -.-> NAT
    NAT -.-> IGW

classDef public fill:#e3f2fd,stroke:#0d47a1
    classDef private fill:#fff3e0,stroke:#e65100
    classDef data fill:#f3e5f5,stroke:#4a148c

class Public_Zone public
    class Private_Zone private
    class Data_Zone data
```

## Cloud Provider Networking

### AWS Networking
**[➡️ Start Here: AWS Networking Deep Dive (VPC, Security, Troubleshooting)](./aws-networking-deep-dive.md)**

```yaml
VPC Components:
  - Internet Gateway (IGW)
  - NAT Gateway/Instance
  - Virtual Private Gateway (VGW)
  - Transit Gateway
  - VPC Peering
  - PrivateLink
  - Direct Connect

Security:
  - Security Groups (stateful)
  - Network ACLs (stateless)
  - AWS WAF
  - Shield (DDoS protection)
```

### Azure Networking
```yaml
Virtual Network Components:
  - Virtual Network (VNet)
  - Subnets
  - Network Security Groups (NSG)
  - Application Security Groups (ASG)
  - Azure Firewall
  - VPN Gateway
  - ExpressRoute
  - Virtual Network Peering

Load Balancing:
  - Azure Load Balancer
  - Application Gateway
  - Traffic Manager
  - Front Door
```

### Google Cloud Networking
```yaml
VPC Components:
  - Virtual Private Cloud
  - Subnets (regional)
  - Firewall rules
  - Cloud NAT
  - Cloud VPN
  - Cloud Interconnect
  - VPC Peering
  - Shared VPC

Global Infrastructure:
  - Global load balancing
  - Anycast IP addresses
  - Edge locations
  - Premium vs Standard tier
```

## Network Security

### Security Groups and Firewalls
```bash
# AWS Security Group
aws ec2 create-security-group \
  --group-name web-sg \
  --description "Web server security group"

aws ec2 authorize-security-group-ingress \
  --group-id sg-12345678 \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

# Azure NSG Rule
az network nsg rule create \
  --resource-group myRG \
  --nsg-name web-nsg \
  --name allow-http \
  --protocol tcp \
  --priority 100 \
  --destination-port-range 80 \
  --access allow

# GCP Firewall Rule
gcloud compute firewall-rules create allow-http \
  --allow tcp:80 \
  --source-ranges 0.0.0.0/0 \
  --target-tags web-server
```

### Network Segmentation
```yaml
Three-Tier Architecture:
  Web Tier:
    - Public subnets
    - Load balancers
    - Web servers

Application Tier:
    - Private subnets
    - Application servers
    - Auto scaling groups

Database Tier:
    - Private subnets
    - Database servers
    - Backup systems
```

## Hybrid Connectivity

### VPN Connections
```bash
# AWS Site-to-Site VPN
aws ec2 create-vpn-connection \
  --type ipsec.1 \
  --customer-gateway-id cgw-12345678 \
  --vpn-gateway-id vgw-12345678

# Azure VPN Gateway
az network vnet-gateway create \
  --resource-group myRG \
  --name myVPNGateway \
  --public-ip-address myGatewayIP \
  --vnet myVNet \
  --gateway-type Vpn \
  --sku VpnGw1

# GCP VPN Tunnel
gcloud compute vpn-tunnels create tunnel1 \
  --peer-address 203.0.113.12 \
  --shared-secret mysharedsecret \
  --target-vpn-gateway myvpngateway
```

### Direct Connections
```yaml
AWS Direct Connect:
  - Dedicated network connection
  - Consistent network performance
  - Reduced bandwidth costs
  - Private connectivity

Azure ExpressRoute:
  - Private connection to Azure
  - Predictable performance
  - Built-in redundancy
  - Global connectivity

GCP Cloud Interconnect:
  - Dedicated connections
  - Partner interconnect
  - Carrier peering
  - Direct peering
```

## Load Balancing and CDN

### Global Load Balancing
```yaml
AWS CloudFront + ALB:
  - Global edge locations
  - SSL termination
  - Caching strategies
  - Origin failover

Azure Front Door:
  - Global load balancing
  - SSL offloading
  - Web Application Firewall
  - URL-based routing

GCP Cloud Load Balancing:
  - Anycast IP addresses
  - Global backend services
  - Health checking
  - Traffic splitting
```

### Content Delivery Networks
```bash
# AWS CloudFront Distribution
aws cloudfront create-distribution \
  --distribution-config file://distribution-config.json

# Azure CDN Profile
az cdn profile create \
  --resource-group myRG \
  --name myCDNProfile \
  --sku Standard_Microsoft

# GCP Cloud CDN
gcloud compute backend-services update mybackend \
  --enable-cdn \
  --cache-mode CACHE_ALL_STATIC
```

## Network Monitoring

### Traffic Analysis
```yaml
AWS VPC Flow Logs:
  - Network traffic monitoring
  - Security analysis
  - Troubleshooting
  - Compliance auditing

Azure Network Watcher:
  - Connection monitoring
  - Packet capture
  - Flow logs
  - Topology visualization

GCP VPC Flow Logs:
  - Network monitoring
  - Security analysis
  - Performance optimization
  - Cost analysis
```

### Performance Monitoring
```bash
# Network latency testing
ping -c 10 target-host
traceroute target-host
mtr target-host

# Bandwidth testing
iperf3 -c target-host -t 60
speedtest-cli

# DNS resolution testing
nslookup domain.com
dig domain.com
```

This comprehensive guide covers cloud networking fundamentals, security, and implementation across major cloud platforms.

## Real World Scenarios

### Scenario 1: Startup Scaling with VPC Peering
**Context:** A startup undergoes a merger and needs to connect their AWS environment with the acquired company's AWS environment securely.
**Solution:**
- **VPC Peering:** Establish a direct network connection between the two VPCs using private IP addresses.
- **Route Table Updates:** Update route tables in both VPCs to allow traffic to the peer's CIDR block.
- **Security Groups:** Update inbound allow rules to accept traffic only from the peer's specific subnets.
**Benefit:** Secure, low-latency, and cost-effective connectivity without utilizing the public internet or complex VPNs.

### Scenario 2: Regulatory Compliance for Hybrid Cloud
**Context:** A bank must keep core transaction data on-premises (mainframe) but wants to use cloud for mobile banking frontend.
**Solution:**
- **Direct Connect / ExpressRoute:** Provision a dedicated physical line (10Gbps) between the on-prem data center and the cloud region.
- **Transit Gateway:** Use a Transit Gateway to route traffic from multiple cloud VPCs back to the on-prem connection.
**Benefit:** Guarantees bandwidth, reduces network jitter, and satisfies "private circuit" regulatory requirements versus a VPN over internet.

---

## Interview Questions

### Basic Level
1.  **What is a CIDR block and why is it important in cloud networking?**
    -   Classless Inter-Domain Routing (CIDR) defines the IP address range for a VPC or subnet (e.g., 10.0.0.0/16). It determines how many IP addresses are available for resources.
2.  **Explain the difference between a Public and a Private Subnet.**
    -   A Public Subnet has a route to an Internet Gateway (can talk to the internet directly). A Private Subnet does not; it often uses a NAT Gateway to initiate outbound requests but cannot receive inbound internet traffic.
3.  **What is a Security Group?**
    -   A virtual stateful firewall that controls inbound and outbound traffic for an EC2 instance or network interface.
4.  **How does a Load Balancer improve availability?**
    -   It distributes incoming traffic across multiple healthy instances. If one instance fails, the LB stops routing traffic to it, ensuring users don't face errors.
5.  **What is a VPN?**
    -   Virtual Private Network. It encrypts traffic running over the public internet to create a secure tunnel between two networks (e.g., On-Prem to Cloud).

### Intermediate Level
6.  **Direct Connect vs. Site-to-Site VPN: When to use which?**
    -   **VPN:** Fast to set up, cheap, uses internet (variable latency). Good for backups or small offices.
    -   **Direct Connect:** Long lead time, expensive, dedicated physical fiber (consistent latency, high bandwidth). Necessary for massive data transfer or strict compliance.
7.  **What is the purpose of a NAT Gateway?**
    -   Allows instances in a private subnet to connect to the internet (e.g., for OS updates) but prevents the internet from initiating a connection to those instances.
8.  **Explain "VPC Peering" limitations.**
    -   It's non-transitive (A connected to B, and B to C, does NOT mean A connects to C). CIDR blocks cannot overlap.
9.  **Stateless vs. Stateful Firewalls (NACL vs. Security Group).**
    -   **Security Group:** Stateful. If you allow inbound request, the outbound reply is automatically allowed.
    -   **NACL:** Stateless. You must explicitly allow both inbound and outbound traffic rules.
10. **What is "DNS Resolution"?**
    -   Translating human-readable domain names (www.google.com) into IP addresses (142.250.x.x) so computers can connect.

<b>11. </b>
<details>
<summary>Show Answer</summary>
Answer: B) 251-256 (Depending on provider reserved IPs)</b>
</details>


<b>2. Which component allows a Private Subnet to access the internet for updates?</b>
<details>
<summary>Show Answer</summary>
Answer: C) NAT Gateway</b>
</details>


<b>3. Security Groups are _____ , meaning return traffic is automatically allowed.</b>
<details>
<summary>Show Answer</summary>
Answer: B) Stateful</b>
</details>


<b>4. Which is a characteristic of Direct Connect / ExpressRoute?</b>
<details>
<summary>Show Answer</summary>
Answer: C) Private, dedicated physical connection</b>
</details>


<b>5. VPC Peering connections are transitive by default. (True/False)</b>
<details>
<summary>Show Answer</summary>
Answer: B) False</b>
</details>


<b>6. What is the primary function of a Route Table?</b>
<details>
<summary>Show Answer</summary>
Answer: B) To determine where network traffic is directed</b>
</details>


<b>7. Which service blocks specific IP addresses at the subnet level?</b>
<details>
<summary>Show Answer</summary>
Answer: B) Network ACL (NACL)</b>
</details>


<b>8. A bastion host (jump box) is typically placed in which subnet?</b>
<details>
<summary>Show Answer</summary>
Answer: C) Public Subnet</b>
</details>


<b>9. To distribute traffic across multiple EC2 instances, you should use:</b>
<details>
<summary>Show Answer</summary>
Answer: B) Load Balancer</b>
</details>


<b>10. Which protocol is ping based on?</b>
<details>
<summary>Show Answer</summary>
Answer: C) ICMP</b>
</details>


<b>11. What is the default route (0.0.0.0/0) usually pointed to for internet access?</b>
<details>
<summary>Show Answer</summary>
Answer: B) Internet Gateway (IGW)</b>
</details>


<b>12. You have overlapping CIDR blocks. Can you set up VPC peering?</b>
<details>
<summary>Show Answer</summary>
Answer: C) No, overlapping CIDRs generally prevent peering</b>
</details>


<b>13. Which DNS record type maps a domain name to an IPv4 address?</b>
<details>
<summary>Show Answer</summary>
Answer: A) A Record</b>
</details>


<b>14. In a "Hub and Spoke" model, the Hub VPC contains:</b>
<details>
<summary>Show Answer</summary>
Answer: B) Shared services (Firewalls, VPN termination)</b>
</details>


<b>15. Why use Private Subnets for Databases?</b>
<details>
<summary>Show Answer</summary>
Answer: B) Security isolation; so they are not directly accessible from the internet</b>
</details>


<b>16. What is the scope of a VPC?</b>
<details>
<summary>Show Answer</summary>
Answer: B) Regional</b>
</details>


<b>17. What allows you to view rejected traffic packets in a VPC?</b>
<details>
<summary>Show Answer</summary>
Answer: A) VPC Flow Logs</b>
</details>


<b>18. Transit Gateway is used to:</b>
<details>
<summary>Show Answer</summary>
Answer: B) Simplify connectivity between many VPCs and on-prem networks (Hub-style interconnection)</b>
</details>


<b>19. Which command traces the path of a network packet?</b>
<details>
<summary>Show Answer</summary>
Answer: B) traceroute / tracert</b>
</details>


<b>20. Does a Security Group deny traffic by default?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes (Implicit Deny)</b>
</details>


<b>21. Ephemeral ports are:</b>
<details>
<summary>Show Answer</summary>
Answer: B) Temporary ports used for the client-side of a connection</b>
</details>
