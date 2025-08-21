# Specify the required Terraform version and AWS provider configuration
terraform {
  required_version = ">=1.5.0" # Ensures that Terraform version 1.5.0 or higher is used

  required_providers {
    aws = {
      source  = "hashicorp/aws" # Specifies the AWS provider from HashiCorp
      version = "~> 6.0"       # Pins the AWS provider to version 6.x
    }
  }
}

# Provider configuration
provider "aws" {
  region = "us-east-1" # Sets the AWS region where resources will be created (e.g., US East (N. Virginia))
}

# Call the key_pair module to create an SSH key pair
module "key_pair" {
  source   = "./modules/key_pair" # Points to the local directory containing the key_pair module
  key_name = var.key_name         # Uses the variable `key_name` to define the name of the SSH key pair
}

# Call the security_group module to create security groups for each instance
module "security_group_1" {
  source = "./modules/security_group" # Points to the local directory containing the security_group module
  name   = "instance-1-sg"            # Defines the name of the security group for Client-1

  ingress_rules = [
    # Allow SSH from your PC (replace YOUR_IP with your public IP)
    {
      from_port   = 22               # Specifies the start port for the rule (SSH uses port 22)
      to_port     = 22               # Specifies the end port for the rule
      protocol    = "tcp"            # Specifies the protocol (TCP for SSH)
      cidr_blocks = ["148.101.225.207/32"] # Allows access only from this specific IP address (your PC's public IP)
    },
    # Allow SSH from Client-1 to Client-2
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      source_security_group_id = module.security_group_2.security_group_id # Allows access from Client-2's security group
    },
    # Allow SSH from Client-1 to Server
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      source_security_group_id = module.security_group_3.security_group_id # Allows access from Server's security group
    },
    # Allow HTTP (port 80) from anywhere
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] # Allows HTTP traffic from any IP address
    }
  ]
}

module "security_group_2" {
  source = "./modules/security_group" # Points to the local directory containing the security_group module
  name   = "instance-2-sg"            # Defines the name of the security group for Client-2

  ingress_rules = [
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      source_security_group_id = module.security_group_1.security_group_id # Allows access from Client-1's security group
    },
    # Allow SSH from Client-1 to Client-2
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      source_security_group_id = module.security_group_3.security_group_id # Allows access from Server's security group
    }
  ]
}

module "security_group_3" {
  source = "./modules/security_group" # Points to the local directory containing the security_group module
  name   = "instance-3-sg"            # Defines the name of the security group for Server

  ingress_rules = [
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      source_security_group_id = module.security_group_1.security_group_id # Allows access from Client-1's security group
    },
    # Allow SSH from Client-2 to Server
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      source_security_group_id = module.security_group_2.security_group_id # Allows access from Client-2's security group
    }
  ]
}

# Call the ec2_instance module to create 3 EC2 instances
module "ec2_instance_1" {
  source            = "./modules/ec2_instance" # Points to the local directory containing the ec2_instance module
  name              = "client-1"              # Defines the name of the EC2 instance
  ami               = var.ami                 # Specifies the AMI ID for the instance
  instance_type     = var.instance_type       # Specifies the instance type (e.g., t2.micro)
  key_name          = module.key_pair.key_name # Uses the SSH key pair created earlier
  security_group_id = module.security_group_1.security_group_id # Associates the instance with its security group
}

module "ec2_instance_2" {
  source            = "./modules/ec2_instance" # Points to the local directory containing the ec2_instance module
  name              = "client-2"              # Defines the name of the EC2 instance
  ami               = var.ami                 # Specifies the AMI ID for the instance
  instance_type     = var.instance_type       # Specifies the instance type (e.g., t2.micro)
  key_name          = module.key_pair.key_name # Uses the SSH key pair created earlier
  security_group_id = module.security_group_2.security_group_id # Associates the instance with its security group
}

module "ec2_instance_3" {
  source            = "./modules/ec2_instance" # Points to the local directory containing the ec2_instance module
  name              = "server"                # Defines the name of the EC2 instance
  ami               = var.ami                 # Specifies the AMI ID for the instance
  instance_type     = var.instance_type       # Specifies the instance type (e.g., t2.micro)
  key_name          = module.key_pair.key_name # Uses the SSH key pair created earlier
  security_group_id = module.security_group_3.security_group_id # Associates the instance with its security group
}




# Explanation of Key Sections
# Terraform Block:
# Specifies the minimum Terraform version and the AWS provider version.
# Ensures compatibility between Terraform and the AWS provider.
# Provider Configuration:
# Configures the AWS region where resources will be deployed.
# Key Pair Module:
# Creates an SSH key pair for secure access to EC2 instances.
# The key pair is reused across all instances.
# Security Group Modules:
# Define ingress rules for each instance to control inbound traffic.
# Rules include:
# Allowing SSH access from your PC (specific IP address).
# Allowing inter-instance communication (e.g., Client-1 ↔ Client-2, Client-1 ↔ Server).
# Allowing HTTP traffic from anywhere.
# EC2 Instance Modules:
# Create three EC2 instances (client-1, client-2, and server).
# Each instance is associated with a specific security group and uses the same SSH key pair.