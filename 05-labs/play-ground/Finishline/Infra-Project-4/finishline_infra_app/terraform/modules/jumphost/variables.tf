#============================================================
#  Project Variables
#============================================================

variable "project_name" {
  description = "The name of the project"
  type        = string

  validation {
    condition = can(regex(
      "^[a-zA-Z][a-zA-Z0-9-]{2,20}[a-zA-Z0-9]$", var.project_name
    ))
    error_message = "Project name must be 4-24 chars, start with letter, lowercase alphanumeric and hyphens only."
  }
}

variable "environment" {
  description = "The environment for the VPC"
  type        = string

  validation {
    condition = can(regex(
      "^[a-zA-Z][a-zA-Z0-9-]{2,20}[a-zA-Z0-9]$", var.environment
    ))
    error_message = "Environment must be 4-24 chars, start with letter, lowercase alphanumeric and hyphens only."
  }
}

variable "manage_by" {
  description = "Whether to manage the VPC by Terraform"
  type        = bool
}

variable "availability_zone" {
  description = "The availability zone for the public subnet"
  type        = list(string)
}

#============================================================
# Jumphost Security Group Variables
#============================================================
variable "vpc_id" {
  description = "The ID of the VPC for the jumphost"
  type        = string
}
variable "jumphost_security_group_name" {
  description = "The name of the jumphost security group"
  type        = string
  default     = ""
}
variable "jumphost_instance_type" {
  description = "The instance type for the jumphost"
  type        = string
}

variable "jumphost_subnet_id" {
  description = "The ID of the subnet for the jumphost"
  type        = string
}

variable "key_pair_name" {
  description = "The name of the key pair for the jumphost"
  type        = string
}
