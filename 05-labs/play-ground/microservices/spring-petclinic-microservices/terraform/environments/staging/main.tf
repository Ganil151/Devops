variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

module "networking" {
  source = "../../modules/networking"

  environment           = var.environment
  vpc_cidr              = "10.2.0.0/16"
  public_subnets_cidrs  = ["10.2.1.0/24", "10.2.2.0/24"]
  private_subnets_cidrs = ["10.2.10.0/24", "10.2.11.0/24"]
  availability_zones    = ["us-east-1a", "us-east-1b"]
  single_nat_gateway    = true
}

module "eks" {
  source = "../../modules/eks"

  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  cluster_version    = "1.31"
  desired_size       = 2
  max_size           = 4
  min_size           = 2
  instance_types     = ["t3.medium"]
}

module "rds" {
  source = "../../modules/rds"

  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  eks_cluster_sg_id  = module.eks.cluster_security_group_id
  password           = random_password.db_password.result
  instance_class     = "db.t3.small"
  allocated_storage  = 20
}

resource "random_password" "db_password" {
  length  = 16
  special = true
}

module "monitoring" {
  source = "../../modules/monitoring"

  environment   = var.environment
  cluster_name  = module.eks.cluster_name
  db_identifier = "${var.environment}-petclinic-db"
}
