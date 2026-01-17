# -----------------------------------------------------------------------------
# Name: Module Usage Example
# Description: Demonstrates how to call a module with parameters.
# -----------------------------------------------------------------------------

# 1. Calling a Local Module
module "vpc_networking" {
  source = "./modules/vpc"
  
  vpc_cidr = "10.0.0.0/16"
  region   = "us-east-1"
}

# 2. Calling a Remote Module (GitHub)
module "security_group" {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group"

  name        = "web-server-sg"
  description = "Security group for user-service with custom ports open within VPC"
  vpc_id      = module.vpc_networking.vpc_id
  
  # Module inputs
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

# 3. Output from Module
output "vpc_id" {
  value = module.vpc_networking.vpc_id
}
