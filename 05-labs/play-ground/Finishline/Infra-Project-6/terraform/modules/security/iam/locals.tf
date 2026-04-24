locals {
  cluster_name           = var.cluster_name
  karpenter_cluster_name = var.karpenter_cluster_name != "" ? var.karpenter_cluster_name : var.cluster_name

  # Naming convention - deterministic or with random suffix
  name_suffix = var.enable_deterministic_naming ? "" : "-${random_integer.random_suffix.result}"

  tags = {
    Name    = "${var.project_name}-${var.environment}-${var.cluster_name}"
    Module  = "iam"
    Cluster = var.cluster_name
  }

  iam_tags = {
    Cluster = var.cluster_name
    Module  = "iam"
  }
}
