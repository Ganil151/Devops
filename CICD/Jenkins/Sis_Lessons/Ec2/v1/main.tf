
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">=1.5.0"
}

provider "aws" {
  region = "us-east-1"
}

module "key_pair" {
  source   = "./modules/key_pair"
  key_name = var.key_name
}

module "security_group" {
  source = "./modules/security_group"
}

module "ec2_instance" {
  source            = "./modules/ec2_instance"
  ami               = var.ami
  instance_type     = var.instance_type
  key_name          = module.key_pair.key_name
  security_group_id = module.security_group.security_group_id
}
