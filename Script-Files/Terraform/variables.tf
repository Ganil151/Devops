variable "aws_region" {
  description = "jenkins App instance Region"
  type        = string
}

variable "project_name" {
  description = "The Project Name"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "key_name" {
  description = "The Key pair name"
  type        = string
}

variable "user_data_replace_on_change" {
  description = "Replace the instance when user data changes"
  type        = bool
}

variable "user_data" {
  description = "User data script to run on the instance"
  type        = string
}

variable "ami_name_pattern" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

variable "ami_virtualization_type" {
  description = "The virtualization type for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the instance will be launched"
  type        = string
}

variable "subnet_cidr_block" {
  description = "The CIDR block for the subnet"
  type        = string
}

variable "security_group_id" {
  description = "A list of security group IDs for the EC2 instance"
  type        = list(string)
}

variable "enable_dns_support" {
  description = "Enable DNS support for the VPC"
  type        = bool
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames for the VPC"
  type        = bool
}

variable "map_public_ip_on_launch" {
  description = "Map public IP on launch for instances in the subnet"
  type        = bool
}

variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "ami_name_pattern" {
  type = string
}

variable "ami_virtualization_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "security_group_id" {
  type = list(string)
}

variable "subnet_id" {
  type = string
}

variable "user_data" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "subnet_cidr_block" {
  type = string
}

variable "enable_dns_support" {
  type = bool
}

variable "enable_dns_hostnames" {
  type = bool
}

variable "map_public_ip_on_launch" {
  type = bool
}

variable "user_data_replace_on_change" {
  type = bool
}

# VPC Module variables
variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "enable_nat_gateway" {
  type = bool
}

variable "enable_vpn_gateway" {
  type = bool
}

