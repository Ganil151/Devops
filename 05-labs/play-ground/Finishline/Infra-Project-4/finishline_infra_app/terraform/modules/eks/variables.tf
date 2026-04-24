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
# Network Variables
#============================================================
variable "vpc_id" {
  type        = string
  description = "VPC ID passed from VPC module output"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs passed from VPC module output"
}

#============================================================
#  IAM & CLUSTER Variables
#============================================================
variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "is_eks_role_enabled" {
  description = "A flag to enable or disable EKS role creation"
  type        = bool
}

variable "is_eks_cluster_enabled" {
  description = "A flag to enable or disable EKS cluster creation"
  type        = bool
}

variable "cluster_role_arn" {
  description = "The ARN of the IAM role for the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "The version of the EKS cluster"
  type        = string
}

variable "cluster_enabled_log_types" {
  description = "The types of logs to enable for the EKS cluster"
  type        = list(string)
}

variable "is_eks_addons_enabled" {
  description = "A flag to enable or disable EKS addons"
  type        = bool
}

variable "addons" {
  description = "The addons to install in the EKS cluster"
  type = map(object({
    version                  = string
    service_account_role_arn = string
  }))
}

variable "endpoint_private_access" {
  description = "Whether to enable private access for the EKS cluster endpoint"
  type        = bool
}

variable "endpoint_public_access" {
  description = "Whether to enable public access for the EKS cluster endpoint"
  type        = bool
}

variable "security_group_ids" {
  description = "The IDs of the security groups for the EKS cluster"
  type        = list(string)
}

