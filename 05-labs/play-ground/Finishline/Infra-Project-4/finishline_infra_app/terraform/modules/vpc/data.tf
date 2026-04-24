#============================================================
#  Data Sources
#============================================================

# Get available availability zones in the current region
data "aws_availability_zones" "available" {
  state = "available"
}

# Get current region information
data "aws_region" "current" {}

# Get current account information
data "aws_caller_identity" "current" {}
