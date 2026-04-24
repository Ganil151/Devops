# =============================================================================
# Backend Configuration: staging Environment
# =============================================================================

terraform {
  backend "s3" {
    bucket       = "finishline-infra-app-<replace-with-hash>"
    key          = "staging/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
