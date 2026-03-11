# EKS Module

## Overview
Deploys and manages Amazon EKS cluster with on-demand and spot node groups, OIDC provider, and add-ons.

## Functions
- **EKS Cluster**: Creates managed Kubernetes cluster with configurable endpoint access
- **Node Groups**: Deploys on-demand and spot instance node groups with auto-scaling
- **OIDC Provider**: Enables pod-level IAM authentication via IRSA (IAM Roles for Service Accounts)
- **Add-ons**: Manages EKS add-ons (CoreDNS, VPC-CNI, etc.)
- **Logging**: Configures control plane logging to CloudWatch

## Inputs
- `cluster_name`: EKS cluster name
- `cluster_version`: Kubernetes version
- `cluster_role_arn`: IAM role ARN for cluster
- `node_role_arn`: IAM role ARN for nodes
- `subnet_ids`: Private subnet IDs for cluster
- `security_group_ids`: Security group IDs for cluster
- `create_ondemand_nodegroup`: Enable on-demand node group
- `desired_capacity_on_demand/spot`: Node group scaling configuration
- `ondemand_instance_types/spot_instance_types`: EC2 instance types

## Outputs
- `cluster_id`: EKS cluster ID
- `cluster_endpoint`: Kubernetes API endpoint
- `cluster_oidc_issuer_url`: OIDC issuer URL
- `ondemand_node_group_id`: On-demand node group ID
- `spot_node_group_id`: Spot node group ID

## Connections
- **Depends on**: IAM module (requires role ARNs), VPC module (requires subnet IDs), Security Group module (requires SG IDs)
- **Used by**: Applications deployed on the cluster
- **Purpose**: Provides managed Kubernetes infrastructure for containerized workloads
