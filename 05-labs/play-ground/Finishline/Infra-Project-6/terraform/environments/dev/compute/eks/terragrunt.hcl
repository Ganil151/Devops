#============================================================
#  Terragrunt Configuration for Dev EKS Cluster
#============================================================

include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  vpc = read_terragrunt_config(find_in_parent_folders("dev/networking/vpc/terragrunt.hcl"))
  iam = read_terragrunt_config(find_in_parent_folders("dev/security/iam/terragrunt.hcl"))
  kms = read_terragrunt_config(find_in_parent_folders("dev/security/kms/terragrunt.hcl"))
}

dependency "vpc" {
  config_path = "../../networking/vpc"
  
  mock_outputs = {
    private_subnet_ids = ["subnet-mock1", "subnet-mock2", "subnet-mock3"]
  }
}

dependency "iam" {
  config_path = "../../security/iam"
  
  mock_outputs = {
    eks_cluster_role_arn     = "arn:aws:iam::123456789012:role/finishline-dev-eks-cluster-role"
    eks_nodegroup_role_arn  = "arn:aws:iam::123456789012:role/finishline-dev-eks-nodegroup-role"
  }
}

dependency "kms" {
  config_path = "../../security/kms"
  
  mock_outputs = {
    kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/mock-kms-key"
  }
}

terraform {
  source = "${get_terragrunt_dir()}/../../../../modules/compute/eks"
}

inputs = {
  # Project and Environment
  project_name = "finishline"
  environment  = "dev"
  managed_by   = "finishline-infra-team"
  aws_region   = "us-east-1"

  # EKS Cluster Configuration
  is_eks_cluster_enabled = true
  cluster_name           = "finishline-dev-eks"
  cluster_version        = "1.35"
  cluster_role_arn       = dependency.iam.outputs.eks_cluster_role_arn

  # Network Configuration
  subnets                  = dependency.vpc.outputs.private_subnet_ids
  endpoint_private_access  = true
  endpoint_public_access   = false
  security_group_ids       = []  # Add security group IDs
  public_access_cidrs     = []

  # Logging
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Security & Encryption
  kms_key_arn = dependency.kms.outputs.kms_key_arn

  # Access Configuration
  authentication_mode                   = "API_AND_CONFIG_MAP"
  bootstrap_cluster_creator_admin_permissions = true
  cluster_admin_principal_arns         = {}
  cluster_admin_kubernetes_groups       = []

  # Node Group Configuration
  # Disable initially to allow cluster to be created first
  is_eks_nodegroup_enabled      = false
  is_eks_nodegroup_role_enabled = false
  node_group_name           = "default-node-group"
  node_group_subnets        = dependency.vpc.outputs.private_subnet_ids
  node_group_ami_type       = "BOTTLEROCKET_x86_64"
  node_group_instance_types = ["t3.medium"]
  node_group_capacity_type  = "ON_DEMAND"
  node_group_disk_size      = 20
  node_group_role_arn       = dependency.iam.outputs.eks_nodegroup_role_arn

  node_group_scaling_config = {
    desired_size = 2
    min_size     = 2
    max_size     = 2
  }

  node_group_labels = {
    "environment" = "dev"
    "node-group" = "default"
  }

  node_group_tags = {
    "Environment" = "dev"
  }

  # Addons Configuration
  is_node_addons_enabled        = false
  is_bootstrap_addons_enabled  = false
  bootstrap_self_managed_addons = false
  addons                       = {}

  # Upgrade Policy
  enable_upgrade_policy       = false
  upgrade_policy_support_type = "STANDARD"
}
