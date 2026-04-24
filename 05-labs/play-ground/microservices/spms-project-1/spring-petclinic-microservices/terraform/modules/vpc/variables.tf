variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "public_subnets_cidrs" {
  description = "Public subnets CIDR blocks"
  type        = list(string)
}

variable "private_subnets_cidrs" {
  description = "Private subnets CIDR blocks"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}
