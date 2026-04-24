# =============================================================================
# ALB Module Variables
# Module: alb
# Assignment Reference: Finish Line 2026 §31, §62, §65
# - Shared Application Load Balancer with IngressGroup mechanism
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
# Network Configuration
# -----------------------------------------------------------------------------

variable "vpc_id" {
  description = "The ID of the VPC where the ALB will be created"
  type        = string
  validation {
    condition     = can(regex("^vpc-[0-9a-f]{8,17}$", var.vpc_id))
    error_message = "VPC ID must match pattern 'vpc-xxxxxxxx'."
  }
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB placement (minimum 2 for HA)"
  type        = list(string)
  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "At least 2 public subnet IDs must be provided for high availability."
  }
}

# -----------------------------------------------------------------------------
# EKS Cluster Configuration (for IngressGroup)
# -----------------------------------------------------------------------------

variable "cluster_name" {
  description = "The name of the EKS cluster (used for ALB controller tagging)"
  type        = string
}

variable "ingress_group" {
  description = "The ingress group name for AWS LB Controller IngressGroup mechanism"
  type        = string
  default     = "finishline"
}

# -----------------------------------------------------------------------------
# ALB Configuration
# -----------------------------------------------------------------------------

variable "deletion_protection" {
  description = "Whether to enable deletion protection for the ALB"
  type        = bool
  default     = false
}

variable "idle_timeout" {
  description = "The idle timeout value in seconds"
  type        = number
  default     = 60
  validation {
    condition     = var.idle_timeout >= 1 && var.idle_timeout <= 4000
    error_message = "Idle timeout must be between 1 and 4000 seconds."
  }
}

variable "desync_mitigation_mode" {
  description = "Determines how the load balancer handles desync during request parsing"
  type        = string
  default     = "defensive"
  validation {
    condition     = contains(["none", "defensive", "strictest"], var.desync_mitigation_mode)
    error_message = "Desync mitigation mode must be one of: none, defensive, strictest."
  }
}

# -----------------------------------------------------------------------------
# SSL/TLS Configuration
# -----------------------------------------------------------------------------

variable "certificate_arn" {
  description = "The ARN of the SSL/TLS certificate for HTTPS listener (empty = HTTP only)"
  type        = string
  default     = ""
}

variable "ssl_policy" {
  description = "The SSL policy for the HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  validation {
    condition = contains([
      "ELBSecurityPolicy-TLS13-1-2-2021-06",
      "ELBSecurityPolicy-TLS13-1-1-2021-06",
      "ELBSecurityPolicy-TLS-1-2-2017-01",
      "ELBSecurityPolicy-TLS-1-2-Ext-2018-06",
      "ELBSecurityPolicy-FS-1-2-2019-08",
      "ELBSecurityPolicy-FS-1-1-2019-08"
    ], var.ssl_policy)
    error_message = "Invalid SSL policy. Must be a valid ELB security policy."
  }
}

# -----------------------------------------------------------------------------
# Access Logs Configuration
# -----------------------------------------------------------------------------

variable "enable_access_logs" {
  description = "Whether to enable access logs for the ALB"
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "The S3 bucket name for access logs"
  type        = string
  default     = ""
}

variable "access_logs_prefix" {
  description = "The S3 prefix for access logs"
  type        = string
  default     = "alb-logs"
}

# -----------------------------------------------------------------------------
# CloudWatch Alarms
# -----------------------------------------------------------------------------

variable "enable_5xx_alarm" {
  description = "Whether to enable CloudWatch alarm for 5XX errors"
  type        = bool
  default     = true
}

variable "alb_5xx_threshold" {
  description = "Threshold for 5XX error alarm (count per 5 minutes)"
  type        = number
  default     = 10
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "additional_tags" {
  description = "Additional tags to merge with default tags"
  type        = map(string)
  default     = {}
}
