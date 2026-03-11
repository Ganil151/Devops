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

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket for OIDC policy"
  type        = string
  default     = ""
}

variable "s3_access_type" {
  description = "The type of S3 access (read, write, readwrite)"
  type        = string
  default     = "read"
}

variable "s3_prefix" {
  description = "The S3 prefix for scoped access"
  type        = string
  default     = ""
}
