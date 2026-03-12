# =============================================================================
# IAM Module - Input Variables
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

variable "manage_by" {
  description = "ManagedBy tag value"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster for access mapping"
  type        = string
}
