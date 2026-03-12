# =============================================================================
# Bootstrap Module - Input Variables
# Finish Line 2026 Infrastructure
# =============================================================================

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment name"
  type        = string
}

variable "manage_by" {
  description = "ManagedBy tag value"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{2,62}[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be 3-63 chars, lowercase, start/end with letter/number."
  }
}

variable "region" {
  description = "AWS region for state bucket"
  type        = string
  default     = "us-east-1"
}
