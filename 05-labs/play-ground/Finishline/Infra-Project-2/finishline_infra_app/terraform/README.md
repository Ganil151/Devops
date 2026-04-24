# Finishline Infrastructure - Terraform Project

## Project Overview

Complete Infrastructure-as-Code for Finishline 2026 project using Terraform, deploying a production-ready EKS cluster with supporting infrastructure on AWS.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    AWS Account (us-east-1)                  │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              VPC (10.0.0.0/16)                       │   │
│  │  ┌────────────────────────────────────────────────┐  │   │
│  │  │  Public Subnets (3x /24)                       │  │   │
│  │  │  - Internet Gateway                            │  │   │
│  │  │  - NAT Gateway                                 │  │   │
│  │  │  - Jump Host (Bastion)                         │  │   │
│  │  └────────────────────────────────────────────────┘  │   │
│  │  ┌────────────────────────────────────────────────┐  │   │
│  │  │  Private Subnets (3x /24)                      │  │   │
│  │  │  - EKS Cluster                                 │  │   │
│  │  │  - On-Demand Node Group (t3.medium)           │  │   │
│  │  │  - Spot Node Group (t3.medium/large)          │  │   │
│  │  └────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Security Groups                                     │   │
│  │  - SSH (22), HTTP (80), HTTPS (443)                 │   │
│  │  - EKS Node Communication (1025-65535)              │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  IAM                                                 │   │
│  │  - EKS Cluster Role                                 │   │
│  │  - EKS Node Group Role                              │   │
│  │  - OIDC Provider (for pod-level IAM)                │   │
│  │  - Instance Profile                                 │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Application Load Balancer (ALB)                    │   │
│  │  - HTTP/HTTPS listeners                             │   │
│  │  - Target groups for EKS services                   │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Module Dependencies

```
VPC Module (Foundation)
├── Security Group Module
│   └── EKS Module
│       └── Applications
├── Key Pair Module
│   └── Bootstrap Module (Jump Host)
│   └── EC2 Module
├── IAM Module
│   └── EKS Module
└── ALB Module
    └── EKS Module (via Kubernetes Ingress)
```

## Modules

### 1. VPC Module

- **Path**: `modules/vpc`
- **Purpose**: Network foundation
- **Creates**: VPC, subnets (public/private), IGW, NAT Gateway, EIP, route tables, NACLs
- **Outputs**: VPC ID, subnet IDs, gateway IDs, route table IDs

### 2. Security Group Module

- **Path**: `modules/security_group`
- **Purpose**: Network access control
- **Creates**: Security group with dynamic ingress/egress rules, EKS node communication rules
- **Outputs**: Security group ID

### 3. Key Pair Module

- **Path**: `modules/secret/key_pair`
- **Purpose**: SSH access management
- **Creates**: RSA 4096-bit key pair, stores private key locally with secure permissions
- **Outputs**: Key name, private key path, public key

### 4. IAM Module

- **Path**: `modules/secret/iam`
- **Purpose**: Authentication and authorization for EKS
- **Creates**: EKS cluster role, EKS node group role, instance profile, OIDC provider, S3 access policy
- **Outputs**: Role ARNs, instance profile ARN, OIDC provider ARN

### 5. EKS Module

- **Path**: `modules/eks`
- **Purpose**: Kubernetes cluster management
- **Creates**: EKS cluster, on-demand node group, spot node group, OIDC provider, EKS add-ons
- **Outputs**: Cluster ID, endpoint, version, OIDC issuer URL, node group IDs

### 6. Bootstrap Module

- **Path**: `modules/bootstrap`
- **Purpose**: Jump host for administrative access
- **Creates**: EC2 instance (Amazon Linux 2023) with public IP, key pair association, security group
- **Outputs**: Instance ID, public/private IP

### 7. EC2 Module

- **Path**: `modules/ec2`
- **Purpose**: General-purpose compute instances
- **Creates**: EC2 instances with networking and storage (placeholder - implementation needed)
- **Outputs**: Instance IDs, IP addresses

### 8. ALB Module

- **Path**: `modules/alb`
- **Purpose**: Application load balancing and ingress
- **Creates**: Application Load Balancer, target groups, listeners (placeholder - implementation needed)
- **Outputs**: ALB ARN, DNS name, target group ARN

## Deployment Flow

1. **VPC Module** creates network infrastructure
2. **Security Group Module** configures network access
3. **IAM Module** sets up authentication roles
4. **Key Pair Module** generates SSH credentials
5. **Bootstrap Module** deploys jump host for admin access
6. **EKS Module** deploys Kubernetes cluster using VPC, SG, and IAM
7. **ALB Module** provides ingress for applications (optional)

## Quick Start

```bash
cd terraform/environments/dev

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -out=tfplan

# Apply configuration
terraform apply tfplan

# Get cluster credentials
aws eks update-kubeconfig --name finishline-eks-cluster --region us-east-1

# Verify cluster
kubectl get nodes
```

## Configuration

Key variables in `terraform.tfvars`:

- `cluster_name`: EKS cluster name
- `cluster_version`: Kubernetes version (1.35)
- `desired_capacity_on_demand`: On-demand node count (2)
- `desired_capacity_on_spot`: Spot node count (2)
- `endpoint_private_access`: Private API endpoint (true)
- `endpoint_public_access`: Public API endpoint (false)

## Outputs

After deployment, retrieve outputs:

```bash
terraform output eks_cluster_role_arn
terraform output cluster_endpoint
terraform output vpc_id
```

## Cleanup

```bash
terraform destroy
```

## Best Practices Implemented

- ✅ Private subnets for EKS nodes
- ✅ NAT Gateway for outbound internet access
- ✅ OIDC provider for pod-level IAM
- ✅ Security groups with least privilege
- ✅ Spot instances for cost optimization
- ✅ Consistent tagging across resources
- ✅ State locking with S3 backend
- ✅ Modular architecture for reusability
- ✅ Jump host for secure administrative access
- ✅ Application Load Balancer for ingress management
