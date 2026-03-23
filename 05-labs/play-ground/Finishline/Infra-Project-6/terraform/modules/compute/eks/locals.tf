locals {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name

  tags = {
    Name    = "${var.project_name}-${var.environment}-${var.cluster_name}"
    Module  = "eks"
    Cluster = var.cluster_name
  }

  node_group_tags = merge(local.tags, {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })

  default_addons = {

    "vpc-cni" = {
      version = "latest"
      configuration_values = jsonencode({
        enableNetworkPolicy = true
      })
    }

    "coredns" = {
      version = "latest"
    }

    "kube-proxy" = {
      version = "latest"
    }
  }

  effective_addons = var.is_bootstrap_addons_enabled ? merge(local.default_addons, var.addons) : {}

  node_group_taints = var.is_eks_nodegroup_enabled ? [
    for taint in var.node_group_taints : {
      key    = taint.key
      value  = taint.value
      effect = taint.effect

    }
  ] : []
}
