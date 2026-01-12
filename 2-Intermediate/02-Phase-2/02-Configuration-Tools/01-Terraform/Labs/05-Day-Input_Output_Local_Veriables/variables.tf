variable "environment" {
  description = "The name of the environment this infra resource belongs to."
  type        = string
  default = "dev"
}

variable "region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default = "us-east-1"
}

variable "bucket_name" {
  description = "The name of the channel."
  type        = string
  default = "demo_bucket"
}

