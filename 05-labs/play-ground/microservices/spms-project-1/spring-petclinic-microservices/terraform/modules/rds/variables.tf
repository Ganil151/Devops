variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "db_allocated_storage" {
  description = "Allocated storage"
  type        = number
}

variable "db_instance_class" {
  description = "Instance class"
  type        = string
}

variable "db_username" {
  description = "Admin username"
  type        = string
}

variable "db_password" {
  description = "Admin password"
  type        = string
  sensitive   = true
}
