locals {
  common_tags = {
    Name   = "${var.project_name}-${var.environment}-vpc"
    Module = "vpc"
  }

  project_name = "${var.project_name}-${var.environment}"

}
