locals {
  vpc_tags = merge({
    Name        = "${var.project_name}-${var.environment}-vpc"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.managedBy
  }, var.additional_tags)

  subnet_tags = merge({
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.managedBy
  }, var.additional_tags)

  igw_tags = merge({
    Name        = "${var.project_name}-${var.environment}-igw"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.managedBy
  }, var.additional_tags)

  nat_tags = merge({
    Name        = "${var.project_name}-${var.environment}-nat-gateway"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.managedBy
  }, var.additional_tags)

  eip_tags = merge({
    Name        = "${var.project_name}-${var.environment}-eip"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.managedBy
  }, var.additional_tags)

  route_table_tags = merge({
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.managedBy
  }, var.additional_tags)
}
