variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "devsecops"
}

variable "key_pair_name" {
  description = "Name of the AWS key pair for EC2 instances"
  type        = string
}