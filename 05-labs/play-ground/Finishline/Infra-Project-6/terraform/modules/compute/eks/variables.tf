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
  default     = "us-east-1"
}

variable "computed_tags" {
  description = "Additional tags to apply"
  type        = map(string)
  default     = {}
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

variable "cluster_role_arn" {
  description = "ARN of the IAM role for the EKS cluster"
  type        = string
  default     = ""
}

variable "cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "cluster_enabled_log_types" {
  description = "List of log types to enable for the EKS cluster"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "subnets" {
  description = "List of subnets for the EKS cluster"
  type        = list(string)
  default     = []
}

variable "endpoint_private_access" {
  description = "Whether to enable private access for the EKS cluster endpoint"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether to enable public access for the EKS cluster endpoint"
  type        = bool
  default     = false
}

variable "security_group_ids" {
  description = "List of security group IDs for the EKS cluster"
  type        = list(string)
  default     = []
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks that can access the EKS cluster public endpoint"
  type        = list(string)
  default     = []
}

#============================================================
#  EKS Security & Encryption Variables
#============================================================
variable "kms_key_arn" {
  description = "ARN of the KMS key for encrypting EKS secrets"
  type        = string
  default     = ""
}

#============================================================
#  EKS Access Configuration Variables
#============================================================
variable "authentication_mode" {
  description = "Authentication mode for the EKS cluster (API_AND_CONFIG_MAP, API, CONFIG_MAP)"
  type        = string
  default     = "API_AND_CONFIG_MAP"

  validation {
    condition     = contains(["API_AND_CONFIG_MAP", "API", "CONFIG_MAP"], var.authentication_mode)
    error_message = "authentication_mode must be one of: API_AND_CONFIG_MAP, API, or CONFIG_MAP."
  }
}

variable "bootstrap_cluster_creator_admin_permissions" {
  description = "Whether to bootstrap cluster creator admin permissions"
  type        = bool
  default     = true
}

variable "cluster_admin_principal_arns" {
  description = "Map of principal ARNs to grant cluster admin access"
  type        = map(string)
  default     = {}
}

variable "cluster_admin_kubernetes_groups" {
  description = "List of Kubernetes groups to associate with cluster admin principals"
  type        = list(string)
  default     = []
}

variable "node_group_role_arn" {
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

#============================================================
#  EKS Node Group Variables
#============================================================
variable "is_eks_nodegroup_role_enabled" {
  description = "Whether to enable EKS nodegroup IAM role"
  type        = bool
  default     = false
}

variable "is_eks_nodegroup_enabled" {
  description = "Whether to enable EKS nodegroup"
  type        = bool
  default     = false
}

variable "node_group_name" {
  description = "Name of the EKS node group"
  type        = string
  default     = "default-node-group"
}

variable "node_group_subnets" {
  description = "List of subnets for the EKS node group"
  type        = list(string)
  default     = []
}

variable "node_group_ami_type" {
  description = "AMI type for the EKS node group (AL2_x86_64, AL2_ARM_64, BOTTLEROCKET_x86_64, BOTTLEROCKET_ARM_64)"
  type        = string
  default     = "AL2_x86_64"
}

variable "node_group_instance_types" {
  description = "List of instance types for the EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_group_capacity_type" {
  description = "Capacity type for the EKS node group (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"
}

variable "node_group_disk_size" {
  description = "Disk size in GB for the EKS node group"
  type        = number
  default     = 20
}

variable "node_group_scaling_config" {
  description = "Scaling configuration for the EKS node group"
  type = object({
    desired_size = number
    min_size     = number
    max_size     = number
  })
  default = null
}

variable "node_group_update_config" {
  description = "Update configuration for the EKS node group"
  type = object({
    max_unavailable = number
  })
  default = null
}

variable "node_group_labels" {
  description = "Labels to apply to the EKS node group"
  type        = map(string)
  default     = {}
}

variable "node_group_tags" {
  description = "Tags to apply to the EKS node group"
  type        = map(string)
  default     = {}
}

variable "node_group_taints" {
  description = "Taints to apply to the EKS node group"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

variable "node_group_timeouts" {
  description = "Timeouts for EKS node group operations"
  type = object({
    create = string
    update = string
    delete = string
  })
  default = {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

variable "node_group_launch_template_id" {
  description = "ID of the launch template to use for the EKS node group"
  type        = string
  default     = ""
}

variable "node_group_version" {
  description = "Version of the launch template for the EKS node group"
  type        = string
  default     = null
}

#============================================================
#  EKS Addons Configuration Variables
#============================================================
variable "is_node_addons_enabled" {
  description = "Whether to enable EKS addons"
  type        = bool
  default     = false
}

variable "is_bootstrap_addons_enabled" {
  description = "Whether to enable bootstrap addons"
  type        = bool
  default     = false
}

variable "addons" {
  description = "Map of EKS addons to configure"
  type = map(object({
    version              = string
    configuration_values = optional(string)
  }))
  default = {}
}
