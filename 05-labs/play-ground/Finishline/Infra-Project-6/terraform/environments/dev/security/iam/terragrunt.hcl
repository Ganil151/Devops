#============================================================
#  IAM Module - Development Environment
#============================================================

include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_terragrunt_dir()}/../../../../modules/security/iam"
}

inputs = {
  project_name = "finishline-infra-app"
  environment  = "dev"
  managed_by   = "finishline-infra-team"
  aws_region   = "us-east-1"

  # IAM Configuration
  cluster_name = "finishline-infra-app-dev-eks"

  # EKS Cluster Role Configuration
  # These roles are consumed by the EKS module at compute/eks
  is_eks_cluster_enabled = true
  is_eks_role_enabled    = true

  # EKS Nodegroup Role Configuration
  is_eks_nodegroup_role_enabled = true

  # OIDC Configuration
  # Note: Update these values after EKS cluster creation
  # eks_oidc_url can be retrieved from: aws eks describe-cluster --name finishline-dev --query "cluster.identity.oidc.issuer" --output text
  # oidc_thumbprint can be retrieved from: openssl s_client -showcerts -connect oidc.eks.us-east-1.amazonaws.com:443 | openssl x509 -fingerprint -sha256 -noout | cut -d= -f2 | tr -d ':'
  eks_oidc_url           = ""
  eks_oidc_namespace     = "default"
  eks_oidc_service_account = ""
  oidc_thumbprint        = ""

  # S3 Access Configuration (Optional)
  s3_bucket_arn  = ""
  s3_prefix      = ""
  s3_access_type = "read"

  # Karpenter Configuration
  is_karpenter_enabled       = true
  karpenter_namespace        = "karpenter"
  karpenter_service_account  = "karpenter"
  karpenter_cluster_name     = "finishline-infra-app-dev-eks"

  # Naming Configuration
  # Set to true for production to have predictable resource names
  enable_deterministic_naming = false

  computed_tags = {}

}
