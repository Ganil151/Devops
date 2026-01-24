# 🏗️ Terraform Golden Boilerplate - AWS Foundation

## 🚀 Overview
This is the "Golden Version" of the standard AWS Infrastructure Provisioning boilerplate. It consolidate multiple isolated patterns into a single, production-ready modular architecture.

## 📂 Structure
- `main.tf`: Root orchestration.
- `variables.tf`: Configuration entry points.
- `outputs.tf`: Infrastructure visibility.
- `modules/vpc/`: Robust VPC networking (Multi-AZ).
- `modules/sg/`: Hardened Security Group policies.

## 🛠️ Key Features
- **High Availability**: Supports multi-AZ subnet distribution.
- **Security**: Principle of Least Privilege in Security Group rules.
- **Maintainability**: Comprehensive tagging and modular design.
- **Idempotency**: Clean state management and resource isolation.

## 🚀 How to Use
1. Initialize: `terraform init`
2. Validate: `terraform validate`
3. Plan: `terraform plan`
4. Apply: `terraform apply`

---
*Senior DevOps Architect Audit 2026*
