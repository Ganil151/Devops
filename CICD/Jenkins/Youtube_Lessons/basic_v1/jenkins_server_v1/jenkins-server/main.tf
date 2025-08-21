module "vpc" {
  source       = "../modules/vpc"
  vpc_id = var.vpc_id
  project_name = var.project_name
  vpc_cidr_block = var.subnet_cidr_block
  subnet_cidr_block = var.subnet_cidr_block
  enable_dns_support = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  map_public_ip_on_launch = var.map_public_ip_on_launch
}
