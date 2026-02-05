# Multi-Tier Enterprise Infrastructure

This project demonstrates a production-grade 3-tier architecture (Web, App, and Database) provisioned completely via Infrastructure-as-Code (Terraform) on AWS.

---

## 🏛️ Infrastructure Architecture

### 1. Networking (VPC)
- **Public Subnets**: Hosting the Application Load Balancers (ALB) and NAT Gateways.
- **Private Subnets**: Hosting the EC2 Application Servers and persistent Database instances.
- **Security Groups**: Strict ingress/egress rules enforcing the principle of least privilege.

### 2. Compute
- **Auto Scaling Groups (ASG)**: Ensuring high availability across multiple availability zones.
- **EC2 Launch Templates**: Standardized server configurations using Amazon Linux 2023.

### 3. Database
- **Amazon RDS**: Managed PostgreSQL/MySQL instances with Multi-AZ failover enabled.

---

## 🚀 Operations
1. **Initialize**: `terraform init`
2. **Plan**: `terraform plan -out=tfplan`
3. **Apply**: `terraform apply "tfplan"`

---
**Learning Integration**: This project is the capstone of the [Intermediate Terraform](../../README.md) module.