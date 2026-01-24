module "vpc" {
  source                  = "../modules/vpc"
  vpc_id                  = var.vpc_id
  project_name            = var.project_name
  vpc_cidr_block          = var.vpc_cidr_block
  subnet_cidr_block       = var.subnet_cidr_block
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_subnet_cidrs    = var.private_subnet_cidrs
  map_public_ip_on_launch = var.map_public_ip_on_launch

}

module "sg" {
  source        = "../modules/sg"
  vpc_id        = module.vpc.vpc_id
  ingress_rules = var.ingress_rules
  egress_rules  = var.egress_rules
  project_name  = var.project_name
}

module "keys" {
  source   = "../modules/keys"
  key_name = var.key_name
}

module "s3" {
  source      = "../modules/s3"
  bucket_name = var.bucket_name
}

data "aws_ami" "amazon-linux" {
  most_recent = true
  owners      = ["amazon"]

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
  instance_type               = var.instance_type
  project_name                = "${var.project_name}-master"
  key_name                    = var.key_name
  user_data                   = file("${path.module}/scripts/master.sh")
  subnet_id                   = element(module.vpc.public_subnet_ids, 0)
  security_group_ids          = [module.sg.cicd_sg]
  user_data_replace_on_change = var.user_data_replace_on_change
}
