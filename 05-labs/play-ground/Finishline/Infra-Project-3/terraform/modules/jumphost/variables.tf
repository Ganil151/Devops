# =============================================================================
# Jumphost Module - Input Variables
# Finish Line 2026 Infrastructure
# =============================================================================

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment name"
  type        = string
}

variable "manage_by" {
  description = "ManagedBy tag value"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where jumphost will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Public subnet ID for jumphost"
  type        = string
}

variable "home_ip_cidrs" {
  description = "List of home IP CIDR blocks allowed for SSH access"
  type        = list(string)
  validation {
    condition     = length(var.home_ip_cidrs) > 0
    error_message = "At least one home IP CIDR is required for SSH access."
  }
}

variable "instance_type" {
  description = "EC2 instance type for jumphost"
  type        = string
  default     = "t3.small"
}

variable "key_pair_name" {
  description = "Name of the SSH key pair for jumphost access"
  type        = string
}

variable "jumphost_role_name" {
  description = "Name of the IAM role for jumphost EKS authentication"
  type        = string
}
