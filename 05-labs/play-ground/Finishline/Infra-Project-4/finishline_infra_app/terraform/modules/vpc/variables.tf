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
  description = "Whether to manage the VPC by Terraform"
  type        = bool
}

variable "availability_zone" {
  description = "The availability zone for the public subnet"
  type        = list(string)
}

#============================================================
#  VPC Variables
#============================================================
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  validation {
    condition     = can(regex("^([0-9]{1,3}[.]){3}[0-9]{1,3}/([0-9]|[1-2][0-9]|3[0-2])$", var.vpc_cidr))
    error_message = "VPC CIDR must be a valid CIDR block (e.g., 10.0.0.0/16)"
  }
}

variable "enable_dns_support" {
  description = "Whether to enable DNS support"
  type        = bool
}

variable "enable_dns_hostnames" {
  description = "Whether to enable DNS hostnames"
  type        = bool
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet"
  type        = list(string)
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet"
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

variable "private_key_filename" {
  description = "The filename for the private key"
  type        = string
}

variable "private_key_directory" {
  description = "The directory where the private key will be stored"
  type        = string
}

variable "computed_tags" {
  description = "Computed tags for the key pair"
  type        = map(string)
  default     = {}
}
