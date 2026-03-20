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
  default     = {}
}

#============================================================
#  IAM Variables
#============================================================
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "is_eks_cluster_enabled" {
  description = "Whether to enable EKS cluster resources"
  type        = bool
  default     = false
}

variable "is_eks_role_enabled" {
  description = "Whether to enable EKS cluster IAM role"
  type        = bool
  default     = false
}

variable "is_eks_nodegroup_role_enabled" {
  description = "Whether to enable EKS nodegroup IAM role"
  type        = bool
  default     = false
}

variable "eks_oidc_url" {
  description = "EKS OIDC provider URL (e.g., https://oidc.eks.us-east-1.amazonaws.com/id/XXXXXXXXXXXXX)"
  type        = string
  default     = ""
}

variable "eks_oidc_namespace" {
  description = "Kubernetes namespace for the service account"
  type        = string
  default     = "default"
}

variable "eks_oidc_service_account" {
  description = "Kubernetes service account name"
  type        = string
  default     = ""
}

variable "oidc_thumbprint" {
  description = "Thumbprint for the OIDC provider"
  type        = string
  default     = ""
}

#============================================================
#  S3 Access Variables
#============================================================
variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket to grant access to"
  type        = string
  default     = ""
}

variable "s3_prefix" {
  description = "S3 bucket prefix/path to grant access to"
  type        = string
  default     = ""
}

variable "s3_access_type" {
  description = "Type of S3 access: read, write, or readwrite"
  type        = string
  default     = "read"

  validation {
    condition     = contains(["read", "write", "readwrite"], var.s3_access_type)
    error_message = "s3_access_type must be one of: read, write, or readwrite."
  }
}

#============================================================
#  Karpenter Variables
#============================================================
variable "is_karpenter_enabled" {
  description = "Whether to enable Karpenter resources (controller role and node role)"
  type        = bool
  default     = false
}

variable "karpenter_namespace" {
  description = "Kubernetes namespace for Karpenter controller"
  type        = string
  default     = "karpenter"
}

variable "karpenter_service_account" {
  description = "Kubernetes service account name for Karpenter controller"
  type        = string
  default     = "karpenter"
}

variable "karpenter_cluster_name" {
  description = "EKS cluster name for Karpenter (defaults to cluster_name)"
  type        = string
  default     = ""
}

variable "karpenter_node_instance_profile_name" {
  description = "IAM instance profile name for Karpenter nodes"
  type        = string
  default     = ""
}

variable "enable_deterministic_naming" {
  description = "Use deterministic naming without random suffix (set to true for production)"
  type        = bool
  default     = false
}
