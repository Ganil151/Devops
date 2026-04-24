# =============================================================================
# Main Configuration: staging Environment
# Finish Line 2026 Infrastructure
# Root Module consuming all sub-modules
# =============================================================================

# VPC Module (Phase 1.1)
module "vpc" {
  source = "../../modules/vpc"

  project_name          = var.project_name
  environment           = var.environment
  manage_by             = var.manage_by
  vpc_cidr              = var.vpc_cidr
  enable_dns_hostnames  = var.enable_dns_hostnames
  enable_dns_support    = var.enable_dns_support
  availability_zones    = var.availability_zones
  public_subnets_cidrs  = var.public_subnets_cidrs
  private_subnets_cidrs = var.private_subnets_cidrs
}

# ALB Module (Phase 1.2)
module "alb" {
  source = "../../modules/alb"

  project_name      = var.project_name
  environment       = var.environment
  manage_by         = var.manage_by
  vpc_id            = module.vpc.main_vpc_id
  public_subnet_ids = module.vpc.main_public_subnet_ids
}

# EKS Module (Phase 1.3)
module "eks" {
  source = "../../modules/eks"

  project_name              = var.project_name
  environment               = var.environment
  manage_by                 = var.manage_by
  cluster_name              = var.cluster_name
  cluster_version           = var.cluster_version
  subnet_ids                = module.vpc.main_private_subnet_ids
  endpoint_private_access   = var.endpoint_private_access
  endpoint_public_access    = var.endpoint_public_access
  cluster_enabled_log_types = var.cluster_enabled_log_types
  instance_types            = var.instance_types
}

# IAM Module (Phase 1.4) - Must run after EKS for access entries
module "iam" {
  source = "../../modules/iam"

  project_name = var.project_name
  environment  = var.environment
  manage_by    = var.manage_by
  # Use module output to create proper dependency on EKS cluster
  cluster_name = module.eks.cluster_name
}

# Jumphost Module (Phase 1.5)
module "jumphost" {
  source = "../../modules/jumphost"

  project_name       = var.project_name
  environment        = var.environment
  manage_by          = var.manage_by
  vpc_id             = module.vpc.main_vpc_id
  subnet_id          = module.vpc.main_public_subnet_ids[0]
  home_ip_cidrs      = var.home_ip_cidrs
  instance_type      = var.jumphost_instance_type
  key_pair_name      = module.key_pair.key_name
  jumphost_role_name = module.iam.jumphost_role_name
}

# Key Pair Module
module "key_pair" {
  source = "../../modules/key_pair"

  project_name = var.project_name
  environment  = var.environment
  key_name     = var.key_name
}
