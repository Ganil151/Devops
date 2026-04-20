# Finishline Infrastructure - Terraform Modules

## Overview

This repository contains Terraform modules for deploying the Finishline infrastructure on AWS. The infrastructure is built around Amazon EKS (Elastic Kubernetes Service) and follows a modular, reusable architecture.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        Finishline Infrastructure                             │
│                              AWS (us-east-1)                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                            VPC Module                                  │  │
│  │                         10.0.0.0/16                                    │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                    │  │
│  │  │ Public AZ-a │  │ Public AZ-b │  │ Public AZ-c │                    │  │
│  │  │ 10.0.1.0/24 │  │ 10.0.2.0/24 │  │ 10.0.3.0/24 │                    │  │
│  │  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘                    │  │
│  │         │                │                │                            │  │
│  │         └────────────────┼────────────────┘                            │  │
│  │                          │                                             │  │
│  │                   ┌──────▼──────┐                                      │  │
│  │                   │     IGW     │                                      │  │
│  │                   │  (Internet  │                                      │  │
│  │                   │   Gateway)  │                                      │  │
│  │                   └──────┬──────┘                                      │  │
│  │                          │                                             │  │
│  │         ┌────────────────┼────────────────┐                            │  │
│  │         │                │                │                            │  │
│  │  ┌──────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐                    │  │
│  │  │Private AZ-a │  │Private AZ-b │  │Private AZ-c │                    │  │
│  │  │10.0.10.0/24 │  │10.0.11.0/24 │  │10.0.12.0/24 │                    │  │
│  │  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘                    │  │
│  │         │                │                │                            │  │
│  │         └────────────────┼────────────────┘                            │  │
│  │                          │                                             │  │
│  │                   ┌──────▼──────┐                                      │  │
│  │                   │  NAT GW     │                                      │  │
│  │                   │  (Single)   │                                      │  │
│  │                   └─────────────┘                                      │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                              │                                                │
│                              │                                                │
│  ┌───────────────────────────▼───────────────────────────────────────────┐  │
│  │                         EKS Module                                     │  │
│  │                    finishline-eks-cluster                              │  │
│  │                                                                        │  │
│  │  ┌─────────────────────────────────────────────────────────────────┐  │  │
│  │  │                    Control Plane (Managed)                       │  │  │
│  │  │  • API Server  • etcd  • Controller Manager  • Scheduler         │  │  │
│  │  └─────────────────────────────────────────────────────────────────┘  │  │
│  │                                                                        │  │
│  │  ┌─────────────────────────────────────────────────────────────────┐  │  │
│  │  │                    EKS Addons                                    │  │  │
│  │  │  • VPC CNI  • CoreDNS  • kube-proxy  • AWS EBS CSI              │  │  │
│  │  └─────────────────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                              │                                                │
│                              │                                                │
│  ┌───────────────────────────▼───────────────────────────────────────────┐  │
│  │                         IAM Module                                     │  │
│  │                                                                        │  │
│  │  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐    │  │
│  │  │  Cluster Role    │  │  NodeGroup Role  │  │   OIDC Role      │    │  │
│  │  │  (eks.amazonaws) │  │  (ec2.amazonaws) │  │  (IRSA)          │    │  │
│  │  └──────────────────┘  └──────────────────┘  └──────────────────┘    │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                              │                                                │
│                              │                                                │
│  ┌───────────────────────────▼───────────────────────────────────────────┐  │
│  │                      Security Group Module                             │  │
│  │                                                                        │  │
│  │  ┌─────────────────────────────────────────────────────────────────┐  │  │
│  │  │  Ingress: SSH(22), HTTP(80), HTTPS(443), EKS Rules (optional)   │  │  │
│  │  │  Egress: All outbound                                           │  │  │
│  │  └─────────────────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                       Key Pair Module                                  │  │
│  │                    (Nested in VPC Module)                              │  │
│  │                  RSA 4096-bit SSH Key Pair                             │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                       Jumphost Module                                  │  │
│  │                    (Bastion Host for SSH Access)                       │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                    │  │
│  │  │    EC2      │  │     SG      │  │    IAM      │                    │  │
│  │  │  Instance   │  │  (SSH:22)   │  │    Role     │                    │  │
│  │  │ AL2023 AMI  │  │  Egress:All │  │  (EC2)      │                    │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘                    │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Module Structure

```
terraform/
├── modules/                    # Reusable Terraform modules
│   ├── vpc/                    # VPC and networking
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── locals.tf
│   │   ├── data.tf
│   │   └── README.md
│   ├── sg/                     # Security Groups
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── locals.tf
│   │   ├── data.tf
│   │   └── README.md
│   ├── eks/                    # EKS Cluster
│   │   ├── main.tf
│   │   ├── addons.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── locals.tf
│   │   ├── data.tf
│   │   └── README.md
│   ├── iam/                    # IAM Roles and Policies
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── locals.tf
│   │   ├── data.tf
│   │   └── README.md
│   ├── key_pair/               # SSH Key Pair
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── locals.tf
│   │   └── README.md
│   ├── jumphost/               # Jumphost / Bastion Host
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── locals.tf
│   │   ├── data.tf
│   │   └── README.md
│   ├── bootstrap/              # Cluster Bootstrap (placeholder)
│   │   ├── versions.tf
│   │   ├── variables.tf
│   │   ├── locals.tf
│   │   └── README.md
│   └── alb/                    # Application Load Balancer (placeholder)
│
└── envs/                       # Environment configurations
    ├── dev/                    # Development environment
    │   └── terragrunt.hcl
    ├── staging/                # Staging environment
    │   └── terragrunt.hcl
    └── prod/                   # Production environment
        └── terragrunt.hcl
```

## Modules

### Core Modules

| Module                                     | Description                                             | Status      |
| ------------------------------------------ | ------------------------------------------------------- | ----------- |
| [**VPC**](modules/vpc/README.md)           | VPC, subnets, gateways, route tables, NACLs, Key Pair   | ✅ Complete |
| [**SG**](modules/sg/README.md)             | Security groups with dynamic rules and EKS support      | ✅ Complete |
| [**EKS**](modules/eks/README.md)           | EKS cluster control plane and addons                    | ✅ Complete |
| [**IAM**](modules/iam/README.md)           | IAM roles, policies, and OIDC provider                  | ✅ Complete |
| [**Key Pair**](modules/key_pair/README.md) | SSH key pair generation and management                  | ✅ Complete |
| [**Jumphost**](modules/jumphost/README.md) | Bastion host for secure SSH access to private resources | ✅ Complete |

### Placeholder Modules

| Module                                       | Description                              | Status         |
| -------------------------------------------- | ---------------------------------------- | -------------- |
| [**Bootstrap**](modules/bootstrap/README.md) | Cluster bootstrapping and initialization | ⚠️ Placeholder |
| **ALB**                                      | Application Load Balancer for ingress    | ⚠️ Placeholder |

## Network Strategy

### VPC Design

| Component          | Configuration                                  |
| ------------------ | ---------------------------------------------- |
| VPC CIDR           | `10.0.0.0/16`                                  |
| Public Subnets     | `10.0.1.0/24`, `10.0.2.0/24`, `10.0.3.0/24`    |
| Private Subnets    | `10.0.10.0/24`, `10.0.11.0/24`, `10.0.12.0/24` |
| Availability Zones | `us-east-1a`, `us-east-1b`, `us-east-1c`       |

### Routing

| Subnet Type | Route Target     | Destination |
| ----------- | ---------------- | ----------- |
| Public      | Internet Gateway | `0.0.0.0/0` |
| Private     | NAT Gateway      | `0.0.0.0/0` |

### Security

| Layer           | Implementation                                |
| --------------- | --------------------------------------------- |
| Network ACLs    | Stateful rules for public and private subnets |
| Security Groups | Dynamic ingress/egress rules with EKS support |
| Key Pair        | RSA 4096-bit SSH keys                         |

## Usage

### Prerequisites

- Terraform >= 1.0
- Terragrunt >= 0.50 (for environment management)
- AWS CLI configured with appropriate credentials
- TLS provider for key generation

### Quick Start (Development)

```bash
cd terraform/envs/dev

# Initialize Terraform
terragrunt init

# Plan the infrastructure
terragrunt plan

# Apply the infrastructure
terragrunt apply
```

### Module Usage Example

```hcl
# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name         = "finishline-infra"
  environment          = "development"
  managed_by           = true
  availability_zone    = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_cidr             = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  public_subnet_cidr   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidr  = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  key_name             = "finishline-key"
  key_algorithm        = "RSA"
  rsa_bits             = 4096
  private_key_directory = path.module
  private_key_filename = "finishline-key.pem"
}

# Security Group Module
module "sg" {
  source = "./modules/sg"

  project_name      = "finishline-infra"
  environment       = "development"
  manage_by         = true
  availability_zone = ["us-east-1a", "us-east-1b"]
  vpc_id            = module.vpc.vpc_id

  ingress_rules = [
    {
      description = "SSH from VPC"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/16"
    }
  ]

  egress_rules = [
    {
      description = "Allow all outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  project_name                = "finishline-infra"
  environment                 = "development"
  manage_by                   = true
  availability_zone           = ["us-east-1a", "us-east-1b"]
  cluster_name                = "finishline-eks-cluster"
  is_eks_role_enabled         = true
  is_eks_cluster_enabled      = true
  is_eks_nodegroup_role_enabled = true
  is_role_enabled             = true
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  project_name            = "finishline-infra"
  environment             = "development"
  manage_by               = true
  availability_zone       = ["us-east-1a", "us-east-1b", "us-east-1c"]
  cluster_name            = "finishline-eks-cluster"
  is_eks_cluster_enabled  = true
  cluster_version         = "1.35"
  cluster_role_arn        = module.iam.eks_cluster_role_arn
  cluster_enabled_log_types = ["api", "audit", "authenticator"]
  subnet_ids              = module.vpc.private_subnet_ids
  security_group_ids      = [module.sg.security_group_id]
  endpoint_private_access = true
  endpoint_public_access  = false
  is_eks_addons_enabled   = true
  addons = {
    "vpc-cni" = {
      version                  = "1.15.0"
      service_account_role_arn = module.iam.oidc_role_arn
    }
  }
}
```

## Environment Configuration

### Development (`envs/dev`)

| Parameter   | Value               |
| ----------- | ------------------- |
| Region      | us-east-1           |
| VPC CIDR    | 10.0.0.0/16         |
| EKS Version | 1.35                |
| Node Types  | t3.medium           |
| Node Count  | 2 on-demand, 2 spot |

### Staging (`envs/staging`)

> Configuration to be defined

### Production (`envs/prod`)

> Configuration to be defined

## Known Issues and Limitations

### 1. NACL Configuration ✅ Resolved

The NACL implementation has been updated to use only internet-facing NACL associated with the first public subnet. This ensures proper multi-AZ compatibility as AWS NACLs can only be associated with one subnet at a time.

### 2. Single NAT Gateway

The VPC module uses a single NAT Gateway in the first public subnet. This creates a single point of failure for private subnet outbound traffic.

**Recommendation**: For production, deploy multiple NAT Gateways across AZs.

### 3. Security Group CIDR Blocks

The EKS rules in the SG module use `var.vpc_id` as a placeholder for CIDR blocks. This should be the actual VPC CIDR.

**Fix Required**: Pass VPC CIDR block instead of VPC ID.

### 4. Placeholder Modules

The following modules have placeholder documentation and are not yet fully implemented:

- **Bootstrap** - Documentation created, implementation pending
- **ALB** - Documentation created, implementation pending

**Completed Modules:**

- ✅ **Jumphost** - Fully implemented with security group, IAM role, and EC2 instance

## Security Considerations

1. **Private Key Management**: SSH private keys are stored locally. Ensure proper file permissions (`0600`) and secure storage.

2. **State File Security**: Terraform state contains sensitive information. Use remote state with encryption (S3 + DynamoDB).

3. **Endpoint Access**: EKS cluster is configured with private-only access by default. Use the jumphost module for SSH access to private resources.

4. **Jumphost SSH Access**: The jumphost security group allows SSH from `0.0.0.0/0` by default. For production, restrict to specific CIDR blocks (office IPs, VPN ranges).

5. **IAM Permissions**: Review and minimize IAM policies for production use.

## Contributing

1. Create a feature branch
2. Make changes to the appropriate module
3. Update the module's README.md
4. Test changes in the dev environment
5. Submit a pull request

## License

[Add your license information here]

## Contact

[Add contact information here]
