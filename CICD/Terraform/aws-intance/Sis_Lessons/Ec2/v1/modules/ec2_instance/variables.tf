variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-01edd5711cfe3825c"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key name"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID"
  type        = string
}
