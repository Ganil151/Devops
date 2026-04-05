# Variable Definitions for S3 Bucket Module

variable "project_name" {
  description = "The name of the project"
  type        = string
  
  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 20
    error_message = "Project name must be between 1 and 20 characters."
  }
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  default     = "development"
  
  validation {
    condition = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable S3 bucket encryption"
  type        = bool
  default     = true
}

variable "lifecycle_enabled" {
  description = "Enable S3 lifecycle management"
  type        = bool
  default     = true
}

variable "transition_to_ia_days" {
  description = "Number of days to transition to Standard-IA"
  type        = number
  default     = 30
}

variable "transition_to_glacier_days" {
  description = "Number of days to transition to Glacier"
  type        = number
  default     = 90
}

variable "transition_to_deep_archive_days" {
  description = "Number of days to transition to Deep Archive"
  type        = number
  default     = 365
}

variable "noncurrent_version_expiration_days" {
  description = "Number of days to expire noncurrent versions"
  type        = number
  default     = 90
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}