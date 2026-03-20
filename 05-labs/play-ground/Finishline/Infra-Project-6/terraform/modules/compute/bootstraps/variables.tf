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
#  EKS Cluster Reference Variables
#============================================================
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint for the EKS cluster API server"
  type        = string
}

variable "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for the cluster CA"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "OIDC Identity Provider issuer URL for the EKS cluster"
  type        = string
}

variable "is_eks_nodegroup_enabled" {
  description = "Whether to enable EKS managed node group"
  type        = bool
}

variable "is_eks_nodegroup_role_enabled" {
  description = "Whether to enable EKS nodegroup IAM role"
  type        = bool
}

#============================================================
#  Node Group Variables
#============================================================
variable "node_group_name" {
  description = "Name of the EKS node group"
  type        = string
}

variable "node_group_instance_types" {
  description = "List of instance types for the node group"
  type        = list(string)
}

variable "node_group_capacity_type" {
  description = "Capacity type for the node group (ON_DEMAND or SPOT)"
  type        = string
}

variable "node_group_disk_size" {
  description = "Disk size in GB for the node group"
  type        = number
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
}

variable "node_group_subnets" {
  description = "List of subnets for the node group"
  type        = list(string)
}

variable "node_group_ami_type" {
  description = "AMI type for the node group (AL2_x86_64, AL2_x86_64_GPU, BOTTLEROCKET_x86_64, etc.)"
  type        = string
}

variable "node_group_launch_template_id" {
  description = "ID of a launch template to use for the node group"
  type        = string
}

variable "node_group_version" {
  description = "Version of the node group"
  type        = string
}

variable "node_group_labels" {
  description = "Labels to apply to the node group"
  type        = map(string)
}

variable "node_group_taints" {
  description = "Taints to apply to the node group"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
}

variable "node_group_scaling_config" {
  description = "Scaling configuration for the node group"
  type = object({
    desired_size = number
    min_size     = number
    max_size     = number
  })
}

variable "node_group_update_config" {
  description = "Update configuration for the node group"
  type = object({
    max_unavailable            = number
    max_unavailable_percentage = number
  })
}

variable "node_group_timeouts" {
  description = "Timeouts for node group operations"
  type = object({
    create = string
    update = string
    delete = string
  })
}

#============================================================
#  Node Group IAM Variables
#============================================================
variable "node_group_role_arn" {
  description = "ARN of the IAM role for the EKS node group"
  type        = string
}

variable "node_group_instance_profile_name" {
  description = "Name of the IAM instance profile for nodes"
  type        = string
}

#============================================================
#  Node Group Tags
#============================================================
variable "node_group_tags" {
  description = "Additional tags to apply to the node group"
  type        = map(string)
}

#============================================================
#  Bootstrap Addons Variables
#============================================================
variable "bootstrap_addons" {
  description = "Map of bootstrap addons to deploy"
  type        = map(any)
}

variable "is_bootstrap_addons_enabled" {
  description = "Whether to enable bootstrap addons"
  type        = bool
}

#============================================================
#  Karpenter Variables
#============================================================
variable "is_karpenter_enabled" {
  description = "Whether to enable Karpenter for auto-scaling"
  type        = bool
}

variable "karpenter_version" {
  description = "Version of Karpenter to install"
  type        = string
}

variable "karpenter_controller_role_arn" {
  description = "ARN of the IAM role for Karpenter controller (IRSA)"
  type        = string
}

variable "karpenter_node_role_arn" {
  description = "ARN of the IAM role for Karpenter nodes"
  type        = string
}

variable "karpenter_instance_profile_name" {
  description = "Name of the IAM instance profile for Karpenter nodes"
  type        = string
}
