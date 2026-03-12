# =============================================================================
# Variables: staging Environment
# Finish Line 2026 Infrastructure
# =============================================================================

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------
variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "finishline-infra"
}

variable "environment" {
  description = "The environment name"
  type        = string
  default     = "staging"
}

variable "manage_by" {
  description = "The entity responsible for managing resources"
  type        = string
  default     = "Terraform"
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = "us-east-1"
}

# -----------------------------------------------------------------------------
# VPC Variables
# -----------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
  default     = true
}

variable "availability_zones" {
  description = "List of 3 availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnets_cidrs" {
  description = "CIDR blocks for 3 public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets_cidrs" {
  description = "CIDR blocks for 3 private subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

# -----------------------------------------------------------------------------
# EKS Variables
# -----------------------------------------------------------------------------
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "finishline-infra-eks-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "endpoint_private_access" {
  description = "Enable private access to EKS endpoint"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public access to EKS endpoint"
  type        = bool
  default     = true
}

variable "cluster_enabled_log_types" {
  description = "EKS control plane logging types"
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

variable "instance_types" {
  description = "Instance types for node group"
  type        = list(string)
  default     = ["t3.medium"]
}

# -----------------------------------------------------------------------------
# Jumphost Variables
# -----------------------------------------------------------------------------
variable "home_ip_cidrs" {
  description = "List of home IP CIDRs for SSH access"
  type        = list(string)
}

variable "jumphost_instance_type" {
  description = "Instance type for jumphost"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "finishline-infra-key-pair"
}
