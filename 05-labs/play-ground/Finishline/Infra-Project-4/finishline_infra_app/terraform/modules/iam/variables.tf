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

variable "is_eks_nodegroup_role_enabled" {
  description = "A flag to enable or disable EKS nodegroup role creation"
  type        = bool
}

variable "is_role_enabled" {
  description = "A flag to enable or disable IAM role creation"
  type        = bool
}

variable "eks_oidc_url" {
  description = "The URL of the EKS OIDC provider"
  type        = string
  default     = ""
}

variable "oidc_thumbprint" {
  description = "The thumbprint of the EKS OIDC provider"
  type        = string
  default     = ""
}

variable "eks_oidc_namespace" {
  description = "The Kubernetes namespace for OIDC service account"
  type        = string
  default     = "kube-system"
}

variable "eks_oidc_service_account_name" {
  description = "The Kubernetes service account name for OIDC"
  type        = string
  default     = "aws-node"
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket for OIDC"
  type        = string
  default     = ""

  validation {
    condition     = var.s3_bucket_arn == "" || can(regex("^arn:aws:s3:::[a-z0-9-]+$", var.s3_bucket_arn))
    error_message = "S3 bucket ARN must be empty or a valid ARN format (arn:aws:s3:::bucket-name)"
  }
}

variable "s3_prefix" {
  description = "The prefix for S3 bucket objects"
  type        = string
  default     = ""
}

variable "s3_access_type" {
  description = "The type of access to S3 bucket for OIDC"
  type        = string
  default     = "read"

  validation {
    condition     = contains(["read", "write", "readwrite"], var.s3_access_type)
    error_message = "S3 access type must be 'read', 'write', or 'readwrite'"
  }
}
