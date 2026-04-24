locals {
  jumphost_tags = merge({
    Name        = var.jumphost_name
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managedBy
    Component   = "jumphost"
  }, var.additional_tags)
}
