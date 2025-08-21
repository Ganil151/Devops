# modules\ec2_instance\variables.tf

variable "instance_type" {
  description = "The type of EC2 instance to launch"
  type        = string
}

variable "ami" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "The name of the SSH key pair"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to launch the instance in"
  type        = string
}

variable "security_group_id" {
  description = "The security group ID"
  type        = string
}

variable "user_data" {
  description = "The startup script for provisioning the instance"
  type        = string
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with the instance"
  type        = bool
  default     = true
}

variable "user_data_replace_on_change" {
  description = "Whether to replace user data on change"
  type        = bool
  default     = true
}
