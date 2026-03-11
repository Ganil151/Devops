# =============================================================================
# Backend Configuration: prod Environment
# =============================================================================

terraform {
  backend "s3" {
    bucket       = "finishline-infra-app-<replace-with-hash>"
    key          = "prod/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
