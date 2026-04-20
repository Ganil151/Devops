#============================================================
#  IAM Module - Development Environment
#============================================================

include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules//iam"
}

inputs = {
  project_name    = "finishline-infra"
  environment     = "development"
  manage_by      = true
  availability_zone = ["us-east-1a", "us-east-1b", "us-east-1c"]

  # IAM Role Configuration
  cluster_name    = "finishline-eks-cluster"
  is_eks_role_enabled = true
  is_eks_cluster_enabled = true
  is_eks_nodegroup_role_enabled = true
  is_role_enabled = true

  # OIDC Configuration - Leave empty initially, update after EKS is created
  eks_oidc_url    = ""
  oidc_thumbprint = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
  eks_oidc_namespace = "kube-system"
  eks_oidc_service_account_name = "aws-node"

  # S3 Configuration (optional)
  s3_bucket_arn  = ""
  s3_prefix      = ""
  s3_access_type = "read"
}

dependency "vpc" {
  config_path   = "../vpc"
  skip_outputs  = true

  mock_outputs = {
    vpc_id = "mock-vpc-id"
  }
}

dependencies {
  paths = ["../vpc"]
}
