# Networking Module

This module provisions a VPC with public and private subnets, NAT Gateway, and Internet Gateway.

## Usage

```hcl
module "networking" {
  source                = "../../modules/networking"
  vpc_cidr              = "10.0.0.0/16"
  public_subnets_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  availability_zones    = ["us-east-1a", "us-east-1b"]
  environment           = "dev"
}
```
