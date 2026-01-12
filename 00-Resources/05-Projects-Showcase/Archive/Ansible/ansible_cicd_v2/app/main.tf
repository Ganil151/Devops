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

module "sg" {
  source        = "../modules/security_group"
  vpc_id        = module.vpc.vpc_id
  project_name  = var.project_name
  ingress_rules = var.ingress_rules
  egress_rules  = var.egress_rules
}

module "keys" {
  source   = "../modules/keys"
  key_name = var.key_name
}

module "master_instance" {
  source                      = "../modules/ec2"
  ami                         = var.ami
  key_name                    = var.key_name
  project_name                = "${var.project_name}-Server"
  instance_type               = var.instance_type
  subnet_id                   = element(module.vpc.public_subnet_ids, 0)
  user_data                   = file("${path.module}/scripts/Terraform-Server.sh")
  user_data_replace_on_change = var.user_data_replace_on_change
  security_group_ids          = [module.sg.cicd_sg]
}

module "s3" {
  source      = "../modules/s3"
  bucket_name = var.bucket_name
}