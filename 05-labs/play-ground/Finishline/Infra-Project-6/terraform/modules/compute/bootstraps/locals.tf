#============================================================
#  Local Values
#============================================================
locals {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name

  tags = merge({
    Name                                        = "${var.project_name}-${var.environment}-${var.node_group_name}"
    Module                                      = "bootstraps"
    Cluster                                     = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }, var.computed_tags)

  # Default bootstrap addons (core addons that should be installed on every cluster)
  default_addons = {
    "vpc-cni" = {
      version = "latest"
      configuration_values = jsonencode({
        enableNetworkPolicy = "true"
      })
    }
    "coredns" = {
      version = "latest"
    }
    "kube-proxy" = {
      version = "latest"
    }
  }

  # Merge default and custom addons
  effective_addons = var.is_bootstrap_addons_enabled ? merge(local.default_addons, var.bootstrap_addons) : {}

  # Node group taints formatting
  node_group_taints = var.is_eks_nodegroup_enabled ? [
    for taint in var.node_group_taints : {
      key    = taint.key
      value  = taint.value
      effect = taint.effect
    }
  ] : []
}
