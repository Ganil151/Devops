# =============================================================================
# EKS Module Outputs
# Module: eks
# Assignment Reference: Finish Line 2026 §74, §75, §76, §79
# - EKS Cluster with Managed Node Groups
# =============================================================================

# -----------------------------------------------------------------------------
# EKS Cluster Outputs
# -----------------------------------------------------------------------------

output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].id, null)
}

output "cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].arn, null)
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].name, null)
}

output "cluster_endpoint" {
  description = "The API endpoint of the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].endpoint, null)
  sensitive   = true
}

output "cluster_version" {
  description = "The Kubernetes version of the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].version, null)
}

output "cluster_platform_version" {
  description = "The platform version of the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].platform_version, null)
}

output "cluster_status" {
  description = "The status of the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].status, null)
}

# -----------------------------------------------------------------------------
# Cluster Certificate and Authentication
# -----------------------------------------------------------------------------

output "cluster_certificate_authority_data" {
  description = "The base64-encoded certificate authority data for the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].certificate_authority[0].data, null)
  sensitive   = true
}

output "cluster_oidc_issuer_url" {
  description = "The OIDC issuer URL for the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].identity[0].oidc[0].issuer, null)
}

# -----------------------------------------------------------------------------
# Cluster Security Configuration
# -----------------------------------------------------------------------------

output "cluster_security_group_id" {
  description = "The ID of the security group created for the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].vpc_config[0].cluster_security_group_id, null)
}

output "cluster_vpc_config" {
  description = "The VPC configuration of the EKS cluster"
  value = try({
    cluster_security_group_id = aws_eks_cluster.eks[0].vpc_config[0].cluster_security_group_id
    endpoint_private_access   = aws_eks_cluster.eks[0].vpc_config[0].endpoint_private_access
    endpoint_public_access    = aws_eks_cluster.eks[0].vpc_config[0].endpoint_public_access
    subnet_ids                = aws_eks_cluster.eks[0].vpc_config[0].subnet_ids
    vpc_id                    = aws_eks_cluster.eks[0].vpc_config[0].vpc_id
  }, null)
}

# -----------------------------------------------------------------------------
# OIDC Provider Outputs
# -----------------------------------------------------------------------------

output "oidc_provider_arn" {
  description = "The ARN of the OIDC identity provider"
  value       = try(aws_iam_openid_connect_provider.eks_oidc_provider[0].arn, null)
}

output "oidc_provider_url" {
  description = "The URL of the OIDC identity provider"
  value       = try(aws_iam_openid_connect_provider.eks_oidc_provider[0].url, null)
}

output "oidc_provider_id" {
  description = "The ID of the OIDC identity provider"
  value       = try(aws_iam_openid_connect_provider.eks_oidc_provider[0].id, null)
}

# -----------------------------------------------------------------------------
# On-Demand Node Group Outputs
# -----------------------------------------------------------------------------

output "ondemand_node_group_id" {
  description = "The ID of the on-demand node group"
  value       = try(aws_eks_node_group.ondemand_node[0].id, null)
}

output "ondemand_node_group_arn" {
  description = "The ARN of the on-demand node group"
  value       = try(aws_eks_node_group.ondemand_node[0].arn, null)
}

output "ondemand_node_group_status" {
  description = "The status of the on-demand node group"
  value       = try(aws_eks_node_group.ondemand_node[0].status, null)
}

output "ondemand_node_group_resources" {
  description = "The EC2 instances in the on-demand node group"
  value       = try(aws_eks_node_group.ondemand_node[0].resources, null)
}

# -----------------------------------------------------------------------------
# Spot Node Group Outputs
# -----------------------------------------------------------------------------

output "spot_node_group_id" {
  description = "The ID of the spot node group"
  value       = try(aws_eks_node_group.spot_node[0].id, null)
}

output "spot_node_group_arn" {
  description = "The ARN of the spot node group"
  value       = try(aws_eks_node_group.spot_node[0].arn, null)
}

output "spot_node_group_status" {
  description = "The status of the spot node group"
  value       = try(aws_eks_node_group.spot_node[0].status, null)
}

# -----------------------------------------------------------------------------
# EKS Addons Outputs
# -----------------------------------------------------------------------------

output "addons" {
  description = "Map of deployed EKS addons with their ARNs and versions"
  value = {
    for k, v in aws_eks_addon.addons : k => {
      arn     = v.addon_arn
      version = v.addon_version
      status  = v.addon_status
    }
  }
}

# -----------------------------------------------------------------------------
# Kubeconfig Helper
# -----------------------------------------------------------------------------

output "kubeconfig_command" {
  description = "AWS CLI command to update kubeconfig for this cluster"
  value       = "aws eks update-kubeconfig --name ${try(aws_eks_cluster.eks[0].name, "")} --region ${var.aws_region}"
}

output "kubeconfig_data" {
  description = "Kubeconfig data for programmatic use"
  value = {
    cluster_name          = try(aws_eks_cluster.eks[0].name, null)
    cluster_endpoint      = try(aws_eks_cluster.eks[0].endpoint, null)
    certificate_authority = try(aws_eks_cluster.eks[0].certificate_authority[0].data, null)
    oidc_issuer_url       = try(aws_eks_cluster.eks[0].identity[0].oidc[0].issuer, null)
    security_group_id     = try(aws_eks_cluster.eks[0].vpc_config[0].cluster_security_group_id, null)
  }
  sensitive = true
}

# -----------------------------------------------------------------------------
# Cluster Information Summary
# -----------------------------------------------------------------------------

output "cluster_info" {
  description = "Complete EKS cluster information for documentation"
  value = {
    cluster_id             = try(aws_eks_cluster.eks[0].id, null)
    cluster_name           = try(aws_eks_cluster.eks[0].name, null)
    cluster_arn            = try(aws_eks_cluster.eks[0].arn, null)
    cluster_endpoint       = try(aws_eks_cluster.eks[0].endpoint, null)
    cluster_version        = try(aws_eks_cluster.eks[0].version, null)
    platform_version       = try(aws_eks_cluster.eks[0].platform_version, null)
    status                 = try(aws_eks_cluster.eks[0].status, null)
    oidc_issuer_url        = try(aws_eks_cluster.eks[0].identity[0].oidc[0].issuer, null)
    security_group_id      = try(aws_eks_cluster.eks[0].vpc_config[0].cluster_security_group_id, null)
    subnet_ids             = try(aws_eks_cluster.eks[0].vpc_config[0].subnet_ids, null)
    vpc_id                 = try(aws_eks_cluster.eks[0].vpc_config[0].vpc_id, null)
    ondemand_node_group_id = try(aws_eks_node_group.ondemand_node[0].id, null)
    spot_node_group_id     = try(aws_eks_node_group.spot_node[0].id, null)
    oidc_provider_arn      = try(aws_iam_openid_connect_provider.eks_oidc_provider[0].arn, null)
    created_at             = try(aws_eks_cluster.eks[0].created_at, null)
  }
  sensitive = true
}
