# main.tf
module "vpc" {
  source = "./modules/vpc"
}

module "security_group" {
  source        = "./modules/security_group"
  petclinic_vpc = "vpc-08a37125a882814c3"
  vpc_id        = module.vpc.vpc_id
  name          = "petclinic_sg"
  ingress_rules = [
    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["148.101.252.23/32"]
    },
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
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







