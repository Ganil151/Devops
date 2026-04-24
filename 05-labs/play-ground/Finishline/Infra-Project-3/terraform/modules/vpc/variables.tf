# =============================================================================
# VPC Module - Input Variables
# Finish Line 2026 Infrastructure
# =============================================================================

variable "project_name" {
  description = "The name of the project (used in resource naming and tags)"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,20}[a-z0-9]$", var.project_name))
    error_message = "Project name must be 4-24 chars, start with letter, lowercase alphanumeric and hyphens only."
  }
}

variable "environment" {
  description = "The environment name (dev/staging/prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "manage_by" {
  description = "The entity responsible for managing resources (ManagedBy tag)"
  type        = string
  default     = "Terraform"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC (recommended: 10.0.0.0/16)"
  type        = string
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "enable_dns_hostnames" {
  description = "Whether to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Whether to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "availability_zones" {
  description = "List of 3 availability zones for subnet distribution"
  type        = list(string)
  validation {
    condition     = length(var.availability_zones) == 3
    error_message = "Exactly 3 availability zones are required per assignment §51."
  }
}

variable "public_subnets_cidrs" {
  description = "CIDR blocks for 3 public subnets"
  type        = list(string)
  validation {
    condition     = length(var.public_subnets_cidrs) == 3
    error_message = "Exactly 3 public subnet CIDRs are required."
  }
}

variable "private_subnets_cidrs" {
  description = "CIDR blocks for 3 private subnets"
  type        = list(string)
  validation {
    condition     = length(var.private_subnets_cidrs) == 3
    error_message = "Exactly 3 private subnet CIDRs are required."
  }
}
