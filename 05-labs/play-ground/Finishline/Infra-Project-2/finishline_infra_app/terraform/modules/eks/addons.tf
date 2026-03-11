#==============================================================
# EKS Addons
#==============================================================
resource "aws_eks_addon" "addons" {
  for_each = var.is_eks_addons_enabled ? var.addons : {}

  cluster_name                = aws_eks_cluster.eks[0].name
  addon_name                  = each.key
  addon_version               = try(each.value.version, null)
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn    = try(each.value.service_account_role_arn, null)

  tags = merge(local.tags, {
    Name = "${var.cluster_name}-${each.key}-addon"
  })

  lifecycle {
    ignore_changes = [addon_version]
  }

  depends_on = [aws_eks_cluster.eks]
}
