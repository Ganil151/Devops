#============================================================
#  EKS Cluster Outputs
#============================================================

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].name, null)
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].arn, null)
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS cluster API server"
  value       = try(aws_eks_cluster.eks[0].endpoint, null)
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for the cluster CA"
  value       = try(aws_eks_cluster.eks[0].certificate_authority[0].data, null)
}

output "cluster_id" {
  description = "ID of the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].id, null)
}

output "cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].version, null)
}

output "cluster_status" {
  description = "Status of the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].status, null)
}

output "cluster_platform_version" {
  description = "Platform version of the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].platform_version, null)
}

#============================================================
#  EKS Cluster Network Outputs
#============================================================

output "cluster_vpc_config_id" {
  description = "VPC ID associated with the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].vpc_config[0].vpc_id, null)
}

output "cluster_security_group_id" {
  description = "Security group ID created by EKS for the cluster"
  value       = try(aws_eks_cluster.eks[0].vpc_config[0].cluster_security_group_id, null)
}

output "cluster_subnet_ids" {
  description = "List of subnet IDs associated with the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].vpc_config[0].subnet_ids, [])
}

#============================================================
#  EKS OIDC Provider Outputs
#============================================================

output "cluster_oidc_issuer_url" {
  description = "OIDC Identity Provider issuer URL for the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].identity[0].oidc[0].issuer, null)
}

output "cluster_oidc_issuer_arn" {
  description = "ARN of the OIDC Identity Provider for the EKS cluster"
  value       = try("arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.eks[0].identity[0].oidc[0].issuer, "https://", "")}", null)
}

output "cluster_oidc_issuer_thumbprint" {
  description = "SHA1 thumbprint of the OIDC issuer certificate"
  value       = try(aws_eks_cluster.eks[0].certificate_authority[0].data, null)
}

#============================================================
#  EKS Access Configuration Outputs
#============================================================

output "cluster_authentication_mode" {
  description = "Authentication mode of the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].access_config[0].authentication_mode, null)
}

output "cluster_created_at" {
  description = "RFC3339 timestamp of when the cluster was created"
  value       = try(aws_eks_cluster.eks[0].created_at, null)
}

output "cluster_enabled_log_types" {
  description = "List of enabled log types for the cluster"
  value       = try(aws_eks_cluster.eks[0].enabled_cluster_log_types, null)
}

output "cluster_encryption_config" {
  description = "Encryption configuration for the cluster"
  value       = try(aws_eks_cluster.eks[0].encryption_config, null)
  sensitive   = true
}

output "cluster_upgrade_policy" {
  description = "Upgrade policy configuration for the cluster"
  value       = try(aws_eks_cluster.eks[0].upgrade_policy, null)
}

#============================================================
#  EKS Access Entry Outputs
#============================================================

output "access_entry_principal_arns" {
  description = "List of access entry principal ARNs"
  value       = var.is_eks_cluster_enabled ? concat(keys(aws_eks_access_entry.cluster_admins), try([aws_eks_access_entry.nodegroup[0].principal_arn], [])) : []
}

output "access_policy_association_arns" {
  description = "Map of access policy association ARNs"
  value = {
    for k, v in aws_eks_access_policy_association.cluster_admins : k => v.id
  }
}
