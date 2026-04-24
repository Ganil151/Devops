#============================================================
#  Security Group Module - Development Environment
#============================================================

include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules//sg"
}

inputs = {
  project_name    = "finishline-infra"
  environment     = "development"
  manage_by      = true
  availability_zone = ["us-east-1a", "us-east-1b", "us-east-1c"]

  vpc_id = dependency.vpc.outputs.vpc_id

  security_group_name        = "finishline-sg"
  security_group_description = "Main security group for Finishline infrastructure"

  ingress_rules = [
    {
      description = "Allow SSH from within VPC"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    },
    {
      description = "Allow HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "EKS worker node communication"
      from_port   = 1025
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
  ]

  egress_rules = [
    {
      description = "Allow all outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  enable_eks_rules = false
}

dependency "vpc" {
  config_path  = "../vpc"
  skip_outputs = true

  mock_outputs = {
    vpc_id = "vpc-0abc123def456789a"
  }
}

dependencies {
  paths = ["../vpc"]
}
