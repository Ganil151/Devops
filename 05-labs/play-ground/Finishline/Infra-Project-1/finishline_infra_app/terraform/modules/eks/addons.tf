# =============================================================================
# EKS Addons
# Module: eks
# Assignment Reference: Finish Line 2026 §74, §75
# - CoreDNS, kube-proxy, VPC-CNI addons
# - Managed by AWS, auto-updated
# =============================================================================

# -----------------------------------------------------------------------------
# EKS Addons
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html
# -----------------------------------------------------------------------------

resource "aws_eks_addon" "addons" {
  for_each = var.is_eks_addons_enabled ? var.addons : {}

  cluster_name                = aws_eks_cluster.eks[0].name
  addon_name                  = each.key
  addon_version               = each.value.version != "" ? each.value.version : null
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  # Optional: attach an IRSA role if provided per addon
  service_account_role_arn = lookup(each.value, "service_account_role_arn", null)

  # Configuration values for addon customization
  configuration_values = lookup(each.value, "configuration_values", null)

  tags = merge({
    Name        = "${var.cluster_name}-${each.key}-addon"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.manage_by
    Terraform   = "true"
  }, var.additional_tags)

  lifecycle {
    # Ignore version changes to allow AWS to manage addon updates
    ignore_changes = [addon_version]
  }

  depends_on = [
    aws_eks_node_group.ondemand_node,
    aws_eks_node_group.spot_node,
  ]
}

# -----------------------------------------------------------------------------
# CoreDNS Addon Configuration (optional - for custom settings)
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/coredns.html
# -----------------------------------------------------------------------------

# resource "aws_eks_addon" "coredns" {
#   count = var.is_eks_addons_enabled && lookup(var.addons, "coredns", null) != null ? 1 : 0
#
#   cluster_name                = aws_eks_cluster.eks[0].name
#   addon_name                  = "coredns"
#   addon_version               = var.addons["coredns"].version
#   resolve_conflicts_on_create = "OVERWRITE"
#   resolve_conflicts_on_update = "OVERWRITE"
#
#   service_account_role_arn = var.addons["coredns"].service_account_role_arn
#
#   configuration_values = jsonencode({
#     computeType = "Standard"
#     coreFile    = ""
#     scaling     = {
#       enabled = true
#       minReplicas = 2
#       maxReplicas = 10
#     }
#   })
#
#   depends_on = [aws_eks_node_group.ondemand_node]
# }

# -----------------------------------------------------------------------------
# VPC-CNI Addon Configuration (optional - for custom networking)
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip.html
# -----------------------------------------------------------------------------

# resource "aws_eks_addon" "vpc_cni" {
#   count = var.is_eks_addons_enabled && lookup(var.addons, "vpc-cni", null) != null ? 1 : 0
#
#   cluster_name                = aws_eks_cluster.eks[0].name
#   addon_name                  = "vpc-cni"
#   addon_version               = var.addons["vpc-cni"].version
#   resolve_conflicts_on_create = "OVERWRITE"
#   resolve_conflicts_on_update = "OVERWRITE"
#
#   service_account_role_arn = var.addons["vpc-cni"].service_account_role_arn
#
#   configuration_values = jsonencode({
#     env = {
#       # Enable prefix assignment for more IPs per node
#       ENABLE_PREFIX_DELEGATION = "true"
#       # Warm IP settings
#       WARM_IP_TARGET = "5"
#       MINIMUM_IP_TARGET = "2"
#     }
#   })
#
#   depends_on = [aws_eks_node_group.ondemand_node]
# }
