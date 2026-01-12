locals {
  common_tags = {
    Project = "Terraform-Gsmash-Demo"
    Environment = var.environment
    Owner   = "Gsmash"
  }

  full_bucket_name = "${var.bucket_name}-${var.environment}-${random_string.suffix.result}"
}