locals {
  alb_name = var.project_name != "" ? "${var.project_name}-alb" : "${var.environment}-alb"

  common_tags = {
    Name   = local.alb_name
    Module = "alb"
  }
}
