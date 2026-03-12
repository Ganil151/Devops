# =============================================================================
# EKS Module - Input Variables
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
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the cluster"
  type        = string
  default     = "1.31"
}

variable "subnet_ids" {
  description = "List of subnet IDs for EKS cluster and node group"
  type        = list(string)
}

variable "endpoint_private_access" {
  description = "Whether to enable private access to EKS endpoint"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether to enable public access to EKS endpoint"
  type        = bool
  default     = true
}

variable "cluster_enabled_log_types" {
  description = "List of control plane logging types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

variable "instance_types" {
  description = "Instance types for node group (assignment: t3.medium)"
  type        = list(string)
  default     = ["t3.medium"]
}
