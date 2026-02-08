# AWS VPC Patterns Index

This directory contains 20 different Virtual Private Cloud (VPC) configurations for Amazon Web Services (AWS) using Terraform. Each pattern is designed for a specific architectural requirement.

## 📂 VPC Types Overview

| # | Type | Description | File |
|---|------|-------------|------|
| 1 | **Default VPC** | Adopts the AWS-provisioned default VPC into Terraform. | `01-default-vpc.tf` |
| 2 | **Custom VPC** | A fully customizable VPC with specific CIDR and options. | `02-custom-vpc.tf` |
| 3 | **Public VPC** | Configured with an IGW and routes for public internet access. | `03-public-vpc.tf` |
| 4 | **Private VPC** | Uses a NAT Gateway for outbound traffic; no direct inbound. | `04-private-vpc.tf` |
| 5 | **Isolated VPC** | No internet access; strictly for internal communication. | `05-isolated-vpc.tf` |
| 6 | **Multi-Tier VPC** | Hierarchical design with Public, Private, and Isolated subnets. | `06-multi-tier-vpc.tf` |
| 7 | **Transit VPC** | Centralized hub for interconnecting multiple VPCs/networks. | `07-transit-vpc.tf` |
| 8 | **Shared VPC** | Centrally managed networking shared across multiple accounts. | `08-shared-vpc.tf` |
| 9 | **VPC with Peering** | Direct private connection between two VPCs. | `09-vpc-peering.tf` |
| 10 | **VPC with Endpoints** | Secure, private access to AWS services (S3, DynamoDB, etc). | `10-vpc-endpoints.tf` |
| 11 | **VPC Flow Logs** | Captures traffic metadata for auditing and security analysis. | `11-vpc-flow-logs.tf` |
| 12 | **VPC with NACLs** | Subnet-level, stateless traffic filtering (Layer 4). | `12-vpc-nacl.tf` |
| 13 | **Security Groups** | Instance-level, stateful traffic filtering. | `13-vpc-security-groups.tf` |
| 14 | **Hybrid VPC** | Connected to on-premises via VPN or Direct Connect. | `14-hybrid-vpc.tf` |
| 15 | **Serverless VPC** | Optimized for Lambda functions with Private Link support. | `15-serverless-vpc.tf` |
| 16 | **IPv6-Enabled VPC** | Supporting dual-stack (IPv4/IPv6) modern networking. | `16-ipv6-vpc.tf` |
| 17 | **HA VPC** | High Availability across multiple Availability Zones. | `17-ha-vpc.tf` |
| 18 | **Egress-Only VPC** | IPv6 outbound-only traffic via Egress-Only IGW. | `18-egress-only-vpc.tf` |
| 19 | **Cross-Account VPC** | Deploying networking across AWS accounts via IAM Roles. | `19-cross-account-vpc.tf` |
| 20 | **Minimalist VPC** | Lightweight, cost-effective setup for POCs or testing. | `20-minimalist-vpc.tf` |

## 🚀 How to use
Each file is designed to be a standalone example. To use a specific pattern:
1. Ensure your AWS credentials are configured.
2. Initialize Terraform: `terraform init`.
3. Plan and apply: `terraform apply`.

> **Note**: Some patterns (like NAT Gateways or VPC Endpoints) incur hourly costs in AWS.
