# Bootstrap Module

## Overview

The Bootstrap module is a **placeholder** for cluster bootstrapping and initialization tasks. It is intended to handle post-deployment configuration of the EKS cluster, including:

- Kubernetes manifest deployment
- Helm chart installations
- Core add-on configurations
- Namespace and RBAC setup
- Initial application deployments

## Status

⚠️ **Placeholder** - This module is not yet implemented.

## Planned Functionality

### Resources to be Created

| Resource Type | Description |
|--------------|-------------|
| `kubernetes_namespace` | Core Kubernetes namespaces |
| `kubernetes_config_map` | Cluster configuration maps |
| `kubernetes_secret` | Cluster secrets |
| `helm_release` | Helm chart deployments |
| `kubectl_manifest` | Raw Kubernetes manifests |

### Planned Features

1. **Cluster Initialization**
   - Deploy core Kubernetes resources
   - Configure cluster autoscaler
   - Set up metrics server

2. **Add-on Deployment**
   - Install AWS Load Balancer Controller
   - Deploy ExternalDNS
   - Configure Cluster Autoscaler
   - Install Cert-Manager

3. **Namespace Setup**
   - Create standard namespaces (dev, staging, prod)
   - Apply resource quotas
   - Configure network policies

4. **RBAC Configuration**
   - Create service accounts
   - Define roles and role bindings
   - Configure cluster role bindings

## Dependencies

- **EKS Module**: Requires a running EKS cluster
- **IAM Module**: Requires OIDC provider for IRSA
- **VPC Module**: Requires CNI configuration
- **Provider**: Kubernetes, Helm, Kubectl providers

## Planned Inputs

| Name | Type | Description | Required |
|------|------|-------------|----------|
| `cluster_name` | `string` | Name of the EKS cluster | Yes |
| `cluster_endpoint` | `string` | EKS API endpoint URL | Yes |
| `cluster_ca_certificate` | `string` | EKS certificate authority data | Yes |
| `oidc_provider_arn` | `string` | OIDC provider ARN for IRSA | No |
| `bootstrap_enabled` | `bool` | Enable bootstrapping | Yes |
| `helm_charts` | `map(object)` | Helm charts to deploy | No |
| `namespaces` | `list(string)` | Namespaces to create | No |

## Planned Outputs

| Name | Description |
|------|-------------|
| `bootstrap_status` | Bootstrap completion status |
| `deployed_namespaces` | List of created namespaces |
| `deployed_helm_releases` | List of deployed Helm charts |
| `config_map_names` | List of created ConfigMaps |

## Usage Example (Planned)

```hcl
module "bootstrap" {
  source = "./modules/bootstrap"

  cluster_name           = module.eks.cluster_name
  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_certificate_authority_data
  oidc_provider_arn      = module.iam.oidc_provider_arn
  
  bootstrap_enabled = true

  namespaces = ["dev", "staging", "prod"]

  helm_charts = {
    "aws-load-balancer-controller" = {
      repository = "https://aws.github.io/eks-charts"
      version    = "1.6.0"
      namespace  = "kube-system"
    },
    "external-dns" = {
      repository = "https://kubernetes-sigs.github.io/external-dns"
      version    = "1.14.0"
      namespace  = "kube-system"
    },
    "cert-manager" = {
      repository = "https://charts.jetstack.io"
      version    = "1.13.0"
      namespace  = "cert-manager"
    }
  }
}
```

## Implementation Notes

### Provider Requirements

```hcl
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.11"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
  }
}
```

### Authentication

The module will use OIDC authentication with the EKS cluster:

```hcl
provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
  }
}
```

## Security Considerations

1. **Service Account Permissions**: Use least-privilege for Kubernetes service accounts
2. **Secret Management**: Use AWS Secrets Manager or External Secrets Operator
3. **Network Policies**: Implement network policies for namespace isolation
4. **RBAC**: Define granular roles and bindings

## Next Steps

1. Implement core bootstrap functionality
2. Add Helm chart deployment support
3. Create Kubernetes manifest templates
4. Add validation and error handling
5. Write comprehensive tests

## Related Modules

- [EKS Module](../eks/README.md) - EKS cluster creation
- [IAM Module](../iam/README.md) - IAM roles and OIDC provider
- [VPC Module](../vpc/README.md) - VPC and networking
