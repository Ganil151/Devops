variable "project_name_1" {
  description = "Master Server"
  type        = string
}
variable "project_name_2" {
  description = "Jenkins Server"
  type        = string
}
variable "project_name_3" {
  description = "Ansible Server"
  type        = string
}
variable "project_name_4" {
  description = "Eks Server"
  type        = string
}

# Vpc
variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}
variable "subnet_cidr_block" {
  description = "The cidr block of the subnet."
  type        = string
}
variable "vpc_cidr_block" {
  description = "The cidr block of the VPC."
  type        = string
}
variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}
variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}
variable "enable_dns_support" {
  description = "Enable DNS support"
  type        = bool
}
variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames"
  type        = bool
}
variable "map_public_ip_on_launch" {
  description = "Map a public IP address for the subnet instances"
  type        = bool
}

# Security Group
variable "ingress_rules" {
  description = "List of ingress ports to allow"
  type        = list(number)
}

variable "egress_rules" {
  description = "List of egress ports (not used directly in this example)"
  type        = list(number)
}

# Keys
variable "key_name" {
  description = "The key name to use for the instance"
  type        = string
}