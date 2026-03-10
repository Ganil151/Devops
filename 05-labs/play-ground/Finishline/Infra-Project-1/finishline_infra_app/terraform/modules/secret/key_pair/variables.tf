# =============================================================================
# Key Pair Module Variables
# Module: secret/key_pair
# Assignment Reference: Finish Line 2026 §71, §73 (Terraform-managed SSH keypairs)
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
# Key Pair Configuration
# -----------------------------------------------------------------------------

variable "key_name" {
  description = "The name for the EC2 key pair (must be unique per region)"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,255}$", var.key_name))
    error_message = "Key name must be 1-255 characters, containing only alphanumeric characters, underscores, and hyphens."
  }
}

variable "key_algorithm" {
  description = "The algorithm for key generation (RSA or ED25519)"
  type        = string
  default     = "RSA"
  validation {
    condition     = contains(["RSA", "ED25519"], var.key_algorithm)
    error_message = "Key algorithm must be either 'RSA' or 'ED25519'."
  }
}

variable "rsa_bits" {
  description = "The number of bits for RSA key (2048, 3072, or 4096)"
  type        = number
  default     = 4096
  validation {
    condition     = contains([2048, 3072, 4096], var.rsa_bits)
    error_message = "RSA key size must be 2048, 3072, or 4096 bits."
  }
}

# -----------------------------------------------------------------------------
# Local File Configuration
# -----------------------------------------------------------------------------

variable "private_key_filename" {
  description = "Custom filename for the private key. If empty, uses key_name.pem"
  type        = string
  default     = ""
}

variable "private_key_directory" {
  description = "Directory where the private key will be stored"
  type        = string
  default     = "."
}

variable "file_permission" {
  description = "File permissions for the private key file (octal)"
  type        = string
  default     = "0400"
  validation {
    condition     = can(regex("^0[0-7]{3}$", var.file_permission))
    error_message = "File permission must be in octal format (e.g., 0400, 0600)."
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

# -----------------------------------------------------------------------------
# Computed Local Values (optional overrides)
# -----------------------------------------------------------------------------

variable "computed_private_key_filename" {
  description = "Pre-computed private key filename (optional override)"
  type        = string
  default     = ""
}

variable "computed_private_key_path" {
  description = "Pre-computed private key path (optional override)"
  type        = string
  default     = ""
}

variable "computed_tags" {
  description = "Pre-computed tags (optional override)"
  type        = map(string)
  default     = {}
}
