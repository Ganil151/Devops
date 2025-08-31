module "vpc" {
  source                  = "../modules/vpc"
  project_name            = var.project_name
  vpc_cidr_block          = var.subnet_cidr_block
  subnet_cidr_block       = var.subnet_cidr_block
  enable_dns_support      = var.enable_dns_support
  enable_dns_hostnames    = var.enable_dns_hostnames
  map_public_ip_on_launch = var.map_public_ip_on_launch
}

module "security_group" {
  source       = "../modules/security-group"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

module "keys" {
  source   = "../modules/keys"
  key_name = var.key_name
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [var.ami_name_pattern]
  }

  filter {
    name   = [var.ami_virtualization_type]
    values = ["hvm"]
  }
}

module "ec2" {
  source                      = "../modules/ec2"
  ami                         = data.aws_ami.amazon-linux-2.id
  aws_region                  = var.aws_region
  instance_type               = var.instance_type
  subnet_id                   = module.vpc.subnet_id
  security_group_id           = [module.security_group.security_group_id]
  key_name                    = var.key_name
  user_data                   = file("${path.module}/script.sh")
  project_name                = var.project_name
  user_data_replace_on_change = var.user_data_replace_on_change
}
