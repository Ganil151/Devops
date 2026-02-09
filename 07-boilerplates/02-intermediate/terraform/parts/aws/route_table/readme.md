# AWS Route Table Architectural Patterns

This directory contains 20 common Route Table (RT) patterns for AWS using Terraform. Route Tables contain a set of rules, called routes, that are used to determine where network traffic is directed.

## 📂 Route Table Types Overview

| # | Type | Description | File |
|---|------|-------------|------|
| 1 | **Default RT** | Adopts the VPC's main route table. | `01-default-rt.tf` |
| 2 | **Public RT** | Route to common internet via IGW. | `02-public-rt.tf` |
| 3 | **Private RT** | Route to common internet via NAT Gateway. | `03-private-rt.tf` |
| 4 | **Isolated RT** | strictly internal; no external exit routes. | `04-isolated-rt.tf` |
| 5 | **Transit Gateway** | VPC-to-VPC or VPC-to-OnPrem routing via TGW. | `05-tgw-rt.tf` |
| 6 | **VPC Peering** | Routing traffic between two peered VPCs. | `06-vpc-peering-rt.tf` |
| 7 | **VPN RT** | Routing to data center over Site-to-Site VPN. | `07-vpn-rt.tf` |
| 8 | **VPC Endpoint** | Private routing to S3/DynamoDB (Gateway type). | `08-vpc-endpoint-rt.tf` |
| 9 | **IPv6 Egress** | Outbound-only IPv6 via Egress-Only IGW. | `09-ipv6-egress-rt.tf` |
| 10 | **Direct Connect** | Dedicated high-bandwidth on-prem connection. | `10-direct-connect-rt.tf` |
| 11 | **Multi-AZ RT** | Separate tables for AZ-specific NAT Gateway HA. | `11-multi-az-rt.tf` |
| 12 | **Local Zone** | Routing for low-latency AWS Local Zones. | `12-local-zone-rt.tf` |
| 13 | **Edge Ingress** | Ingress routing for security appliance clusters. | `13-edge-rt.tf` |
| 14 | **Blackhole** | Traffic mitigation pattern (packets dropped). | `14-blackhole-rt.tf` |
| 15 | **NAT Instance** | Legacy pattern using custom EC2 NAT instances. | `15-nat-instance-rt.tf` |
| 16 | **Outpost RT** | Networking for AWS Outposts infrastructure. | `16-outpost-rt.tf` |
| 17 | **Dual-Stack** | Combined IPv4 and IPv6 internet routing. | `17-dual-stack-rt.tf` |
| 18 | **Hub & Spoke** | Routing for centralized hub networking VPCs. | `18-hub-rt.tf` |
| 19 | **Prefix List** | Scalable management using Managed Prefix Lists. | `19-prefix-list-rt.tf` |
| 20 | **Minimalist** | Baseline table with no custom routes. | `20-minimalist-rt.tf` |

## 🚀 Key Best Practices
1.  **Least Privilege**: Only add routes that are absolutely necessary for the application.
2.  **High Availability**: Use separate route tables for private subnets in different AZs to avoid a single NAT Gateway failure affecting the entire VPC.
3.  **Naming Conventions**: Use clear tags (`Name`) that indicate the purpose and the tiers associated with the route table.
4.  **Gateway Endpoints**: Always use S3 and DynamoDB Gateway Endpoints to save on NAT Gateway data processing costs.
5.  **Transit Gateway**: For complex multi-VPC architectures, prefer Transit Gateway over mesh peering for easier management.

## 🛠 Prerequisites
These files are standalone examples. They assume variables like `var.vpc_id`, `var.igw_id`, `var.nat_gw_id`, etc., are provided by your environment.
