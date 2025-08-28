#!/bin/bash
set -e 

install_dependencies(){
  echo "Installing dependencies..."
  sudo yum update -y
  sudo yum install -y yum-utils
}

install_terraform(){
  echo "Installing Terraform..."
  sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
  sudo yum -y install terraform
}

change_hostname(){
  echo "Changing hostname..."
  sudo hostnamectl set-hostname "terraform-server"
}

configure_terraform(){
  echo "Configuring Terraform project..."
  mkdir -p ~/jenkins
  cd ~/jenkins
    
  touch provider.tf variables.tf main.tf security.tf data.tf
 
  cat <<EOF > provider.tf
  terraform {
  required_version = "~>1.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>6.0"
    }
  }

    backend "s3" {
      bucket = "terra-app-register"         
      key    = "jenkins/terraform.tfstate"
      region = "us-east-1"
    }
  }

  provider "aws" {
    region = "us-east-1"
  }

  resource "aws_dynamodb_table" "tf_lock" {
    name           = "terraform-lock"
    hash_key       = "LockID"
    read_capacity  = 3
    write_capacity = 3
    attribute {
      name = "LockID"
      type = "S"
    }
    tags = {
      Name = "Terraform Lock Table" #to destroy, add flag --lock=false

    }
    lifecycle {
      prevent_destroy = true #to destroy, change to false
    }
  }

EOF

  cat <<EOF > variables.tf
    variable "region" {
    type    = string
    default = "us-east-2"
  }
  variable "my_instance_type" {
    type    = string
    default = "t2.micro"
  }


  variable "my_key" {
    description = "AWS EC2 Key pair that needs to be associated with EC2 Instance"
    type        = string
    default     = "OhioKey"
  }

  variable "ingressrules" {
    type    = list(number)
    default = [22, 80, 443, 8080, 8090, 9000, 8081, 2479]
  }

  variable "egressrules" {
    type    = list(number)
    default = [25, 80, 443, 8080, 8090, 3306, 53]
  }

EOF

  cat <<EOF > main.tf
  resource "aws_instance" "Jenkinsserver" {
    ami                    = data.aws_ami.amazonlinux.id
    instance_type          = var.my_instance_type
    key_name               = var.my_key
    vpc_security_group_ids = [aws_security_group.vpc-ssh.id, aws_security_group.vpc-web.id]

    tags = {
      Name = "Jenkins-Server"
    }
  }
EOF

  cat <<EOF >security.tf
  # Create Security Group - SSH Traffic and other ports
  resource "aws_security_group" "web-traffic" {
    name = "My_Security_Group1"

    ingress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }


    tags = {
      "Name" = "My_SG1"
    }
  }

EOF
  cat <<EOF >data.tf
    data "aws_ami" "amazonlinux2" {
    most_recent = true

    filter {
      name   = "owner-alias"
      values = ["amazon"]
    }

    filter {
      name   = "name"
      values = ["amzn2-ami-hvm-*-x86_64-ebs"]
    }
  }
EOF 

}

# Main Execution
install_dependencies
install_terraform
change_hostname
configure_terraform

echo "Terraform setup complete. Run:"
echo "cd ~/jenkins && terraform init && terraform plan"
