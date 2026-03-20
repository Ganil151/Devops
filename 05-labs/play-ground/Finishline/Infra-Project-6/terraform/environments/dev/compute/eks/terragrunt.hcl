#============================================================
#  EKS Module - Development Environment
#============================================================

include {
  path = find_in_parent_folders("root.hcl")
}

# Dependency on VPC module
dependency "vpc" {
  config_path = "../../networking/vpc"
}

# Dependency on Security Group module
dependency "sg" {
  config_path = "../../networking/sg"
}

# Dependency on IAM role for EKS cluster
dependency "iam" {
  config_path = "../../security/iam"
  skip_outputs = false
}

# Dependency on KMS for encryption
dependency "kms" {
  config_path = "../../security/kms"
}

terraform {
  source = "../../../../modules//compute/eks"
}

inputs = {
  #============================================================
  # Project Variables
  #============================================================
  project_name = "finishline-infra-app"
  environment  = "dev"
  managed_by   = "finishline-infra-team"
  aws_region   = "us-east-1"
  computed_tags = {}

  #============================================================
  # EKS Cluster Configuration
  #============================================================
  cluster_name = "finishline-infra-app-dev-eks"
  is_eks_cluster_enabled        = true
  is_eks_role_enabled           = false  # IAM role managed separately in security/iam
  cluster_version               = "1.35"
  cluster_role_arn              = dependency.iam.outputs.eks_cluster_role_arn
  cluster_enabled_log_types     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Nodegroup role ARN for access entry (nodegroup managed by bootstraps module)
  nodegroup_role_arn = dependency.iam.outputs.eks_nodegroup_role_arn

  #============================================================
  # Network Configuration
  #============================================================
  subnets = dependency.vpc.outputs.private_subnet_ids
  security_group_ids = [dependency.sg.outputs.security_group_id]
  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs = ["0.0.0.0/0"]

  #============================================================
  # Security & Encryption
  #============================================================
  kms_key_arn = dependency.kms.outputs.kms_key_arn
  authentication_mode = "API_AND_CONFIG_MAP"
  bootstrap_cluster_creator_admin_permissions = true

  #============================================================
  # Access Configuration
  #============================================================
  # Note: bootstrap_cluster_creator_admin_permissions=true already grants admin access to creator
  # Only add additional principals here if needed (e.g., additional IAM roles/users)
  cluster_admin_principal_arns = {}
  cluster_admin_kubernetes_groups = []

  #============================================================
  # Upgrade Policy
  #============================================================
  enable_upgrade_policy       = false
  upgrade_policy_support_type = "STANDARD"

  #============================================================
  # EKS Addons Configuration
  #============================================================
  # Note: Addons are now managed by the bootstraps module
  bootstrap_self_managed_addons = false
}
