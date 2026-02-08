# AWS Subnet Architectural Patterns

This directory contains 20 common subnet configuration patterns for AWS using Terraform. Subnets allow you to partition your VPC's IP address range into smaller segments for better security and routing control.

## 📂 Subnet Types Overview

| # | Type | Description | File |
|---|------|-------------|------|
| 1 | **Default Subnet** | Adopts an existing AWS-managed default subnet. | `01-default-subnet.tf` |
| 2 | **Public Subnet** | Configured with `map_public_ip_on_launch = true`. | `02-public-subnet.tf` |
| 3 | **Private Subnet** | No public IP mapping; for backend resources. | `03-private-subnet.tf` |
| 4 | **Isolated Subnet** | Purely internal; no IGW/NAT routing. | `04-isolated-subnet.tf` |
| 5 | **Multi-AZ Subnets** | Scalable subnet creation using `count` across AZs. | `05-multi-az-subnets.tf` |
| 6 | **Database Subnet** | Specifically tagged for RDS Subnet Groups. | `06-database-subnet.tf` |
| 7 | **App Tier** | Private segment for application servers. | `07-app-tier-subnet.tf` |
| 8 | **Web Tier** | Highly available public segment for frontends. | `08-web-tier-subnet.tf` |
| 9 | **Management** | Small `/28` range for bastions and jump hosts. | `09-management-subnet.tf` |
| 10 | **Lambda Subnet** | Optimized for Serverless VPC integration. | `10-lambda-subnet.tf` |
| 11 | **TGW Attachment** | Dedicated small subnets for Transit Gateway. | `11-tgw-attachment-subnet.tf` |
| 12 | **ALB Subnet** | Public subnets specifically for Load Balancers. | `12-load-balancer-subnet.tf` |
| 13 | **VPN Traffic** | Hybrid-cloud segment for on-premises traffic. | `13-vpn-traffic-subnet.tf` |
| 14 | **Outpost Subnet** | Deployed on physical AWS Outposts hardware. | `14-outpost-subnet.tf` |
| 15 | **IPv6-Only** | Native IPv6 networking with no IPv4 stack. | `15-ipv6-only-subnet.tf` |
| 16 | **Dual-Stack** | Supporting both IPv4 and IPv6 traffic. | `16-dual-stack-subnet.tf` |
| 17 | **Reserved Spare** | Placeholder space for future architectural growth. | `17-reserved-spare-subnet.tf` |
| 18 | **High-Density** | Large `/20` range for high-scale container apps. | `18-high-density-subnet.tf` |
| 19 | **Local Zone** | Low-latency edge computing in Local Zones. | `19-local-zone-subnet.tf` |
| 20 | **Minimalist** | Smallest supported segment for nano-services. | `20-minimalist-subnet.tf` |

## 🚀 Technical Considerations
- **CIDR Calculation**: Always use the `cidrsubnet()` function to avoid manual IP overlap mistakes.
- **AZ Distribution**: For production, always distribute subnets across at least 2, ideally 3, Availability Zones (AZs).
- **Sizing**: Don't undersize subnets. AWS reserves 5 IP addresses per subnet (Network, Gateway, DNS, Reserved, Broadcast).
- **Public vs Private**: Public subnets MUST have a route to an Internet Gateway (IGW). Private subnets SHOULD have a route to a NAT Gateway.

## 🛠 Prerequisites
These files are modular but require common variables like `var.vpc_id` and `var.ipv6_vpc_cidr` to be defined in your root module.
