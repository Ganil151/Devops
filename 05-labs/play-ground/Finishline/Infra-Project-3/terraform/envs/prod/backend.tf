# =============================================================================
# Backend Configuration: prod Environment
# Finish Line 2026 Infrastructure
# Assignment: §28, §101 - S3 backend with state locking
# =============================================================================

terraform {
  backend "s3" {
    bucket         = "finishline-infra"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "finishline-infra-locks"
  }
}
