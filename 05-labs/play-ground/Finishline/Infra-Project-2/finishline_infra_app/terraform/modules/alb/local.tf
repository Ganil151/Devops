#===========================================================
# Locals Values
#===========================================================
locals {
  alb_name           = var.alb_name != "" ? var.alb_name : "${var.project_name}-${var.environment}-alb"
  target_group_name  = var.target_group_name != "" ? var.target_group_name : "${var.project_name}-${var.environment}-tg"
  
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.managedBy
    Module      = "alb"
  }

  alb_tags = merge(
    local.common_tags,
    var.additional_tags,
    {
      Name = local.alb_name
    }
  )

  target_group_tags = merge(
    local.common_tags,
    var.additional_tags,
    {
      Name = local.target_group_name
    }
  )
}
