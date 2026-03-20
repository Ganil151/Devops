# EKS Module

This module creates and manages Amazon EKS (Elastic Kubernetes Service) clusters.

## Overview

The EKS module provides:

- **EKS Cluster** - Managed Kubernetes control plane
- **Access Management** - IAM-based cluster access
- **EKS Addons** - Core Kubernetes addons (vpc-cni, coredns, kube-proxy)
- **Encryption** - KMS-based secrets encryption

## Resources Created

### EKS Resources

- EKS Cluster
- EKS Access Entries for IAM principals
- EKS Access Policy Associations
- EKS Addons

### IAM Resources (optional)

- EKS Cluster IAM Role

## Usage

```hcl
terraform {
  source = "../../modules/compute/eks"
}

include {
  path = find_in_parent_folders("root.hcl")
}

# Dependencies
dependency "vpc" {
  config_path = "../../networking/vpc"
}

dependency "sg" {
  config_path = "../../networking/sg"
}

dependency "iam" {
  config_path = "../../security/iam"
}

dependency "kms" {
  config_path = "../../security/kms"
}

inputs = {
  project_name = "finishline-infra-app"
  environment  = "dev"
  managed_by   = "finishline-infra-team"
  aws_region   = "us-east-1"

  cluster_name = "finishline-dev-eks"
  cluster_version = "1.35"

  # Network
  subnets            = dependency.vpc.outputs.private_subnet_ids
  security_group_ids = [dependency.sg.outputs.security_group_id]

  # IAM
  cluster_role_arn = dependency.iam.outputs.eks_cluster_role_arn

  # Encryption
  kms_key_arn = dependency.kms.outputs.kms_key_arn

  # Endpoint Access
  endpoint_private_access = true
  endpoint_public_access  = true

  # Addons
  is_eks_addons_enabled = true
  addons = {
    vpc-cni     = {}
    coredns     = {}
    kube-proxy  = {}
  }
}
```

## Variables

### Cluster Configuration

| Variable                 | Description             | Type   | Default  |
| ------------------------ | ----------------------- | ------ | -------- |
| `cluster_name`           | Name of the EKS cluster | string | required |
| `cluster_version`        | Kubernetes version      | string | "1.35"   |
| `is_eks_cluster_enabled` | Enable cluster creation | bool   | false    |

### Network Configuration

| Variable                  | Description            | Type         | Default  |
| ------------------------- | ---------------------- | ------------ | -------- |
| `subnets`                 | Subnet IDs for cluster | list(string) | required |
| `security_group_ids`      | Security groups        | list(string) | []       |
| `endpoint_private_access` | Private endpoint       | bool         | false    |
| `endpoint_public_access`  | Public endpoint        | bool         | true     |

### Access Configuration

| Variable                       | Description                            | Type        | Default              |
| ------------------------------ | -------------------------------------- | ----------- | -------------------- |
| `authentication_mode`          | API_AND_CONFIG_MAP, API, or CONFIG_MAP | string      | "API_AND_CONFIG_MAP" |
| `cluster_admin_principal_arns` | Admin IAM principals                   | map(string) | {}                   |

### Addons

| Variable                | Description         | Type     | Default |
| ----------------------- | ------------------- | -------- | ------- |
| `is_eks_addons_enabled` | Enable addons       | bool     | false   |
| `addons`                | Addon configuration | map(any) | {}      |

## Outputs

| Output                               | Description         |
| ------------------------------------ | ------------------- |
| `cluster_name`                       | Cluster name        |
| `cluster_arn`                        | Cluster ARN         |
| `cluster_endpoint`                   | API server endpoint |
| `cluster_certificate_authority_data` | CA certificate      |
| `cluster_oidc_issuer_url`            | OIDC issuer URL     |
| `cluster_oidc_issuer_arn`            | OIDC provider ARN   |

## Dependencies

- VPC with subnets
- Security groups
- IAM role for cluster (or use security/iam module)
- KMS key for encryption

## Security Considerations

1. **Network Access**: Configure endpoint access appropriately for your environment
2. **Encryption**: Enable KMS encryption for secrets at rest
3. **Access Control**: Use IAM-based access control with minimal privileges
4. **Logging**: Enable cluster logging for audit purposes
