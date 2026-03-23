#============================================================
#  Key Pair Module - Development Environment
#============================================================

include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_terragrunt_dir()}/../../../../modules/security/key_pair"
}

inputs = {
  project_name = "finishline-infra-app"
  environment  = "dev"
  managed_by   = "finishline-infra-team"
  aws_region   = "us-east-1"

  # Key Pair Configuration
  key_name        = "finishline-infra-app-dev-key"
  key_algorithm   = "RSA"
  rsa_bits        = 4096

  # Private Key Storage Configuration
  # Store private key in dev environment root directory for easy access
  private_key_directory = "${get_terragrunt_dir()}/../../"
  private_key_filename  = "finishline-infra-app-dev-key.pem"
  file_permission       = "0600"

  computed_tags = {}

}
