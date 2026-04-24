locals {
  instance_name = var.instance_name

  tags = merge({
    Name        = "${var.project_name}-${var.environment}-${var.instance_name}"
    Module      = "jumphost"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }, var.computed_tags)
}
