# Variable declarations moved to variables.tf

module "networking" {
  source = "../../modules/networking"

  environment           = var.environment
  vpc_cidr              = "10.0.0.0/16"
  public_subnets_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
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
  min_size           = 1
  instance_types     = ["t3.medium"]
}

module "rds" {
  source = "../../modules/rds"

  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  eks_cluster_sg_id  = module.eks.cluster_security_group_id
  password           = random_password.db_password.result
  instance_class     = "db.t3.micro"
  allocated_storage  = 20
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "ec2_bastion" {
  source = "../../modules/ec2"

  environment      = var.environment
  vpc_id           = module.networking.vpc_id
  public_subnet_id = module.networking.public_subnet_ids[0]
  key_name         = "petclinic-dev-key" # Assumes key exists
  allowed_ssh_cidr = ["0.0.0.0/0"]       # Restrict in production!
}

module "monitoring" {
  source = "../../modules/monitoring"

  environment   = var.environment
  cluster_name  = module.eks.cluster_name
  db_identifier = "${var.environment}-petclinic-db"
}

# Shared ECR repositories
module "ecr" {
  source = "../../modules/ecr"

  repository_names = [
    "petclinic-api-gateway",
    "petclinic-customers-service",
    "petclinic-vets-service",
    "petclinic-visits-service",
    "petclinic-admin-server",
    "petclinic-config-server",
    "petclinic-discovery-server"
  ]
}
