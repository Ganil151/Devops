# Finishline Infrastructure - Terragrunt Runbook

## Overview

This runbook provides instructions for deploying the Finishline infrastructure using Terragrunt.

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terragrunt installed (v0.54+)
- Terraform installed (v1.0+)

## Architecture

The infrastructure consists of the following modules:

| Module      | Description                    | Dependencies |
| ----------- | ------------------------------ | ------------ |
| `vpc`       | VPC, Subnets, NAT Gateway, IGW | None         |
| `iam`       | IAM Roles, OIDC Provider       | EKS          |
| `sg`        | Security Groups                | VPC          |
| `eks`       | EKS Cluster                    | VPC, SG, IAM |
| `jumphost`  | Bastion Host                   | VPC, SG      |
| `alb`       | Application Load Balancer      | VPC          |
| `bootstrap` | K8s Namespaces, Helm Charts    | EKS          |

## Deployment Steps

### 1. Initial Setup

Navigate to the environment directory:

```bash
cd terraform/envs/dev
```

### 2. Verify Configuration

Review the configuration files:

```bash
# Check VPC configuration
cat terragrunt.hcl

# Check each module configuration
cat iam/terragrunt.hcl
cat eks/terragrunt.hcl
# etc.
```

### 3. Plan Deployment

Dry-run to see what will be created:

```bash
terragrunt run-all plan
```

### 4. Apply Infrastructure

Deploy all modules:

```bash
terragrunt run-all apply
```

Terragrunt will automatically:

1. Create VPC networking
2. Create IAM roles (without OIDC provider initially)
3. Create Security Groups
4. Create EKS cluster
5. Create Jumphost
6. Create ALB
7. Deploy Kubernetes bootstrap resources

> **Note**: The OIDC provider will be created in step 5 below.

### 5. Configure OIDC (Required for IRSA)

After EKS is created, update IAM with OIDC configuration:

1. Get the OIDC issuer URL:

```bash
export OIDC_URL=$(aws eks describe-cluster \
  --name finishline-eks-cluster \
  --region us-east-1 \
  --query "cluster.identity.oidc.issuer" \
  --output text)
echo $OIDC_URL
```

2. Update the IAM terragrunt.hcl with the OIDC URL:

```bash
# Edit terraform/envs/dev/iam/terragrunt.hcl
# Change: eks_oidc_url = ""
# To: eks_oidc_url = "https://oidc.eks.us-east-1.amazonaws.com/xxxxx"
```

3. Apply IAM again:

```bash
cd terraform/envs/dev/iam
terragrunt apply
```

### 6. Verify Deployment

```bash
# Check VPC
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=*finishline*" --region us-east-1

# Check EKS Cluster
aws eks describe-cluster --name finishline-eks-cluster --region us-east-1

# Check Jumphost
aws ec2 describe-instances --filters "Name=tag:Name,Values=*jumphost*" --region us-east-1

# Check ALB
aws elbv2 describe-load-balancers --names finishline-dev-alb --region us-east-1
```

## OIDC Configuration

The IAM module automatically configures OIDC when the EKS cluster is available. No manual steps required.

## Updating Configuration

### Update VPC

```bash
cd terraform/envs/dev
terragrunt run-all apply --terragrunt-include-dir=vpc
```

### Update EKS

```bash
cd terraform/envs/dev/eks
terragrunt apply
```

### Update IAM (including OIDC)

```bash
cd terraform/envs/dev/iam
terragrunt apply
```

### Update Bootstrap (Helm Charts)

1. Edit `terraform/envs/dev/bootstrap/terragrunt.hcl`
2. Add or modify helm charts:

```hcl
helm_charts = {
  "aws-load-balancer-controller" = {
    repository = "https://aws.github.io/eks-charts"
    version    = "1.6.0"
    namespace  = "kube-system"
  }
}
```

3. Apply:

```bash
cd terraform/envs/dev/bootstrap
terragrunt apply
```

## Destroy Infrastructure

### Destroy all resources

```bash
cd terraform/envs/dev
terragrunt run-all destroy
```

### Destroy specific module

```bash
cd terraform/envs/dev/jumphost
terragrunt destroy
```

## Troubleshooting

### Common Issues

#### 1. Dependency cycle errors

If you see dependency cycle errors, ensure you're running from the correct directory and using `run-all` command.

#### 2. State lock errors

If state is locked:

```bash
# Check for locks
terragrunt force-unlock <lock-id>
```

#### 3. EKS cluster not found during IAM apply

This is expected on first run. Re-run IAM after EKS is created:

```bash
cd terraform/envs/dev/iam
terragrunt apply
```

#### 4. Missing OIDC thumbprint

If OIDC thumbprint is required:

```bash
# Get thumbprint from AWS
aws iam get-open-id-connect-provider-thumbprint --open-id-connect-provider-arn <provider-arn>
```

## Configuration Reference

### VPC Configuration

- CIDR: 10.0.0.0/16
- Public Subnets: 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24
- Private Subnets: 10.0.10.0/24, 10.0.11.0/24, 10.0.12.0/24
- Region: us-east-1

### EKS Configuration

- Cluster Name: finishline-eks-cluster
- Kubernetes Version: 1.35
- Endpoint Access: Private only

### Bootstrap Namespaces

- dev
- staging
- prod

## Outputs

After deployment, key outputs are available:

```bash
# VPC ID
terragrunt run-all output vpc vpc_id

# EKS Cluster Endpoint
terragrunt run-all output eks cluster_endpoint

# Jumphost Public IP
terragrunt run-all output jumphost public_ip
```

## Security Considerations

1. **SSH Keys**: Private keys are stored locally in the environment directory
2. **IAM Roles**: Use least-privilege permissions
3. **Security Groups**: Restrictive by default
4. **EKS**: Private endpoint only (no public access)

## Maintenance

### Update Kubernetes Addons

Edit `terraform/envs/dev/eks/terragrunt.hcl`:

```hcl
is_eks_addons_enabled = true
addons = {
  "vpc-cni" = {
    version = "latest"
    service_account_role_arn = ""
  }
}
```

### Scale Node Groups

Modify the instance types or counts in the EKS configuration.

## Support

For issues or questions, refer to:

- AWS EKS Documentation: https://docs.aws.amazon.com/eks/
- Terragrunt Documentation: https://terragrunt.gruntwork.io/docs/
- Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws
