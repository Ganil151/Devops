variable "aws_region" {
  default = "us-east-1"
}

variable "environment" {
  default = "dev"
}

module "../../../shared/versions.tf" {}
module "../../../shared/providers.tf" {}

module "networking" {
  source = "../../modules/networking"

  vpc_cidr              = "10.0.0.0/16"
  public_subnets_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  availability_zones    = ["us-east-1a", "us-east-1b"]
  environment           = var.environment
}

module "eks" {
  source = "../../modules/eks"

  cluster_name = "${var.environment}-petclinic-cluster"
  vpc_id       = module.networking.vpc_id
  subnet_ids   = module.networking.private_subnets
  environment  = var.environment
}

module "rds" {
  source = "../../modules/rds"

  identifier  = "${var.environment}-petclinic-db"
  vpc_id      = module.networking.vpc_id
  subnet_ids  = module.networking.private_subnets
  password    = "CHANGE_ME_IN_PRODUCTION" # Use Secrets Manager!
  environment = var.environment
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

module "secrets" {
  source      = "../../modules/secrets"
  environment = var.environment
}

module "monitoring" {
  source      = "../../modules/monitoring"
  environment = var.environment
}
