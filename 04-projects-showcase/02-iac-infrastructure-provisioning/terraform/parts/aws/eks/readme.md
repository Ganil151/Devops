# Amazon EKS Architectural Patterns

This directory contains 20 common Elastic Kubernetes Service (EKS) patterns for AWS using Terraform. EKS is a managed service that makes it easy to run Kubernetes on AWS without needing to install, operate, and maintain your own Kubernetes control plane.

## 📂 EKS Patterns Overview

| # | Type | Description | File |
|---|------|-------------|------|
| 1 | **Basic Cluster** | Minimal managed control plane setup. | `01-basic-cluster.tf` |
| 2 | **Managed Node Group**| AWS-managed EC2 worker nodes. | `02-managed-node-group.tf` |
| 3 | **Fargate Profile** | Running pods on serverless compute. | `03-fargate-profile.tf` |
| 4 | **OIDC Provider** | enabling IAM Roles for Service Accounts (IRSA). | `04-oidc-provider.tf` |
| 5 | **Private Endpoint** | Hardened cluster with no public API access. | `05-private-endpoint.tf` |
| 6 | **KMS Secrets** | Hardware encryption for K8s secrets. | `06-kms-secrets.tf` |
| 7 | **Cluster Add-ons** | managing VPC-CNI, CoreDNS, and Kube-Proxy. | `07-cluster-addons.tf` |
| 8 | **Audit Logging** | CloudWatch logging for control plane events. | `08-audit-logging.tf` |
| 9 | **Cluster SG Rules** | Customizing ingress/egress for the API server. | `09-eks-sg-rules.tf` |
| 10 | **Spot Node Group** | leveraging Spot instances for massive savings. | `10-spot-node-group.tf` |
| 11 | **Bottlerocket** | Using AWS container-optimized OS for nodes. | `11-bottlerocket-nodes.tf` |
| 12 | **Tainted Nodes** | Workload isolation via K8s taints/tolerations. | `12-tainted-node-group.tf` |
| 13 | **Remote Access** | enabling SSH (debugging) on managed nodes. | `13-remote-access-nodes.tf` |
| 14 | **Pinned Version** | Stability via explicit Kubernetes versioning. | `14-versioned-cluster.tf` |
| 15 | **Public Whitelist** | Restricting API access to specific CIDRs. | `15-whitelisted-access.tf` |
| 16 | **Launch Template** | Advanced node configuration (disk, tags). | `16-launch-template-nodes.tf` |
| 17 | **Identity Provider** | External OIDC integration (Okta/Google). | `17-oidc-identity-config.tf` |
| 18 | **Graviton (ARM)** | Cost-effective ARM64 worker nodes. | `18-graviton-nodes.tf` |
| 19 | **Cluster Tags** | discovery tags for ALB/External-DNS. | `19-cluster-tags.tf` |
| 20 | **Minimalist** | Baseline control plane boilerplate. | `20-minimalist-eks.tf` |

## 🚀 Key Best Practices
1.  **IRSA (OIDC)**: Use IAM Roles for Service Accounts instead of node roles for better security.
2.  **Private Endpoints**: Disable public API access for production clusters.
3.  **KMS Encryption**: Always enable secrets encryption using a customer-managed KMS key.
4.  **AZ Awareness**: Spread worker nodes across at least 3 Availability Zones.
5.  **Managed Add-ons**: Prefer AWS-managed add-ons for VPC-CNI and CoreDNS for easier updates.

## 🛠 Prerequisites
EKS clusters require existing IAM roles (Cluster and Node) and specific subnets. See the `iam` and `vpcs` directories for associated resource patterns.
