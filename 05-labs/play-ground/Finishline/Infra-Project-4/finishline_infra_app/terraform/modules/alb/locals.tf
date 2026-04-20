#============================================================
#  ALB Locals
#============================================================

locals {
  

  common_tags = {
    Name   = "${var.project_name}-${var.environment}-alb"
    Module = "alb"
  }
}
