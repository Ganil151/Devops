variable "project_name" {}

# VPC
variable "vpc_id" {
  description = "The VPC ID where the security group will be created"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_cidr_block" {
  description = "CIDR block for subnets"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "map_public_ip_on_launch" {
  description = "Map public IP on launch for public subnets"
  type        = bool
  default     = true
}




# # Security Group
variable "security_group_ids" {
  description = "A list of security group IDs for the EC2 instance"
  type        = list(string)
}


# # Keys
variable "key_name" {
  description = "The name of the key pair to associate with the EC2 instance"
  type        = string
}

# # EC2

variable "ami_name_pattern" {
  description = "The name pattern of the AMI to use for the EC2 instance"
  type        = string
}

variable "ami_virtualization_type" {
  description = "The virtualization type of the AMI to use for the EC2 instance"
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

variable "user_data" {
  description = "The user data to pass to the EC2 instance"
  type        = string

}
variable "user_data_replace_on_change" {
  description = "Whether to replace the user data if it changes"
  type        = bool
}

