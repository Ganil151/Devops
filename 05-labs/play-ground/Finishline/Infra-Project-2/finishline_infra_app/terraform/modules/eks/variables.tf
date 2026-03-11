#========================================================
#  Project Variables
#========================================================
variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = ""
}

variable "environment" {
  description = "The environment name"
  type        = string
  default     = ""
}

variable "managedBy" {
  description = "The team or individual managing the resources"
  type        = string
  default     = ""
}

#========================================================
#  IAM Variables
#========================================================
variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = ""
}

variable "additional_tags" {
  description = "Additional tags for the IAM resources"
  type        = map(string)
  default     = {}
}

variable "is_role_enabled" {
  description = "Whether the IAM role is enabled"
  type        = bool
  default     = false
}
      
variable "is_eks_nodegroup_role_enabled" {
  description = "Whether the nodegroup role is enabled"
  type        = bool
  default     = false
}

variable "is_eks_cluster_enabled" {
  description = "Whether the EKS cluster is enabled"
  type        = bool
  default     = false
}

variable "eks_oidc_url" {
  description = "The OIDC issuer URL from the EKS cluster"
  type        = string
  default     = ""
}

variable "oidc_thumbprint" {
  description = "The OIDC thumbprint list"
  type        = list(string)
  default     = []
}

variable "oidc_namespace" {
  description = "The Kubernetes namespace for OIDC"
  type        = string
  default     = "kube-system"
}

variable "oidc_service_account" {
  description = "The Kubernetes service account for OIDC"
  type        = string
  default     = "aws-node"
}

variable "endpoint_private_access" {
  description = "Whether the EKS cluster has private endpoint access"
  type        = bool
  default     = false
}

variable "endpoint_public_access" {
  description = "Whether the EKS cluster has public endpoint access"
  type        = bool
  default     = false
}

variable "authentication_mode" {
  description = "The authentication mode for the EKS cluster"
  type        = string
  default     = "API"
}

variable "bootstrap_cluster_creator_admin_permissions" {
  description = "Whether to bootstrap cluster creator admin permissions"
  type        = bool
  default     = false
}

variable "node_role_arn" {
  description = "The ARN of the IAM role for the EKS node group"
  type        = string
  default     = ""
}

variable "iam_instance_profile_name" {
  description = "The name of the IAM instance profile for EKS nodes"
  type        = string
  default     = ""
}

variable "create_ondemand_nodegroup" {
  description = "Whether to create an on-demand node group"
  type        = bool
  default     = false
}

variable "desired_capacity_on_demand" {
  description = "The desired capacity for the on-demand node group"
  type        = number
  
}

variable "min_capacity_on_demand" {
  description = "The minimum capacity for the on-demand node group"
  type        = number
}

variable "max_capacity_on_demand" {
  description = "The maximum capacity for the on-demand node group"
  type        = number
}

variable "ami_type" {
  description = "The AMI type for the EKS node groups"
  type        = string
}

variable "cluster_disk_size" {
  description = "The disk size for the EKS cluster"
  type        = number
}

variable "ondemand_instance_types" {
  description = "The instance types for the on-demand node group"
  type        = list(string)
}

variable "ondemand_taints" {
  description = "The taints for the on-demand node group"
  type        = list(string)
}

variable "desired_capacity_on_spot" {
  description = "The desired capacity for the spot node group"
  type        = number
}

variable "min_capacity_on_spot" {
  description = "The minimum capacity for the spot node group"
  type        = number
}

variable "max_capacity_on_spot" {
  description = "The maximum capacity for the spot node group"
  type        = number
}

variable "spot_instance_types" {
  description = "The instance types for the spot node group"
  type        = list(string)
}

variable "spot_taints" {
  description = "The taints for the spot node group"
  type        = list(string)
}

variable "admin_role_arn" {
  description = "The ARN of the IAM role for the EKS admin group"
  type        = string
  default     = ""
}

variable "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.35"
}

variable "cluster_enabled_log_types" {
  description = "List of control plane log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

variable "cluster_role_arn" {
  description = "The ARN of the IAM role for the EKS cluster"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security group IDs for the EKS cluster"
  type        = list(string)
  default     = []
}

variable "is_eks_addons_enabled" {
  description = "Whether to enable EKS addons"
  type        = bool
  default     = false
}

variable "addons" {
  description = "Map of EKS addons to enable"
  type        = map(any)
  default     = {}
}