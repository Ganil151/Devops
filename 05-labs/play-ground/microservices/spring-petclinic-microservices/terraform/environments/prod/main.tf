variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

module "networking" {
  source = "../../modules/networking"

  environment           = var.environment
  vpc_cidr              = "10.1.0.0/16"
  public_subnets_cidrs  = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  private_subnets_cidrs = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"]
  availability_zones    = ["us-east-1a", "us-east-1b", "us-east-1c"]
  single_nat_gateway    = false # HA Networking
}

module "eks" {
  source = "../../modules/eks"

  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  cluster_version    = "1.31"
  desired_size       = 3
  max_size           = 10
  min_size           = 3
  instance_types     = ["t3.large"]
}

module "rds" {
  source = "../../modules/rds"

  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  eks_cluster_sg_id  = module.eks.cluster_security_group_id
  password           = random_password.db_password.result
  instance_class     = "db.r5.large"
  allocated_storage  = 100
  multi_az           = true # HA Database
}

resource "random_password" "db_password" {
  length  = 24
  special = true
}

module "ec2_bastion" {
  source = "../../modules/ec2"

  environment      = var.environment
  vpc_id           = module.networking.vpc_id
  public_subnet_id = module.networking.public_subnet_ids[0]
  key_name         = "petclinic-prod-key"
  allowed_ssh_cidr = ["203.0.113.0/24"] # Example corporate IP
}

module "monitoring" {
  source = "../../modules/monitoring"

  environment   = var.environment
  cluster_name  = module.eks.cluster_name
  db_identifier = "${var.environment}-petclinic-db"
}
