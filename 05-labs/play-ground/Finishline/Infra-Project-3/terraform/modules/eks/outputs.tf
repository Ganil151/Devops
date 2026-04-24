# =============================================================================
# EKS Module - Output Values
# Finish Line 2026 Infrastructure
# =============================================================================

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.finishline_eks.name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.finishline_eks.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for cluster CA"
  value       = aws_eks_cluster.finishline_eks.certificate_authority[0].data
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.finishline_eks.arn
}

output "node_group_name" {
  description = "Name of the managed node group"
  value       = aws_eks_node_group.finishline_node_group.node_group_name
}

output "node_group_arn" {
  description = "ARN of the managed node group"
  value       = aws_eks_node_group.finishline_node_group.arn
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "node_group_role_arn" {
  description = "ARN of the node group IAM role"
  value       = aws_iam_role.eks_node_group_role.arn
}

output "cluster_security_group_id" {
  description = "Security group ID of the EKS cluster"
  value       = aws_eks_cluster.finishline_eks.vpc_config[0].cluster_security_group_id
}
