variable "environment" {
  type        = string
  description = "Target environment for deployment (dev, staging, prod)"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "ERROR: Allowed environments are: dev, staging, prod."
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_name_suffix" {
  type    = string
  default = "app-node"
}
