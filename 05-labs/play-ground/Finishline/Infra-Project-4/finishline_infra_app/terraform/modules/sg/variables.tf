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
#  VPC Variables
#============================================================
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

#============================================================
#  Security Group Variables
#============================================================
variable "security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = ""
}

variable "ingress_rules" {
  description = "List of ingress rules for the security group"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "egress_rules" {
  description = "List of egress rules for the security group"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

#============================================================
# EKS Security Group Variables
#============================================================

variable "enable_eks_rules" {
  description = "Whether to enable EKS rules"
  type        = bool
  default     = false
}

variable "eks_cluster_security_group_id" {
  description = "The ID of the EKS cluster security group"
  type        = string
  default     = ""
}



