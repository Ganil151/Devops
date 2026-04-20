#============================================================
# EKS Cluster Role Outputs
#============================================================

output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = try(aws_iam_role.eks-cluster-role[0].arn, "")
}

output "eks_cluster_role_name" {
  description = "Name of the EKS cluster IAM role"
  value       = try(aws_iam_role.eks-cluster-role[0].name, "")
}

#============================================================
# EKS NodeGroup Role Outputs
#============================================================

output "eks_nodegroup_role_arn" {
  description = "ARN of the EKS nodegroup IAM role"
  value       = try(aws_iam_role.eks-nodegroup-role[0].arn, "")
}

output "eks_nodegroup_role_name" {
  description = "Name of the EKS nodegroup IAM role"
  value       = try(aws_iam_role.eks-nodegroup-role[0].name, "")
}

#============================================================
# OIDC Provider Outputs
#============================================================

output "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider"
  value       = try(aws_iam_openid_connect_provider.eks-oidc-provider[0].arn, "")
}

output "oidc_provider_url" {
  description = "URL of the EKS OIDC provider"
  value       = try(aws_iam_openid_connect_provider.eks-oidc-provider[0].url, "")
}

#============================================================
# OIDC IAM Role Outputs
#============================================================

output "oidc_role_arn" {
  description = "ARN of the OIDC IAM role"
  value       = try(aws_iam_role.eks_oidc_role[0].arn, "")
}

output "oidc_role_name" {
  description = "Name of the OIDC IAM role"
  value       = try(aws_iam_role.eks_oidc_role[0].name, "")
}

#============================================================
# S3 Policy Outputs
#============================================================

output "oidc_s3_policy_arn" {
  description = "ARN of the OIDC S3 policy"
  value       = try(aws_iam_policy.eks_oidc_policy[0].arn, "")
}

output "oidc_s3_policy_name" {
  description = "Name of the OIDC S3 policy"
  value       = try(aws_iam_policy.eks_oidc_policy[0].name, "")
}
