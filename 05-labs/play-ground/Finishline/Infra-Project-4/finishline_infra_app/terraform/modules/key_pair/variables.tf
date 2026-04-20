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

variable "managed_by" {
  description = "Whether to manage the key pair by Terraform"
  type        = bool
  default     = true
}

variable "availability_zone" {
  description = "The availability zone for the public subnet"
  type        = list(string)
}

#============================================================
#  Key Pair Variables
#============================================================
variable "key_name" {
  description = "The name of the key pair"
  type        = string
}

variable "key_algorithm" {
  description = "The algorithm for the key pair"
  type        = string
}

variable "rsa_bits" {
  description = "The number of bits for the RSA key"
  type        = number
}

variable "file_permission" {
  description = "The file permission for the private key"
  type        = string
  default     = "0600"
}

#============================================================
#  Key Pair Local Variables
#============================================================
variable "computed_private_key_filename" {
  description = "The filename for the computed private key"
  type        = string
  default     = ""
}

variable "private_key_filename" {
  description = "The filename for the private key"
  type        = string
}

variable "computed_private_key_path" {
  description = "The path for the computed private key"
  type        = string
  default     = ""
}

variable "private_key_directory" {
  description = "The directory where the private key will be stored"
  type        = string
}

variable "computed_tags" {
  description = "Computed tags for the key pair"
  type        = map(string)
}
