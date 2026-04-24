#============================================================
#  EKS Module - Development Environment
#============================================================

include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules//eks"
}

inputs = {
  project_name    = "finishline-infra"
  environment     = "development"
  manage_by      = true
  availability_zone = ["us-east-1a", "us-east-1b", "us-east-1c"]

  # VPC Configuration
  vpc_id = dependency.vpc.outputs.vpc_id

  # EKS Cluster Configuration
  cluster_name              = "finishline-eks-cluster"
  cluster_role_arn         = dependency.iam.outputs.eks_cluster_role_arn
  cluster_version           = "1.35"
  cluster_enabled_log_types = ["api", "audit", "authenticator"]
  subnet_ids                = dependency.vpc.outputs.private_subnet_ids
  security_group_ids        = [dependency.sg.outputs.security_group_id]
  endpoint_private_access   = true
  endpoint_public_access    = false

  # EKS Feature Flags
  is_eks_role_enabled    = true
  is_eks_cluster_enabled = true

  # EKS Addons (optional)
  is_eks_addons_enabled = false
  addons                = {}
}

dependency "vpc" {
  config_path   = "../vpc"
  skip_outputs  = false

  mock_outputs = {
    vpc_id             = "vpc-0abc123def456789a"
    private_subnet_ids = ["subnet-0abc123def456789a", "subnet-0abc123def456789b"]
  }
}

dependency "iam" {
  config_path   = "../iam"
  skip_outputs  = true

  mock_outputs = {
    eks_cluster_role_arn = "arn:aws:iam::123456789012:role/eks-cluster-role"
  }
}

dependency "sg" {
  config_path   = "../sg"
  skip_outputs  = true

  mock_outputs = {
    security_group_id = "sg-0abc123def456789a"
  }
}

dependencies {
  paths = ["../vpc", "../iam", "../sg"]
}
