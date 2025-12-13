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

## Cloud Provider Networking

### AWS Networking
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