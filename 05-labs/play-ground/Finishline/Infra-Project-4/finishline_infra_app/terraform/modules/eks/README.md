# EKS Module

## Overview

The EKS (Elastic Kubernetes Service) module creates and manages AWS EKS clusters for the Finishline infrastructure. It provisions the EKS control plane and supports optional EKS addons for cluster functionality.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        EKS Cluster                               │
│                   finishline-eks-cluster                         │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    Control Plane                           │  │
│  │  • Kubernetes API Server                                   │  │
│  │  • etcd Storage                                            │  │
│  │  • Controller Manager                                      │  │
│  │  • Scheduler                                               │  │
│  │  Version: 1.35                                             │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                   VPC Configuration                        │  │
│  │  • Subnets: module.vpc.private_subnet_ids                  │  │
│  │  • Security Groups: module.sg.security_group_id            │  │
│  │  • Endpoint Access: Private only (configurable)            │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    EKS Addons (Optional)                   │  │
│  │  • VPC CNI                                                 │  │
│  │  • CoreDNS                                                 │  │
│  │  • kube-proxy                                              │  │
│  │  • AWS EBS CSI Driver                                      │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                 Logging Configuration                      │  │
│  │  • api                                                   │  │
│  │  • audit                                                 │  │
│  │  • authenticator                                         │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Depends On
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    IAM Module                                    │
│  • eks-cluster-role (AmazonEKSClusterPolicy)                    │
│  • eks-nodegroup-role (Worker Node Policies)                    │
└─────────────────────────────────────────────────────────────────┘
```

## Resources Created

| Resource Type     | Resource Name | Description                         |
| ----------------- | ------------- | ----------------------------------- |
| `aws_eks_cluster` | `eks`         | EKS cluster control plane           |
| `aws_eks_addon`   | `addons`      | EKS addons (VPC CNI, CoreDNS, etc.) |

### Data Sources

| Name                       | Description                               |
| -------------------------- | ----------------------------------------- |
| `tls_certificate.eks_cert` | Fetches TLS certificate for OIDC provider |

## Inputs

### Project Configuration

| Name                | Type           | Description                  | Required |
| ------------------- | -------------- | ---------------------------- | -------- |
| `project_name`      | `string`       | Name of the project          | Yes      |
| `environment`       | `string`       | Environment name             | Yes      |
| `manage_by`         | `bool`         | Whether managed by Terraform | Yes      |
| `availability_zone` | `list(string)` | List of availability zones   | Yes      |

### Cluster Configuration

| Name                        | Type           | Description                       | Required |
| --------------------------- | -------------- | --------------------------------- | -------- |
| `cluster_name`              | `string`       | Name of the EKS cluster           | Yes      |
| `is_eks_cluster_enabled`    | `bool`         | Enable EKS cluster creation       | Yes      |
| `cluster_version`           | `string`       | Kubernetes version (e.g., `1.35`) | Yes      |
| `cluster_role_arn`          | `string`       | ARN of IAM role for EKS cluster   | Yes      |
| `cluster_enabled_log_types` | `list(string)` | Log types to enable               | Yes      |

### Network Configuration

| Name                      | Type           | Description                        | Required |
| ------------------------- | -------------- | ---------------------------------- | -------- |
| `subnet_ids`              | `list(string)` | Subnet IDs for cluster networking  | Yes      |
| `security_group_ids`      | `list(string)` | Security group IDs for cluster     | Yes      |
| `endpoint_private_access` | `bool`         | Enable private API endpoint access | Yes      |
| `endpoint_public_access`  | `bool`         | Enable public API endpoint access  | Yes      |

### Addons Configuration

| Name                    | Type          | Description                                             | Required |
| ----------------------- | ------------- | ------------------------------------------------------- | -------- |
| `is_eks_addons_enabled` | `bool`        | Enable EKS addons installation                          | Yes      |
| `addons`                | `map(object)` | Map of addons with version and service account role ARN | Yes      |

### Addons Object Structure

```hcl
addons = {
  "vpc-cni" = {
    version                  = "1.15.0"
    service_account_role_arn = module.iam.oidc_role_arn
  },
  "coredns" = {
    version                  = "1.11.0"
    service_account_role_arn = ""
  }
}
```

## Outputs

### Cluster Information

| Name                       | Description                             |
| -------------------------- | --------------------------------------- |
| `cluster_arn`              | ARN of the EKS cluster                  |
| `cluster_name`             | Name of the EKS cluster                 |
| `cluster_id`               | ID of the EKS cluster                   |
| `cluster_endpoint`         | API endpoint URL                        |
| `cluster_version`          | Kubernetes version                      |
| `cluster_platform_version` | EKS platform version                    |
| `cluster_status`           | Cluster status (ACTIVE, CREATING, etc.) |

### Cluster Configuration

| Name                            | Description                                |
| ------------------------------- | ------------------------------------------ |
| `cluster_oidc_issuer_url`       | OIDC issuer URL for IAM integration        |
| `cluster_security_group_ids`    | Security group IDs associated with cluster |
| `cluster_subnet_ids`            | Subnet IDs associated with cluster         |
| `cluster_certificate_authority` | Certificate authority data                 |

### Addons

| Name         | Description               |
| ------------ | ------------------------- |
| `eks_addons` | Map of created EKS addons |

### Tags

| Name   | Description                   |
| ------ | ----------------------------- |
| `tags` | Tags applied to EKS resources |

## Usage Example

```hcl
module "eks" {
  source = "./modules/eks"

  # Project Configuration
  project_name        = "finishline-infra"
  environment         = "development"
  manage_by           = true
  availability_zone   = ["us-east-1a", "us-east-1b", "us-east-1c"]

  # Cluster Configuration
  cluster_name              = "finishline-eks-cluster"
  is_eks_cluster_enabled    = true
  cluster_version           = "1.35"
  cluster_role_arn          = module.iam.eks_cluster_role_arn
  cluster_enabled_log_types = ["api", "audit", "authenticator"]

  # Network Configuration
  subnet_ids              = module.vpc.private_subnet_ids
  security_group_ids      = [module.sg.security_group_id]
  endpoint_private_access = true
  endpoint_public_access  = false

  # Addons Configuration
  is_eks_addons_enabled = true
  addons = {
    "vpc-cni" = {
      version                  = "1.15.0"
      service_account_role_arn = module.iam.oidc_role_arn
    },
    "coredns" = {
      version                  = "1.11.0"
      service_account_role_arn = ""
    },
    "kube-proxy" = {
      version                  = "1.35.0"
      service_account_role_arn = ""
    }
  }
}
```

## Dependencies

- **IAM Module**: Requires EKS cluster role and node group role
- **VPC Module**: Requires subnet IDs for cluster networking
- **SG Module**: Requires security group IDs for cluster security

## File Structure

```
eks/
├── main.tf         # EKS cluster resource
├── addons.tf       # EKS addons resources
├── variables.tf    # Input variables
├── outputs.tf      # Output values
├── locals.tf       # Local values and tags
├── data.tf         # TLS certificate data source
└── README.md       # This documentation
```

## Cluster Configuration Details

### Access Configuration

```hcl
access_config {
  authentication_mode                         = "API_AND_CONFIG_MAP"
  bootstrap_cluster_creator_admin_permissions = true
}
```

- **API_AND_CONFIG_MAP**: Supports both IAM and Kubernetes RBAC
- **bootstrap_cluster_creator_admin_permissions**: Grants admin access to cluster creator

### Compute Configuration

```hcl
compute_config {
  enabled = false
}
```

Compute configuration is disabled as node groups are managed separately.

### Storage Configuration

```hcl
storage_config {
  block_storage {
    enabled = false
  }
}
```

Block storage is disabled; use EBS CSI driver addon for persistent storage.

### Network Configuration

```hcl
kubernetes_network_config {
  elastic_load_balancing {
    enabled = false
  }
}
```

Elastic load balancing for Kubernetes services is disabled by default.

## Lifecycle Configuration

```hcl
lifecycle {
  ignore_changes = [version]
}
```

- **ignore_changes [version]**: Prevents Terraform from updating Kubernetes version automatically

## Addon Management

Addons are managed with conflict resolution:

```hcl
resolve_conflicts_on_create = "OVERWRITE"
resolve_conflicts_on_update = "OVERWRITE"
```

This ensures addons are properly installed even if conflicting configurations exist.

## Security Considerations

1. **Endpoint Access**: For production, set `endpoint_public_access = false` and access the cluster via private endpoints or bastion host.

2. **Security Groups**: Ensure security groups allow necessary traffic between control plane and worker nodes.

3. **OIDC Integration**: Configure OIDC provider for IAM roles for service accounts (IRSA).

4. **Version Management**: The module ignores version changes to prevent unintended upgrades. Plan version upgrades carefully.

## Tags

All resources are tagged with:

- `Name` - Resource-specific name
- `Environment` - Environment name
- `Project` - Project identifier
- `ManagedBy` - Terraform management flag
- `Terraform` - "true"
- `kubernetes.io/cluster/{cluster_name}` - "owned" (for node groups)
