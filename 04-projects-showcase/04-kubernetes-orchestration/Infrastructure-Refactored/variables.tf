# ============================================================================
# Variables: EKS Infrastructure
# ============================================================================

# ----------------------------------------------------------------------------
# Project Configuration
# ----------------------------------------------------------------------------

variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
  
  validation {
    condition     = length(var.project_name) >= 3 && length(var.project_name) <= 32
    error_message = "Project name must be between 3 and 32 characters."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition     = can(regex("^(us|eu|ap|sa|ca|me|af)-(north|south|east|west|central|northeast|southeast)-[1-9]$", var.aws_region))
    error_message = "Must be a valid AWS region (e.g., us-east-1, eu-west-2)."
  }
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}

# ----------------------------------------------------------------------------
# Networking Configuration
# ----------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block."
  }
  
  validation {
    condition     = tonumber(split("/", var.vpc_cidr)[1]) <= 16
    error_message = "VPC CIDR block must be /16 or larger for sufficient IP space."
  }
}

variable "az_count" {
  description = "Number of availability zones to use"
  type        = number
  default     = 3
  
  validation {
    condition     = var.az_count >= 2 && var.az_count <= 6
    error_message = "Must use between 2 and 6 availability zones."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  
  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "Must specify at least 2 public subnets for high availability."
  }
  
  validation {
    condition     = alltrue([for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All public subnet CIDRs must be valid IPv4 CIDR blocks."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  
  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "Must specify at least 2 private subnets for high availability."
  }
  
  validation {
    condition     = alltrue([for cidr in var.private_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All private subnet CIDRs must be valid IPv4 CIDR blocks."
  }
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway (cost optimization for non-prod)"
  type        = bool
  default     = false
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs for network monitoring"
  type        = bool
  default     = true
}

# ----------------------------------------------------------------------------
# EKS Cluster Configuration
# ----------------------------------------------------------------------------

variable "eks_cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
  
  validation {
    condition     = can(regex("^1\\.(2[4-9]|[3-9][0-9])$", var.eks_cluster_version))
    error_message = "EKS version must be 1.24 or higher."
  }
}

variable "node_disk_size" {
  description = "Disk size in GB for EKS worker nodes"
  type        = number
  default     = 50
  
  validation {
    condition     = var.node_disk_size >= 20 && var.node_disk_size <= 1000
    error_message = "Node disk size must be between 20 GB and 1000 GB."
  }
}

variable "enable_cluster_autoscaler" {
  description = "Enable Kubernetes Cluster Autoscaler"
  type        = bool
  default     = true
}

variable "enable_cluster_encryption" {
  description = "Enable EKS cluster encryption for secrets"
  type        = bool
  default     = true
}

variable "cluster_encryption_kms_key_id" {
  description = "KMS key ID for EKS cluster encryption (optional)"
  type        = string
  default     = null
}

variable "cluster_enabled_log_types" {
  description = "List of EKS control plane logging types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  
  validation {
    condition = alltrue([
      for log_type in var.cluster_enabled_log_types :
      contains(["api", "audit", "authenticator", "controllerManager", "scheduler"], log_type)
    ])
    error_message = "Log types must be one of: api, audit, authenticator, controllerManager, scheduler."
  }
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to EKS cluster endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to access EKS public endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
  
  validation {
    condition     = alltrue([for cidr in var.cluster_endpoint_public_access_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All CIDRs must be valid IPv4 CIDR blocks."
  }
}

# ----------------------------------------------------------------------------
# Service Mesh Configuration
# ----------------------------------------------------------------------------

variable "enable_service_mesh" {
  description = "Enable Istio service mesh"
  type        = bool
  default     = true
}

variable "istio_version" {
  description = "Istio version to install"
  type        = string
  default     = "1.20.0"
  
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.istio_version))
    error_message = "Istio version must be in semantic versioning format (e.g., 1.20.0)."
  }
}

variable "enable_istio_ingress" {
  description = "Enable Istio ingress gateway"
  type        = bool
  default     = true
}

variable "enable_istio_egress" {
  description = "Enable Istio egress gateway"
  type        = bool
  default     = false
}

variable "enable_kiali" {
  description = "Enable Kiali service mesh observability"
  type        = bool
  default     = true
}

variable "enable_jaeger" {
  description = "Enable Jaeger distributed tracing"
  type        = bool
  default     = true
}

variable "enable_prometheus" {
  description = "Enable Prometheus for metrics"
  type        = bool
  default     = true
}

variable "enable_grafana" {
  description = "Enable Grafana for visualization"
  type        = bool
  default     = true
}

# ----------------------------------------------------------------------------
# Monitoring Configuration
# ----------------------------------------------------------------------------

variable "enable_monitoring" {
  description = "Enable monitoring stack"
  type        = bool
  default     = true
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 30
  
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.log_retention_days)
    error_message = "Log retention must be a valid CloudWatch retention period."
  }
}

variable "enable_prometheus_operator" {
  description = "Enable Prometheus Operator"
  type        = bool
  default     = true
}

variable "prometheus_storage_size" {
  description = "Prometheus storage size in GB"
  type        = string
  default     = "50Gi"
  
  validation {
    condition     = can(regex("^[0-9]+Gi$", var.prometheus_storage_size))
    error_message = "Storage size must be in format: 50Gi, 100Gi, etc."
  }
}

variable "grafana_admin_password" {
  description = "Grafana admin password (use AWS Secrets Manager in production)"
  type        = string
  default     = null
  sensitive   = true
}

# ----------------------------------------------------------------------------
# Security Configuration
# ----------------------------------------------------------------------------

variable "enable_security_features" {
  description = "Enable security features module"
  type        = bool
  default     = true
}

variable "enable_pod_security_policy" {
  description = "Enable Pod Security Policies"
  type        = bool
  default     = true
}

variable "enable_network_policies" {
  description = "Enable Kubernetes Network Policies"
  type        = bool
  default     = true
}

variable "enable_secrets_store_csi" {
  description = "Enable Secrets Store CSI Driver for AWS Secrets Manager"
  type        = bool
  default     = true
}

variable "secrets_manager_arns" {
  description = "List of AWS Secrets Manager ARNs to allow access"
  type        = list(string)
  default     = []
}

variable "enable_image_scanning" {
  description = "Enable container image scanning"
  type        = bool
  default     = true
}

# ----------------------------------------------------------------------------
# GitOps Configuration
# ----------------------------------------------------------------------------

variable "enable_gitops" {
  description = "Enable ArgoCD for GitOps"
  type        = bool
  default     = true
}

variable "argocd_version" {
  description = "ArgoCD version to install"
  type        = string
  default     = "5.51.0"
}

variable "argocd_namespace" {
  description = "Kubernetes namespace for ArgoCD"
  type        = string
  default     = "argocd"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.argocd_namespace))
    error_message = "Namespace must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "git_repository_url" {
  description = "Git repository URL for GitOps"
  type        = string
  default     = ""
  
  validation {
    condition     = var.git_repository_url == "" || can(regex("^https://.*\\.git$", var.git_repository_url))
    error_message = "Git repository URL must be a valid HTTPS URL ending with .git"
  }
}

variable "git_repository_path" {
  description = "Path within Git repository for manifests"
  type        = string
  default     = "manifests"
}

variable "git_branch" {
  description = "Git branch to track"
  type        = string
  default     = "main"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9/_-]+$", var.git_branch))
    error_message = "Git branch name must be valid."
  }
}

variable "enable_argocd_sso" {
  description = "Enable SSO for ArgoCD"
  type        = bool
  default     = false
}

variable "argocd_sso_issuer_url" {
  description = "SSO issuer URL for ArgoCD"
  type        = string
  default     = ""
}
