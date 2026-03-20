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
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "computed_tags" {
  description = "Additional tags to apply"
  type        = map(string)
}

#============================================================
# EKS Variables
#============================================================
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "is_eks_cluster_enabled" {
  description = "Whether to enable EKS cluster resources"
  type        = bool
}

variable "is_eks_role_enabled" {
  description = "Whether to enable EKS cluster IAM role"
  type        = bool
  default     = false
}

variable "cluster_role_arn" {
  description = "ARN of the IAM role for the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
}

variable "cluster_enabled_log_types" {
  description = "List of log types to enable for the EKS cluster"
  type        = list(string)
}

variable "subnets" {
  description = "List of subnets for the EKS cluster"
  type        = list(string)
}

variable "endpoint_private_access" {
  description = "Whether to enable private access for the EKS cluster endpoint"
  type        = bool
}

variable "endpoint_public_access" {
  description = "Whether to enable public access for the EKS cluster endpoint"
  type        = bool
}

variable "security_group_ids" {
  description = "List of security group IDs for the EKS cluster"
  type        = list(string)
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks that can access the EKS cluster public endpoint"
  type        = list(string)
}

#============================================================
#  EKS Security & Encryption Variables
#============================================================
variable "kms_key_arn" {
  description = "ARN of the KMS key for encrypting EKS secrets"
  type        = string
}

#============================================================
#  EKS Access Configuration Variables
#============================================================
variable "authentication_mode" {
  description = "Authentication mode for the EKS cluster (API_AND_CONFIG_MAP, API, CONFIG_MAP)"
  type        = string

  validation {
    condition     = contains(["API_AND_CONFIG_MAP", "API", "CONFIG_MAP"], var.authentication_mode)
    error_message = "authentication_mode must be one of: API_AND_CONFIG_MAP, API, or CONFIG_MAP."
  }
}

variable "bootstrap_cluster_creator_admin_permissions" {
  description = "Whether to bootstrap cluster creator admin permissions"
  type        = bool
}

variable "cluster_admin_principal_arns" {
  description = "Map of principal ARNs to grant cluster admin access"
  type        = map(string)
}

variable "cluster_admin_kubernetes_groups" {
  description = "List of Kubernetes groups to associate with cluster admin principals"
  type        = list(string)
}

variable "nodegroup_role_arn" {
  description = "ARN of the IAM role used by nodegroups (for access entry)"
  type        = string
  default     = ""
}

#============================================================
#  EKS Upgrade Policy Variables
#============================================================
variable "enable_upgrade_policy" {
  description = "Whether to enable upgrade policy for the EKS cluster"
  type        = bool
  default     = false
}

variable "upgrade_policy_support_type" {
  description = "Support type for upgrade policy (STANDARD or EXTENDED)"
  type        = string

  validation {
    condition     = contains(["STANDARD", "EXTENDED"], var.upgrade_policy_support_type)
    error_message = "upgrade_policy_support_type must be one of: STANDARD or EXTENDED."
  }
  default = "STANDARD"
}

#============================================================
#  EKS Addons Variables
#============================================================
variable "bootstrap_self_managed_addons" {
  description = "Whether to bootstrap self-managed addons (set false to let EKS manage them)"
  type        = bool
  default     = false
}
