# =============================================================================
# VPC Module Variables
# Module: vpc
# Assignment Reference: Finish Line 2026 §51, §55, §56, §57
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
  description = "The entity responsible for managing this resource"
  type        = string
  default     = "Terraform"
}

# -----------------------------------------------------------------------------
# VPC Configuration
# -----------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid CIDR block."
  }
}

variable "enable_dns_support" {
  description = "Whether to enable DNS support for the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Whether to enable DNS hostnames for the VPC"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Subnet Configuration
# Assignment: §51, §55 (Exactly 3 subnets across 3 AZs)
# -----------------------------------------------------------------------------

variable "availability_zones" {
  description = "List of availability zones for subnet distribution (must be 3)"
  type        = list(string)
  validation {
    condition     = length(var.availability_zones) == 3
    error_message = "Exactly 3 availability zones must be specified for high availability."
  }
}

variable "public_subnets_cidrs" {
  description = "CIDR blocks for public subnets (must be 3)"
  type        = list(string)
  validation {
    condition     = length(var.public_subnets_cidrs) == 3
    error_message = "Exactly 3 public subnet CIDRs must be provided."
  }
}

variable "private_subnets_cidrs" {
  description = "CIDR blocks for private subnets (must be 3)"
  type        = list(string)
  validation {
    condition     = length(var.private_subnets_cidrs) == 3
    error_message = "Exactly 3 private subnet CIDRs must be provided."
  }
}

# -----------------------------------------------------------------------------
# Optional Features
# -----------------------------------------------------------------------------

variable "enable_flow_logs" {
  description = "Whether to enable VPC Flow Logs"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Whether to use a single NAT Gateway (cost optimization)"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "additional_tags" {
  description = "Additional tags to merge with default tags"
  type        = map(string)
  default     = {}
}
