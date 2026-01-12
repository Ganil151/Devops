variable "project_name" {
  type        = string
  description = "Project name"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDRs"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDRs"
  default     = []
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "map_public_ip_on_launch" {
  type    = bool
  default = true
}
