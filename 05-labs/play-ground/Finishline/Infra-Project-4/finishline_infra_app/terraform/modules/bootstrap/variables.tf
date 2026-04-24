#============================================================
#  Project Variables
#============================================================

variable "project_name" {
  description = "The name of the project"
  type        = string

  validation {
    condition = can(regex(
      "^[a-zA-Z][a-zA-Z0-9-]{2,20}[a-zA-Z0-9]$", var.project_name
    ))
    error_message = "Project name must be 4-24 chars, start with letter, lowercase alphanumeric and hyphens only."
  }
}

variable "environment" {
  description = "The environment for the VPC"
  type        = string

  validation {
    condition = can(regex(
      "^[a-zA-Z][a-zA-Z0-9-]{2,20}[a-zA-Z0-9]$", var.environment
    ))
    error_message = "Environment must be 4-24 chars, start with letter, lowercase alphanumeric and hyphens only."
  }
}

variable "manage_by" {
  description = "Whether to manage the VPC by Terraform"
  type        = bool
}

variable "availability_zone" {
  description = "The availability zone for the public subnet"
  type        = list(string)
}

#============================================================
#  EKS Cluster Variables
#============================================================

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "The endpoint URL of the EKS cluster"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "The certificate authority data for the EKS cluster"
  type        = string
}

variable "bootstrap_enabled" {
  description = "Whether to enable bootstrap functionality"
  type        = bool
  default     = true
}

#============================================================
#  Namespace Variables
#============================================================

variable "namespaces" {
  description = "List of namespaces to create"
  type        = list(string)
  default     = ["dev", "staging", "prod"]
}

#============================================================
#  Helm Chart Variables
#============================================================

variable "helm_charts" {
  description = "Map of helm charts to deploy"
  type = map(object({
    repository = string
    version    = string
    namespace  = string
    values     = optional(list(string), [])
  }))
  default = {}
}
