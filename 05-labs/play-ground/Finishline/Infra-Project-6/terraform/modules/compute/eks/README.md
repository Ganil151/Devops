# EKS Module

This module creates and manages Amazon EKS (Elastic Kubernetes Service) clusters.

## Overview

The EKS module provides:

- **EKS Cluster** - Managed Kubernetes control plane
- **Node Groups** - Managed node groups for running workloads
- **Access Management** - IAM-based cluster access with EKS Access Entries
- **EKS Addons** - Core Kubernetes addons (vpc-cni, coredns, kube-proxy)
- **Encryption** - KMS-based secrets encryption

## Resources Created

### EKS Resources

- EKS Cluster
- EKS Access Entries for IAM principals
- EKS Access Policy Associations
- EKS Addons
- EKS Node Groups

### IAM Resources (optional)

- EKS Cluster IAM Role
- EKS Node Group IAM Role
- IAM Instance Profile for Node Groups

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

  # Cluster Configuration
  is_eks_cluster_enabled = true
  cluster_name           = "finishline-dev-eks"
  cluster_version       = "1.29"

  # Network
  subnets            = dependency.vpc.outputs.private_subnet_ids
  security_group_ids = [dependency.sg.outputs.security_group_id]

  # IAM
  cluster_role_arn = dependency.iam.outputs.eks_cluster_role_arn

  # Encryption
  kms_key_arn = dependency.kms.outputs.kms_key_arn

  # Endpoint Access
  endpoint_private_access = true
  endpoint_public_access  = false

  # Node Group Configuration
  is_eks_nodegroup_enabled   = true
  is_eks_nodegroup_role_enabled = true
  node_group_name           = "default-node-group"
  node_group_subnets        = dependency.vpc.outputs.private_subnet_ids
  node_group_instance_types = ["t3.medium"]
  node_group_capacity_type  = "ON_DEMAND"
  node_group_role_arn       = dependency.iam.outputs.eks_nodegroup_role_arn

  node_group_scaling_config = {
    desired_size = 2
    min_size     = 1
    max_size     = 4
  }

  # Addons
  is_node_addons_enabled       = false
  is_bootstrap_addons_enabled = false
  bootstrap_self_managed_addons = false
}
```

## Variables

### Cluster Configuration

| Variable                 | Description              | Type   | Default  |
| ------------------------ | ------------------------ | ------ | -------- |
| `cluster_name`           | Name of the EKS cluster  | string | required |
| `cluster_version`        | Kubernetes version       | string | "1.29"   |
| `is_eks_cluster_enabled` | Enable cluster creation  | bool   | false    |
| `cluster_role_arn`       | IAM role ARN for cluster | string | ""       |

### Network Configuration

| Variable                  | Description                     | Type         | Default |
| ------------------------- | ------------------------------- | ------------ | ------- |
| `subnets`                 | Subnet IDs for cluster          | list(string) | []      |
| `security_group_ids`      | Security groups                 | list(string) | []      |
| `endpoint_private_access` | Private endpoint                | bool         | true    |
| `endpoint_public_access`  | Public endpoint                 | bool         | false   |
| `public_access_cidrs`     | Allowed CIDRs for public access | list(string) | []      |

### Node Group Configuration

| Variable                        | Description                    | Type         | Default              |
| ------------------------------- | ------------------------------ | ------------ | -------------------- |
| `is_eks_nodegroup_enabled`      | Enable node group              | bool         | false                |
| `is_eks_nodegroup_role_enabled` | Enable node group IAM role     | bool         | false                |
| `node_group_name`               | Name of node group             | string       | "default-node-group" |
| `node_group_subnets`            | Subnet IDs for node group      | list(string) | []                   |
| `node_group_ami_type`           | AMI type for node group        | string       | "AL2_x86_64"         |
| `node_group_instance_types`     | Instance types                 | list(string) | ["t3.medium"]        |
| `node_group_capacity_type`      | Capacity type (ON_DEMAND/SPOT) | string       | "ON_DEMAND"          |
| `node_group_disk_size`          | Disk size in GB                | number       | 20                   |
| `node_group_role_arn`           | IAM role ARN for node group    | string       | ""                   |
| `node_group_scaling_config`     | Scaling configuration          | object       | null                 |
| `node_group_labels`             | Node group labels              | map(string)  | {}                   |
| `node_group_tags`               | Node group tags                | map(string)  | {}                   |

### Access Configuration

| Variable                                      | Description                            | Type         | Default              |
| --------------------------------------------- | -------------------------------------- | ------------ | -------------------- |
| `authentication_mode`                         | API_AND_CONFIG_MAP, API, or CONFIG_MAP | string       | "API_AND_CONFIG_MAP" |
| `bootstrap_cluster_creator_admin_permissions` | Bootstrap admin permissions            | bool         | true                 |
| `cluster_admin_principal_arns`                | Admin IAM principals                   | map(string)  | {}                   |
| `cluster_admin_kubernetes_groups`             | Kubernetes groups for admins           | list(string) | []                   |

### Addons Configuration

| Variable                        | Description                   | Type        | Default |
| ------------------------------- | ----------------------------- | ----------- | ------- |
| `is_node_addons_enabled`        | Enable EKS addons             | bool        | false   |
| `is_bootstrap_addons_enabled`   | Enable bootstrap addons       | bool        | false   |
| `bootstrap_self_managed_addons` | Bootstrap self-managed addons | bool        | false   |
| `addons`                        | Addon configuration           | map(object) | {}      |

### Upgrade Policy

| Variable                      | Description                      | Type   | Default    |
| ----------------------------- | -------------------------------- | ------ | ---------- |
| `enable_upgrade_policy`       | Enable upgrade policy            | bool   | false      |
| `upgrade_policy_support_type` | Support type (STANDARD/EXTENDED) | string | "STANDARD" |

## Outputs

| Output                               | Description         |
| ------------------------------------ | ------------------- |
| `cluster_name`                       | Cluster name        |
| `cluster_arn`                        | Cluster ARN         |
| `cluster_endpoint`                   | API server endpoint |
| `cluster_certificate_authority_data` | CA certificate      |
| `cluster_id`                         | Cluster ID          |
| `cluster_version`                    | Kubernetes version  |
| `cluster_status`                     | Cluster status      |
| `cluster_vpc_config_id`              | VPC ID              |
| `cluster_security_group_id`          | Security group ID   |
| `cluster_subnet_ids`                 | Subnet IDs          |
| `cluster_oidc_issuer_url`            | OIDC issuer URL     |
| `cluster_oidc_issuer_arn`            | OIDC provider ARN   |
| `cluster_authentication_mode`        | Authentication mode |
| `access_entry_principal_arns`        | Access entry ARNs   |

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
5. **Node Group**: Use appropriate instance types and capacity types for your workload
