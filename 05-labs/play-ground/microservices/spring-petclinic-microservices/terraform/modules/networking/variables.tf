variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "public_subnets_cidrs" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnets_cidrs" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}
