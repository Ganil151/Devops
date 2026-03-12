# =============================================================================
# Variables: dev Environment
# Finish Line 2026 Infrastructure
# Consolidated from all modules
# =============================================================================

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------
variable "aws_region" {
  description = "The AWS region"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment name"
  type        = string
}

variable "manage_by" {
  description = "The entity responsible for managing resources"
  type        = string
}

# -----------------------------------------------------------------------------
# VPC Variables (from vpc module)
# -----------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
}

variable "enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
}

variable "availability_zones" {
  description = "List of 3 availability zones"
  type        = list(string)
}

variable "public_subnets_cidrs" {
  description = "CIDR blocks for 3 public subnets"
  type        = list(string)
}

variable "private_subnets_cidrs" {
  description = "CIDR blocks for 3 private subnets"
  type        = list(string)
}

# -----------------------------------------------------------------------------
# EKS Variables (from eks module)
# -----------------------------------------------------------------------------
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
}

variable "endpoint_private_access" {
  description = "Enable private access to EKS endpoint"
  type        = bool
}

variable "endpoint_public_access" {
  description = "Enable public access to EKS endpoint"
  type        = bool
}

variable "cluster_enabled_log_types" {
  description = "EKS control plane logging types"
  type        = list(string)
}

variable "instance_types" {
  description = "Instance types for node group"
  type        = list(string)
}

# -----------------------------------------------------------------------------
# ALB Variables (from alb module)
# -----------------------------------------------------------------------------
variable "acm_certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener"
  type        = string
}

# -----------------------------------------------------------------------------
# Jumphost Variables (from jumphost module)
# -----------------------------------------------------------------------------
variable "home_ip_cidrs" {
  description = "List of home IP CIDRs for SSH access"
  type        = list(string)
}

variable "jumphost_instance_type" {
  description = "Instance type for jumphost"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}
