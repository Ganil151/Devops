#!/bin/bash

set -e 

# Change Host Name
echo "Changing Host Name..."
sudo hostnamectl set-hostname "ansible-server"

# Install dependencies
echo "Installing dependencies..."
sudo yum update -y
sudo yum -y upgrade --releasever=2023.8.20250908
sudo yum install -y yum-utils device-mapper-persistent-data lvm2 ansible git python3 net-tools bind-utils

# Install Terraform 
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

# Verfiy Terraform installation
if ! command -v terraform &> /dev/null; then
    echo "Terraform installation failed."
    exit 1
fi

# Create Jenkins Directory
mkdir -p jenkins && cd ~/jenkins

# Create Modules in Jenkins Directory
touch providers.tf main.tf variables.tf data.tf security.tf

# Create Providers file
cat <<EOF > providers.tf
terraform {
  required_version = "~> 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket = "ansible-register"
    key    = "ansible/terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"

}
EOF

# Create Date file
cat <<EOF > data.tf
data "aws_ami" "amazonlinux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}


EOF

# Create Security file
cat <<EOF > security.tf
resource "aws_security_group" "cicd_sg" {
  name        = "cicd_sg_1_${var.project_name}"
  description = "Allow inbound/outbound traffic"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = "Allow port \${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cicd_sg_1"
  }
}
EOF

# Create Main file
cat <<EOF > main.tf
resource "aws_instance" "AnsibleServer" {
  ami           = data.aws_ami.amazonlinux2.id
  instance_type = "t3.small"
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [aws_security_group.cicd_sg_${var.project_name}.id]

  tags = {
    Name = "Ansible-Server"
  }
}
EOF

# Create Variables file
cat <<EOF > variables.tf
variable "project_name" {
  type        = string
  description = "Project Name"
  default     = "Jenkins"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
  default     = "cicd_vpc"
}

variable "key_name" {
  type        = string
  description = "Key Pair"
  default     = "cicd-keys"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID"
  default     = "cicd_subnet"
}

variable "ingress_rules" {
  type        = list(number)
  description = "List of ingress ports"
  default     = [22, 80, 443, 8080, 8090, 9000, 8081, 2479]
}

variable "egressrules" {
  type    = list(number)
  default = [25, 80, 443, 8080, 8090, 3306, 53]
}
EOF

# Verify File Creation
if [[ -f "providers.tf" && -f "main.tf" && -f "variables.tf" && -f "data.tf" && -f "security.tf" ]]; then
    echo "All Terraform files created successfully."
else
    echo "Failed to create one or more Terraform files."
    exit 1
fi

echo "Setup completed successfully."
