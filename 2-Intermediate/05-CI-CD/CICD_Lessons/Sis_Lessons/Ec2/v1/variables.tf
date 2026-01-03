variable "key_name" {
  description = "SSH key name"
  type        = string
  default     = "aws_key_pair.key_pair.key_name"
}

variable "ami" {
  description = "Amazon Linux 2023 AMI"
  type        = string
  default     = "ami-08a6efd148b1f7504"
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t3.micro"
}

variable "security_group_id" {
  description = "Instance security group"
  type        = string
  default     = "aws_security_group.allow_ssh_http.id"
}
