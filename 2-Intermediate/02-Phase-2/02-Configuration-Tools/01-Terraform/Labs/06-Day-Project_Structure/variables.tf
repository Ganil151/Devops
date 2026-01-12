variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "staging"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Aws instance type"
  type = string
  default = "t2.micro"
}

variable "instance_count" {
  description = "Aws instance count"
  type = number
  default = 1  
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "owner" {
  description = "The owner"
  type        = string
  default     = "Gsmash"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring for EC2 instances"
  type        = bool
  default     = false
  
}

variable "associate_public_ip" {
  description = "Associate public IP address with EC2 instances"
  type        = bool
  default     = true
}

variable "instance_tags" {
  description = "Tags for EC2 instances"
  type = map(string)
  default = {}
  
}

variable "storage_size" {
  description = "Size of the root block device in GB"
  type        = number
  default     = 20
  
}

variable "allowed_cidr_blocks" {
  description = "List of allowed CIDR blocks"
  type = list(string)
  default = []
}