#============================================================
#  Project Variables
#============================================================
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, stage, prod)"
  type        = string
}

variable "managed_by" {
  description = "Team managing this resource"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "computed_tags" {
  description = "Additional tags to apply"
  type        = map(string)
  default     = {}
}
#============================================================
# VPC Variables
#============================================================
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}
variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnet_cidr" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidr" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

#============================================================
# NACL Variables
#============================================================
variable "ingress_rules" {
  description = "List of ingress rules for NACL"
  type = list(object({
    rule_no     = number
    from_port   = number
    to_port     = number
    protocol    = string
    action      = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules for NACL"
  type = list(object({
    rule_no     = number
    from_port   = number
    to_port     = number
    protocol    = string
    action      = string
    cidr_blocks = list(string)
  }))
  default = []
}

