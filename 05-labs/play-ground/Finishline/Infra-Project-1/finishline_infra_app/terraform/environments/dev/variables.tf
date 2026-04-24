# =============================================================================
# Environment Variables: dev
# Project: Finish Line 2026 Infrastructure
# Assignment Reference: Finish Line 2026 §2, §21 (Target: us-east-1)
# Reporter: Joseph Ndzoh Dong
# Timeline: Feb 26, 2026 – March 2, 2026
# =============================================================================

variable "private_key_filename" {
  description = "Custom filename for the private key (default: key_name.pem)"
  type        = string
  default     = ""
}

variable "file_permission" {
  description = "File permissions for the private key"
  type        = string
  default     = "0400"
}

variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

# =============================================================================
# General Project Variables
# =============================================================================

variable "project_name" {
  description = "The name of the project (used in resource naming and tags)"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,20}$", var.project_name))
    error_message = "Project name must be 3-21 characters, start with a letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "aws_region" {
  description = "The AWS region for resource deployment"
  type        = string
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be in format like 'us-east-1'."
  }
}

variable "aws_account_id" {
  description = "The AWS account ID for resource deployment"
  type        = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "AWS account ID must be a 12-digit number."
  }
}

variable "environment" {
  description = "The environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "manage_by" {
  description = "The entity responsible for managing this infrastructure"
  type        = string
  default     = "Terraform"
}

# =============================================================================
# VPC Module Variables
# Reference: terraform/modules/vpc/
# Assignment: §51, §55, §56, §57 (3 subnets across 3 AZs)
# =============================================================================

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid CIDR block."
  }
}

variable "enable_dns_support" {
  description = "Whether to enable DNS support for the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Whether to enable DNS hostnames for the VPC"
  type        = bool
  default     = true
}

variable "availability_zones" {
  description = "List of availability zones for subnet distribution (must be 3)"
  type        = list(string)
  validation {
    condition     = length(var.availability_zones) == 3
    error_message = "Exactly 3 availability zones must be specified for high availability."
  }
}

variable "public_subnets_cidrs" {
  description = "CIDR blocks for public subnets (must be 3)"
  type        = list(string)
  validation {
    condition     = length(var.public_subnets_cidrs) == 3
    error_message = "Exactly 3 public subnet CIDRs must be provided."
  }
}

variable "private_subnets_cidrs" {
  description = "CIDR blocks for private subnets (must be 3)"
  type        = list(string)
  validation {
    condition     = length(var.private_subnets_cidrs) == 3
    error_message = "Exactly 3 private subnet CIDRs must be provided."
  }
}

# =============================================================================
# Security Group Module Variables
# Reference: terraform/modules/security_group/
# Assignment: §69, §70, §73 (SSH restricted to home IP CIDRs)
# =============================================================================

variable "ingress_rules" {
  description = "List of ingress rules for the security group"
  type = list(object({
    description = string
    name        = optional(string, "")
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = string
  }))
  validation {
    condition     = length(var.ingress_rules) > 0
    error_message = "At least one ingress rule must be provided."
  }
}

variable "egress_rules" {
  description = "List of egress rules for the security group (empty = allow all outbound)"
  type = list(object({
    description = string
    name        = optional(string, "")
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = string
  }))
  default = []
}

variable "additional_sg_tags" {
  description = "Additional tags for the security group"
  type        = map(string)
  default     = {}
}

variable "security_group_name" {
  description = "Custom name for the security group (default: project-environment-sg)"
  type        = string
  default     = ""
}

variable "security_group_description" {
  description = "Custom description for the security group"
  type        = string
  default     = ""
}

# =============================================================================
# Key Pair Module Variables
# Reference: terraform/modules/secret/key_pair/
# Assignment: §71, §73 (Terraform-managed SSH keypairs)
# =============================================================================

variable "key_name" {
  description = "The name of the EC2 key pair"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,255}$", var.key_name))
    error_message = "Key name must be 1-255 characters, alphanumeric with underscores and hyphens."
  }
}

variable "key_algorithm" {
  description = "The algorithm for key generation (RSA or ED25519)"
  type        = string
  default     = "RSA"
  validation {
    condition     = contains(["RSA", "ED25519"], var.key_algorithm)
    error_message = "Key algorithm must be either 'RSA' or 'ED25519'."
  }
}

variable "rsa_bits" {
  description = "The number of bits for RSA key (2048, 3072, or 4096)"
  type        = number
  default     = 4096
  validation {
    condition     = contains([2048, 3072, 4096], var.rsa_bits)
    error_message = "RSA key size must be 2048, 3072, or 4096 bits."
  }
}

variable "private_key_directory" {
  description = "Directory where the private key will be stored"
  type        = string
  default     = "."
}

# =============================================================================
# Jumphost (Bootstrap) Module Variables
# Reference: terraform/modules/bootstrap/
# Assignment: §69, §70, §73, §83, §84, §87, §89
# - Amazon Linux 2023
# - SSH restricted to home IP CIDRs
# - IAM role for EKS authentication via RBAC
# - User-data for tool installation (aws-cli v2, kubectl, helm, kustomize, mysql-client)
# =============================================================================

variable "jumphost_availability_zone" {
  description = "The availability zone for the jumphost instance"
  type        = string
  default     = "us-east-1a"
}

variable "jumphost_ami_id" {
  description = "The AMI ID for the jumphost (empty = Amazon Linux 2023)"
  type        = string
  default     = ""
}

variable "jumphost_instance_type" {
  description = "The EC2 instance type for the jumphost"
  type        = string
  default     = "t3.micro"
  validation {
    condition     = can(regex("^t[23]\\.(micro|small|medium|large)$", var.jumphost_instance_type))
    error_message = "Instance type must be t2 or t3 family (micro to large)."
  }
}

variable "jumphost_root_volume_size" {
  description = "The size of the root EBS volume for the jumphost in GB"
  type        = number
  default     = 20
  validation {
    condition     = var.jumphost_root_volume_size >= 10 && var.jumphost_root_volume_size <= 500
    error_message = "Root volume size must be between 10 and 500 GB."
  }
}

variable "jumphost_root_volume_iops" {
  description = "The IOPS for the gp3 root volume of the jumphost"
  type        = number
  default     = 3000
  validation {
    condition     = var.jumphost_root_volume_iops >= 3000 && var.jumphost_root_volume_iops <= 16000
    error_message = "gp3 volume IOPS must be between 3000 and 16000."
  }
}

variable "jumphost_iam_instance_profile_name" {
  description = "The name of the IAM instance profile for the jumphost"
  type        = string
  default     = null
}

variable "jumphost_user_data_base64" {
  description = "Base64-encoded user data script for the jumphost"
  type        = string
  default     = null
}

variable "jumphost_additional_tags" {
  description = "Additional tags to apply to the jumphost instance"
  type        = map(string)
  default     = {}
}

# =============================================================================
# IAM Module Variables
# Reference: terraform/modules/secret/iam/
# Assignment: §83, §84, §87, §89 (EKS IAM/RBAC integration)
# =============================================================================

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,30}$", var.cluster_name))
    error_message = "Cluster name must be 3-31 characters, start with a letter."
  }
}

variable "is_eks_role_enabled" {
  description = "Whether to enable the EKS cluster IAM role"
  type        = bool
  default     = true
}

variable "is_eks_nodegroup_role_enabled" {
  description = "Whether to enable the EKS node group IAM role"
  type        = bool
  default     = true
}

variable "is_eks_cluster_enabled" {
  description = "Whether to enable OIDC provider and OIDC IAM role"
  type        = bool
  default     = false
}

variable "eks_oidc_url" {
  description = "The OIDC issuer URL from the EKS cluster"
  type        = string
  default     = ""
}

variable "oidc_thumbprint" {
  description = "TLS thumbprints for the OIDC provider"
  type        = list(string)
  default     = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket to scope the OIDC policy"
  type        = string
  default     = ""
}

variable "iam_additional_tags" {
  description = "Additional tags for IAM resources"
  type        = map(string)
  default     = {}
}

# =============================================================================
# EKS Module Variables
# Reference: terraform/modules/eks/
# Assignment: §74, §75, §76, §79 (2x t3.medium, Bottlerocket AMI)
# =============================================================================

variable "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.31"
}

variable "cluster_enabled_log_types" {
  description = "The log types to enable for the EKS cluster"
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
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

variable "is_eks_module_enabled" {
  description = "Whether to enable the EKS cluster module"
  type        = bool
  default     = true
}

variable "is_eks_node_group_enabled" {
  description = "Whether to enable the EKS node group"
  type        = bool
  default     = true
}

variable "desired_capacity_on_demand" {
  description = "The desired capacity for the on-demand node group (exactly 2 per assignment)"
  type        = number
  default     = 2
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
  description = "The instance types for the on-demand node group (t3.medium per assignment)"
  type        = list(string)
  default     = ["t3.medium"]
}

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

variable "is_eks_addons_enabled" {
  description = "Whether to enable EKS addons"
  type        = bool
  default     = true
}

variable "addons" {
  description = "The list of EKS addons to deploy"
  type = map(object({
    version                  = string
    service_account_role_arn = string
  }))
  default = {
    coredns = {
      version                  = "v1.11.1-eksbuild.9"
      service_account_role_arn = ""
    }
    kube-proxy = {
      version                  = "v1.31.0-eksbuild.1"
      service_account_role_arn = ""
    }
    vpc-cni = {
      version                  = "v1.18.1-eksbuild.3"
      service_account_role_arn = ""
    }
  }
}

variable "eks_additional_tags" {
  description = "Additional tags for EKS resources"
  type        = map(string)
  default     = {}
}

# =============================================================================
# ALB Module Variables
# Reference: terraform/modules/alb/
# Assignment: §31, §62, §65 (Shared ALB with group-tag=finishline, IngressGroup)
# =============================================================================

variable "alb_ingress_group" {
  description = "The ingress group name for AWS LB Controller IngressGroup mechanism"
  type        = string
  default     = "finishline"
}

variable "alb_certificate_arn" {
  description = "The ARN of the SSL/TLS certificate for HTTPS listener (empty = HTTP only)"
  type        = string
  default     = ""
}

variable "alb_ssl_policy" {
  description = "The SSL policy for the HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "alb_deletion_protection" {
  description = "Whether to enable deletion protection for the ALB"
  type        = bool
  default     = false
}

variable "alb_idle_timeout" {
  description = "The idle timeout value in seconds"
  type        = number
  default     = 60
}

variable "alb_desync_mitigation_mode" {
  description = "Determines how the load balancer handles desync during request parsing"
  type        = string
  default     = "defensive"
}

variable "alb_enable_access_logs" {
  description = "Whether to enable access logs for the ALB"
  type        = bool
  default     = false
}

variable "alb_access_logs_bucket" {
  description = "The S3 bucket name for access logs"
  type        = string
  default     = ""
}

variable "alb_access_logs_prefix" {
  description = "The S3 prefix for access logs"
  type        = string
  default     = "alb-logs"
}

variable "alb_enable_5xx_alarm" {
  description = "Whether to enable CloudWatch alarm for 5XX errors"
  type        = bool
  default     = true
}

variable "alb_5xx_threshold" {
  description = "Threshold for 5XX error alarm (count per 5 minutes)"
  type        = number
  default     = 10
}

variable "alb_additional_tags" {
  description = "Additional tags for ALB resources"
  type        = map(string)
  default     = {}
}
