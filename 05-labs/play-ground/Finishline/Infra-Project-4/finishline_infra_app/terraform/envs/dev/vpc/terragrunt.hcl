#============================================================
#  VPC Module - Development Environment
#============================================================

include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules//vpc"
}

inputs = {
  project_name    = "finishline-infra"
  environment     = "development"
  managed_by      = true
  aws_region      = "us-east-1"

  vpc_cidr             = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  availability_zone    = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnet_cidr   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidr  = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]

  # Key Pair Configuration
  key_name              = "finishline-key"
  key_algorithm         = "RSA"
  rsa_bits              = 4096
  private_key_directory = "${get_terragrunt_dir()}"
  private_key_filename  = "finishline-key.pem"

  computed_tags   = {}
}
