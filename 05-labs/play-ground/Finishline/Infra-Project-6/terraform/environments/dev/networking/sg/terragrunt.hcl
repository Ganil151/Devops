#============================================================
#  Terragrunt Configuration - Security Groups Module
#============================================================
include {
  path = find_in_parent_folders("root.hcl")
}

# Dependency on VPC module
dependency "vpc" {
  config_path = "../vpc"
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../../modules/networking/sg"
}

inputs = {
  project_name  = "finishline-infra-app"
  environment   = "dev"
  managed_by    = "finishline-infra-team"
  aws_region    = "us-east-1"

  # Security Group Configuration
  security_group_name        = "main-security-groups"
  security_group_description = "Security groups for finishline infrastructure"

  # VPC Reference
  vpc_id = dependency.vpc.outputs.vpc_id

  # Basic Ingress Rules (allow all from within VPC)
  ingress_rules = [
    {
      description = "Allow all traffic from VPC"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["10.0.0.0/16"]
    }
  ]

  # Basic Egress Rules (allow all outbound)
  egress_rules = [
    {
      description = "Allow all outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  # EKS-specific ingress rules (for worker nodes)
  eks_ingress_rules = []

  # Tags
  computed_tags = {}
}
