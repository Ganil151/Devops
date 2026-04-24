# =============================================================================
# EKS Module Variables
# Module: eks
# Assignment Reference: Finish Line 2026 §74, §75, §76, §79
# - EKS Cluster with Managed Node Groups
# - Exactly 2x t3.medium nodes
# - Bottlerocket AMI
# =============================================================================

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "The name of the project (used in resource naming and tags)"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,20}$", var.project_name))
    error_message = "Project name must be 3-21 characters, start with a letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod", "sandbox"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, sandbox."
  }
}

variable "manage_by" {
  description = "The entity responsible for managing this resource"
  type        = string
  default     = "Terraform"
}

variable "aws_region" {
  description = "The AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

# -----------------------------------------------------------------------------
# EKS Cluster Configuration
# Assignment: §74, §75 (EKS Cluster)
# -----------------------------------------------------------------------------

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,30}$", var.cluster_name))
    error_message = "Cluster name must be 3-31 characters, start with a letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.31"
  validation {
    condition     = can(regex("^1\\.(2[8-9]|3[0-5])$", var.cluster_version))
    error_message = "Kubernetes version must be 1.28 or higher."
  }
}

variable "cluster_role_arn" {
  description = "The ARN of the IAM role for the EKS cluster"
  type        = string
  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/", var.cluster_role_arn))
    error_message = "Cluster role ARN must be a valid IAM role ARN."
  }
}

variable "is_eks_cluster_enabled" {
  description = "Whether to enable the EKS cluster"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Cluster Access Configuration
# -----------------------------------------------------------------------------

variable "authentication_mode" {
  description = "The authentication mode for the EKS cluster (CONFIG_MAP, API, or API_AND_CONFIG_MAP)"
  type        = string
  default     = "CONFIG_MAP"
  validation {
    condition     = contains(["CONFIG_MAP", "API", "API_AND_CONFIG_MAP"], var.authentication_mode)
    error_message = "Authentication mode must be CONFIG_MAP, API, or API_AND_CONFIG_MAP."
  }
}

variable "bootstrap_cluster_creator_admin_permissions" {
  description = "Whether to bootstrap cluster creator admin permissions"
  type        = bool
  default     = true
}

variable "admin_role_arn" {
  description = "The ARN of an additional IAM role to grant cluster admin access"
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# Cluster Logging Configuration
# -----------------------------------------------------------------------------

variable "cluster_enabled_log_types" {
  description = "The log types to enable for the EKS cluster"
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
  validation {
    condition = alltrue([
      for log in var.cluster_enabled_log_types :
      contains(["api", "audit", "authenticator", "controllerManager", "scheduler"], log)
    ])
    error_message = "Log types must be one of: api, audit, authenticator, controllerManager, scheduler."
  }
}

# -----------------------------------------------------------------------------
# VPC Configuration
# -----------------------------------------------------------------------------

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster and node groups (private subnets recommended)"
  type        = list(string)
  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 subnet IDs must be provided for high availability."
  }
}

variable "security_group_ids" {
  description = "List of security group IDs for the EKS cluster"
  type        = list(string)
  default     = []
}

variable "endpoint_private_access" {
  description = "Whether to enable private API endpoint access"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether to enable public API endpoint access"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Node Group Configuration
# Assignment: §74, §75, §76, §79 (2x t3.medium, Bottlerocket AMI)
# -----------------------------------------------------------------------------

variable "is_eks_node_group_enabled" {
  description = "Whether to enable the EKS node group"
  type        = bool
  default     = true
}

variable "node_role_arn" {
  description = "The ARN of the IAM role for the EKS node group"
  type        = string
  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/", var.node_role_arn))
    error_message = "Node role ARN must be a valid IAM role ARN."
  }
}

# On-Demand Node Group
variable "desired_capacity_on_demand" {
  description = "The desired capacity for the on-demand node group (assignment requires exactly 2)"
  type        = number
  default     = 2
  validation {
    condition     = var.desired_capacity_on_demand >= 1
    error_message = "On-demand desired capacity must be at least 1."
  }
}

variable "min_capacity_on_demand" {
  description = "The minimum capacity for the on-demand node group"
  type        = number
  default     = 1
}

variable "max_capacity_on_demand" {
  description = "The maximum capacity for the on-demand node group"
  type        = number
  default     = 4
}

variable "ondemand_instance_types" {
  description = "The instance types for the on-demand node group (assignment requires t3.medium)"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "ondemand_taints" {
  description = "Optional taints for the on-demand node group"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

# Spot Node Group (Optional)
variable "desired_capacity_spot" {
  description = "The desired capacity for the spot node group"
  type        = number
  default     = 0
}

variable "min_capacity_spot" {
  description = "The minimum capacity for the spot node group"
  type        = number
  default     = 0
}

variable "max_capacity_spot" {
  description = "The maximum capacity for the spot node group"
  type        = number
  default     = 2
}

variable "spot_instance_types" {
  description = "The instance types for the spot node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "spot_taints" {
  description = "Optional taints for the spot node group"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

# -----------------------------------------------------------------------------
# EKS Addons Configuration
# -----------------------------------------------------------------------------

variable "is_eks_addons_enabled" {
  description = "Whether to enable EKS addons"
  type        = bool
  default     = true
}

variable "addons" {
  description = "Map of EKS addons to deploy with version and optional service_account_role_arn"
  type = map(object({
    version                  = string
    service_account_role_arn = optional(string, "")
    configuration_values     = optional(string, null)
  }))
  default = {
    coredns = {
      version                  = "v1.11.1-eksbuild.9"
      service_account_role_arn = ""
      configuration_values     = null
    }
    kube-proxy = {
      version                  = "v1.31.0-eksbuild.1"
      service_account_role_arn = ""
      configuration_values     = null
    }
    vpc-cni = {
      version                  = "v1.18.1-eksbuild.3"
      service_account_role_arn = ""
      configuration_values     = null
    }
  }
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "additional_tags" {
  description = "Additional tags to merge with default tags"
  type        = map(string)
  default     = {}
}
