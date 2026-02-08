# AWS Security Group Patterns Index

This directory contains 20 common Security Group (SG) patterns for AWS using Terraform. Security Groups act as virtual firewalls for your EC2 instances, providing stateful traffic filtering at the resource level.

## 📂 Security Group Types Overview

| # | Type | Description | File |
|---|------|-------------|------|
| 1 | **Web Server** | Allows public HTTP (80) and HTTPS (443) traffic. | `01-web-server-sg.tf` |
| 2 | **SSH/Management** | Restricted SSH access from specific admin/office IPs. | `02-ssh-access-sg.tf` |
| 3 | **Database** | Stateful filtering allowing DB ports (5432) from App SG. | `03-database-sg.tf` |
| 4 | **Load Balancer** | Public-facing ALB accepting web traffic. | `04-load-balancer-sg.tf` |
| 5 | **App Tier** | Middle-tier accepting traffic ONLY from the ALB. | `05-app-tier-sg.tf` |
| 6 | **Internal Mesh** | Allows all traffic between members of the same SG (self). | `06-internal-mesh-sg.tf` |
| 7 | **Outbound Only** | Denies all ingress; allows all egress (standard for updates). | `07-outbound-only-sg.tf` |
| 8 | **Restricted Egress** | Strict outbound control (e.g., only HTTPS allowed). | `08-restricted-egress-sg.tf` |
| 9 | **EFS Mount** | NFS traffic (2049) configuration for shared storage. | `09-efs-mount-sg.tf` |
| 10 | **Redis/Cache** | Elasticache ports (6379) restricted to app clients. | `10-redis-cache-sg.tf` |
| 11 | **Monitoring** | Ports for Prometheus, Node Exporter, and metrics scraping. | `11-monitoring-metrics-sg.tf` |
| 12 | **Bastion Host** | Highly restricted SSH for jump servers. | `12-bastion-host-sg.tf` |
| 13 | **Active Directory** | complex set of ports (LDAP, DNS, Kerberos) for AD. | `13-active-directory-sg.tf` |
| 14 | **WinRM** | Remote management ports for Windows instances. | `14-winrm-management-sg.tf` |
| 15 | **K8s Cluster** | Control plane and worker node communication ports. | `15-k8s-cluster-sg.tf` |
| 16 | **CloudFront Origin** | Uses Prefix Lists to allow only CloudFront traffic. | `16-cloud-front-origin-sg.tf` |
| 17 | **VPN Access** | Allows internal traffic from on-premises CIDR ranges. | `17-vpn-access-sg.tf` |
| 18 | **VPC Peering** | Cross-VPC communication via peering CIDR blocks. | `18-vpc-peering-sg.tf` |
| 19 | **Prefix List** | Managed IP lists for easy scaled management. | `19-prefix-list-sg.tf` |
| 20 | **Minimalist** | A clean "Deny All" starting block for custom rules. | `20-minimalist-sg.tf` |

## 🚀 Key Concepts
- **Stateful**: SGs are stateful—if you send a request from your instance, the response traffic is allowed regardless of inbound rules.
- **Default Deny**: By default, SGs deny all inbound traffic and allow all outbound traffic.
- **Security Group Referencing**: Many examples here use `source_security_group_id`. This is a best practice that avoids hardcoding IP addresses.

## 🛠 Usage
You can reference these patterns when building your infrastructure modules. Each file assumes a `var.vpc_id` is available.
