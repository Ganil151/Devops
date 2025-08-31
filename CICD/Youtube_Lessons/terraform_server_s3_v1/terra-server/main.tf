module "vpc" {
  source                  = "../modules/vpc"
  vpc_id                  = var.vpc_id
  project_name            = var.project_name
  vpc_cidr_block          = var.vpc_cidr_block
  subnet_cidr_block       = var.subnet_cidr_block
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_subnet_cidrs    = var.private_subnet_cidrs
  enable_dns_support      = var.enable_dns_support
  enable_dns_hostnames    = var.enable_dns_hostnames
  map_public_ip_on_launch = var.map_public_ip_on_launch
}

module "security_group" {
  source       = "../modules/security_group"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
}

module "keys" {
  source   = "../modules/keys"
  key_name = var.key_name
}

data "aws_ami" "amazon-linux" {
  most_recent = true
  owners      = ["amazon"] # Canonical

  filter {
    name   = "name"
    values = [var.ami_name_pattern]
    
  }

  filter {
    name   = "virtualization-type"
    values = [var.ami_virtualization_type]  
  }
}

module "master_instance" {
  source                      = "../modules/ec2"
  ami                         = data.aws_ami.amazon-linux.id
  key_name                    = var.key_name
  project_name                = "${var.project_name}-master-v2"
  instance_type               = var.instance_type
  subnet_id                   = element(module.vpc.public_subnet_ids, 0)
  user_data                   = file("${path.module}/scripts/terraform_setup.sh")
  user_data_replace_on_change = var.user_data_replace_on_change
  security_group_ids          = [module.security_group.security_group_id]
}

module "s3" {
  source       = "../modules/s3"
  project_name = var.project_name
}