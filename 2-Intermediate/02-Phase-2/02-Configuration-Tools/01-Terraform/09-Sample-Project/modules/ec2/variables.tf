variable "ami" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "The key name to use for the instance"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the EC2 instance will be created"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance to run"
  type        = string
}

variable "security_group_ids" {
  description = "The security group IDs to associate with the EC2 instance"
  type        = list(string)
}

variable "user_data" {
  description = "The user data to pass to the EC2 instance"
  type        = string
  default     = ""
}

variable "user_data_replace_on_change" {
  description = "Whether to replace the user data if it changes"
  type        = bool
  default     = true
}
