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

# 🦅 Primary Cluster (US-East-1)
module "eks_primary" {
  source = "../../modules/eks"
  providers = {
    aws = aws.primary
  }

  cluster_name       = "global-platform-primary"
  region             = "us-east-1"
  vpc_id             = module.vpc_primary.vpc_id
  private_subnet_ids = module.vpc_primary.private_subnets
}

# 🦅 Secondary Cluster (EU-West-1)
module "eks_secondary" {
  source = "../../modules/eks"
  providers = {
    aws = aws.secondary
  }

  cluster_name       = "global-platform-secondary"
  region             = "eu-west-1"
  vpc_id             = module.vpc_secondary.vpc_id
  private_subnet_ids = module.vpc_secondary.private_subnets
}

# 🌐 Global Accelerator (The Traffic Director)
# Routes traffic to US or EU based on latency.
resource "aws_globalaccelerator_accelerator" "global_entry" {
  provider        = aws.primary
  name            = "global-platform-accelerator"
  ip_address_type = "IPV4"
  enabled         = true

  attributes {
    flow_logs_enabled = false
  }
}

# Listener (Port 80/443)
resource "aws_globalaccelerator_listener" "http" {
  provider        = aws.primary
  accelerator_arn = aws_globalaccelerator_accelerator.global_entry.id
  client_affinity = "NONE"
  protocol        = "TCP"

  port_range {
    from_port = 80
    to_port   = 80
  }
}

# Endpoint Group (US-East-1)
resource "aws_globalaccelerator_endpoint_group" "us_east_1" {
  provider     = aws.primary
  listener_arn = aws_globalaccelerator_listener.http.id
  
  endpoint_region = "us-east-1"

  # We need the load balancer ARN here, but it's created by Kubernetes later!
  # This is the "Chicken-and-Egg" problem of IaC + K8s.
  # Solution: Use Terraform to create the NLB? No, K8s creates the NLB via Ingress Controller.
  # Solution: We will output the GA ARN and manually attach the ALB/NLB ARN later, 
  # OR use the 'aws_lb' data source after K8s runs. 
  # For now, we leave the group empty or use a placeholder if allowed.
  # AWS Global Accelerator allows empty endpoint groups.
}

# Endpoint Group (EU-West-1)
resource "aws_globalaccelerator_endpoint_group" "eu_west_1" {
  provider     = aws.primary
  listener_arn = aws_globalaccelerator_listener.http.id
  
  endpoint_region = "eu-west-1"
}
