# IAM Module

## Overview
Manages IAM roles, policies, and OIDC provider for EKS cluster and node group authentication.

## Functions
- **Cluster Role**: Creates IAM role for EKS control plane with required policies
- **Node Group Role**: Creates IAM role for EKS worker nodes with container registry and EBS access
- **Instance Profile**: Creates instance profile for EC2 node instances
- **OIDC Provider**: Sets up OpenID Connect provider for pod-level IAM authentication
- **S3 Access Policy**: Configures scoped S3 bucket access for workloads

## Inputs
- `cluster_name`: EKS cluster name
- `is_role_enabled`: Enable cluster and node group roles
- `is_eks_nodegroup_role_enabled`: Enable node group role creation
- `is_eks_cluster_enabled`: Enable OIDC provider and policies
- `eks_oidc_url`: OIDC issuer URL from EKS cluster
- `oidc_thumbprint`: OIDC provider thumbprint
- `s3_bucket_arn`: S3 bucket ARN for workload access

## Outputs
- `eks_cluster_role_arn`: Cluster role ARN
- `eks_nodegroup_role_arn`: Node group role ARN
- `eks_nodegroup_instance_profile_arn`: Instance profile ARN
- `eks_oidc_provider_arn`: OIDC provider ARN
- `eks_oidc_role_arn`: OIDC role ARN

## Connections
- **Depends on**: None (standalone module)
- **Used by**: EKS module (requires role ARNs)
- **Purpose**: Provides authentication and authorization for cluster and workloads
