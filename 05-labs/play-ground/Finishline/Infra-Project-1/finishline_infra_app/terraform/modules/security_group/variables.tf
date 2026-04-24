# =============================================================================
# Security Group Module Variables
# Module: security_group
# Assignment Reference: Finish Line 2026 §69, §70, §73 (SSH restriction to home IP CIDRs)
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
  description = "The entity responsible for managing this resource (e.g., Terraform, Platform-Team)"
  type        = string
  default     = "Terraform"
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------

variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  type        = string
  validation {
    condition     = can(regex("^vpc-[0-9a-f]{8,17}$", var.vpc_id))
    error_message = "VPC ID must match pattern 'vpc-xxxxxxxx'."
  }
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC (used for default internal rules)"
  type        = string
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid CIDR block."
  }
}

# -----------------------------------------------------------------------------
# Ingress Rules Configuration
# -----------------------------------------------------------------------------

variable "ingress_rules" {
  description = "List of ingress rules to apply to the security group"
  type = list(object({
    description = string
    name        = optional(string, "")
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = string # Comma-separated CIDR blocks
  }))

  validation {
    condition     = length(var.ingress_rules) > 0
    error_message = "At least one ingress rule must be provided."
  }

  validation {
    condition = alltrue([
      for rule in var.ingress_rules :
      rule.from_port >= 0 && rule.from_port <= 65535
    ])
    error_message = "Ingress rule from_port must be between 0 and 65535."
  }

  validation {
    condition = alltrue([
      for rule in var.ingress_rules :
      rule.to_port >= 0 && rule.to_port <= 65535
    ])
    error_message = "Ingress rule to_port must be between 0 and 65535."
  }

  validation {
    condition = alltrue([
      for rule in var.ingress_rules :
      rule.from_port <= rule.to_port
    ])
    error_message = "Ingress rule from_port must be less than or equal to to_port."
  }

  validation {
    condition = alltrue([
      for rule in var.ingress_rules :
      contains(["tcp", "udp", "icmp", "-1", "all"], rule.protocol)
    ])
    error_message = "Protocol must be one of: tcp, udp, icmp, -1, or all."
  }
}

# -----------------------------------------------------------------------------
# Egress Rules Configuration (Optional - defaults to allow all outbound)
# -----------------------------------------------------------------------------

variable "egress_rules" {
  description = "List of egress rules to apply. If empty, defaults to allow all outbound traffic."
  type = list(object({
    description = string
    name        = optional(string, "")
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = string # Comma-separated CIDR blocks
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Security Group Naming (Optional)
# -----------------------------------------------------------------------------

variable "security_group_name" {
  description = "Custom name for the security group. If empty, uses default naming convention."
  type        = string
  default     = ""
}

variable "security_group_description" {
  description = "Custom description for the security group. If empty, uses default description."
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "additional_tags" {
  description = "Additional tags to merge with default tags"
  type        = map(string)
  default     = {}
}
