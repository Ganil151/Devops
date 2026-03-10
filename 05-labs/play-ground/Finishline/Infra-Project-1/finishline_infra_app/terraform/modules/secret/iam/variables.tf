# =============================================================================
# IAM Module Variables
# Module: secret/iam
# Assignment Reference: Finish Line 2026 §83, §84, §87, §89 (EKS IAM/RBAC integration)
# =============================================================================

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "The name of the project (used in resource naming and tags)"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,20}$", var.project_name))
    error_message = "Project name must be 3-21 characters, start with a letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "aws_region" {
  description = "The AWS region for resource deployment"
  type        = string
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be in format like 'us-east-1'."
  }
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod", "sandbox"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, sandbox."
  }
}

variable "manage_by" {
  description = "The entity responsible for managing this resource (e.g., Terraform, Platform-Team)"
  type        = string
  default     = "Terraform"
}

# -----------------------------------------------------------------------------
# EKS Cluster Configuration
# -----------------------------------------------------------------------------

variable "cluster_name" {
  description = "The name of the EKS cluster (used as name prefix for IAM resources)"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,30}$", var.cluster_name))
    error_message = "Cluster name must be 3-31 characters, start with a letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

# -----------------------------------------------------------------------------
# Feature Flags (Conditional Resource Creation)
# -----------------------------------------------------------------------------

variable "is_eks_role_enabled" {
  description = "Whether to enable the EKS cluster IAM role"
  type        = bool
  default     = true
}

variable "is_eks_nodegroup_role_enabled" {
  description = "Whether to enable the EKS node group IAM role"
  type        = bool
  default     = true
}

variable "is_eks_cluster_enabled" {
  description = "Whether to enable OIDC provider and OIDC IAM role (requires existing EKS cluster)"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# OIDC Provider Configuration
# -----------------------------------------------------------------------------

variable "eks_oidc_url" {
  description = "The OIDC issuer URL from the EKS cluster (e.g., https://oidc.eks.us-east-1.amazonaws.com/id/xxxxxxxx)"
  type        = string
  default     = ""
  validation {
    condition     = var.eks_oidc_url == "" || can(regex("^https://", var.eks_oidc_url))
    error_message = "EKS OIDC URL must start with 'https://' or be empty."
  }
}

variable "oidc_thumbprint" {
  description = "TLS thumbprints for the OIDC provider (default: AWS root CA)"
  type        = list(string)
  default     = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"] # AWS root CA
}

# -----------------------------------------------------------------------------
# OIDC Service Account Configuration (Least Privilege)
# -----------------------------------------------------------------------------

variable "oidc_service_account" {
  description = "The Kubernetes service account name that can assume the OIDC IAM role"
  type        = string
  default     = "aws-node"
}

variable "oidc_namespace" {
  description = "The Kubernetes namespace for the service account"
  type        = string
  default     = "kube-system"
}

# -----------------------------------------------------------------------------
# OIDC Policy Configuration
# -----------------------------------------------------------------------------

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket to scope the OIDC policy (REQUIRED for least privilege - must be specific bucket)"
  type        = string
  default     = ""
  validation {
    condition     = var.s3_bucket_arn != "" && can(regex("^arn:aws:s3:::", var.s3_bucket_arn))
    error_message = "S3 bucket ARN is required and must start with 'arn:aws:s3:::'."
  }
}

variable "s3_prefix" {
  description = "Optional S3 object prefix to restrict access to specific folder path within the bucket"
  type        = string
  default     = ""
}

variable "s3_access_type" {
  description = "Type of S3 access: 'read' (GetObject only), 'write' (GetObject, PutObject, DeleteObject), or 'readwrite' (GetObject, PutObject)"
  type        = string
  default     = "read"
  validation {
    condition     = contains(["read", "write", "readwrite"], var.s3_access_type)
    error_message = "S3 access type must be one of: read, write, readwrite."
  }
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "additional_tags" {
  description = "Additional tags to merge with default tags"
  type        = map(string)
  default     = {}
}
