variable "name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_pair_name" {
  description = "AWS key pair name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "user_data" {
  description = "User data script"
  type        = string
  default     = ""
}

variable "server_type" {
  description = "Server type tag"
  type        = string
  default     = "General"
}