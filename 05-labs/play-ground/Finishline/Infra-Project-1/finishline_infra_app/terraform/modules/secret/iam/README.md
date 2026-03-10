# IAM Module

## Overview

This Terraform module creates and manages AWS Identity and Access Management (IAM) resources for the **Finishline Infrastructure project**. The IAM module provides identity management for EKS clusters, worker nodes, and OIDC authentication.

## Function in the Project

The IAM module is a **critical security component** within the Finishline Infrastructure project. It manages AWS identity and access controls that work alongside network security (Security Groups) to provide comprehensive security for cloud resources.

### Role in the Infrastructure Architecture

The IAM module integrates with other Finishline infrastructure components as follows:

```
┌──────────────────────────────────────────────────────────────────────────┐
│                    Finishline Infrastructure Project                     │
│                                                                          │
│  ┌──────────────┐      ┌──────────────────┐      ┌──────────────────┐   │
│  │     VPC      │      │  Security Group  │      │       IAM        │   │
│  │   Module     │◄─────│     Module       │      │     Module       │   │
│  └──────────────┘      └──────────────────┘      └────────┬─────────┘   │
│         │                                                │               │
│         │                                         ┌──────▼──────┐        │
│         │                                         │             │        │
│         │                                   ┌─────▼─────┐ ┌─────▼─────┐  │
│         │                                   │    EKS    │ │  OIDC     │  │
│         │                                   │  Cluster  │ │ Provider  │  │
│         │                                   │   Role    │ │           │  │
│         │                                   └───────────┘ └───────────┘  │
│         │                                         │             │         │
│         │                                   ┌─────▼───────────▼─────┐    │
│         │                                   │     Node Group Role    │    │
│         │                                   └───────────────────────┘    │
│         │                                                          │      │
│         └──────────────────────────────────────────────────────────┘      │
│                              AWS Cloud                                    │
└──────────────────────────────────────────────────────────────────────────┘
```

### Key Functions

1. **EKS Cluster Authentication**: Creates IAM roles that allow the EKS cluster to authenticate with AWS services

2. **Worker Node Authorization**: Creates IAM roles with appropriate policies for EKS worker nodes to:
   - Communicate with the cluster control plane
   - Access container registry (ECR)
   - Manage elastic block storage (EBS)
   - Use container networking interface (CNI)

3. **OIDC Provider Integration**: Sets up OpenID Connect authentication for Kubernetes service accounts to assume IAM roles

4. **S3 Access Control**: Creates IAM policies and roles for pod-level access to S3 buckets

## Resources Created

| Resource | Description |
| -------- | ------------ |
| `aws_iam_role` | IAM roles for EKS cluster, node groups, and OIDC |
| `aws_iam_role_policy_attachment` | Policy attachments for cluster and node group roles |
| `aws_iam_openid_connect_provider` | OIDC provider for EKS cluster |
| `aws_iam_policy` | Custom policies for OIDC role S3 access |

## Inputs

| Variable | Type | Description | Required |
| -------- | ---- | ----------- | -------- |
| `project_name` | string | The name of the project | Yes |
| `aws_region` | string | The AWS region for the VPC | Yes |
| `environment` | string | The environment (dev, staging, prod) | Yes |
| `manage_by` | string | The entity managing the resources | Yes |
| `cluster_name` | string | The name of the EKS cluster | Yes |
| `is_eks_role_enabled` | bool | Whether to enable the EKS cluster role | Yes |
| `is_eks_nodegroup_role_enabled` | bool | Whether to enable the EKS node group role | Yes |
| `is_eks_cluster_enabled` | bool | Whether to enable the EKS cluster | Yes |
| `eks_oidc_url` | string | The URL of the EKS OIDC provider | Yes |
| `oidc_thumbprint` | list(string) | The thumbprint of the OIDC provider | Yes |
| `s3_bucket_arn` | string | The ARN of the S3 bucket for OIDC access | No |

## Outputs

| Output | Description |
| ------- | ------------ |
| `eks_cluster_role_arn` | The ARN of the EKS cluster IAM role |
| `eks_cluster_role_name` | The name of the EKS cluster IAM role |
| `eks_nodegroup_role_arn` | The ARN of the EKS node group IAM role |
| `eks_nodegroup_role_name` | The name of the EKS node group IAM role |
| `oidc_provider_arn` | The ARN of the EKS OIDC provider |
| `oidc_provider_url` | The URL of the EKS OIDC provider |
| `oidc_role_arn` | The ARN of the OIDC IAM role |
| `oidc_role_name` | The name of the OIDC IAM role |
| `oidc_policy_arn` | The ARN of the OIDC IAM policy |
| `oidc_policy_name` | The name of the OIDC IAM policy |

## Usage Example

```hcl
module "iam" {
  source = "./modules/secret/iam"

  project_name                  = "finishline"
  aws_region                    = "us-east-1"
  environment                   = "dev"
  manage_by                     = "terraform"
  cluster_name                  = "finishline-eks"

  # Role enabling
  is_eks_role_enabled           = true
  is_eks_nodegroup_role_enabled = true
  is_eks_cluster_enabled        = true

  # OIDC Configuration
  eks_oidc_url                  = module.eks.oidc_provider_url
  oidc_thumbprint               = ["example-thumbprint"]
  s3_bucket_arn                 = "finishline-bucket"
}
```

## IAM Policies Attached

### EKS Cluster Role
- `AmazonEKSClusterPolicy` - Required for EKS cluster to manage resources

### EKS Node Group Role
- `AmazonEKSWorkerNodePolicy` - Allows nodes to join the cluster
- `AmazonEKS_CNI_Policy` - Allows CNI to manage ENIs
- `AmazonEC2ContainerRegistryReadOnly` - Read access to ECR
- `AmazonEBSCSIDriverPolicy` - EBS CSI driver permissions

### OIDC Role
- Custom S3 access policy allowing:
  - `s3:ListAllMyBuckets`
  - `s3:GetBucketLocation`
  - `s3:GetObject`

## Security Considerations

1. **Least Privilege**: Only create roles that are needed for your deployment
2. **OIDC Security**: OIDC provider should be created after cluster is operational
3. **S3 Access**: Limit S3 bucket access to specific buckets when possible
4. **Role Assumption**: Use role assumption with appropriate trust policies

## Dependencies

This module depends on:

- An EKS cluster being created (for OIDC provider URL)
- The VPC module for network configuration

## Integration with Security Groups

The IAM module works alongside the Security Group module ([`terraform/modules/security_group`](terraform/modules/security_group)):

| Component | Purpose | Security Layer |
| --------- | ------- | --------------- |
| **IAM Roles** | Authentication and authorization | Identity-level security |
| **Security Groups** | Network traffic filtering | Network-level security |

Together, these modules provide defense-in-depth security for the Finishline infrastructure:
- **IAM** answers: "Who can access this resource?"
- **Security Groups** answers: "From where and how can it be accessed?"
