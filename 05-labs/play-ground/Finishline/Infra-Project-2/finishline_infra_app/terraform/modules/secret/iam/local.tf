locals {
  cluster_name = var.cluster_name

  tags = merge({
    Name        = var.cluster_name
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managedBy
    Terraform   = "true"
  }, var.additional_tags)

  iam_tags = {
    Cluster     = var.cluster_name
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managedBy
  }
}