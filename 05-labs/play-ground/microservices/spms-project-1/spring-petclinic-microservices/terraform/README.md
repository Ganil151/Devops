# Spring PetClinic Microservices - Terraform Infrastructure

> **Production-Grade Infrastructure as Code for the PetClinic Microservices Application**

This directory contains a complete, enterprise-ready Terraform configuration for deploying the Spring PetClinic Microservices application to AWS.

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                     AWS Cloud                           │
│  ┌───────────────────────────────────────────────────┐  │
│  │  VPC (10.x.0.0/16)                                 │  │
│  │  ┌─────────────┐         ┌─────────────┐          │  │
│  │  │   Public    │         │   Private   │          │  │
│  │  │   Subnets   │──NAT──▶ │   Subnets   │          │  │
│  │  │             │         │             │          │  │
│  │  │   - ALB     │         │ - EKS Nodes │          │  │
│  │  │   - NAT GW  │         │ - RDS       │          │  │
│  │  └─────────────┘         └─────────────┘          │  │
│  └───────────────────────────────────────────────────┘  │
│                                                          │
│  ┌────────────┐  ┌────────────┐  ┌────────────────┐    │
│  │    EKS     │  │    RDS     │  │      ECR       │    │
│  │  Cluster   │  │   MySQL    │  │  Repositories  │    │
│  └────────────┘  └────────────┘  └────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 Directory Structure

```
terraform/
├── environments/
│   ├── dev/              ← Development environment
│   ├── staging/          ← Staging environment
│   └── prod/             ← Production environment (3 AZs)
├── modules/
│   ├── networking/       ← VPC, Subnets, NAT, IGW
│   ├── eks/              ← Kubernetes cluster
│   ├── rds/              ← MySQL database
│   ├── ecr/              ← Container registries
│   ├── secrets/          ← Secrets Manager
│   ├── monitoring/       ← CloudWatch logs
│   └── alb/              ← Load balancer config
├── shared/
│   ├── versions.tf       ← Terraform version constraints
│   ├── providers.tf      ← AWS provider config
│   └── data.tf           ← Shared data sources
└── scripts/
    ├── init.sh           ← Initialize environment
    ├── plan.sh           ← Generate execution plan
    ├── apply.sh          ← Deploy infrastructure
    └── destroy.sh        ← Cleanup (with prod protection)
```

---

## 🚀 Quick Start

### Prerequisites
- Terraform `>= 1.5.0`
- AWS CLI configured with credentials
- S3 bucket for state backend (create manually first)

### 1. Initialize the Environment

```bash
cd terraform
./scripts/init.sh dev
```

### 2. Review the Plan

```bash
./scripts/plan.sh dev
```

### 3. Deploy

```bash
./scripts/apply.sh dev
```

### 4. Get Outputs

```bash
cd environments/dev
terraform output
```

---

## 🛠️ Module Details

### Networking Module
- **VPC** with DNS support
- **Public Subnets** for ALB and NAT Gateway
- **Private Subnets** for EKS nodes and RDS
- **NAT Gateway** for outbound internet access
- **Route Tables** with proper associations

### EKS Module
- **Managed Node Groups** using Spot Instances
- **IRSA (IAM Roles for Service Accounts)** enabled
- **AWS Load Balancer Controller** IAM role
- **Karpenter** support for autoscaling

### RDS Module
- **MySQL 8.0** with automated backups
- **Security Groups** restricting access to VPC
- **Multi-AZ** in production (disabled in dev/staging for cost)
- **IAM Database Authentication** enabled

### ECR Module
- **Image Scanning** on push
- **Mutable Tags** for development velocity
- Separate repositories for each microservice

---

## 🌍 Environment Differences

| Feature | Dev | Staging | Prod |
|:---|:---|:---|:---|
| **Availability Zones** | 2 | 2 | 3 |
| **EKS Min Nodes** | 1 | 1 | 2 |
| **EKS Max Nodes** | 3 | 3 | 6 |
| **RDS Multi-AZ** | ❌ | ❌ | ✅ |
| **VPC CIDR** | 10.0.0.0/16 | 10.1.0.0/16 | 10.2.0.0/16 |

---

## 🔐 Security Best Practices

- ✅ **RDS** is in private subnets with no public access
- ✅ **Security Groups** follow principle of least privilege
- ✅ **Secrets** managed via AWS Secrets Manager
- ✅ **Terraform State** encrypted in S3 with DynamoDB locking
- ✅ **IAM Roles** use IRSA (no static credentials in pods)

---

## 💰 Cost Optimization

- **Spot Instances** for all EKS worker nodes (70% savings)
- **Single NAT Gateway** in dev/staging (multi-NAT in prod)
- **RDS Single-AZ** in non-production environments
- **7-day log retention** (vs. default indefinite)

---

## 🧪 Testing

Run Terraform validation:
```bash
terraform fmt -recursive -check
terraform validate
```

Run TFLint:
```bash
tflint --init
tflint
```

---

## 📊 State Management

State is stored in **S3** with **DynamoDB** locking:

```hcl
backend "s3" {
  bucket         = "petclinic-terraform-state-{env}"
  key            = "{env}/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-state-lock"
}
```

**Before first run**, create the S3 bucket and DynamoDB table manually.

---

## 🔄 CI/CD Integration

The `scripts/` directory contains automation-friendly helpers:

```yaml
# Example GitHub Actions workflow
- name: Deploy to Dev
  run: |
    ./terraform/scripts/init.sh dev
    ./terraform/scripts/plan.sh dev
    ./terraform/scripts/apply.sh dev
```

---

## 🚨 Troubleshooting

### Plan shows no changes but resources exist
- Check that you're in the correct environment directory
- Verify backend configuration matches

### EKS nodes not joining cluster
- Check security group rules allow kubelet communication
- Verify IAM roles are correctly attached

### RDS connection timeout
- Confirm application pods are in the same VPC
- Check security group ingress rules

---

## 📚 Additional Resources

- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Terraform AWS Modules](https://registry.terraform.io/namespaces/terraform-aws-modules)
- [Spring PetClinic Source](https://github.com/spring-petclinic/spring-petclinic-microservices)

---

**Status**: ✅ Production-Ready
**Last Updated**: 2026-02-08
