variable "project_name" {}

# VPC
variable "vpc_id" {
  description = "The VPC ID where the security group will be created"
  type        = string
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "enable_dns_support" {}
variable "enable_dns_hostnames" {}
variable "map_public_ip_on_launch" {}

# Security Group
variable "security_group_id" {
  description = "A list of security group IDs for the EC2 instance"
  type        = list(string)
}

# Keys
variable "key_name" {
  description = "The name of the key pair to associate with the EC2 instance"
  type        = string
}

# EC2

variable "ami" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}
variable "instance_type" {
  description = "The type of EC2 instance to run"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the EC2 instance will be created"
  type        = string
}

variable "user_data_replace_on_change" {
  description = "Whether to replace the user data if it changes"
  type        = bool
}



