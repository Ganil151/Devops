module "vpc" {
  source = "../../modules/vpc"

  environment           = var.environment
  vpc_cidr              = var.vpc_cidr
  public_subnets_cidrs  = var.public_subnets_cidrs
  private_subnets_cidrs = var.private_subnets_cidrs
  availability_zones    = var.availability_zones
}

module "eks" {
  source = "../../modules/eks"

  environment        = var.environment
  private_subnet_ids = module.vpc.private_subnet_ids
  cluster_version    = var.cluster_version
}

module "rds" {
  source = "../../modules/rds"

  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  db_allocated_storage = var.db_allocated_storage
  db_instance_class    = var.db_instance_class
  db_username          = var.db_username
  db_password          = random_password.db_password.result
}

resource "random_password" "db_password" {
  length  = 16
  special = true
}

module "ecr" {
  source = "../../modules/ecr"

  repository_names = [
    "petclinic-api-gateway",
    "petclinic-customers-service",
    "petclinic-vets-service",
    "petclinic-visits-service"
  ]
}
