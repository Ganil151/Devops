# =============================================================================
# General Variables
# =============================================================================

variable "project_name" {
  description = "The name of the project (used in resource naming and tags)"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,20}$", var.project_name))
    error_message = "Project name must be 3-21 characters, start with a letter, and contain only lowercase letters, numbers, and hyphens."
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

variable "availability_zone" {
  description = "The availability zone for the jumphost instance (e.g., us-east-1a)"
  type        = string
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9][a-z]$", var.availability_zone))
    error_message = "Availability zone must be in format like 'us-east-1a'."
  }
}

# =============================================================================
# EC2 Instance Configuration
# =============================================================================

variable "ami_id" {
  description = "The AMI ID for the EC2 instance. Leave empty to use Amazon Linux 2023 x86_64 (default)"
  type        = string
  default     = ""

  validation {
    condition     = var.ami_id == "" || can(regex("^ami-[0-9a-f]{8,17}$", var.ami_id))
    error_message = "AMI ID must be empty or match pattern 'ami-xxxxxxxx'."
  }
}

variable "instance_type" {
  description = "The EC2 instance type for the jumphost"
  type        = string
  default     = "t3.micro"
  validation {
    condition     = can(regex("^t[23]\\.(micro|small|medium|large)$", var.instance_type))
    error_message = "Instance type must be t2 or t3 family (micro to large)."
  }
}

variable "root_volume_size" {
  description = "The size of the root EBS volume in GB"
  type        = number
  default     = 20
  validation {
    condition     = var.root_volume_size >= 10 && var.root_volume_size <= 500
    error_message = "Root volume size must be between 10 and 500 GB."
  }
}

variable "root_volume_iops" {
  description = "The IOPS for the gp3 root volume"
  type        = number
  default     = 3000
  validation {
    condition     = var.root_volume_iops >= 3000 && var.root_volume_iops <= 16000
    error_message = "gp3 volume IOPS must be between 3000 and 16000."
  }
}

# =============================================================================
# Network Configuration
# =============================================================================

variable "public_subnet_ids" {
  description = "List of public subnet IDs. The first subnet will be used for the jumphost"
  type        = list(string)
  validation {
    condition     = length(var.public_subnet_ids) >= 1
    error_message = "At least one public subnet ID must be provided."
  }
}

variable "security_group_id" {
  description = "The ID of the security group allowing SSH access (restricted to home IP CIDRs)"
  type        = string
  validation {
    condition     = can(regex("^sg-[0-9a-f]{8,17}$", var.security_group_id))
    error_message = "Security group ID must match pattern 'sg-xxxxxxxx'."
  }
}

# =============================================================================
# IAM & Authentication
# =============================================================================

variable "key_name" {
  description = "The name of the EC2 key pair for SSH access"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,255}$", var.key_name))
    error_message = "Key name must be 1-255 characters, alphanumeric with underscores and hyphens."
  }
}

variable "iam_instance_profile_name" {
  description = "The name of the IAM instance profile for EKS authentication via RBAC"
  type        = string
  default     = null
}

# =============================================================================
# User Data Script
# =============================================================================

variable "user_data_base64" {
  description = "Base64-encoded user data script for installing tools (aws-cli v2, kubectl, helm, kustomize, mysql-client)"
  type        = string
  default     = null

  validation {
    condition     = var.user_data_base64 == "" || can(base64decode(var.user_data_base64))
    error_message = "user_data_base64 must be a valid base64-encoded string or empty."
  }
}

# =============================================================================
# Tags
# =============================================================================

variable "additional_tags" {
  description = "Additional tags to merge with default tags"
  type        = map(string)
  default     = {}
}