# =============================================================================
# Variables: staging Environment
# =============================================================================

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "finishline-infra"
}

variable "environment" {
  description = "The environment name"
  type        = string
  default     = "staging"
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = "us-east-1"
}
