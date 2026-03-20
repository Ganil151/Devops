#============================================================
#  Node Group IAM Outputs
#============================================================

output "nodegroup_role_name" {
  description = "Name of the IAM role for the EKS node group"
  value       = var.is_eks_nodegroup_role_enabled ? aws_iam_role.eks_nodegroup[0].name : null
}

output "nodegroup_role_arn" {
  description = "ARN of the IAM role for the EKS node group"
  value       = var.is_eks_nodegroup_role_enabled ? aws_iam_role.eks_nodegroup[0].arn : null
}

output "nodegroup_instance_profile_name" {
  description = "Name of the IAM instance profile for the node group"
  value       = var.is_eks_nodegroup_enabled ? aws_iam_instance_profile.eks_nodegroup[0].name : null
}

output "nodegroup_instance_profile_arn" {
  description = "ARN of the IAM instance profile for the node group"
  value       = var.is_eks_nodegroup_enabled ? aws_iam_instance_profile.eks_nodegroup[0].arn : null
}

#============================================================
#  EKS Node Group Outputs
#============================================================

output "nodegroup_id" {
  description = "ID of the EKS node group"
  value       = var.is_eks_nodegroup_enabled ? aws_eks_node_group.nodegroup[0].id : null
}

output "nodegroup_arn" {
  description = "ARN of the EKS node group"
  value       = var.is_eks_nodegroup_enabled ? aws_eks_node_group.nodegroup[0].arn : null
}

output "nodegroup_resources" {
  description = "List of resources associated with the node group"
  value       = var.is_eks_nodegroup_enabled ? aws_eks_node_group.nodegroup[0].resources : null
}

output "nodegroup_iam_role_arn" {
  description = "IAM role ARN of the node group"
  value       = var.is_eks_nodegroup_enabled ? aws_eks_node_group.nodegroup[0].node_role_arn : null
}

output "nodegroup_status" {
  description = "Status of the node group"
  value       = var.is_eks_nodegroup_enabled ? aws_eks_node_group.nodegroup[0].status : null
}

output "nodegroup_labels" {
  description = "Labels attached to the node group"
  value       = var.is_eks_nodegroup_enabled ? aws_eks_node_group.nodegroup[0].labels : null
}

output "nodegroup_taints" {
  description = "Taints attached to the node group"
  value       = var.is_eks_nodegroup_enabled ? aws_eks_node_group.nodegroup[0].taint : null
}

#============================================================
#  Bootstrap Addons Outputs
#============================================================

output "bootstrap_addons" {
  description = "Map of bootstrap addon names to their ARNs"
  value = var.is_bootstrap_addons_enabled ? {
    for k, v in aws_eks_addon.bootstrap_addons : k => v.arn
  } : {}
}

output "bootstrap_addon_statuses" {
  description = "Map of bootstrap addon names to their ARNs"
  value = var.is_bootstrap_addons_enabled ? {
    for k, v in aws_eks_addon.bootstrap_addons : k => v.arn
  } : {}
}

#============================================================
#  Karpenter Outputs
#  Note: IAM roles are managed separately in security/iam module
#============================================================

output "karpenter_controller_role_name" {
  description = "Name of the IAM role for Karpenter controller"
  value       = var.is_karpenter_enabled && var.karpenter_controller_role_arn != "" ? split("/", var.karpenter_controller_role_arn)[1] : null
}

output "karpenter_controller_role_arn" {
  description = "ARN of the IAM role for Karpenter controller"
  value       = var.is_karpenter_enabled ? var.karpenter_controller_role_arn : null
}

output "karpenter_node_role_name" {
  description = "Name of the IAM role for Karpenter nodes"
  value       = var.is_karpenter_enabled && var.karpenter_node_role_arn != "" ? split("/", var.karpenter_node_role_arn)[1] : null
}

output "karpenter_node_role_arn" {
  description = "ARN of the IAM role for Karpenter nodes"
  value       = var.is_karpenter_enabled ? var.karpenter_node_role_arn : null
}

output "karpenter_node_instance_profile_name" {
  description = "Name of the IAM instance profile for Karpenter nodes"
  value       = var.is_karpenter_enabled ? var.karpenter_instance_profile_name : null
}

#============================================================
#  Summary Outputs
#============================================================

output "nodegroup_summary" {
  description = "Summary of node group configuration"
  value = var.is_eks_nodegroup_enabled ? {
    name           = var.node_group_name
    instance_types = var.node_group_instance_types
    capacity_type  = var.node_group_capacity_type
    desired_size   = var.node_group_desired_size
    min_size       = var.node_group_min_size
    max_size       = var.node_group_max_size
    role_arn       = var.node_group_role_arn != "" ? var.node_group_role_arn : aws_iam_role.eks_nodegroup[0].arn
    status         = aws_eks_node_group.nodegroup[0].status
  } : null
}

output "is_nodegroup_created" {
  description = "Whether the node group was created"
  value       = var.is_eks_nodegroup_enabled
}

output "is_karpenter_enabled" {
  description = "Whether Karpenter is enabled"
  value       = var.is_karpenter_enabled
}
