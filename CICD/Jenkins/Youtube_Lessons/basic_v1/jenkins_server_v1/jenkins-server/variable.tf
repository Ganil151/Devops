variable "project_name" {}

# VPC
variable "vpc_id" {
  description = "The VPC ID where the security group will be created"
  type        = string
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block"{}
variable "enable_dns_support" {}
variable "enable_dns_hostnames" {}
variable "map_public_ip_on_launch" {}

# Security Group
variable "security_group_id" {
  description = "A list of security group IDs for the EC2 instance"
  type        = list(string)
}