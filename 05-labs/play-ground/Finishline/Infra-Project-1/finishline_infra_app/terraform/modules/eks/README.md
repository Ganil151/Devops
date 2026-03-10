# EKS Module — Elastic Kubernetes Service

**Module Path:** `terraform/modules/eks/`  
**Version:** 1.0.0  
**Terraform Version:** >= 1.6.0  
**AWS Provider Version:** ~> 6.0  

---

## Overview

This module provisions an **Amazon EKS (Elastic Kubernetes Service)** cluster with managed node groups for the Finish Line 2026 infrastructure project.

### Assignment Requirements Compliance

| Requirement | Status | Implementation |
|-------------|--------|----------------|
| EKS Cluster | ✅ | Managed EKS cluster with CONFIG_MAP auth |
| 2x t3.medium nodes | ✅ | On-demand node group with desired=2 |
| Bottlerocket AMI | ✅ | `ami_type = "BOTTLEROCKET_x86_64"` |
| OIDC Provider | ✅ | For IRSA (IAM Roles for Service Accounts) |
| EKS Addons | ✅ | CoreDNS, kube-proxy, VPC-CNI |

---

## Architecture

```
                                    ┌─────────────────────────────────┐
                                    │         EKS Cluster             │
                                    │  finishline-eks                 │
                                    │  Kubernetes 1.31                │
                                    │  Endpoint: Private + Public     │
                                    └───────────────┬─────────────────┘
                                                    │
                    ┌───────────────────────────────┼───────────────────────────────┐
                    │                               │                               │
        ┌───────────▼───────────┐       ┌───────────▼───────────┐       ┌───────────▼───────────┐
        │   On-Demand Node      │       │    Spot Node Group    │       │   OIDC Provider       │
        │   Group               │       │    (Optional)         │       │   (IRSA)              │
        │   - 2x t3.medium      │       │   - 0x t3.medium      │       │   - sts.amazonaws.com │
        │   - Bottlerocket      │       │   - Bottlerocket      │       │   - S3 access policy  │
        │   - Private Subnets   │       │   - Private Subnets   │       │                       │
        └───────────────────────┘       └───────────────────────┘       └───────────────────────┘
                    │                               │                               │
                    └───────────────────────────────┼───────────────────────────────┘
                                                    │
                                    ┌───────────────▼─────────────────┐
                                    │   EKS Addons (Managed)          │
                                    │   - CoreDNS v1.11.1             │
                                    │   - kube-proxy v1.31.0          │
                                    │   - VPC-CNI v1.18.1             │
                                    └─────────────────────────────────┘
```

---

## Resources Created

| Resource | Type | Description |
|----------|------|-------------|
| `aws_eks_cluster.eks` | EKS Cluster | Managed Kubernetes control plane |
| `aws_iam_openid_connect_provider.eks_oidc_provider` | OIDC Provider | For IRSA (IAM Roles for Service Accounts) |
| `aws_eks_node_group.ondemand_node` | Node Group | On-demand nodes (2x t3.medium, Bottlerocket) |
| `aws_eks_node_group.spot_node` | Node Group | Spot nodes (optional, 0 by default) |
| `aws_eks_access_entry.node_role` | Access Entry | Node role access (EKS v1.30+) |
| `aws_eks_access_entry.admin_role` | Access Entry | Admin role access (optional) |
| `aws_eks_addon.addons` | EKS Addons | CoreDNS, kube-proxy, VPC-CNI |

---

## Usage

### Basic Example

```hcl
module "eks" {
  source = "../../modules/eks"

  project_name      = "finishline-infra"
  environment       = "dev"
  manage_by         = "Terraform"
  cluster_name      = "finishline-eks"
  cluster_version   = "1.31"

  # IAM Roles (from secret/iam module)
  cluster_role_arn  = module.finishline_iam.eks_cluster_role_arn
  node_role_arn     = module.finishline_iam.eks_nodegroup_role_arn

  # VPC Configuration
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_ids = [module.finishline_sg.security_group_id]

  # Endpoint Access
  endpoint_private_access = true
  endpoint_public_access  = false

  # Node Group: Exactly 2x t3.medium (assignment requirement)
  desired_capacity_on_demand = 2
  min_capacity_on_demand     = 1
  max_capacity_on_demand     = 4
  ondemand_instance_types    = ["t3.medium"]

  # EKS Addons
  is_eks_addons_enabled = true
  addons = {
    coredns = {
      version = "v1.11.1-eksbuild.9"
    }
    kube-proxy = {
      version = "v1.31.0-eksbuild.1"
    }
    vpc-cni = {
      version = "v1.18.1-eksbuild.3"
    }
  }

  additional_tags = {
    CostCenter = "finishline-dev"
    Owner      = "platform-team"
  }
}
```

### With Spot Node Group

```hcl
module "eks" {
  # ... base configuration ...

  # Enable spot node group
  desired_capacity_spot = 2
  min_capacity_spot     = 0
  max_capacity_spot     = 4
  spot_instance_types   = ["t3.medium", "t3.large"]

  # Add taints to spot nodes (prevent critical workloads)
  spot_taints = [
    {
      key    = "spot"
      value  = "true"
      effect = "PREFER_NO_SCHEDULE"
    }
  ]
}
```

---

## Variables

### Required

| Name | Type | Description |
|------|------|-------------|
| `project_name` | `string` | Project name for resource naming |
| `environment` | `string` | Environment name (dev, staging, prod) |
| `cluster_name` | `string` | EKS cluster name |
| `cluster_role_arn` | `string` | IAM role ARN for EKS control plane |
| `node_role_arn` | `string` | IAM role ARN for worker nodes |
| `subnet_ids` | `list(string)` | Subnet IDs for cluster and nodes (min 2) |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `cluster_version` | `string` | `"1.31"` | Kubernetes version |
| `is_eks_cluster_enabled` | `bool` | `true` | Enable EKS cluster |
| `is_eks_node_group_enabled` | `bool` | `true` | Enable node groups |
| `authentication_mode` | `string` | `"CONFIG_MAP"` | Auth mode (CONFIG_MAP, API, API_AND_CONFIG_MAP) |
| `endpoint_private_access` | `bool` | `true` | Enable private endpoint |
| `endpoint_public_access` | `bool` | `false` | Enable public endpoint |
| `desired_capacity_on_demand` | `number` | `2` | On-demand nodes (assignment: exactly 2) |
| `ondemand_instance_types` | `list(string)` | `["t3.medium"]` | On-demand instance types |
| `desired_capacity_spot` | `number` | `0` | Spot nodes (0 = disabled) |
| `is_eks_addons_enabled` | `bool` | `true` | Enable EKS addons |
| `addons` | `map(object)` | `{coredns, kube-proxy, vpc-cni}` | EKS addons configuration |

---

## Outputs

| Name | Description |
|------|-------------|
| `cluster_id` | EKS cluster ID |
| `cluster_arn` | EKS cluster ARN |
| `cluster_name` | EKS cluster name |
| `cluster_endpoint` | API endpoint (sensitive) |
| `cluster_version` | Kubernetes version |
| `cluster_certificate_authority_data` | CA cert data (sensitive) |
| `cluster_oidc_issuer_url` | OIDC issuer URL |
| `cluster_security_group_id` | Cluster security group ID |
| `oidc_provider_arn` | OIDC provider ARN |
| `ondemand_node_group_id` | On-demand node group ID |
| `spot_node_group_id` | Spot node group ID |
| `addons` | Map of deployed addons |
| `kubeconfig_command` | AWS CLI command for kubeconfig |
| `cluster_info` | Complete cluster information |

---

## Connecting to the Cluster

After deployment, connect to the EKS cluster:

```bash
# Update kubeconfig
aws eks update-kubeconfig --name finishline-eks --region us-east-1

# Verify connection
kubectl get nodes

# Expected output:
# NAME                                        STATUS   ROLES    AGE   VERSION
# ip-10-0-10-xxx.ec2.internal                 Ready    <none>   5m    v1.31.x
# ip-10-0-11-xxx.ec2.internal                 Ready    <none>   5m    v1.31.x
```

---

## Bottlerocket AMI

This module uses **Bottlerocket x86_64** AMI for node groups as per assignment requirement §79.

### Benefits

- **Security-focused**: Minimal OS surface area
- **Automatic updates**: Built-in update mechanism
- **Kubernetes-native**: Designed specifically for containers

### SSH Access (for troubleshooting)

Bottlerocket uses a special container for admin access:

```bash
# Connect via SSM (recommended)
aws ssm start-session --target <node-instance-id>

# Or use the admin container
ssh -i <key.pem> ec2-user@<node-ip>
# Then run: sudo sheltie (to enter admin container)
```

---

## EKS Addons

The module deploys the following managed addons:

| Addon | Version | Purpose |
|-------|---------|---------|
| **CoreDNS** | v1.11.1-eksbuild.9 | Cluster DNS service |
| **kube-proxy** | v1.31.0-eksbuild.1 | Network proxy for services |
| **VPC-CNI** | v1.18.1-eksbuild.3 | Pod networking (ENI-based) |

### Updating Addon Versions

```hcl
addons = {
  coredns = {
    version = "v1.11.1-eksbuild.9"  # Update as needed
  }
  # ...
}
```

---

## Security Considerations

### 1. Endpoint Access

- **Private access enabled**: Allows internal cluster communication
- **Public access disabled**: Prevents direct internet access (production recommended)

### 2. Authentication Mode

- **CONFIG_MAP**: Uses aws-auth ConfigMap for RBAC (default)
- **API**: Uses EKS Access Entries only (v1.30+)
- **API_AND_CONFIG_MAP**: Both methods

### 3. Node IAM Role

Ensure the node role has minimum required policies:
- `AmazonEKSWorkerNodePolicy`
- `AmazonEKS_CNI_Policy`
- `AmazonEC2ContainerRegistryReadOnly`
- `AmazonEBSCSIDriverPolicy` (if using EBS)

### 4. IRSA (IAM Roles for Service Accounts)

The OIDC provider enables IRSA for pod-level IAM:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-sa
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/my-role
```

---

## Troubleshooting

### Nodes Not Ready

1. Check node IAM role has correct policies
2. Verify security group allows cluster communication
3. Check node logs: `aws eks describe-nodegroup --cluster-name finishline-eks --nodegroup-name finishline-eks-ondemand-nodes`

### OIDC Provider Issues

1. Verify thumbprint matches: `openssl s_client -showcerts -servername oidc.eks.us-east-1.amazonaws.com -connect oidc.eks.us-east-1.amazonaws.com:443`
2. Check client_id_list includes `sts.amazonaws.com`

### Addon Failures

1. Ensure node group is healthy first
2. Check addon status: `aws eks describe-addon --cluster-name finishline-eks --addon-name coredns`

---

## References

- [EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)
- [Bottlerocket Documentation](https://github.com/bottlerocket-os/bottlerocket)
- [IRSA Documentation](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
- [Finish Line 2026 Assignment PDF §74, §75, §76, §79]

---

## License

This module is part of the Finish Line 2026 Infrastructure Project.  
**Reporter:** Joseph Ndzoh Dong  
**Timeline:** Feb 26, 2026 – March 2, 2026
