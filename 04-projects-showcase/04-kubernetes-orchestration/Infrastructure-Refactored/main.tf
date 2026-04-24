# ============================================================================
# Terraform Configuration: EKS Cluster with Service Mesh
# ============================================================================
# Description: Production-ready EKS cluster with Istio service mesh
# Version: 1.0.0
# Last Updated: 2024
# ============================================================================

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

data "aws_availability_zones" "available" {
  state = "available"
  
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  cluster_config = {
    dev = {
      instance_types = ["t3.medium"]
      desired_size   = 2
      max_size       = 4
      min_size       = 1
    }
    staging = {
      instance_types = ["t3.large"]
      desired_size   = 3
      max_size       = 6
      min_size       = 2
    }
    production = {
      instance_types = ["t3.xlarge", "t3.2xlarge"]
      desired_size   = 5
      max_size       = 10
      min_size       = 3
    }
  }
  
  selected_config = lookup(local.cluster_config, var.environment, local.cluster_config.dev)
  
  common_tags = merge(
    var.tags,
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
  
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

module "networking" {
  source = "./modules/networking"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = local.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  enable_flow_logs     = var.enable_vpc_flow_logs
  
  tags = local.common_tags
}

module "eks" {
  source = "./modules/eks"

  project_name    = var.project_name
  environment     = var.environment
  cluster_version = var.eks_cluster_version
  
  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.private_subnet_ids
  
  instance_types = local.selected_config.instance_types
  desired_size   = local.selected_config.desired_size
  max_size       = local.selected_config.max_size
  min_size       = local.selected_config.min_size
  
  tags = local.common_tags
  
  depends_on = [module.networking]
}
