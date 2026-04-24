locals {
  common_tags = {
    Name   = "${var.project_name}-${var.environment}-bootstrap"
    Module = "bootstrap"
  }
}
