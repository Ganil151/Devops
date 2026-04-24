provider "aws" {
  region = var.region
}

# Data source for AMI
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Local naming logic
locals {
  full_instance_name = "${var.environment}-${var.instance_name_suffix}"
  
  common_tags = {
    Environment = var.environment
    Project     = "Terraform-Patterns-Lab"
  }
}

# Resource using data source and locals
resource "aws_instance" "example" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = "t3.micro"

  tags = merge(local.common_tags, {
    Name = local.full_instance_name
  })
}

output "ami_used" {
  value = data.aws_ami.latest_amazon_linux.id
}
