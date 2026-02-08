variable "aws_region" {
  default = "us-east-1"
}

variable "environment" {
  default = "staging"
}



module "networking" {
  source = "../../modules/networking"

  vpc_cidr              = "10.1.0.0/16"
  public_subnets_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets_cidrs = ["10.1.10.0/24", "10.1.11.0/24"]
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
  password    = random_password.db_password.result
  environment = var.environment
}

resource "random_password" "db_password" {
  length  = 16
  special = false
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
  password    = random_password.db_password.result
}

module "monitoring" {
  source      = "../../modules/monitoring"
  environment = var.environment
}
