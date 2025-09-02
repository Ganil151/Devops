# main.tf
module "vpc" {
  source = "./modules/vpc"
}

module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
  petclinic_vpc = "${var.project_name}-sg"

}
module "key_pair" {
  source   = "./modules/key_pair"
  key_name = "sis_key_pair"

}

module "ec2_instances" {
  source                 = "./modules/ec2_instances"
  subnet_id              = module.vpc.subnet_id
  key_name               = module.key_pair.key_name
  vpc_security_group_ids = [module.security_group.security_group_id]

}







