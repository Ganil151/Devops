#============================================================
#  EKS Cluster Role Outputs
#============================================================
output "eks_cluster_role_name" {
  description = "Name of the EKS cluster IAM role"
  value       = try(aws_iam_role.eks-cluster-role[0].name, null)
}

output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = try(aws_iam_role.eks-cluster-role[0].arn, null)
}

#============================================================
#  EKS Nodegroup Role Outputs
#============================================================
output "eks_nodegroup_role_name" {
  description = "Name of the EKS nodegroup IAM role"
  value       = try(aws_iam_role.eks-nodegroup-role[0].name, null)
}

output "eks_nodegroup_role_arn" {
  description = "ARN of the EKS nodegroup IAM role"
  value       = try(aws_iam_role.eks-nodegroup-role[0].arn, null)
}

#============================================================
#  OIDC Provider Outputs
#============================================================
output "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider"
  value       = try(aws_iam_openid_connect_provider.eks-oidc-provider[0].arn, null)
}

output "oidc_provider_url" {
  description = "URL of the EKS OIDC provider"
  value       = try(aws_iam_openid_connect_provider.eks-oidc-provider[0].url, null)
}

#============================================================
#  OIDC Role Outputs
#============================================================
output "eks_oidc_role_name" {
  description = "Name of the generic EKS OIDC IAM role"
  value       = try(aws_iam_role.eks_oidc_role[0].name, null)
}

output "eks_oidc_role_arn" {
  description = "ARN of the generic EKS OIDC IAM role"
  value       = try(aws_iam_role.eks_oidc_role[0].arn, null)
}

#============================================================
#  OIDC Policy Outputs
#============================================================
output "eks_oidc_policy_arn" {
  description = "ARN of the EKS OIDC IAM policy"
  value       = try(aws_iam_policy.eks_oidc_policy[0].arn, null)
}

output "eks_oidc_policy_name" {
  description = "Name of the EKS OIDC IAM policy"
  value       = try(aws_iam_policy.eks_oidc_policy[0].name, null)
}

#============================================================
#  Karpenter Controller Role Outputs
#============================================================
output "karpenter_controller_role_name" {
  description = "Name of the Karpenter controller IAM role"
  value       = try(aws_iam_role.karpenter-controller-role[0].name, null)
}

output "karpenter_controller_role_arn" {
  description = "ARN of the Karpenter controller IAM role"
  value       = try(aws_iam_role.karpenter-controller-role[0].arn, null)
}

output "karpenter_controller_policy_arn" {
  description = "ARN of the Karpenter controller IAM policy"
  value       = try(aws_iam_policy.karpenter-controller-policy[0].arn, null)
}

output "karpenter_controller_policy_name" {
  description = "Name of the Karpenter controller IAM policy"
  value       = try(aws_iam_policy.karpenter-controller-policy[0].name, null)
}

#============================================================
#  Karpenter Node Role Outputs
#============================================================
output "karpenter_node_role_name" {
  description = "Name of the Karpenter node IAM role"
  value       = try(aws_iam_role.karpenter-node-role[0].name, null)
}

output "karpenter_node_role_arn" {
  description = "ARN of the Karpenter node IAM role"
  value       = try(aws_iam_role.karpenter-node-role[0].arn, null)
}

#============================================================
#  Karpenter Instance Profile Outputs
#============================================================
output "karpenter_node_instance_profile_name" {
  description = "Name of the Karpenter node instance profile"
  value       = try(aws_iam_instance_profile.karpenter-node-profile[0].name, null)
}

output "karpenter_node_instance_profile_arn" {
  description = "ARN of the Karpenter node instance profile"
  value       = try(aws_iam_instance_profile.karpenter-node-profile[0].arn, null)
}
