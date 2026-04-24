#============================================================
#  Project Variables
#============================================================
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, stage, prod)"
  type        = string
}

variable "managed_by" {
  description = "Team managing this resource"
  type        = string
  default     = "finishline-infra-team"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "computed_tags" {
  description = "Additional tags to apply"
  type        = map(string)
  default     = {}
}

#============================================================
#  KMS Specific Variables
#============================================================
variable "description" {
  description = "Description of the KMS key"
  type        = string
  default     = "KMS key for encrypting EKS cluster secrets"
}

variable "deletion_window_in_days" {
  description = "Number of days before the KMS key is deleted"
  type        = number
  default     = 10
}

variable "enable_key_rotation" {
  description = "Enable key rotation for the KMS key"
  type        = bool
  default     = true
}

variable "policy" {
  description = "KMS key policy (leave empty for default policy)"
  type        = string
  default     = ""
}
