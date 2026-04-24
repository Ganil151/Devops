#========================================================
#  Project Variables
#========================================================
variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = ""
}

variable "environment" {
  description = "The environment name"
  type        = string
  default     = ""
}

variable "managedBy" {
  description = "The team or individual managing the resources"
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = ""
}

#========================================================
#  VPC Variables
#========================================================

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = ""
}

variable "enable_dns_support" {
  description = "Whether to enable DNS support"
  type        = bool
}

variable "enable_dns_hostnames" {
  description = "Whether to enable DNS hostnames"
  type        = bool
}
  
variable "availability_zone" {
  description = "The availability zone"
  type        = list(string)
  default     = []
}

#========================================================
#  Subnets Variables
#========================================================
variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet"
  type        = list(string)
  default     = []
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet"
  type        = list(string)
  default     = []
}

variable "additional_tags" {
  description = "Additional tags for the resources"
  type        = map(string)
  default     = {}
}

#========================================================
#  Subnets Variables
#========================================================
variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = ""
}
