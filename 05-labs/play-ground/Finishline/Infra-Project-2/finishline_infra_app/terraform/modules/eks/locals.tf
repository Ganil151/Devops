locals {
  tags = merge({
    Name        = var.cluster_name
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managedBy
  }, var.additional_tags)
}
