# Topic: Scalable Network Provisioning
# Description: Demonstrates modularity using the official AWS VPC module.

provider "aws" {
  region = var.region
}

# 🚀 Use validated modules instead of writing raw resources
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "prod-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true # Save cost in non-HA dev environments

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Team        = "Platform"
  }
}

variable "region" {
  default = "us-east-1"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
