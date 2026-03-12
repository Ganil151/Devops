# =============================================================================
# Backend Configuration: dev Environment
# Finish Line 2026 Infrastructure
# Assignment: §28, §101 - S3 backend with state locking
# =============================================================================

terraform {
  backend "s3" {
    bucket       = "finishline-infra-app-ba3347ce"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
