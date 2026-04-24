# =============================================================================
# IAM Module Outputs
# Module: secret/iam
# Assignment Reference: Finish Line 2026 §83, §84, §87, §89 (EKS IAM/RBAC integration)
# =============================================================================

# =============================================================================
# EKS Cluster Role Outputs
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html
# =============================================================================

output "eks_cluster_role_arn" {
  description = "The ARN of the EKS cluster IAM role"
  value       = try(aws_iam_role.eks-cluster-role[0].arn, null)
}

output "eks_cluster_role_name" {
  description = "The name of the EKS cluster IAM role"
  value       = try(aws_iam_role.eks-cluster-role[0].name, null)
}

output "eks_cluster_role_id" {
  description = "The unique ID of the EKS cluster IAM role"
  value       = try(aws_iam_role.eks-cluster-role[0].unique_id, null)
}

output "eks_cluster_role_create_date" {
  description = "The creation date of the EKS cluster IAM role"
  value       = try(aws_iam_role.eks-cluster-role[0].create_date, null)
}

# =============================================================================
# EKS Node Group Role Outputs
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/worker_node_IAM_role.html
# =============================================================================

output "eks_nodegroup_role_arn" {
  description = "The ARN of the EKS node group IAM role"
  value       = try(aws_iam_role.eks-nodegroup-role[0].arn, null)
}

output "eks_nodegroup_role_name" {
  description = "The name of the EKS node group IAM role"
  value       = try(aws_iam_role.eks-nodegroup-role[0].name, null)
}

output "eks_nodegroup_role_id" {
  description = "The unique ID of the EKS node group IAM role"
  value       = try(aws_iam_role.eks-nodegroup-role[0].unique_id, null)
}

output "eks_nodegroup_attached_policies" {
  description = "List of IAM policies attached to the EKS node group role"
  value = try(
    [
      "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
      "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
      "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
      "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    ],
    []
  )
}

# =============================================================================
# OIDC Provider Outputs
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
# =============================================================================

output "oidc_provider_arn" {
  description = "The ARN of the EKS OIDC identity provider"
  value       = try(aws_iam_openid_connect_provider.eks-oidc-provider[0].arn, null)
}

output "oidc_provider_url" {
  description = "The URL of the EKS OIDC identity provider"
  value       = try(aws_iam_openid_connect_provider.eks-oidc-provider[0].url, null)
}

output "oidc_provider_id" {
  description = "The unique ID of the EKS OIDC identity provider"
  value       = try(aws_iam_openid_connect_provider.eks-oidc-provider[0].id, null)
}

output "oidc_provider_client_id_list" {
  description = "The client ID list configured for the OIDC provider"
  value       = try(aws_iam_openid_connect_provider.eks-oidc-provider[0].client_id_list, [])
}

output "oidc_provider_thumbprint_list" {
  description = "The thumbprint list configured for the OIDC provider"
  value       = try(aws_iam_openid_connect_provider.eks-oidc-provider[0].thumbprint_list, [])
}

# =============================================================================
# OIDC IAM Role Outputs (for Service Accounts)
# =============================================================================

output "oidc_role_arn" {
  description = "The ARN of the OIDC IAM role for Kubernetes service accounts"
  value       = try(aws_iam_role.eks_oidc[0].arn, null)
}

output "oidc_role_name" {
  description = "The name of the OIDC IAM role for Kubernetes service accounts"
  value       = try(aws_iam_role.eks_oidc[0].name, null)
}

output "oidc_role_id" {
  description = "The unique ID of the OIDC IAM role"
  value       = try(aws_iam_role.eks_oidc[0].unique_id, null)
}

output "oidc_role_assume_role_policy" {
  description = "The assume role policy document for the OIDC IAM role"
  value       = try(aws_iam_role.eks_oidc[0].assume_role_policy, null)
}

# =============================================================================
# OIDC IAM Policy Outputs
# =============================================================================

output "oidc_policy_arn" {
  description = "The ARN of the OIDC IAM policy"
  value       = try(aws_iam_policy.eks-oidc-policy[0].arn, null)
}

output "oidc_policy_name" {
  description = "The name of the OIDC IAM policy"
  value       = try(aws_iam_policy.eks-oidc-policy[0].name, null)
}

output "oidc_policy_id" {
  description = "The unique ID of the OIDC IAM policy"
  value       = try(aws_iam_policy.eks-oidc-policy[0].policy_id, null)
}

output "oidc_policy_document" {
  description = "The policy document for the OIDC IAM policy (JSON)"
  value       = try(aws_iam_policy.eks-oidc-policy[0].policy, null)
}

# =============================================================================
# Composite Outputs (for use in other modules)
# =============================================================================

output "cluster_role" {
  description = "Complete EKS cluster role object for advanced use cases"
  value       = try(aws_iam_role.eks-cluster-role[0], null)
}

output "nodegroup_role" {
  description = "Complete EKS node group role object for advanced use cases"
  value       = try(aws_iam_role.eks-nodegroup-role[0], null)
}

output "oidc_provider" {
  description = "Complete OIDC provider object for advanced use cases"
  value       = try(aws_iam_openid_connect_provider.eks-oidc-provider[0], null)
}

output "oidc_role" {
  description = "Complete OIDC IAM role object for advanced use cases"
  value       = try(aws_iam_role.eks_oidc[0], null)
}

# =============================================================================
# Module Configuration Outputs
# =============================================================================

output "configuration" {
  description = "Module configuration summary for documentation"
  value = {
    cluster_name                = var.cluster_name
    is_eks_role_enabled         = var.is_eks_role_enabled
    is_eks_nodegroup_enabled    = var.is_eks_nodegroup_role_enabled
    is_eks_cluster_enabled      = var.is_eks_cluster_enabled
    oidc_provider_configured    = var.is_eks_cluster_enabled && var.eks_oidc_url != ""
    s3_bucket_arn_configured    = var.s3_bucket_arn != ""
    random_suffix_used          = random_integer.random_suffix.result
  }
}
