# 🌐 Global Capstone: Multi-Region Platform
# terraform apply -var-file="prod.tfvars"

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 1. Primary Region (US-East-1)
provider "aws" {
  alias  = "primary"
  region = "us-east-1"
}

# 2. Secondary Region (EU-West-1)
provider "aws" {
  alias  = "secondary"
  region = "eu-west-1"
}

# 🛠️ Module: Primary VPC (US)
module "vpc_primary" {
  source = "../../modules/vpc"
  providers = {
    aws = aws.primary
  }

  environment = "prod"
  region      = "us-east-1"
  vpc_cidr    = "10.1.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
}

# 🛠️ Module: Secondary VPC (EU)
module "vpc_secondary" {
  source = "../../modules/vpc"
  providers = {
    aws = aws.secondary
  }

  environment = "prod"
  region      = "eu-west-1"
  vpc_cidr    = "10.2.0.0/16" # NO Overlap allowed for peering!
  availability_zones = ["eu-west-1a", "eu-west-1b"]
}

# 🌉 Cross-Region Peering Connection (The Bridge)
# Active-Active requires a route between regions.
resource "aws_vpc_peering_connection" "global_mesh" {
  provider      = aws.primary
  vpc_id        = module.vpc_primary.vpc_id
  peer_vpc_id   = module.vpc_secondary.vpc_id
  peer_region   = "eu-west-1"
  auto_accept   = false # Cross-region requires manual accepters

  tags = {
    Name = "global-capstone-mesh"
  }
}

# Accepter in Secondary Region
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.secondary
  vpc_peering_connection_id = aws_vpc_peering_connection.global_mesh.id
  auto_accept               = true

  tags = {
    Name = "global-capstone-mesh-accepter"
  }
}

# 🛣️ Routes (The Traffic Flow)
# US -> EU
resource "aws_route" "primary_to_secondary" {
  provider                  = aws.primary
  route_table_id            = module.vpc_primary.public_route_table_id # Need to export this
  destination_cidr_block    = "10.2.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.global_mesh.id
}

# EU -> US
resource "aws_route" "secondary_to_primary" {
  provider                  = aws.secondary
  route_table_id            = module.vpc_secondary.public_route_table_id # Need to export this
  destination_cidr_block    = "10.1.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.global_mesh.id
}
