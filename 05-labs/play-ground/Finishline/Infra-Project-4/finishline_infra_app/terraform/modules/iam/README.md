# IAM Module

## Overview

The IAM (Identity and Access Management) module creates and manages AWS IAM roles, policies, and OIDC providers for the Finishline EKS infrastructure. It provides the necessary IAM resources for EKS cluster operations, worker nodes, and service account IAM roles.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         IAM Module                               │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                  EKS Cluster Role                          │  │
│  │  aws_iam_role.eks-cluster-role                             │  │
│  │                                                            │  │
│  │  Trust Policy:                                             │  │
│  │  • Principal: eks.amazonaws.com                            │  │
│  │  • Action: sts:AssumeRole                                  │  │
│  │                                                            │  │
│  │  Attached Policies:                                        │  │
│  │  • AmazonEKSClusterPolicy                                  │  │
│  │  • AmazonEKSWorkerNodePolicy                               │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                 EKS Node Group Role                        │  │
│  │  aws_iam_role.eks-nodegroup-role                           │  │
│  │                                                            │  │
│  │  Trust Policy:                                             │  │
│  │  • Principal: ec2.amazonaws.com                            │  │
│  │  • Action: sts:AssumeRole                                  │  │
│  │                                                            │  │
│  │  Attached Policies:                                        │  │
│  │  • AmazonEKSWorkerNodePolicy                               │  │
│  │  • AmazonEKS_CNI_Policy                                    │  │
│  │  • AmazonEC2ContainerRegistryReadOnly                      │  │
│  │  • AmazonEBSCSIDriverPolicy                                │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                  OIDC Provider                             │  │
│  │  aws_iam_openid_connect_provider.eks-oidc-provider         │  │
│  │                                                            │  │
│  │  • URL: EKS cluster OIDC issuer URL                        │  │
│  │  • Client ID: sts.amazonaws.com                            │  │
│  │  • Thumbprint: OIDC certificate thumbprint                 │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                  OIDC IAM Role                             │  │
│  │  aws_iam_role.eks_oidc_role                                │  │
│  │  (For IRSA - IAM Roles for Service Accounts)               │  │
│  │                                                            │  │
│  │  Trust Policy:                                             │  │
│  │  • Principal: OIDC Provider                                │  │
│  │  • Action: sts:AssumeRoleWithWebIdentity                   │  │
│  │  • Condition: Service Account match                        │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                  S3 Access Policy                          │  │
│  │  aws_iam_policy.eks_oidc_policy                            │  │
│  │  (Optional - for S3 access from service accounts)          │  │
│  │                                                            │  │
│  │  Actions: s3:GetObject, s3:PutObject (configurable)        │  │
│  │  Resource: S3 bucket ARN with optional prefix              │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Resources Created

| Resource Type                     | Resource Name                | Description                               |
| --------------------------------- | ---------------------------- | ----------------------------------------- |
| `random_integer`                  | `random_suffix`              | Random suffix for unique resource names   |
| `aws_iam_role`                    | `eks-cluster-role`           | IAM role for EKS cluster                  |
| `aws_iam_role`                    | `eks-nodegroup-role`         | IAM role for EKS worker nodes             |
| `aws_iam_role`                    | `eks_oidc_role`              | IAM role for OIDC service accounts (IRSA) |
| `aws_iam_role_policy_attachment`  | `AmazonEKSClusterPolicy`     | Attaches EKS cluster policy               |
| `aws_iam_role_policy_attachment`  | `AmazonEKSWorkerNodePolicy`  | Attaches worker node policy               |
| `aws_iam_role_policy_attachment`  | `node-policies`              | Attaches node group policies              |
| `aws_iam_openid_connect_provider` | `eks-oidc-provider`          | OIDC identity provider                    |
| `aws_iam_policy`                  | `eks_oidc_policy`            | S3 access policy for service accounts     |
| `aws_iam_role_policy_attachment`  | `eks-oidc-policy-attachment` | Attaches S3 policy to OIDC role           |

### Data Sources

| Name                                                  | Description                           |
| ----------------------------------------------------- | ------------------------------------- |
| `aws_iam_policy_document.eks_oidc_assume_role_policy` | Generates assume role policy for OIDC |

## Inputs

### Project Configuration

| Name                | Type           | Description                  | Required |
| ------------------- | -------------- | ---------------------------- | -------- |
| `project_name`      | `string`       | Name of the project          | Yes      |
| `environment`       | `string`       | Environment name             | Yes      |
| `manage_by`         | `bool`         | Whether managed by Terraform | Yes      |
| `availability_zone` | `list(string)` | List of availability zones   | Yes      |

### Cluster Configuration

| Name                            | Type     | Description                      | Required |
| ------------------------------- | -------- | -------------------------------- | -------- |
| `cluster_name`                  | `string` | Name of the EKS cluster          | Yes      |
| `is_eks_role_enabled`           | `bool`   | Enable EKS cluster role creation | Yes      |
| `is_eks_cluster_enabled`        | `bool`   | Enable EKS cluster (for OIDC)    | Yes      |
| `is_eks_nodegroup_role_enabled` | `bool`   | Enable node group role creation  | Yes      |
| `is_role_enabled`               | `bool`   | Generic role enable flag         | Yes      |

### OIDC Configuration

| Name                            | Type     | Description                              | Required |
| ------------------------------- | -------- | ---------------------------------------- | -------- |
| `eks_oidc_url`                  | `string` | EKS OIDC provider URL                    | No       |
| `oidc_thumbprint`               | `string` | OIDC certificate thumbprint              | No       |
| `eks_oidc_namespace`            | `string` | Kubernetes namespace for service account | No       |
| `eks_oidc_service_account_name` | `string` | Service account name for OIDC            | No       |

### S3 Access Configuration

| Name             | Type     | Description                                  | Required |
| ---------------- | -------- | -------------------------------------------- | -------- |
| `s3_bucket_arn`  | `string` | S3 bucket ARN for OIDC access                | No       |
| `s3_prefix`      | `string` | S3 object prefix                             | No       |
| `s3_access_type` | `string` | Access type: `read`, `write`, or `readwrite` | No       |

## Outputs

### EKS Cluster Role

| Name                    | Description                  |
| ----------------------- | ---------------------------- |
| `eks_cluster_role_arn`  | ARN of EKS cluster IAM role  |
| `eks_cluster_role_name` | Name of EKS cluster IAM role |

### EKS Node Group Role

| Name                      | Description                     |
| ------------------------- | ------------------------------- |
| `eks_nodegroup_role_arn`  | ARN of EKS node group IAM role  |
| `eks_nodegroup_role_name` | Name of EKS node group IAM role |

### OIDC Provider

| Name                | Description              |
| ------------------- | ------------------------ |
| `oidc_provider_arn` | ARN of EKS OIDC provider |
| `oidc_provider_url` | URL of EKS OIDC provider |

### OIDC IAM Role

| Name             | Description           |
| ---------------- | --------------------- |
| `oidc_role_arn`  | ARN of OIDC IAM role  |
| `oidc_role_name` | Name of OIDC IAM role |

### S3 Policy

| Name                  | Description                   |
| --------------------- | ----------------------------- |
| `oidc_s3_policy_arn`  | ARN of OIDC S3 access policy  |
| `oidc_s3_policy_name` | Name of OIDC S3 access policy |

## Usage Example

### Basic EKS IAM Setup

```hcl
module "iam" {
  source = "./modules/iam"

  # Project Configuration
  project_name        = "finishline-infra"
  environment         = "development"
  manage_by           = true
  availability_zone   = ["us-east-1a", "us-east-1b"]

  # Cluster Configuration
  cluster_name                    = "finishline-eks-cluster"
  is_eks_role_enabled             = true
  is_eks_cluster_enabled          = true
  is_eks_nodegroup_role_enabled   = true
  is_role_enabled                 = true
}
```

### EKS with OIDC and S3 Access

```hcl
module "iam" {
  source = "./modules/iam"

  project_name        = "finishline-infra"
  environment         = "development"
  manage_by           = true
  availability_zone   = ["us-east-1a", "us-east-1b"]

  cluster_name                  = "finishline-eks-cluster"
  is_eks_role_enabled           = true
  is_eks_cluster_enabled        = true
  is_eks_nodegroup_role_enabled = true
  is_role_enabled               = true

  # OIDC Configuration
  eks_oidc_url                  = module.eks.cluster_oidc_issuer_url
  oidc_thumbprint               = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
  eks_oidc_namespace            = "kube-system"
  eks_oidc_service_account_name = "aws-node"

  # S3 Access for Service Accounts
  s3_bucket_arn    = "arn:aws:s3:::my-application-bucket"
  s3_prefix        = "eks-data/"
  s3_access_type   = "readwrite"
}
```

## Dependencies

- AWS Provider
- EKS Module (for OIDC URL and thumbprint)

## File Structure

```
iam/
├── main.tf         # IAM resources (roles, policies, attachments)
├── variables.tf    # Input variables
├── outputs.tf      # Output values
├── locals.tf       # Local values and tags
├── data.tf         # IAM policy document data source
└── README.md       # This documentation
```

## IAM Policies Attached

### EKS Cluster Role

| Policy ARN                                          | Description                        |
| --------------------------------------------------- | ---------------------------------- |
| `arn:aws:iam::aws:policy/AmazonEKSClusterPolicy`    | EKS cluster management permissions |
| `arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy` | Worker node permissions            |

### EKS Node Group Role

| Policy ARN                                                      | Description                 |
| --------------------------------------------------------------- | --------------------------- |
| `arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy`             | EKS worker node permissions |
| `arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy`                  | VPC CNI plugin permissions  |
| `arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly`    | ECR read access             |
| `arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy` | EBS CSI driver permissions  |

## OIDC Trust Policy

The OIDC role uses a trust policy that allows Kubernetes service accounts to assume IAM roles:

```json
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/oidc.eks.REGION.amazonaws.com/id/CLUSTER_ID"
			},
			"Action": "sts:AssumeRoleWithWebIdentity",
			"Condition": {
				"StringEquals": {
					"oidc.eks.REGION.amazonaws.com/id/CLUSTER_ID:sub": "system:serviceaccount:NAMESPACE:SERVICE_ACCOUNT"
				}
			}
		}
	]
}
```

## S3 Access Policy

The S3 policy supports three access levels:

| Access Type | Actions                                           |
| ----------- | ------------------------------------------------- |
| `read`      | `s3:GetObject`                                    |
| `write`     | `s3:GetObject`, `s3:PutObject`, `s3:DeleteObject` |
| `readwrite` | `s3:GetObject`, `s3:PutObject`                    |

## Resource Naming

All IAM resources include a random suffix to ensure unique names:

```
{project}-{environment}-{cluster_name}-{resource_type}-{random_suffix}
```

Example: `finishline-development-finishline-eks-cluster-role-1234`

## Security Considerations

1. **Least Privilege**: The module uses AWS managed policies. Consider creating custom policies with minimal required permissions for production.

2. **OIDC Thumbprint**: The OIDC thumbprint should be fetched dynamically or updated when certificates rotate.

3. **S3 Access**: S3 access is scoped to specific bucket and prefix. Ensure proper bucket policies are in place.

4. **Random Suffix**: Random suffixes prevent naming conflicts but make resource discovery harder. Use consistent tagging for resource management.

## Tags

All resources are tagged with:

- `Name` - Resource-specific name
- `Environment` - Environment name
- `Project` - Project identifier
- `ManagedBy` - Terraform management flag
- `Terraform` - "true"
- `Cluster` - Cluster name (for IAM resources)
