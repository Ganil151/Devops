# Finishline Infra Project Overview

## Directory Structure

```
terraform/
├── environments/
│   ├── dev/          # Development environment
│   ├── staging/      # Staging environment
│   └── prod/         # Production environment
└── modules/
    ├── vpc/          # VPC, subnets, IGW, NAT, route tables
    ├── alb/          # Application Load Balancer with IngressGroup
    ├── eks/          # EKS cluster and managed node groups
    ├── bootstrap/    # Jumphost EC2 instance
    ├── security_group/  # Security groups
    ├── ec2/          # EC2 instances
    └── secret/
        ├── iam/      # IAM roles and policies
        └── key_pair/ # SSH key pairs
```

## Quick Start

### Prerequisites

- Terraform >= 1.6.0
- AWS CLI >= 2.x
- Git

### Initial Setup

1. **Configure AWS credentials:**
   ```bash
   aws configure
   # or
   aws sso login --profile <profile>
   ```

2. **Create S3 backend bucket (one-time):**
   ```bash
   ./scripts/create-backend-bucket.sh
   ```

3. **Initialize and deploy (dev environment):**
   ```bash
   cd terraform/environments/dev
   terraform init
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

## Environments

| Environment | State Backend | Status |
|-------------|---------------|--------|
| `dev`       | S3: finishline-infra-app-<hash> | ✅ Active |
| `staging`   | S3: finishline-infra-app-<hash> | 🔲 Pending |
| `prod`      | S3: finishline-infra-app-<hash> | 🔲 Pending |

## Modules

| Module | Description | Status |
|--------|-------------|--------|
| `vpc` | VPC with 3 public + 3 private subnets | ✅ Complete |
| `alb` | Shared ALB with IngressGroup | ✅ Complete |
| `eks` | EKS cluster with 2x t3.medium nodes | ✅ Complete |
| `bootstrap` | Jumphost (Amazon Linux 2023) | ✅ Complete |
| `security_group` | Dynamic security groups | ✅ Complete |
| `secret/iam` | IAM roles for EKS | ✅ Complete |
| `secret/key_pair` | SSH key pair management | ✅ Complete |

## Assignment Compliance

| Requirement | Status | Reference |
|-------------|--------|-----------|
| 3 subnets across 3 AZs | ✅ | §51, §55 |
| EKS with 2x t3.medium | ✅ | §74, §75 |
| Bottlerocket AMI | ✅ | §79 |
| Jumphost with SSH restriction | ✅ | §69, §70 |
| ALB with IngressGroup | ✅ | §31, §62 |
| S3 backend with locking | ✅ | §28, §101 |

## Documentation

- [Runbook](../../docs/RUNBOOK.md)
- [Assignment PDF](../../docs/Finishline_Infra_Project_Assignment.pdf)

## Support

For issues or questions, contact the Platform Team.

---

**Reporter:** Ganil Batist  
**Timeline:** Feb 26, 2026 – March 2, 2026

