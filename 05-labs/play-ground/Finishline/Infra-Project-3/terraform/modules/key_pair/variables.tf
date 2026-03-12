# =============================================================================
# Key Pair Module - Input Variables
# Finish Line 2026 Infrastructure
# =============================================================================

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment name"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "finishline-key-pair"
}

variable "manage_by" {
  description = "The entity managing the key pair"
  type        = string
}
