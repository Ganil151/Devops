locals {
  sg_tags = {
    Name        = "${var.project_name}-${var.environment}-sg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.managedBy
  }
}
