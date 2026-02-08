# AWS IAM Architectural Patterns

This directory contains 20 common Identity and Access Management (IAM) patterns for AWS using Terraform. IAM allows you to securely manage access to AWS services and resources.

## 📂 IAM Patterns Overview

| # | Type | Description | File |
|---|------|-------------|------|
| 1 | **IAM User** | Creating a standard user with access keys. | `01-iam-user.tf` |
| 2 | **IAM Group** | scalable permission management via groups. | `02-iam-group.tf` |
| 3 | **Policy (JSON)** | Managed policy defined as a JSON string. | `03-iam-policy-json.tf` |
| 4 | **Policy (Data Source)** | cleaner policy definition using HCL data blocks. | `04-iam-policy-data.tf` |
| 5 | **Role for EC2** | Trust policy for EC2 instances. | `05-iam-role-ec2.tf` |
| 6 | **Role for Lambda** | Trust policy and execution roles for functions. | `06-iam-role-lambda.tf` |
| 7 | **Role for RDS** | Granting database service permissions to S3/etc. | `07-iam-role-rds.tf` |
| 8 | **EKS Cluster Role** | Required permissions for Kubernetes control plane. | `08-iam-role-eks-cluster.tf` |
| 9 | **EKS Node Role** | Permissions for worker nodes (CNI, ECR). | `09-iam-role-eks-nodes.tf` |
| 10 | **Inline Policy** | Non-reusable policy embedded in an entity. | `10-iam-inline-policy.tf` |
| 11 | **User/Role Attach** | Attaching managed policies to multiple targets. | `11-iam-policy-attachment.tf` |
| 12 | **Account Policy** | Setting global password and security rules. | `12-iam-password-policy.tf` |
| 13 | **OIDC Provider** | Federated access for GitHub/GitLab automation. | `13-iam-oidc-provider.tf` |
| 14 | **Service-Linked** | Roles managed by AWS for specific integrations. | `14-iam-service-linked-role.tf` |
| 15 | **MFA Device** | managing virtual MFA devices for security. | `15-iam-mfa-device.tf` |
| 16 | **Permissions Boundary** | Hard limit on the maximum permissions of a role. | `16-iam-permission-boundary.tf` |
| 17 | **Cross-Account** | Trusting roles from another AWS account. | `17-iam-cross-account.tf` |
| 18 | **Login Profile** | enabling AWS Management Console access. | `18-iam-login-profile.tf` |
| 19 | **MFA Condition** | Enforcing MFA for sensitive API actions. | `19-iam-mfa-condition.tf` |
| 20 | **Minimalist** | Baseline "caller identity" policy. | `20-minimalist-iam.tf` |

## 🚀 Security Best Practices
1.  **Principle of Least Privilege**: Grant only the permissions required for a specific task.
2.  **Avoid Inline Policies**: Use managed policies for reusability and versioning.
3.  **Roles over Users**: Prefer IAM Roles for applications (EC2, Lambda) instead of access keys.
4.  **Enforce MFA**: Requires MFA for console access and sensitive programmatic actions.
5.  **Audit Regularly**: Use IAM Access Analyzer to find unused or overly permissive policies.

## 🛠 Usage
These patterns are designed to be copied into your infrastructure modules. most roles require a `trust_policy` (assume role policy) and one or more `policy_attachments`.
