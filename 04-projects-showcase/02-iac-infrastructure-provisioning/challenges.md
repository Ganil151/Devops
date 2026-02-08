# Infrastructure Provisioning: Engineering Challenges

These challenges are designed to test your understanding of Terraform patterns, AWS architecture, and SRE principles.

## 🟢 Level 1: Beginner (Base Camp)
1. **The "Wait" Problem**: How do you ensure an RDS database is fully ready before a Lambda function tries to run a DB migration? (Hint: `depends_on` vs. custom scripts).
2. **Tagging Policy**: Write a Terraform block that forces every resource to have a `Project`, `Owner`, and `Environment` tag.
3. **S3 Public Lockout**: Create an S3 bucket configuration that explicitly blocks all public access and enforces encryption-at-rest.

## 🟡 Level 2: Intermediate (The Professional)
1. **The "DR" Switch**: Design a multi-region VPC Peering setup. If Region A goes down, how does your infrastructure handle the failover?
2. **State Locking Mystery**: You try to run `terraform apply` and get a message saying the state is "Locked." What happened, and how do you resolve it safely?
3. **Dynamic Subnets**: Use the `cidrsubnet()` function to dynamically calculate 3 public and 3 private subnets across multiple Availability Zones given a single VPC CIDR block.

## 🔴 Level 3: Advanced (The Staff Engineer)
1. **EKS Secret Injection**: Compare using Kubernetes Secrets vs. AWS Secrets Manager (via CSI driver). Which is more secure for an SRE-grade cluster?
2. **Zero-Trust Networking**: Design a CloudFront + S3 static site where the S3 bucket has NO public IP and NO public access, restricted entirely via OAC (Origin Access Control).
3. **The Migration Hazard**: You need to rename a resource in Terraform without destroying and recreating it. How do you use `moved` blocks or `terraform state mv`?

---
*Solve these by searching the patterns library in `terraform/parts/`!*
