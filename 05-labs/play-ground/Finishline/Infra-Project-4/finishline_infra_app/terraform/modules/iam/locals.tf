locals {
  cluster_name = var.cluster_name

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
