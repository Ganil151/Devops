output "cluster_id" {
  description = "EKS cluster ID"
  value       = try(aws_eks_cluster.eks[0].id, null)
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = try(aws_eks_cluster.eks[0].arn, null)
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = try(aws_eks_cluster.eks[0].endpoint, null)
}

output "cluster_version" {
  description = "EKS cluster version"
  value       = try(aws_eks_cluster.eks[0].version, null)
}

output "cluster_oidc_issuer_url" {
  description = "EKS cluster OIDC issuer URL"
  value       = try(aws_eks_cluster.eks[0].identity[0].oidc[0].issuer, null)
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN"
  value       = try(aws_iam_openid_connect_provider.eks_oidc[0].arn, null)
}

output "ondemand_node_group_id" {
  description = "On-demand node group ID"
  value       = try(aws_eks_node_group.ondemand_nodes[0].id, null)
}

output "spot_node_group_id" {
  description = "Spot node group ID"
  value       = try(aws_eks_node_group.spot_nodes[0].id, null)
}
