module "vpc" {
  source                  = "../modules/vpc"
  vpc_id                  = var.vpc_id
  project_name            = var.project_name
  vpc_cidr_block          = var.subnet_cidr_block
  subnet_cidr_block       = var.subnet_cidr_block
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

module "ec2" {
  source                      = "../modules/ec2"
  ami                         = var.ami
  key_name                    = var.key_name
  project_name                = var.project_name
  instance_type               = var.instance_type
  subnet_id                   = module.vpc.subnet_id
  user_data                   = file("${path.module}/jscript.sh")
  user_data_replace_on_change = var.user_data_replace_on_change
  vpc_security_group_id       = module.security_group.security_group_id
}
