#==============================================================
# EKS Module Outputs
#==============================================================

# Cluster ARN
output "cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].arn, null)
}

# Cluster Name
output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].name, null)
}

# Cluster ID
output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].id, null)
}

# Cluster Endpoint
output "cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].endpoint, null)
}

# Cluster Version
output "cluster_version" {
  description = "The version of the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].version, null)
}

# Cluster Platform Version
output "cluster_platform_version" {
  description = "The platform version of the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].platform_version, null)
}

# Cluster Status
output "cluster_status" {
  description = "The status of the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].status, null)
}

# Cluster OIDC Issuer URL
output "cluster_oidc_issuer_url" {
  description = "The OIDC issuer URL of the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].identity[0].oidc[0].issuer, null)
}

# Cluster Security Group IDs
output "cluster_security_group_ids" {
  description = "The security group IDs associated with the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].vpc_config[0].security_group_ids, [])
}

# Cluster Subnet IDs
output "cluster_subnet_ids" {
  description = "The subnet IDs associated with the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].vpc_config[0].subnet_ids, [])
}

# Certificate Authority Data
output "cluster_certificate_authority" {
  description = "The certificate authority data for the EKS cluster"
  value       = try(aws_eks_cluster.eks[0].identity[0].oidc[0].issuer, null)
}

# EKS Addons
output "eks_addons" {
  description = "Map of EKS addons created"
  value       = aws_eks_addon.addons
}

# Tags
output "tags" {
  description = "Tags applied to EKS resources"
  value       = local.tags
}
