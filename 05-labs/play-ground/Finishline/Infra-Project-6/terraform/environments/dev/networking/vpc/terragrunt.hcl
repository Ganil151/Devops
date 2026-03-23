#============================================================
#  Terragrunt Configuration - VPC Module
#============================================================
include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_terragrunt_dir()}/../../../../modules/networking/vpc"
}

inputs = {
  project_name  = "finishline-infra-app"
  environment   = "dev"
  managed_by    = "finishline-infra-team"
  aws_region    = "us-east-1"

  # VPC Configuration
  vpc_name           = "main-vpc"
  is_vpc_enabled     = true

  # Network Configuration
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  # Public Subnets
  public_subnet_cidr = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  # Private Subnets
  private_subnet_cidr = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]

  # Database Subnets (not used by this module - kept for reference)
  # database_subnets_cidrs = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]

  # NAT Gateway
  enable_nat_gateway     = true
  single_nat_gateway     = false
  enable_vpn_gateway     = false

  # DNS Configuration
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Tags
  computed_tags = {}
}
